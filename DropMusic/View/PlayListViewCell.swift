//
//  PlayListViewCell.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class PlayListViewCell: UITableViewCell {
    var icon: UIImageView!
    var nameLabel: UILabel!
    var tracksLabel: UILabel!
    
    var index: Int = 0
    var longpressTarget: NSObject? = nil
    var longpressSelector: Selector? = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        
        icon = UIImageView(image: UIImage())
        icon.contentMode = .scaleAspectFit
        contentView.addSubview(icon)
        
        nameLabel = UILabel(frame: CGRect.zero)
        nameLabel.textAlignment = .left
        contentView.addSubview(nameLabel)
        
        tracksLabel = UILabel(frame: CGRect.zero)
        tracksLabel.textAlignment = .left
        tracksLabel.textColor = UIColor.gray
        contentView.addSubview(tracksLabel)
        
        // 長押し.
        let tapGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(selectorLongpressLayer(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        icon.frame = CGRect(x: 0, y: 0.5, width: frame.height-1, height: frame.height-1)
        nameLabel.frame = CGRect(x: 80, y: -15, width: frame.width - 65, height: frame.height)
        tracksLabel.frame = CGRect(x: 80, y: 15, width: frame.width - 65, height: frame.height)
    }
    
    
    
    // MARK: -
    func set(data: PlayListData?) {
        icon.image = UIImage()
        if data != nil {
            nameLabel.text = data!.name
            tracksLabel.text = String(data!.audioList.count) + " tracks"
            if (data?.audioList.count)! > 0 {
                let d: AudioData = (data?.audioList[0])!
                let metadata = MetadataCacheManager.sharedManager.get(audioData: d)
                if metadata?.artwork != nil {
                    icon.image = metadata?.artwork
                }
            }
        }
    }
    
    func setAddPlayListCell() {
        nameLabel.text = "+"
        tracksLabel.text = ""
        icon.image = UIImage()
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
