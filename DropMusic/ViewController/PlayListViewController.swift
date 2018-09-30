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
        self.view.backgroundColor = UIColor.white
        self.title = "Playlist"
        
        var bounds = self.view.bounds
        bounds.size.height = bounds.size.height-98
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
    
    
    @objc func showEdit(_ sender: PlayListViewCell) {
        let vc = PlayListEditViewController()
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        vc.rootViewController = self
        vc.setPlaylistId(id: PlayListManager.sharedManager.playlistManageData.playlists[sender.index].id)
        present(vc, animated: true, completion: nil)
    }
    
    
    
    // MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlayListManager.sharedManager.playlistManageData.playlists.count+1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let temp = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PlayListViewCell.self))
            ?? UITableViewCell(style: .default, reuseIdentifier: NSStringFromClass(PlayListViewCell.self))
        let c = temp as! PlayListViewCell
        
        c.index = indexPath.row
        c.longpressTarget = self
        c.longpressSelector = #selector(showEdit(_:))
        if PlayListManager.sharedManager.playlistManageData.playlists.count > indexPath.row {
            let playList = PlayListManager.sharedManager.playlistManageData.playlists[indexPath.row]
            c.nameLabel.text = playList.name
            c.tracksLabel.text = String(playList.audioList.count) + " tracks"
        }
        else {
            c.nameLabel.text = "+"
            c.tracksLabel.text = ""
        }
        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
        
        if PlayListManager.sharedManager.playlistManageData.playlists.count > indexPath.row {
            // 曲一覧へ.
        }
        else {
            // 追加.
            PlayListManager.sharedManager.addPlaylist(isSave: true)
            updateScrollView()
        }
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
