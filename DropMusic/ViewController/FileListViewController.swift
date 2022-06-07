//
//  FileListViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class FileListViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    //
    // MARK: - Properties
    //
    private var _pathList: [String] = []
    
    private var _tableView: UITableView!
    private var _datas: [FileInfo] = []
    
    private var _isLoading: Bool = false
    private var _refreshControll: UIRefreshControl!
    
    
    
    //
    // MARK: -
    //
    ///
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(pathList: [String]){
        super.init(nibName: nil, bundle: nil)
        self._pathList = pathList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = _pathList.count != 0 ? _pathList.last : "File"
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
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_menu.png")?.resizeImage(reSize: CGSize(width:30,height:30)),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(selectorMenuButton))
        
        // tableview.
        _tableView = UITableView()
        _tableView.backgroundColor = UIColor.clear
        _tableView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.register(UINib(nibName: FileListViewCell.cellIdentifier, bundle: nil),
                            forCellReuseIdentifier: FileListViewCell.cellIdentifier)
        
        self.view.addSubview(_tableView)

        // refresh control.
        _refreshControll = UIRefreshControl()
        _refreshControll.addTarget(self, action: #selector(selectorRefreshControll), for: .valueChanged)
        _tableView.refreshControl = _refreshControll
        
        load()
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
    
    
    
    //
    // MARK: -
    //
    /// 一覧読み込み.
    func load(){
        guard let client = DropboxClientsManager.authorizedClient else {
            Utility.alertLinkDropbox(viewController: self, title: "Error", message: nil)
            return
        }
        if _isLoading {
            return
        }
            
        _isLoading = true
        let path = makePath()
        if let cacheData = DropboxFileListManager.sharedManager.get(pathLower: path) {
            if cacheData.count != 0 {
                // キャッシュから.
                self._datas = cacheData
                sortAndReloadList()
            }
        }
        else {
            client.files.listFolder(path: path).response { response, error in
                if let metadata = response {
                    self._datas = []
//                    print("Entries: \(metadata.entries)")
                    for entry in metadata.entries {
                        if let info = FileInfo.make(metadata: entry) {
                            if info.getType() == .Audio || info.getType() == .Folder {
                                // フォルダか音声ファイルのみ.
                                self._datas.append(info)
                            }
                        }
                    }
                } else {
                    if let error = error {
                        print(error)
                        Utility.alertLinkDropbox(viewController: self, title: "Error", message: error.description)
                    }
                    if let controller = self.navigationController {
                        controller.popViewController(animated: true)
                    }
                    self._isLoading = false
                    return
                }
                
                if self._datas.count != 0 {
                    // 登録.
                    DropboxFileListManager.sharedManager.regist(pathLower: path, list: self._datas)
                    DropboxFileListManager.sharedManager.save()
                    // 更新.
                    self.sortAndReloadList()
                }
            }
        }
    }
    
    /// 一覧更新.
    func sortAndReloadList() {
        self._datas.sort(by: {$0.name.lowercased() < $1.name.lowercased()})
        self._tableView.reloadData()
        _isLoading = false
        _refreshControll.endRefreshing()
    }
    
    /// パス作成.
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
        
        let alert = UIAlertController(title: fileInfo.name,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        if fileInfo.isAudioFile() {
            // ダウンロード.
            alert.addAction(
                UIAlertAction(title: isExist ? "Download again" : "Download",
                              style: .default,
                              handler:{
                                (action:UIAlertAction!) -> Void in
                                if let d = AudioData.createFromFileInfo(fileInfo) {
                                    if isExist {
                                        deleteCache()
                                        MetadataCacheManager.sharedManager.remove(audioData: d)
                                        sender.setProgress(0)
                                    }
                                    DownloadFileManager.sharedManager.addQueue(audioData: d)
                                    DownloadFileManager.sharedManager.startDownload()
                                }
                })
            )
            
            // プレイリスト追加.
            if isExist {
                alert.addAction(
                    UIAlertAction(title: "Add to playlist",
                                  style: .default,
                                  handler:{
                                    (action:UIAlertAction!) -> Void in
                                    let playlistvc = PlayListSelectViewController()
                                    if let d = AudioData.createFromFileInfo(fileInfo) {
                                        playlistvc.setAudioData(data: d)
                                        let vc = UINavigationController(rootViewController: playlistvc)
                                        vc.modalTransitionStyle = .coverVertical
                                        self.present(vc, animated: true, completion: nil)
                                    }
                    })
                )
            }
            
            // キャッシュ削除.
            alert.addAction(
                UIAlertAction(title: "Delete cache",
                              style: .destructive,
                              handler:{
                                (action:UIAlertAction!) -> Void in
                                deleteCache()
                                sender.setProgress(0)
                })
            )
        }

        // お気に入り.
        let fav = AppDataManager.sharedManager.favorite
        let isFavorite = fav.isFavorite(fileInfo)
        alert.addAction(
            UIAlertAction(title: isFavorite ? "Delete favorite" : "Add favorite",
                          style: isFavorite ? .destructive : .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            if isFavorite {
                                fav.deleteFavorite(fileInfo)
                            }
                            else {
                                fav.addFavorite(fileInfo)
                            }
                            AppDataManager.sharedManager.save()
            })
        )
        
        
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
    
    
    // MARK: -
    @objc func selectorRefreshControll() {
        // キャッシュから消す.
        DropboxFileListManager.sharedManager.remove(pathLower: makePath())
        // 読み込み.
        load()
    }

    @objc func selectorMenuButton() {
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        // ダウンロード.
        alert.addAction(
            UIAlertAction(title: "Download all",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            for info in self._datas {
                                if let d = AudioData.createFromFileInfo(info) {
                                    DownloadFileManager.sharedManager.addQueue(audioData: d)
                                }
                            }
                            DownloadFileManager.sharedManager.startDownload()
            })
        )
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


    
    //
    // MARK: - TableViewController Delegate.
    //
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FileListViewCell.height
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _datas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: FileListViewCell.cellIdentifier ) as! FileListViewCell
        let fileInfo = _datas[indexPath.row]
        
        c.set(fileInfo: fileInfo)
        c.index = indexPath.row
        c.longpressTarget = self
        c.longpressSelector = #selector(showActionSheet(_:))
        
        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileInfo = _datas[indexPath.row]
        if fileInfo.getType() == .Folder {
            // フォルダ.
            var l: [String] = _pathList
            l.append(fileInfo.name)
            self.navigationController?.pushViewController(FileListViewController(pathList: l),
                                                          animated: true)
        }
        else if fileInfo.getType() == .Audio {
            // ファイル.
            guard let audioData = AudioData.createFromFileInfo(fileInfo) else {
                return
            }
            
            if DownloadFileManager.sharedManager.isExistAudioFile(audioData: audioData) {
                // AudioDataのリストを作成する.
                var index = 0
                var list: [AudioData] = []
                for i in 0 ..< _datas.count {
                    if let d = AudioData.createFromFileInfo(_datas[i]) {
                        if d.isEqualData(audioData: audioData) {
                            index = list.count
                        }
                        list.append(d)
                    }
                }
                
                // 再生.
                AudioPlayManager.sharedManager.set(selectType: .Cloud,
                                                   selectValue: makePath(),
                                                   audioList: list,
                                                   playIndex: index)
                _ = AudioPlayManager.sharedManager.play()
            }
            else {
                DownloadFileManager.sharedManager.addQueue(audioData: audioData)
                DownloadFileManager.sharedManager.startDownload()
            }
        }
    }
}
