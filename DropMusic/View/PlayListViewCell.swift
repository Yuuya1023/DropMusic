//
//  PlayListViewCell.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class PlayListViewCell: UITableViewCell {
    
    @IBOutlet var _artwork: UIImageView!
    @IBOutlet var _titleLabel: UILabel!
    @IBOutlet var _tracksLabel: UILabel!
    
    var index: Int = 0
    var longpressTarget: NSObject? = nil
    var longpressSelector: Selector? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // アートワーク.
        _artwork.layer.shadowOpacity = 0.7
        _artwork.layer.shadowOffset = CGSize(width: 2, height: 2)
        // 長押し.
        let tapGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(selectorLongpressLayer(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: -
    func set(data: PlayListData?) {
        _artwork.image = UIImage()
        if data != nil {
            _titleLabel.text = data!.name
            _tracksLabel.text = String(data!.audioList.count) + " tracks."
            if (data?.audioList.count)! > 0 {
                let d: AudioData = (data?.audioList[0])!
                let metadata = MetadataCacheManager.sharedManager.get(audioData: d)
                if metadata?.artwork != nil {
                    _artwork.image = metadata?.artwork
                }
            }
        }
    }
    
    
    
    // MARK: -
    @objc func selectorLongpressLayer(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            if longpressTarget != nil && longpressSelector != nil {
                longpressTarget?.perform(longpressSelector, with: self)
            }
        default:
            break
        }
    }
}
