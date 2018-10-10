//
//  AudioPlayStatusView.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import Foundation
import MarqueeLabel


class AudioPlayStatusView: UIView {
    
    var _effectView: UIVisualEffectView!
    var _artwork: UIImageView!
    var _titleLabel: MarqueeLabel!
    var _detailLabel: MarqueeLabel!

    var _timer: Timer!
    
    
    
    
    
    public init(x: CGFloat, y: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: UIScreen.main.bounds.size.width, height: 50))
        
//        self.backgroundColor = UIColor.clear
//        self.backgroundColor = UIColor(displayP3Red: 200/255, green: 200/255, blue: 255/255, alpha: 1)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: -3)
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                       action: #selector(selectorTouchLayer(_:)))
        self.addGestureRecognizer(tapGesture)
        
        _effectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        _effectView.frame = self.bounds
        self.addSubview(_effectView)
        
        _artwork = UIImageView()
        _artwork.contentMode = .scaleAspectFit
        _artwork.frame = CGRect(x: 5, y: 5, width: 40, height: 40)
        _artwork.layer.shadowOpacity = 0.5
        _artwork.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.addSubview(_artwork)
        
        _titleLabel = MarqueeLabel(frame: CGRect(x: 50, y: 6, width: 270, height: 20),
                                   duration: 10,
                                   fadeLength: 10)
        _titleLabel.textColor = UIColor.black
        self.addSubview(_titleLabel)
        
        _detailLabel = MarqueeLabel(frame: CGRect(x: 50, y: 25, width: 270, height: 20),
                                    duration: 10,
                                    fadeLength: 10)
        _detailLabel.font = UIFont.systemFont(ofSize: 12)
//        _detailLabel.textColor = UIColor(displayP3Red: 90/255, green: 90/255, blue: 255/255, alpha: 1)
        _detailLabel.textColor = UIColor.darkGray
        self.addSubview(_detailLabel)
        
        
        // 曲情報監視.
        _timer = Timer.scheduledTimer(timeInterval: 1.0,
                                      target: self,
                                      selector: #selector(selectorCheckAudioInformation),
                                      userInfo: nil,
                                      repeats: true)
        // 曲監視.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(selectorDidChangeAudio),
                                               name: NSNotification.Name(rawValue: NOTIFICATION_DID_CHANGE_AUDIO),
                                               object: nil)
    }
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
//    override func intrinsicContentSize() -> CGSize {
//        return CGSize(width: 210, height: 100)
//    }
//    override open var intrinsicContentSize: CGSize {
//        // 自身のサイズを返却.
//        return CGSize(width: UIScreen.main.bounds.size.width, height: 50)
//    }
    
    @objc func selectorTouchLayer(_ sender: UITapGestureRecognizer) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_SHOW_AUDIO_PLAYER_VIEW),
                                        object: nil)
    }
    
    @objc func selectorDidChangeAudio(_ notification: Notification) {
        let audioManager = AudioPlayManager.sharedManager
        if audioManager._metadata.artwork == nil {
            _artwork.image = UIImage(named: "no_image.gif")
        }
        else {
            _artwork.image = audioManager._metadata.artwork
        }
        _titleLabel.text = audioManager._metadata.title
        _detailLabel.text = audioManager._metadata.artist + " ─ " + audioManager._metadata.album
    }
    
    @objc func selectorCheckAudioInformation(_ sender: UIButton) {
        
    }
    
}
