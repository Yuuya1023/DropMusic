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
        nameLabel.adjustsFontSizeToFitWidth = true
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
    func set(fileInfo: FileInfo!) {
        isAudioFile = fileInfo.isAudioFile()
        nameLabel.text = fileInfo.name()
        
        var iconName = "icon_cell_question.png"
        if fileInfo.isFolder() {
            iconName = "icon_cell_folder.png"
        }
        else if fileInfo.isAudioFile() {
            iconName = "icon_cell_audio.png"
        }
        icon.image = UIImage(named: iconName)
        
        if DownloadFileManager.sharedManager.isExistAudioFile(fileInfo: fileInfo) {
            progress.progress = 1
        }
        else {
            progress.progress = 0
        }
        
        if fileInfo.isFile() {
            updateObserber(identifier: fileInfo.id()!)
        }
    }
    
    
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
        var p = Float(truncating: notification.object as! NSNumber)
        if p < 0 { p = 0.0 }
        self.progress.progress = p
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
        nameLabel.frame = CGRect(x: 45, y: 0, width: frame.width - 50, height: frame.height)
        icon.frame = CGRect(x: 5, y: 5, width: frame.height - 10, height: frame.height - 10)
        progress.frame = CGRect(x: 0, y: frame.height-2.5, width: frame.width, height: frame.height - 5)
    }
}
