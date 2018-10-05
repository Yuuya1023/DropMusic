//
//  AudioListViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class AudioListViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var _tableView: UITableView!
    var _playListId: String!
    
    
    
    // MARK: -
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(playListId: String){
        super.init(nibName: nil, bundle: nil)
        _playListId = playListId
        let playlist = PlayListManager.sharedManager.getPlaylistData(id: _playListId)
        if playlist != nil {
            self.title = playlist?.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.delegate = self
//        self.navigationController?.navigationBar.tintColor = UIColor(displayP3Red: 20/255, green: 29/255, blue: 80/255, alpha: 1)
        self.view.backgroundColor = UIColor.white
//        self.view.backgroundColor = UIColor(displayP3Red: 20/255, green: 30/255, blue: 80/255, alpha: 1)
        
        //
        var bounds = self.view.bounds
        bounds.size.height = bounds.size.height-98
        _tableView = UITableView(frame: bounds, style: .plain)
        _tableView.backgroundColor = UIColor.clear
        _tableView.rowHeight = 60
        _tableView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.register(AudioListViewCell.self, forCellReuseIdentifier: NSStringFromClass(AudioListViewCell.self))
        
        self.view.addSubview(_tableView)
        
        updateScroll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateScroll() {
        self._tableView.reloadData()
    }

    
    
    
    // MARK: -
    @objc func showActionSheet(_ sender: AudioListViewCell) {
        let playlist = PlayListManager.sharedManager.getPlaylistData(id: _playListId)
        if playlist == nil { return }
            
        let audioData = playlist?.audioList[sender.index]
        let isExist = DownloadFileManager.sharedManager.isExistAudioFile(audioData: audioData!)
        func deleteCache() {
            do {
                let path = DownloadFileManager.sharedManager.getFileCachePath(audioData: audioData!)
                try FileManager.default.removeItem(at: URL(fileURLWithPath: path))
            }
            catch {}
        }

        
        let alert: UIAlertController = UIAlertController(title: audioData?.fileName,
                                                         message: nil,
                                                         preferredStyle: .actionSheet)

        // 削除.
        let deleteAction:UIAlertAction =
            UIAlertAction(title: "Delete from playlist",
                          style: .destructive,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            PlayListManager.sharedManager.deleteAudioFromPlayList(playListId: (playlist?.id)!,
                                                                                  audioId: (audioData?.id)!,
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
                                MetadataCacheManager.sharedManager.remove(audioData: audioData!)
                                sender.progress.progress = 0
                            }
                            DownloadFileManager.sharedManager.download(audioData: audioData!)
            })
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
    
    
    
    // MARK: NavigationController Delegate.
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    }


    
    // MARK: - TableViewController Delegate.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let playlist = PlayListManager.sharedManager.getPlaylistData(id: _playListId)
        if playlist != nil {
            return (playlist?.audioList.count)!
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let temp = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(AudioListViewCell.self))
            ?? UITableViewCell(style: .default, reuseIdentifier: NSStringFromClass(AudioListViewCell.self))
        let c = temp as! AudioListViewCell
        
        let playlist = PlayListManager.sharedManager.getPlaylistData(id: _playListId)
        if playlist != nil {
            let audioData = playlist?.audioList[indexPath.row]
            
            c.set(audioData: audioData)
            c.index = indexPath.row
            c.longpressTarget = self
            c.longpressSelector = #selector(showActionSheet(_:))
        }
        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let playlist = PlayListManager.sharedManager.getPlaylistData(id: _playListId)
        if playlist != nil {
            let audioData = playlist?.audioList[indexPath.row]
            if DownloadFileManager.sharedManager.isExistAudioFile(audioData: audioData!) {
                AudioPlayManager.sharedManager.set(selectType: .Playlist,
                                                   selectPath: (playlist?.name)!,
                                                   audioList: (playlist?.audioList)!,
                                                   playIndex: indexPath.row)
                AudioPlayManager.sharedManager.play()
            }
            else {
                // ダウンロード.
                DownloadFileManager.sharedManager.download(audioData: audioData!)
            }
        }
    }
}
