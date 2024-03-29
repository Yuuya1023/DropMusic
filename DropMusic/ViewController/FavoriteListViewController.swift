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
    // MARK: - Enumeration.
    //
    enum ListType {
        case Folder
        case Audio
    }
    
    
    
    //
    // MARK: - Properties
    //
    private var _tableView: UITableView!
    private var _datas: [FavoriteData] = []
    private var _listType: ListType = .Folder

    private var _refreshControll: UIRefreshControl!
    
    
    
    //
    // MARK: - Initialize.
    //
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    
    
    //
    // MARK: - Override.
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Favorite"
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
        _tableView.register(UINib(nibName: AudioListViewCell.cellIdentifier, bundle: nil),
                            forCellReuseIdentifier: AudioListViewCell.cellIdentifier)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        sortAndReloadList()
    }
    
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
    /// 一覧更新.
    func sortAndReloadList() {
        var type: AppManageData.FileType = .None
        switch _listType {
        case .Folder:
            type = .Folder
        case .Audio:
            type = .Audio
        }
        _datas = AppDataManager.sharedManager.favorite.getList(type)
        self._datas.sort(by: {$0.getParentFolderName() < $1.getParentFolderName()})
        self._tableView.reloadData()
        _refreshControll.endRefreshing()
    }
    
    @objc func showActionSheet(_ sender: FileListViewCell) {
        let favoriteData = _datas[sender.index]
        
        let alert = UIAlertController(title: favoriteData.path,
                                      message: nil,
                                      preferredStyle: .actionSheet)

        // お気に入り解除.
        let fav = AppDataManager.sharedManager.favorite
        alert.addAction(
            UIAlertAction(title: "Delete favorite",
                          style: .destructive,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            fav.deleteFavorite(favoriteData)
                            AppDataManager.sharedManager.save()
                            // 更新.
                            self.sortAndReloadList()
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
        AppDataManager.sharedManager.checkFile {
            // 読み込み.
            self.sortAndReloadList()
        }
    }

    @objc func selectorMenuButton() {
        let alert = UIAlertController(title: "Select display type.",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        // Folder.
        alert.addAction(
            UIAlertAction(title: "Folder",
                          style: _listType == .Folder ? .destructive : .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            if self._listType != .Folder {
                                self._listType = .Folder
                                self.sortAndReloadList()
                            }
            })
        )
        // Audio.
        alert.addAction(
            UIAlertAction(title: "Audio",
                          style: _listType == .Audio ? .destructive : .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            if self._listType != .Audio {
                                self._listType = .Audio
                                self.sortAndReloadList()
                            }
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
        var height: CGFloat = 0.0
        switch _listType {
        case .Folder:
            height = FileListViewCell.height
        case .Audio:
            height = AudioListViewCell.height
        }
        return height
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _datas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch _listType {
        case .Folder:
            let c = tableView.dequeueReusableCell(withIdentifier: FileListViewCell.cellIdentifier ) as! FileListViewCell
            let favoriteData = _datas[indexPath.row]
            
            c.set(favoriteData: favoriteData)
            c.index = indexPath.row
            c.longpressTarget = self
            c.longpressSelector = #selector(showActionSheet(_:))
            
            return c
        case .Audio:
            let c = tableView.dequeueReusableCell(withIdentifier: AudioListViewCell.cellIdentifier ) as! AudioListViewCell
            let favoriteData = _datas[indexPath.row]
            
            c.set(audioData: AudioData.createFromFavorite(favoriteData))
            c.index = indexPath.row
            c.longpressTarget = self
            c.longpressSelector = #selector(showActionSheet(_:))
            
            return c
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favoriteData = _datas[indexPath.row]
        if favoriteData.fileType == .Folder {
            // フォルダ.
            self.navigationController?.pushViewController(FileListViewController(pathList: favoriteData.createPathList()),
                                                          animated: true)
        }
        else if favoriteData.fileType == .Audio {
            // ファイル.
            guard let audioData = AudioData.createFromFavorite(favoriteData) else {
                return
            }
            
            if DownloadFileManager.sharedManager.isExistAudioFile(audioData: audioData) {
                // AudioDataのリストを作成する.
                var index = 0
                var list: [AudioData] = []
                let favoriteList = AppDataManager.sharedManager.favorite.getList(.Audio)
                for i in 0 ..< favoriteList.count {
                    if let d = AudioData.createFromFavorite(favoriteList[i]) {
                        if d.isEqualData(audioData: audioData) {
                            index = list.count
                        }
                        list.append(d)
                    }
                }
                
                // 再生.
                AudioPlayManager.sharedManager.set(selectType: .Favorite,
                                                   selectValue: "",
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
