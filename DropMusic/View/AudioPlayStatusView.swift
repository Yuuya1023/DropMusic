//
//  AudioPlayStatusView.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import Foundation



class AudioPlayStatusView: UIView {
    
    var _effectView: UIVisualEffectView!
    var _artwork: UIImageView!
    var _titleLabel: UILabel!
    var _detailLabel: UILabel!

    var _timer: Timer!
    
    
    
    
    
    public init(x: CGFloat, y: CGFloat) {
        super.init(frame: CGRect(x: x, y: y, width: UIScreen.main.bounds.size.width, height: 50))
        
        self.backgroundColor = UIColor.blue
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                       action: #selector(selectorTouchLayer(_:)))
        self.addGestureRecognizer(tapGesture)
        
        _effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        _effectView.frame = self.bounds
        self.addSubview(_effectView)
        
        _artwork = UIImageView()
        _artwork.frame = CGRect(x: 5, y: 5, width: 40, height: 40)
        self.addSubview(_artwork)
        
        _titleLabel = UILabel()
        _titleLabel.frame = CGRect(x: 50, y: 6, width: 200, height: 20)
        self.addSubview(_titleLabel)
        
        _detailLabel = UILabel()
        _detailLabel.frame = CGRect(x: 50, y: 25, width: 200, height: 20)
        _detailLabel.font = UIFont.systemFont(ofSize: 12)
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
        print("touch")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_SHOW_AUDIO_PLAYER_VIEW),
                                        object: nil)
    }
    
    @objc func selectorDidChangeAudio(_ sender: UIButton) {
        let audioManager = AudioPlayManager.sharedManager
        if audioManager._artwork == nil {
            _artwork.image = UIImage(named: "no_image.gif")
        }
        else {
            _artwork.image = audioManager._artwork
        }
        _titleLabel.text = audioManager._title
        _detailLabel.text = audioManager._artist + " - " + audioManager._album
    }
    
    @objc func selectorCheckAudioInformation(_ sender: UIButton) {
        
    }
    
}
