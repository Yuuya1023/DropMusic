//
//  PlayListViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class PlayListViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variable Declaration
    var _tableView: UITableView!
    var _timer: Timer!
    var _refreshControll: UIRefreshControl!
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Playlist"
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 40/255, green: 50/255, blue: 100/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = .white
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_menu.png")?.resizeImage(reSize: CGSize(width:30,height:30)),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(selectorMenuButton))
        
        var bounds = self.view.bounds
        bounds.size.height = bounds.size.height-132
        _tableView = UITableView(frame: bounds, style: .plain)
        _tableView.backgroundColor = UIColor.clear
        _tableView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        _tableView.rowHeight = 70
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.register(PlayListViewCell.self, forCellReuseIdentifier: NSStringFromClass(PlayListViewCell.self))
        
        self.view.addSubview(_tableView)
        
        //
        _refreshControll = UIRefreshControl()
        _refreshControll.addTarget(self, action: #selector(selectorRefreshControll), for: .valueChanged)
        _tableView.refreshControl = _refreshControll
        
        // プレイリストの読み込み確認.
        if !PlayListManager.sharedManager.isLoaded {
            setScheduler()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        updateScrollView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: -
    func setScheduler() {
        _timer = Timer.scheduledTimer(timeInterval: 1.0,
                                      target: self,
                                      selector: #selector(selectorLoagingCheck),
                                      userInfo: nil,
                                      repeats: true)
    }
    
    
    func updateScrollView() {
        self._tableView.reloadData()
    }
    
    private func editPlaylist(playlistId: String) {
        let vc = PlayListEditViewController()
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        vc.rootViewController = self
        vc.setPlaylistId(id: playlistId)
        present(vc, animated: true, completion: nil)
        
    }
    
    
    // MARK: - Selector
    @objc func selectorLoagingCheck() {
        if PlayListManager.sharedManager.isLoaded {
            _timer.invalidate()
            updateScrollView()
        }
    }
    
    
    @objc func selectorRefreshControll() {
        print("selectorRefreshControll")
        
        PlayListManager.sharedManager.updateCheck {
            print("update")
            self.updateScrollView()
            self._refreshControll.endRefreshing()
        }
    }
    
    @objc func selectorMenuButton() {
        let alert: UIAlertController = UIAlertController(title: nil,
                                                         message: nil,
                                                         preferredStyle: .actionSheet)
        // プレイリスト作成.
        let playlistAction:UIAlertAction =
            UIAlertAction(title: "Create playlist",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            let playlistId = PlayListManager.sharedManager.addPlaylist(isSave: true)
                            self.updateScrollView()
                            self.editPlaylist(playlistId: playlistId)
            })
        
        // キャンセル.
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            // 閉じるだけ.
            })
        
        alert.addAction(playlistAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func showEdit(_ sender: PlayListViewCell) {
        editPlaylist(playlistId: PlayListManager.sharedManager.playlistManageData.playlists[sender.index].id)
    }
    
    
    
    // MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlayListManager.sharedManager.playlistManageData.playlists.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let temp = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PlayListViewCell.self))
            ?? UITableViewCell(style: .default, reuseIdentifier: NSStringFromClass(PlayListViewCell.self))
        let c = temp as! PlayListViewCell
        
        c.index = indexPath.row
        c.longpressTarget = self
        c.longpressSelector = #selector(showEdit(_:))
        c.set(data: PlayListManager.sharedManager.playlistManageData.playlists[indexPath.row])
        
        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
        // 曲一覧へ.
        let d = PlayListManager.sharedManager.playlistManageData.playlists[indexPath.row]
        self.navigationController?.pushViewController(AudioListViewController(playListId: d.id),
                                                      animated: true)
    }
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
