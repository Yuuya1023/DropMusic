//
//  AudioListViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class AudioListViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //
    // MARK: - Properties.
    //
    var _tableView: UITableView!
    var _playListId: String!
    
    private let _cellIdentifier = "AudioListViewCell"
    
    //
    // MARK: -
    //
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(playListId: String){
        super.init(nibName: nil, bundle: nil)
        _playListId = playListId
        if let playlist = PlayListManager.sharedManager.getPlaylistData(id: _playListId) {
            self.title = playlist.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        if let navigationController = self.navigationController {
            navigationController.delegate = self
            navigationController.navigationBar.tintColor = UIColor(displayP3Red: 20/255, green: 29/255, blue: 80/255, alpha: 1)
            navigationController.navigationBar.tintColor = .white
        }
        
        if let image = UIImage(named: "icon_menu.png") {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image.resizeImage(reSize: CGSize(width:30,height:30)),
                                                                     style: .plain,
                                                                     target: self,
                                                                     action: #selector(selectorMenuButton))
        }
        // tableview.
        _tableView = UITableView()
        _tableView.backgroundColor = UIColor.clear
        _tableView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.register(UINib(nibName: _cellIdentifier, bundle: nil), forCellReuseIdentifier: _cellIdentifier)
        
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
        guard let playlist = PlayListManager.sharedManager.getPlaylistData(id: self._playListId) else {
            return
        }
        let alert: UIAlertController = UIAlertController(title: nil,
                                                         message: nil,
                                                         preferredStyle: .actionSheet)
        // ダウンロード.
        let downloadAction:UIAlertAction =
            UIAlertAction(title: "Download all",
                          style: .default,
                          handler:{ (action:UIAlertAction!) -> Void in
                            for audioData in (playlist.audioList) {
                                DownloadFileManager.sharedManager.addQueue(audioData: audioData)
                            }
                            DownloadFileManager.sharedManager.startDownload()
            })
        
        // キャンセル.
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler:{ (action:UIAlertAction!) -> Void in
                            // 閉じるだけ.
            })
        
        alert.addAction(downloadAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    // MARK: -
    @objc func showActionSheet(_ sender: AudioListViewCell) {
        guard let playlist = PlayListManager.sharedManager.getPlaylistData(id: _playListId) else {
            return
        }
        guard playlist.audioList.indices.contains(sender.index) else {
            return
        }
        let audioData = playlist.audioList[sender.index]
        let isExist = DownloadFileManager.sharedManager.isExistAudioFile(audioData: audioData)
        func deleteCache() {
            do {
                let path = DownloadFileManager.sharedManager.getFileCachePath(audioData: audioData)
                try FileManager.default.removeItem(at: URL(fileURLWithPath: path))
            }
            catch {}
        }

        
        let alert: UIAlertController = UIAlertController(title: audioData.fileName,
                                                         message: nil,
                                                         preferredStyle: .actionSheet)

        // 削除.
        let deleteAction:UIAlertAction =
            UIAlertAction(title: "Delete from playlist",
                          style: .destructive,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            PlayListManager.sharedManager.deleteAudioFromPlayList(playListId: playlist.id,
                                                                                  audioId: audioData.id,
                                                                                  isSave: true)
                            self.updateScroll()
            })
        // ダウンロード.
        let downloadAction:UIAlertAction =
            UIAlertAction(title: isExist ? "Download again": "Download",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            if isExist {
                                deleteCache()
                                sender._progressView.progress = 0
                            }
                            MetadataCacheManager.sharedManager.remove(audioData: audioData)
                            DownloadFileManager.sharedManager.addQueue(audioData: audioData)
                            DownloadFileManager.sharedManager.startDownload()
            })
        
        if isExist {
            let playlistAction:UIAlertAction =
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
            alert.addAction(playlistAction)
        }
        // キャンセル.
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            // 閉じるだけ.
            })
        
        alert.addAction(deleteAction)
        alert.addAction(downloadAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    //
    // MARK: - NavigationController Delegate.
    //
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    }


    
    //
    // MARK: - TableViewController Delegate.
    //
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let playlist = PlayListManager.sharedManager.getPlaylistData(id: _playListId)
        if playlist != nil {
            return (playlist?.audioList.count)!
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: _cellIdentifier ) as! AudioListViewCell
        
        if let playlist = PlayListManager.sharedManager.getPlaylistData(id: _playListId) {
            let audioData = playlist.audioList[indexPath.row]
            
            c.set(audioData: audioData)
            c.index = indexPath.row
            c.longpressTarget = self
            c.longpressSelector = #selector(showActionSheet(_:))
        }
        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let playlist = PlayListManager.sharedManager.getPlaylistData(id: _playListId) {
            let audioData = playlist.audioList[indexPath.row]
            if DownloadFileManager.sharedManager.isExistAudioFile(audioData: audioData) {
                // 再生.
                AudioPlayManager.sharedManager.set(selectType: .Playlist,
                                                   selectPath: playlist.name,
                                                   audioList: playlist.audioList,
                                                   playIndex: indexPath.row)
                _ = AudioPlayManager.sharedManager.play()
            }
            else {
                // ダウンロード.
                DownloadFileManager.sharedManager.addQueue(audioData: audioData)
                DownloadFileManager.sharedManager.startDownload()
            }
        }
    }
}
