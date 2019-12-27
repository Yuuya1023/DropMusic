//
//  FavoriteListViewController.swift
//  DropMusic
//
//  Copyright © 2019年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class FavoriteListViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //
    // MARK: - Properties
    //
    var _tableView: UITableView!
    var _datas: Array<FavoriteData> = []
    
    var _isLoading: Bool = false
    var _refreshControll: UIRefreshControl!
    
    private let _cellIdentifier = "FileListViewCell"
    
    
    
    //
    // MARK: -
    //
    ///
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Favorite"
        self.view.backgroundColor = UIColor.white
        if let navigationController = self.navigationController {
            navigationController.delegate = self
            navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController.navigationBar.barTintColor = UIColor(displayP3Red: 40/255, green: 50/255, blue: 100/255, alpha: 1)
            navigationController.navigationBar.tintColor = .white
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
        _tableView.register(UINib(nibName: _cellIdentifier, bundle: nil), forCellReuseIdentifier: _cellIdentifier)
        
        self.view.addSubview(_tableView)

        // refresh control.
        _refreshControll = UIRefreshControl()
        _refreshControll.addTarget(self, action: #selector(selectorRefreshControll), for: .valueChanged)
        _tableView.refreshControl = _refreshControll
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///
    override func viewWillAppear(_ animated: Bool) {
        load()
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
        if _isLoading {
            return
        }
            
        _isLoading = true
        _datas = AppDataManager.sharedManager.favorite.getList(.Folder)
        sortAndReloadList()
    }
    
    /// 一覧更新.
    func sortAndReloadList() {
        self._tableView.reloadData()
        _isLoading = false
        _refreshControll.endRefreshing()
    }
    
    @objc func showActionSheet(_ sender: FileListViewCell) {
        let favoriteData = _datas[sender.index]
        
        let alert = UIAlertController(title: favoriteData.path,
                                      message: nil,
                                      preferredStyle: .actionSheet)

        // お気に入り解除.
        if let fav = AppDataManager.sharedManager.favorite {
            let favoriteAction:UIAlertAction =
                UIAlertAction(title: "Delete favorite",
                              style: .destructive,
                              handler:{
                                (action:UIAlertAction!) -> Void in
                                fav.deleteFavorite(favoriteData)
                                AppDataManager.sharedManager.save()
                                // 更新.
                                self.load()
                })
            alert.addAction(favoriteAction)
        }
        
        
        // キャンセル.
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            // 閉じるだけ.
            })
        
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: -
    @objc func selectorRefreshControll() {
        // 読み込み.
        load()
    }

    @objc func selectorMenuButton() {
//        let alert: UIAlertController = UIAlertController(title: nil,
//                                                         message: nil,
//                                                         preferredStyle: .actionSheet)
//        // ダウンロード.
//        let downloadAction:UIAlertAction =
//            UIAlertAction(title: "Download all",
//                          style: .default,
//                          handler:{
//                            (action:UIAlertAction!) -> Void in
//                            for info in self._datas {
//                                if let d = AudioData.createFromFileInfo(fileInfo: info) {
//                                    DownloadFileManager.sharedManager.addQueue(audioData: d)
//                                }
//                            }
//                            DownloadFileManager.sharedManager.startDownload()
//            })
//
//        // キャンセル.
//        let cancelAction:UIAlertAction =
//            UIAlertAction(title: "Cancel",
//                          style: .cancel,
//                          handler:{
//                            (action:UIAlertAction!) -> Void in
//                            // 閉じるだけ.
//            })
//
//        alert.addAction(downloadAction)
//        alert.addAction(cancelAction)
//        present(alert, animated: true, completion: nil)
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
        return 40.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _datas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: _cellIdentifier ) as! FileListViewCell
        let favoriteData = _datas[indexPath.row]
        
        c.set(favoriteData: favoriteData)
        c.index = indexPath.row
        c.longpressTarget = self
        c.longpressSelector = #selector(showActionSheet(_:))
        
        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favoriteData = _datas[indexPath.row]
        if favoriteData.fileType == .Folder {
            // フォルダ.
            self.navigationController?.pushViewController(FileListViewController(pathList: favoriteData.createPathList()),
                                                          animated: true)
        }
        else if favoriteData.fileType == .Audio {
//            // ファイル.
//            guard let audioData = AudioData.createFromFileInfo(fileInfo: fileInfo) else {
//                return
//            }
//
//            if DownloadFileManager.sharedManager.isExistAudioFile(audioData: audioData) {
//                // AudioDataのリストを作成する.
//                var list: Array<AudioData> = []
//                for i in 0 ..< _datas.count {
//                    if let d = AudioData.createFromFileInfo(fileInfo: _datas[i]) {
//                        list.append(d)
//                    }
//                }
//                // 再生.
//                AudioPlayManager.sharedManager.set(selectType: .Cloud,
//                                                   selectPath: makePath(),
//                                                   audioList: list,
//                                                   playIndex: indexPath.row)
//                _ = AudioPlayManager.sharedManager.play()
//            }
//            else {
//                DownloadFileManager.sharedManager.addQueue(audioData: audioData)
//                DownloadFileManager.sharedManager.startDownload()
//            }
        }
    }
}
