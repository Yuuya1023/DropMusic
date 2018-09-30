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
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        self.title = "Playlist"
        
        var bounds = self.view.bounds
        bounds.size.height = bounds.size.height
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
    
    
    
    // MARK: -
    @objc func selectorLoagingCheck() {
        if PlayListManager.sharedManager.isLoaded {
            _timer.invalidate()
            updateScrollView()
        }
    }
    
    
    // MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlayListManager.sharedManager.playlistManageData.playlists.count+1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let temp = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PlayListViewCell.self))
            ?? UITableViewCell(style: .default, reuseIdentifier: NSStringFromClass(PlayListViewCell.self))
        let c = temp as! PlayListViewCell
        
        if PlayListManager.sharedManager.playlistManageData.playlists.count > indexPath.row {
            let playList = PlayListManager.sharedManager.playlistManageData.playlists[indexPath.row]
            c.nameLabel.text = playList.name
            c.tracksLabel.text = String(playList.audioList.count) + " tracks"
        }
        else {
            c.nameLabel.text = "+"
        }
        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
        
        if PlayListManager.sharedManager.playlistManageData.playlists.count > indexPath.row {
//            var alert = PlaylistEditAlertController()
//            var vc = PlayListViewController()
//            present(vc, animated: true, completion: nil)
        }
        else {
            // 追加.
            PlayListManager.sharedManager.addPlaylist()
            PlayListManager.sharedManager.save()
            updateScrollView()
        }
    }
}
