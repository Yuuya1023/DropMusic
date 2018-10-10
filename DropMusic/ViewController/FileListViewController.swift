//
//  FileListViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class FileListViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var _pathList: [String] = []
    
    var _tableView: UITableView!
    var _datas: Array<FileInfo> = []
    
    var _isLoading: Bool = false
    var _refreshControll: UIRefreshControl!
    
    
    
    // MARK: -
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(pathList: [String]){
        super.init(nibName: nil, bundle: nil)
        self._pathList = pathList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = _pathList.last
        self.navigationController?.delegate = self
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 40/255, green: 50/255, blue: 100/255, alpha: 1)
        self.view.backgroundColor = UIColor.white
        
        //
        var bounds = self.view.bounds
        bounds.size.height = bounds.size.height-98
        _tableView = UITableView(frame: bounds, style: .plain)
        _tableView.backgroundColor = UIColor.clear
        _tableView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.register(FileListViewCell.self, forCellReuseIdentifier: NSStringFromClass(FileListViewCell.self))
        
        self.view.addSubview(_tableView)
        
        //
        _refreshControll = UIRefreshControl()
        _refreshControll.addTarget(self, action: #selector(selectorRefreshControll), for: .valueChanged)
        _tableView.refreshControl = _refreshControll
        
        load()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: -
    func load(){
        if _isLoading {
            return
        }
        _isLoading = true
        let path = makePath()
        let cacheData = DropboxFileListManager.sharedManager.get(pathLower: path)
        if cacheData != nil && cacheData?.count != 0 {
            // キャッシュから.
            self._datas = cacheData!
            sortAndReloadList()
        }
        else {
            if let client = DropboxClientsManager.authorizedClient {
                client.files.listFolder(path: path).response { response, error in
                    if let metadata = response {
                        self._datas = []
//                        print("Entries: \(metadata.entries)")
                        for entry in metadata.entries {
                            let info = FileInfo(metadata: entry)
                            if info.isFolder() || info.isAudioFile() {
                                // フォルダか音声ファイルのみ.
                                self._datas.append(FileInfo(metadata: entry))
                            }
                        }
                    } else {
                        print(error!)
                        self.navigationController?.popViewController(animated: true)
                        return
                    }
                    
                    if self._datas.count != 0 {
                        // 登録.
                        DropboxFileListManager.sharedManager.regist(pathLower: path, list: self._datas)
                        // 更新.
                        self.sortAndReloadList()
                    }
                }
            }
        }
    }
    
    
    func sortAndReloadList() {
        self._datas.sort(by: {$0.name().lowercased() < $1.name().lowercased()})
        self._tableView.reloadData()
        _isLoading = false
        _refreshControll.endRefreshing()
    }
    
    
    func makePath() -> (String) {
        var ret: String = ""
        for v in _pathList {
            ret += "/" + v
        }
        return ret
    }
    
    
    @objc func showActionSheet(_ sender: FileListViewCell) {
        let fileInfo = _datas[sender.index]
        let isExist = DownloadFileManager.sharedManager.isExistAudioFile(fileInfo: fileInfo)
        
        func deleteCache() {
            do {
                let path = DownloadFileManager.sharedManager.getFileCachePath(fileInfo: fileInfo)
                try FileManager.default.removeItem(at: URL(fileURLWithPath: path))
            }
            catch {}
        }
        
        let alert: UIAlertController = UIAlertController(title: fileInfo.name(),
                                                         message: nil,
                                                         preferredStyle: .actionSheet)
        // ダウンロード.
        let downloadAction:UIAlertAction =
            UIAlertAction(title: isExist ? "Download again": "Download",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            let d: AudioData! = AudioData.createFromFileInfo(fileInfo: fileInfo)
                            if isExist {
                                deleteCache()
                                MetadataCacheManager.sharedManager.remove(audioData: d)
                                sender.progress.progress = 0
                            }
                            DownloadFileManager.sharedManager.download(audioData: d)
            })
        // キャッシュ削除.
        let deleteCacheAction:UIAlertAction =
            UIAlertAction(title: "Delete cache",
                          style: .destructive,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            deleteCache()
                            sender.progress.progress = 0
            })
        
        // キャンセル.
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            // 閉じるだけ.
            })
        
        if isExist {
            let playlistAction:UIAlertAction =
                UIAlertAction(title: "Add to playlist",
                              style: .default,
                              handler:{
                                (action:UIAlertAction!) -> Void in
                                let playlistvc = PlayListSelectViewController()
                                let d: AudioData! = AudioData.createFromFileInfo(fileInfo: fileInfo)
                                playlistvc.setAudioData(data: d)
                                let vc = UINavigationController(rootViewController: playlistvc)
                                vc.modalTransitionStyle = .coverVertical
                                self.present(vc, animated: true, completion: nil)
                })
            alert.addAction(playlistAction)
        }
        
        alert.addAction(downloadAction)
        alert.addAction(deleteCacheAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    // MARK: -
    @objc func selectorRefreshControll() {
        // キャッシュから消す.
        DropboxFileListManager.sharedManager.remove(pathLower: makePath())
        // 読み込み.
        load()
    }
    
    
    
    // MARK: NavigationController Delegate.
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    }


    
    // MARK: - TableViewController Delegate.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _datas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let temp = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(FileListViewCell.self))
            ?? UITableViewCell(style: .default, reuseIdentifier: NSStringFromClass(FileListViewCell.self))
        let c = temp as! FileListViewCell
        let fileInfo = _datas[indexPath.row]
        
        c.set(fileInfo: fileInfo)
        c.index = indexPath.row
        c.longpressTarget = self
        c.longpressSelector = #selector(showActionSheet(_:))
        
        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileInfo = _datas[indexPath.row]
        if fileInfo.isFolder() {
            // フォルダ.
            var l: [String] = _pathList
            l.append(fileInfo.name())
            self.navigationController?.pushViewController(FileListViewController(pathList: l),
                                                          animated: true)
        }
        else if fileInfo.isFile() {
            // ファイル.
            let audioData: AudioData! = AudioData.createFromFileInfo(fileInfo: fileInfo)
            
            if DownloadFileManager.sharedManager.isExistAudioFile(audioData: audioData) {
                // AudioDataのリストを作成する.
                var list: Array<AudioData> = []
                for i in 0 ..< _datas.count {
                    list.append(AudioData.createFromFileInfo(fileInfo: _datas[i])!)
                }
                // 再生.
//                AudioPlayManager.sharedManager.set(audioData: audioData)
                AudioPlayManager.sharedManager.set(selectType: .Cloud,
                                                   selectPath: makePath(),
                                                   audioList: list,
                                                   playIndex: indexPath.row)
                AudioPlayManager.sharedManager.play()
            }
            else {
                DownloadFileManager.sharedManager.download(audioData: audioData)
            }
        }
    }
}
