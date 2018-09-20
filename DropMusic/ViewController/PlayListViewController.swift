//
//  PlayListViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class PlayListViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var _tableView: UITableView!
    var _datas: Array<PlayListData>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        self.title = "Playlist"
        
        _datas = []
        
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
        
        for i in 0..<5 {
            let p = PlayListData(_name: String(i), _audioList: [])
            _datas.append(p)
        }
        
        self._tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _datas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let temp = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PlayListViewCell.self))
            ?? UITableViewCell(style: .default, reuseIdentifier: NSStringFromClass(PlayListViewCell.self))
        let c = temp as! PlayListViewCell
        
        let playList = _datas[indexPath.row]
        c.nameLabel.text = playList._name
        c.tracksLabel.text = String(playList._audioList.count) + "tracks"
        
        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
