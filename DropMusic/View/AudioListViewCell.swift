//
//  AudioListViewCell.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class AudioListViewCell: UITableViewCell {
    var audioData: AudioData? = nil
    var nameLabel: UILabel!
    var artistLabel: UILabel!
    var icon: UIImageView!
    var progress: UIProgressView!
    
    var index: Int = 0
    weak var longpressTarget: NSObject? = nil
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
        icon.contentMode = .scaleAspectFit
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
    
    
    func set(audioData: AudioData!) {
        self.audioData = audioData
        // ダウンロード監視.
        updateObserber(identifier: audioData.id)
        // ファイル確認.
        if DownloadFileManager.sharedManager.isExistAudioFile(audioData: audioData!) {
            let metadata = MetadataCacheManager.sharedManager.get(audioData: audioData)
            if metadata != nil {
                nameLabel.text = metadata?.title
                artistLabel.text = (metadata?.artist)! + " ─ " + (metadata?.album)!
                
                if metadata?.artwork != nil {
                    icon.image = metadata?.artwork!
                }
                else {
                    icon.image = UIImage()
                }
                return
            }
        }
        nameLabel.text = audioData.fileName
        artistLabel.text = ""
        icon.image = UIImage()
    }
    
    
    
    private func updateObserber(identifier: String) {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setProgress(notification:)),
                                               name: NSNotification.Name(rawValue: identifier),
                                               object: nil)
    }
    
    // MARK: -
    @objc func setProgress(notification: Notification) {
        var p = Float(truncating: notification.object as! NSNumber)
        if p < 0 { p = 0.0 }
        self.progress.progress = p
        if p >= 1.0 {
            self.progress.progress = 0
            set(audioData: self.audioData)
        }
    }
    
    
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
        progress.frame = CGRect(x: 0, y: frame.height-2.5, width: frame.width, height: frame.height - 5)
    }
}
