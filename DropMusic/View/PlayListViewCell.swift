//
//  PlayListViewCell.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class PlayListViewCell: UITableViewCell {
    
    //
    // MARK: - Constant.
    //
    static let cellIdentifier = "PlayListViewCell"
    static let height: CGFloat = 100.0
    
    
    
    //
    // MARK: - Properties.
    //
    @IBOutlet var _artwork: UIImageView!
    @IBOutlet var _titleLabel: UILabel!
    @IBOutlet var _tracksLabel: UILabel!
    
    var index: Int = 0
    weak var longpressTarget: NSObject? = nil
    var longpressSelector: Selector? = nil
    
    
    
    //
    // MARK: - Override.
    //
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
    
    
    
    //
    // MARK: - Public.
    //
    func set(data: PlayListData?) {
        guard let data = data else {
            return
        }
        _artwork.image = UIImage()
        _titleLabel.text = data.name
        _tracksLabel.text = String(data.audioList.count) + " tracks."
        if (data.audioList.count) > 0 {
            let d: AudioData = data.audioList[0]
            if let metadata = MetadataCacheManager.sharedManager.get(audioData: d) {
                if let artwork = metadata.artwork {
                    _artwork.image = artwork
                }
            }
        }
    }
    
    
    
    //
    // MARK: - Private.
    //
    @objc private func selectorLongpressLayer(_ sender: UILongPressGestureRecognizer) {
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
