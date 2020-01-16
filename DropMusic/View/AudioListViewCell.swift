//
//  AudioListViewCell.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class AudioListViewCell: UITableViewCell {
    
    //
    // MARK: - Constant.
    //
    static let cellIdentifier = "AudioListViewCell"
    static let height: CGFloat = 80.0
    
    
    
    //
    // MARK: - Properties.
    //
    @IBOutlet var _artwork: UIImageView!
    @IBOutlet var _titleLabel: UILabel!
    @IBOutlet var _artistLabel: UILabel!
    @IBOutlet var _progressView: UIProgressView!
    
    var audioData: AudioData? = nil
    
    var index: Int = 0
    weak var longpressTarget: NSObject? = nil
    var longpressSelector: Selector? = nil
    
    
    
    //
    // MARK: -
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
    
    
    
    //
    // MARK: -
    //
    func set(audioData: AudioData!) {
        self.audioData = audioData
        // ダウンロード監視.
        updateObserber(identifier: audioData.id)
        // ファイル確認.
        if DownloadFileManager.sharedManager.isExistAudioFile(audioData: audioData!) {
            if let metadata = MetadataCacheManager.sharedManager.get(audioData: audioData) {
                _titleLabel.text = metadata.title
                _artistLabel.text = (metadata.artist) + " ─ " + (metadata.album)
                
                if metadata.artwork != nil {
                    _artwork.image = metadata.artwork!
                }
                else {
                    _artwork.image = UIImage()
                }
                return
            }
        }
        _titleLabel.text = audioData.fileName
        _artistLabel.text = ""
        _artwork.image = UIImage()
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
        self._progressView.progress = p
        if p >= 1.0 {
            self._progressView.progress = 0
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
    }
}
