//
//  AudioListView.swift
//  DropMusic
//
//  Copyright © 2022 n.yuuya. All rights reserved.
//

import UIKit

protocol AudioListViewDelegate: AnyObject {
    
    func touchCell(index: Int)
    func longpressCell(index: Int)
}

extension AudioListViewDelegate {
 
    func touchCell(index: Int){}
    func longpressCell(index: Int){}
}


class AudioListView : UITableView, UITableViewDelegate, UITableViewDataSource {
    
    //
    // MARK: - Properties.
    //
    weak var audioListViewDelegate: AudioListViewDelegate?
    private var audioList: Array<AudioData> = []
    
    
    
    //
    // MARK: - Override.
    //
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    //
    // MARK: -
    //
    func initialize() {
        backgroundColor = UIColor.clear
        autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        delegate = self
        dataSource = self
        register(UINib(nibName: AudioListViewCell.cellIdentifier, bundle: nil),
                        forCellReuseIdentifier: AudioListViewCell.cellIdentifier)
    }
    
    func setAudioList(list: Array<AudioData>) {
        audioList = list
    }
    
    func touchCell(index: Int) {
        guard let delegate = audioListViewDelegate else {
            return
        }
        delegate.touchCell(index: index)
    }
    
    @objc func longpressCell(_ sender: AudioListViewCell) {
        guard let delegate = audioListViewDelegate else {
            return
        }
        let index = sender.index
        delegate.longpressCell(index: index)
    }
    
    //
    // MARK: - TableViewController Delegate.
    //
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AudioListViewCell.height
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: AudioListViewCell.cellIdentifier ) as! AudioListViewCell
        
        let audioData = audioList[indexPath.row]
        
        c.set(audioData: audioData)
        c.index = indexPath.row
        c.longpressTarget = self
        c.longpressSelector = #selector(longpressCell(_:))

        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        touchCell(index: indexPath.row)
    }
}
