//
//  PlayListViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class PlayListViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    //
    // MARK: - Properties.
    //
    private var _tableView: UITableView!
    private var _refreshControll: UIRefreshControl!
    
    
    
    //
    // MARK: - Override.
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Playlist"
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: AppColor.sub]
        self.navigationController?.navigationBar.barTintColor = AppColor.main
        self.navigationController?.navigationBar.tintColor = AppColor.sub
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_menu.png")?.resizeImage(reSize: CGSize(width:30,height:30)),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(selectorMenuButton))
        
        // tableview
        _tableView = UITableView()
        _tableView.backgroundColor = UIColor.clear
        _tableView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
//        _tableView.isEditing = true
//        _tableView.allowsSelectionDuringEditing = true
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.register(UINib(nibName: PlayListViewCell.cellIdentifier, bundle: nil),
                            forCellReuseIdentifier: PlayListViewCell.cellIdentifier)
        
        self.view.addSubview(_tableView)
        
        // refresh control.
        _refreshControll = UIRefreshControl()
        _refreshControll.addTarget(self, action: #selector(selectorRefreshControll), for: .valueChanged)
        _tableView.refreshControl = _refreshControll
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
    
    override func viewWillAppear(_ animated: Bool) {
        updateScrollView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    //
    // MARK: -
    //
    func updateScrollView() {
        self._tableView.reloadData()
    }
    
    private func editPlaylist(playlistId: String) {
        let vc = PlayListEditViewController()
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        vc._rootViewController = self
        vc._playlistId = playlistId
        present(vc, animated: true, completion: nil)
    }
    
    
    //
    // MARK: - Selector
    //
    @objc func selectorRefreshControll() {
        AppDataManager.sharedManager.checkFile {
            self.updateScrollView()
            self._refreshControll.endRefreshing()
        }
    }
    
    @objc func selectorMenuButton() {
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        // プレイリスト作成.
        alert.addAction(
            UIAlertAction(title: "Create playlist",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            let playlistId = AppDataManager.sharedManager.playlist.addPlaylist()
                            AppDataManager.sharedManager.save()
                            self.updateScrollView()
                            self.editPlaylist(playlistId: playlistId)
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
    
    @objc func showEdit(_ sender: PlayListViewCell) {
        editPlaylist(playlistId: AppDataManager.sharedManager.playlist.playlists[sender.index].id)
    }
    
    
    
    //
    // MARK: - TableViewDelegate
    //
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PlayListViewCell.height
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppDataManager.sharedManager.playlist.playlists.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: PlayListViewCell.cellIdentifier ) as! PlayListViewCell
        
        c.index = indexPath.row
        c.longpressTarget = self
        c.longpressSelector = #selector(showEdit(_:))
        c.set(data: AppDataManager.sharedManager.playlist.playlists[indexPath.row])
        
        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 曲一覧へ.
        let d = AppDataManager.sharedManager.playlist.playlists[indexPath.row]
        
        self.navigationController?.pushViewController(AudioListViewController(playListId: d.id),
                                                      animated: true)
    }
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
////        let d = PlayListManager.sharedManager.playlistManageData.playlists?[sourceIndexPath.row]
//
//    }
//    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return .none
//    }
//    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
}


// MARK: -
extension PlayListViewController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PlayListEditPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
//    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//
//    }
}
