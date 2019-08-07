//
//  PlayListSelectViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class PlayListSelectViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variable Declaration
    var _tableView: UITableView!
    var _timer: Timer!
    var _refreshControll: UIRefreshControl!
    
    var _audioData: AudioData? = nil
    
    private let _cellIdentifier = "PlayListViewCell"
    
    
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        self.title = "Add to playlist"
        
        _tableView = UITableView(frame: self.view.bounds, style: .plain)
        _tableView.backgroundColor = UIColor.clear
        _tableView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        _tableView.rowHeight = 70
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.register(UINib(nibName: _cellIdentifier, bundle: nil), forCellReuseIdentifier: _cellIdentifier)
        
        self.view.addSubview(_tableView)
        
        //
        _refreshControll = UIRefreshControl()
        _refreshControll.addTarget(self, action: #selector(selectorRefreshControll), for: .valueChanged)
        _tableView.refreshControl = _refreshControll
        
        // キャンセル.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                 target: self,
                                                                 action: #selector(close))
        
        // プレイリストの読み込み確認.
        if !PlayListManager.sharedManager.isLoaded {
            setScheduler()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    // MARK: -
    private func setScheduler() {
        _timer = Timer.scheduledTimer(timeInterval: 1.0,
                                      target: self,
                                      selector: #selector(selectorLoagingCheck),
                                      userInfo: nil,
                                      repeats: true)
    }
    
    
    func setAudioData(data: AudioData?) {
        _audioData = data
    }
    
    
    func updateScrollView() {
        self._tableView.reloadData()
    }
    
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
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
            self.updateScrollView()
            self._refreshControll.endRefreshing()
        }
    }
    
    
    
    // MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlayListManager.sharedManager.playlistManageData.playlists.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: _cellIdentifier ) as! PlayListViewCell
        
        c.index = indexPath.row
        c.set(data: PlayListManager.sharedManager.playlistManageData.playlists[indexPath.row])
        
        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
        
        // 追加.
        if _audioData != nil {
            let playlist = PlayListManager.sharedManager.playlistManageData.playlists[indexPath.row]
            PlayListManager.sharedManager.addAudioToPlayList(playListId: playlist.id, addList: [_audioData!], isSave: true)
        }
        close()
    }
}


