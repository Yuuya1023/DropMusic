//
//  MusicSuggestViewController.swift
//  DropMusic
//
//  Copyright © 2022 n.yuuya. All rights reserved.
//

import UIKit

class MusicSuggestViewController: UIViewController, AudioListViewDelegate {
    
    //
    // MARK: - Properties.
    //
    @IBOutlet var _suggestView: UIView!
    @IBOutlet var _artwork: UIImageView!
    @IBOutlet var _typeLabel: UILabel!
    @IBOutlet var _titleLabel: UILabel!
    @IBOutlet var _subtitleLabel: UILabel!
    
    private var _image: UIImage = UIImage()
    private var _type: String = ""
    private var _title: String = ""
    private var _subtitle: String = ""
    
    var _audioListView: AudioListView = AudioListView()
    var _suggestList: Array<AudioData> = []
    
    
    
    //
    // MARK: - Override.
    //
    override func loadView() {
        let nib = UINib(nibName: "MusicSuggestView", bundle: .main)
        self.view = nib.instantiate(withOwner: self).first as? UIView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _artwork.image = _image
        _artwork.contentMode = .scaleAspectFit
        _artwork.layer.shadowOpacity = 0.7
        _artwork.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        _typeLabel.text = _type
        _titleLabel.text = _title
        _subtitleLabel.text = _subtitle
        
        _audioListView.audioListViewDelegate = self
        _audioListView.setAudioList(list: _suggestList)
        _suggestView.addSubview(_audioListView)
        
        _audioListView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        // tableview.
        var frame = _suggestView.bounds
        frame.size.height = frame.size.height
        _audioListView.frame = frame
    }
    
    
    
    //
    // MARK: -
    //
    func setInfo(image: UIImage, type: String, title: String, subtitle: String) {
        _image = image
        _type = type
        _title = title
        _subtitle = subtitle
    }
    
    func setupForCloud(path: String) {
        var image: UIImage = UIImage()
        var title = ""
        var subtitle = ""
        let list = DropboxFileListManager.sharedManager.getAudioList(pathLower: path)
        for d in list {
            if let metadata = MetadataCacheManager.sharedManager.get(audioData: d) {
                if let artwork = metadata.artwork {
                    image = artwork
                }
                title = metadata.album
                subtitle = metadata.artist
                break
            }
        }
        _image = image
        _type = ""
        _title = title
        _subtitle = subtitle
        
        setSuggestList(list: list)
    }
    
    func setupForPlayList(playListId: String) {
        guard let playlist = AppDataManager.sharedManager.playlist.getPlaylistData(id: playListId) else {
            setInfo(image: UIImage(), type: "", title: "", subtitle: "")
            return
        }
        
        var image: UIImage = UIImage()
        if let d = playlist.getHeadData() {
            if let metadata = MetadataCacheManager.sharedManager.get(audioData: d) {
                if let artwork = metadata.artwork {
                    image = artwork
                }
            }
        }
        _image = image
        _type = "Playlist"
        _title = playlist.name
        _subtitle = ""
        
        setSuggestList(list: playlist.audioList)
    }
    
    func setSuggestList(list: Array<AudioData>) {
        _suggestList = list
    }
    
    
    
    //
    // MARK: - AudioListViewDelegate.
    //
    func touchCell(index: Int) {
        let audioData = _suggestList[index]
        if DownloadFileManager.sharedManager.isExistAudioFile(audioData: audioData) {
            // 再生.
            AudioPlayManager.sharedManager.set(audioData: audioData)
            _ = AudioPlayManager.sharedManager.play()
            // 閉じる.
            self.dismiss(animated: true,
                         completion: nil)
        }
        else {
            // ダウンロード.
            DownloadFileManager.sharedManager.addQueue(audioData: audioData)
            DownloadFileManager.sharedManager.startDownload()
        }
        
    }
    
    func longpressCell(index: Int) {
        guard _suggestList.indices.contains(index) else {
            return
        }
        let audioData = _suggestList[index]
        let isExist = DownloadFileManager.sharedManager.isExistAudioFile(audioData: audioData)
        func deleteCache() {
            do {
                let path = DownloadFileManager.sharedManager.getFileCachePath(audioData: audioData)
                try FileManager.default.removeItem(at: URL(fileURLWithPath: path))
            }
            catch {}
        }

        
        let alert = UIAlertController(title: audioData.fileName,
                                      message: nil,
                                      preferredStyle: .actionSheet)

        // ダウンロード.
        alert.addAction(
            UIAlertAction(title: isExist ? "Download again": "Download",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            if isExist {
                                deleteCache()
                            }
                            MetadataCacheManager.sharedManager.remove(audioData: audioData)
                            DownloadFileManager.sharedManager.addQueue(audioData: audioData)
                            DownloadFileManager.sharedManager.startDownload()
            })
        )
        // お気に入り.
        let fav = AppDataManager.sharedManager.favorite
        let isFavorite = fav.isFavorite(audioData)
        alert.addAction(
            UIAlertAction(title: isFavorite ? "Delete favorite" : "Add favorite",
                          style: isFavorite ? .destructive : .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            if isFavorite {
                                fav.deleteFavorite(audioData)
                            }
                            else {
                                fav.addFavorite(audioData)
                            }
                            AppDataManager.sharedManager.save()
            })
        )
        if isExist {
            alert.addAction(
                UIAlertAction(title: "Add to playlist",
                              style: .default,
                              handler:{
                                (action:UIAlertAction!) -> Void in
                                let playlistvc = PlayListSelectViewController()
                                playlistvc.setAudioData(data: audioData)
                                let vc = UINavigationController(rootViewController: playlistvc)
                                vc.modalTransitionStyle = .coverVertical
                                self.present(vc, animated: true, completion: nil)
                })
            )
        }
        // キャンセル.
        alert.addAction(
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            // 閉じるだけ.
            })
        )
        // ipad.
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert.popoverPresentationController?.sourceView = self.view
            let screenSize = UIScreen.main.bounds
            alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2,
                                                                     y: screenSize.size.height,
                                                                     width: 0,
                                                                     height: 0)
        }
        present(alert, animated: true, completion: nil)
    }
}
