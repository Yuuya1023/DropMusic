//
//  FileListViewCell.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class FileListViewCell: UITableViewCell {
    var nameLabel: UILabel!
    var icon: UIImageView!
    var progress: UIProgressView!
    var isAudioFile: Bool = false
    
    var index: Int = 0
    var longpressTarget: NSObject? = nil
    var longpressSelector: Selector? = nil
    
    
    // MARK: - 
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        
        
        nameLabel = UILabel(frame: CGRect.zero)
        nameLabel.textAlignment = .left
        contentView.addSubview(nameLabel)
        
        icon = UIImageView(image: UIImage())
        contentView.addSubview(icon)
        
        progress = UIProgressView()
        progress.progress = 0.0
        progress.trackTintColor = UIColor.clear
        contentView.addSubview(progress)
        
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
    
    
    // MARK: -
    func updateObserber(identifier: String) {
        NotificationCenter.default.removeObserver(self)
        if isAudioFile {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(setProgress(notification:)),
                                                   name: NSNotification.Name(rawValue: identifier),
                                                   object: nil)
        }
    }
    
    
    
    // MARK: -
    @objc func setProgress(notification: Notification) {
        let p = notification.object as! NSNumber
        self.progress.progress = Float(truncating: p)
    }
    
    @objc func selectorLongpressLayer(_ sender: UILongPressGestureRecognizer) {
        if isAudioFile {
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
    
    
    // MARK: -
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.frame = CGRect(x: 50, y: 0, width: frame.width - 55, height: frame.height)
        icon.frame = CGRect(x: 5, y: 5, width: frame.height - 10, height: frame.height - 10)
        progress.frame = CGRect(x: 0, y: frame.height-2.5, width: frame.width, height: frame.height - 5)
    }
}
