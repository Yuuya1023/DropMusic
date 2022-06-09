//
//  AudioListViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class AudioListViewController: UIViewController, UINavigationControllerDelegate, AudioListViewDelegate {
    
    //
    // MARK: - Properties.
    //
    private var _tableView: AudioListView!
    private var _playListId: String!
    
    
    
    //
    // MARK: -
    //
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(playListId: String){
        super.init(nibName: nil, bundle: nil)
        _playListId = playListId
        if let playlist = AppDataManager.sharedManager.playlist.getPlaylistData(id: _playListId) {
            self.title = playlist.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = AppColor.main
            appearance.titleTextAttributes = [.foregroundColor: AppColor.sub]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            self.navigationController?.navigationBar.tintColor = AppColor.sub
        } else {
            self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: AppColor.sub]
            self.navigationController?.navigationBar.barTintColor = AppColor.main
            self.navigationController?.navigationBar.tintColor = AppColor.sub
        }
        
        if let image = UIImage(named: "icon_menu.png") {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image.resizeImage(reSize: CGSize(width:30,height:30)),
                                                                     style: .plain,
                                                                     target: self,
                                                                     action: #selector(selectorMenuButton))
        }
        // tableview.
        _tableView = AudioListView()
        if let playlist = AppDataManager.sharedManager.playlist.getPlaylistData(id: _playListId) {
            _tableView.setAudioList(list: playlist.audioList)
        }
        _tableView.audioListViewDelegate = self
        
        self.view.addSubview(_tableView)
        
        updateScroll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///
    override func viewWillLayoutSubviews() {
        // tableview.
        var frame = self.view.frame
        var margin = AudioPlayStatusView._height
        if let val = self.tabBarController {
            margin += val.tabBar.frame.size.height
        }
        frame.size.height = frame.size.height-margin
        _tableView.frame = frame
    }
    
    
    func updateScroll() {
        self._tableView.reloadData()
    }

    
    // MARK: -
    @objc func selectorMenuButton() {
        guard let playlist = AppDataManager.sharedManager.playlist.getPlaylistData(id: self._playListId) else {
            return
        }
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        // ダウンロード.
        alert.addAction(
            UIAlertAction(title: "Download all",
                          style: .default,
                          handler:{ (action:UIAlertAction!) -> Void in
                            for audioData in (playlist.audioList) {
                                DownloadFileManager.sharedManager.addQueue(audioData: audioData)
                            }
                            DownloadFileManager.sharedManager.startDownload()
            })
        )
        // キャンセル.
        alert.addAction(
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler:{ (action:UIAlertAction!) -> Void in
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
    
    
    //
    // MARK: - AudioListViewDelegate.
    //
    func touchCell(index: Int) {
        if let playlist = AppDataManager.sharedManager.playlist.getPlaylistData(id: _playListId) {
            let audioData = playlist.audioList[index]
            if DownloadFileManager.sharedManager.isExistAudioFile(audioData: audioData) {
                // 再生.
                AudioPlayManager.sharedManager.set(selectType: .Playlist,
                                                   selectValue: playlist.id,
                                                   audioList: playlist.audioList,
                                                   playIndex: index)
                _ = AudioPlayManager.sharedManager.play()
            }
            else {
                // ダウンロード.
                DownloadFileManager.sharedManager.addQueue(audioData: audioData)
                DownloadFileManager.sharedManager.startDownload()
            }
        }
    }
    
    func longpressCell(index: Int) {
        guard let playlist = AppDataManager.sharedManager.playlist.getPlaylistData(id: _playListId) else {
            return
        }
        guard playlist.audioList.indices.contains(index) else {
            return
        }
        let audioData = playlist.audioList[index]
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

        // 削除.
        alert.addAction(
            UIAlertAction(title: "Delete from playlist",
                          style: .destructive,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            AppDataManager.sharedManager.playlist.deleteAudioFromPlayList(playListId: playlist.id,
                                                                                          audioId: audioData.id)
                            AppDataManager.sharedManager.save()
                            self.updateScroll()
            })
        )
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
    
    
    
    //
    // MARK: - NavigationController Delegate.
    //
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    }
}
