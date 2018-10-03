//
//  AudioListViewCell.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class AudioListViewCell: UITableViewCell {
    var nameLabel: UILabel!
    var artistLabel: UILabel!
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
        
        artistLabel = UILabel(frame: CGRect.zero)
        artistLabel.textAlignment = .left
        artistLabel.adjustsFontSizeToFitWidth = true
        artistLabel.textColor = UIColor.darkGray
        contentView.addSubview(artistLabel)
        
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
        let metadata = AudioMetadata()
        metadata.set(atPath: DownloadFileManager.sharedManager.getFileCachePath(audioData: audioData))
        nameLabel.text = metadata.title
        artistLabel.text = metadata.artist + " ─ " + metadata.album
        
        
        if metadata.artwork != nil {
            icon.image = metadata.artwork!
        }
        else {
            icon.image = UIImage()
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
    
    
    // MARK: -
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = CGRect(x: 65, y:10, width: frame.width - 70, height: 20)
        artistLabel.frame = CGRect(x: 65, y:30, width: frame.width - 70, height: 20)
        icon.frame = CGRect(x: 0, y: 0.5, width: frame.height-1, height: frame.height-1)
    }
}
