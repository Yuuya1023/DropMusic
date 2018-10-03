//
//  AudioListViewCell.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class AudioListViewCell: UITableViewCell {
    var nameLabel: UILabel!
    var icon: UIImageView!
    
    var index: Int = 0
    var longpressTarget: NSObject? = nil
    var longpressSelector: Selector? = nil
    
    
    // MARK: -
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        
        nameLabel = UILabel(frame: CGRect.zero)
        nameLabel.textAlignment = .left
        nameLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(nameLabel)
        
        icon = UIImageView(image: UIImage())
        contentView.addSubview(icon)
        
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
    
    
    func set(audioData: AudioData!) {
        nameLabel.text = audioData.fileName
        icon.image = UIImage(named: "icon_cell_audio.png")
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
    
    
    // MARK: -
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = CGRect(x: 45, y: 0, width: frame.width - 50, height: frame.height)
        icon.frame = CGRect(x: 5, y: 5, width: frame.height - 10, height: frame.height - 10)
    }
}
