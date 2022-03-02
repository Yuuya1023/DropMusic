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
    
    //
    // MARK: - Outlets
    //
    @IBOutlet var _touchView: UIView!
    @IBOutlet var tapGesture:UITapGestureRecognizer!
    
    @IBOutlet var _effectView: UIVisualEffectView!

    @IBOutlet var _artwork: UIImageView!
    @IBOutlet var _titleView: UIView!
    @IBOutlet var _descView: UIView!
    
    @IBOutlet var _playButton: UIButton!
    @IBOutlet var _seakBar: UISlider!
    
    
    //
    // MARK: - Properties
    //
    private var _view: UIView!
    static let _height: CGFloat = 50.0
    
    var _titleLabel: MarqueeLabel!
    var _detailLabel: MarqueeLabel!

    var _timer: Timer!
    
    
    
    //
    // MARK: -
    //
    /// コードから生成した時の初期化処理
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibInit()
    }
    
    // ストーリーボードで配置した時の初期化処理
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibInit()
    }
    
    // xibファイルを読み込んでviewに重ねる
    fileprivate func nibInit() {
        // File's OwnerをXibViewにしたので ownerはself になる
        _view = UINib(nibName: "AudioPlayStatusView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView
        guard _view != nil else {
            return
        }
        
        self.bounds = _view.bounds
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 0, height: -3)
        
        // アートワーク.
        _artwork.contentMode = .scaleAspectFit
        _artwork.layer.shadowOpacity = 0.5
        _artwork.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        // タイトル.
        _titleLabel = MarqueeLabel(frame: _titleView.bounds,
                                   duration: 10,
                                   fadeLength: 10)
        _titleLabel.textColor = .black
        _titleLabel.font = UIFont(name: "Avenir Book", size: 17.0)
        _titleView.addSubview(_titleLabel)
        
        // 情報.
        _detailLabel = MarqueeLabel(frame: _descView.bounds)
        _detailLabel.font = UIFont.systemFont(ofSize: 12)
        _detailLabel.textColor = .darkGray
        _detailLabel.font = UIFont(name: "Avenir Book", size: 15.0)
        _descView.addSubview(_detailLabel)
        
        // シークバー.
        _seakBar.tintColor = AppColor.accent
        _seakBar.setThumbImage(UIImage(), for: .normal)
        
        // 再生.
        _playButton.addTarget(self, action: #selector(selectorPlayButton(_:)), for: .touchUpInside)
        layoutPlayButton()
        
        // 曲情報監視.
        _timer = Timer.scheduledTimer(timeInterval: 1.0 / 30.0,
                                      target: self,
                                      selector: #selector(update),
                                      userInfo: nil,
                                      repeats: true)
        // 曲監視.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(selectorDidChangeAudio),
                                               name: NSNotification.Name(rawValue: NOTIFICATION_DID_CHANGE_AUDIO),
                                               object: nil)
        //
        self.addSubview(_view)
    }
    
    override func layerWillDraw(_ layer: CALayer) {
        super.layerWillDraw(layer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // チェック.
        set()
    }
    
    override func draw(_ rect: CGRect) {
        _titleLabel.frame = _titleView.bounds
        _detailLabel.frame = _descView.bounds
        super.draw(rect)
    }
    
    
    
    
    //
    // MARK: - Private.
    //
    /// 更新.
    @objc private func update() {
        updateProgress()
        layoutPlayButton()
    }
    
    /// 進捗更新.
    private func updateProgress() {
        guard let player = AudioPlayManager.sharedManager._audioPlayer else {
            _seakBar.setValue(0.0, animated: false)
            return
        }
        let current = Double((player.currentTime))
        let duration = Double(AudioPlayManager.sharedManager._duration)
        let v = current/duration
        _seakBar.setValue(Float(v), animated: true)
    }
    
//    override func intrinsicContentSize() -> CGSize {
//        return CGSize(width: 210, height: 100)
//    }
//    override open var intrinsicContentSize: CGSize {
//        // 自身のサイズを返却.
//        return CGSize(width: UIScreen.main.bounds.size.width, height: 50)
//    }
    
    @IBAction func selectorTouchLayer() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_SHOW_AUDIO_PLAYER_VIEW),
                                        object: nil)
    }
    
    @objc func selectorPlayButton(_ sender: UIButton) {
        if AudioPlayManager.sharedManager.isPlaying() {
            AudioPlayManager.sharedManager.pause()
        }
        else {
            _ = AudioPlayManager.sharedManager.play()
        }
        layoutPlayButton()
    }
    
    private func layoutPlayButton() {
        _playButton.setImage(UIImage(named: AudioPlayManager.sharedManager.isPlaying() ? "pause.png" : "play.png"), for: .normal)
    }
    
    
    @objc func selectorDidChangeAudio(_ notification: Notification) {
        set()
    }
    
    private func set() {
        guard let metadata = AudioPlayManager.sharedManager._metadata else {
            return
        }
        if metadata.artwork == nil {
            _artwork.image = UIImage(named: "no_image.gif")
        }
        else {
            _artwork.image = metadata.artwork
        }
        _titleLabel.text = metadata.title
        _detailLabel.text = metadata.artist + " ─ " + metadata.album
    }
    
    @objc func selectorCheckAudioInformation(_ sender: UIButton) {
        layoutPlayButton()
    }
}
