//
//  PlayListSelectViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class PlayListSelectViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //
    // MARK: - Properties.
    //
    var _tableView: UITableView!
    var _refreshControll: UIRefreshControl!
    var _audioData: AudioData? = nil
    
    
    
    //
    // MARK: - Override.
    //
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
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.register(UINib(nibName: PlayListViewCell.cellIdentifier, bundle: nil),
                            forCellReuseIdentifier: PlayListViewCell.cellIdentifier)
        
        self.view.addSubview(_tableView)
        
        //
        _refreshControll = UIRefreshControl()
        _refreshControll.addTarget(self, action: #selector(selectorRefreshControll), for: .valueChanged)
        _tableView.refreshControl = _refreshControll
        
        // キャンセル.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                                 target: self,
                                                                 action: #selector(close))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    //
    // MARK: - Public.
    //
    func setAudioData(data: AudioData) {
        _audioData = data
    }
    
    
    
    //
    // MARK: - Private.
    //
    private func updateScrollView() {
        self._tableView.reloadData()
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func selectorRefreshControll() {
        AppDataManager.sharedManager.checkFile {
            self.updateScrollView()
            self._refreshControll.endRefreshing()
        }
    }
    
    
    
    //
    // MARK: - TableViewDelegate.
    //
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PlayListViewCell.height
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppDataManager.sharedManager.playlist.getPlaylists().count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: PlayListViewCell.cellIdentifier ) as! PlayListViewCell
        
        c.index = indexPath.row
        let playlist = AppDataManager.sharedManager.playlist.getPlaylists()[indexPath.row]
        c.set(data: playlist)
        if let audioData = _audioData {
            let isInclude = AppDataManager.sharedManager.playlist.isIncludeAudio(playListId: playlist.id, data: audioData)
            c.selectionStyle = isInclude ? .none : .default
            c.contentView.backgroundColor = isInclude ? UIColor(displayP3Red: 0/255, green: 0/255, blue: 255/255, alpha: 0.1) : .clear
        }
        return c
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let c = tableView.cellForRow(at: indexPath) {
            if c.selectionStyle == .none {
                return nil
            }
        }
        return indexPath
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 追加.
        if let audioData = _audioData {
            let playlist = AppDataManager.sharedManager.playlist.getPlaylists()[indexPath.row]
            AppDataManager.sharedManager.playlist.addAudioToPlayList(playListId: playlist.id,
                                                                     addList: [audioData])
            AppDataManager.sharedManager.save()
        }
        close()
    }
    
}


