//
//  MusicPlayerViewControlloer.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import AVFoundation
import TwitterKit
import MediaPlayer

class MusicPlayerViewControlloer: UIViewController {
    
    var _effectView: UIVisualEffectView!
    
    var _titleLabel: UILabel = UILabel()
    var _albumLabel: UILabel = UILabel()
    var _artistLabel: UILabel = UILabel()
    var _artwork: UIImageView = UIImageView()
    
    var _playButton: UIButton = UIButton()
    var _seakBar: UISlider = UISlider()
    var _currentTimeLabel: UILabel = UILabel()
    var _durationLabel: UILabel = UILabel()
    
    var _repeatButton: UIButton = UIButton()
    var _playlistButton: UIButton = UIButton()
    var _twitterButton: UIButton = UIButton()
    
    var _timer: Timer = Timer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.clear
        
        _effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        _effectView.frame = self.view.bounds
        self.view.addSubview(_effectView)
        
        _artwork.frame = CGRect(x:self.view.bounds.width/2 - 125, y:80, width:250, height:250)
        _artwork.contentMode = .scaleAspectFit
        self.view.addSubview(_artwork)
        
        _titleLabel.frame = CGRect(x:0, y:330, width:self.view.bounds.width, height:30)
        _titleLabel.textAlignment = .center
        _titleLabel.font = UIFont.systemFont(ofSize: 30)
        self.view.addSubview(_titleLabel)
        
        _artistLabel.frame = CGRect(x:0, y:370, width:self.view.bounds.width, height:30)
        _artistLabel.textAlignment = .center
        self.view.addSubview(_artistLabel)
        
        _albumLabel.frame = CGRect(x:0, y:390, width:self.view.bounds.width, height:30)
        _albumLabel.textAlignment = .center
        self.view.addSubview(_albumLabel)
        
        _seakBar.frame = CGRect(x:self.view.bounds.width/2 - 120, y:430, width:240, height:5)
        _seakBar.setThumbImage(UIColor.blue.circleImage(width: 20, height: 20), for: .normal)
        self.view.addSubview(_seakBar)
        
        _currentTimeLabel.frame = CGRect(x:0, y:417, width:40, height:30)
        _currentTimeLabel.font = UIFont.systemFont(ofSize: 12)
        _currentTimeLabel.textAlignment = .center
        _currentTimeLabel.textColor = UIColor.gray
        _currentTimeLabel.text = "0:00"
        self.view.addSubview(_currentTimeLabel)
        
        _durationLabel.frame = CGRect(x:280, y:417, width:40, height:30)
        _durationLabel.font = UIFont.systemFont(ofSize: 12)
        _durationLabel.textAlignment = .center
        _durationLabel.textColor = UIColor.gray
        _durationLabel.text = "0:00"
        self.view.addSubview(_durationLabel)
        
        _playButton.setImage(UIImage(named: "play.png"), for: .normal)
        _playButton.frame = CGRect(x:self.view.bounds.width/2 - 20, y:450, width:40, height:40)
        _playButton.addTarget(self, action: #selector(selectorPlayButton(_:)), for: .touchUpInside)
        self.view.addSubview(_playButton)
        
        let y = 510
        _repeatButton.setImage(UIImage(named: "icon_repeat_one.png"), for: .normal)
        _repeatButton.frame = CGRect(x:30, y:y, width:40, height:40)
        _repeatButton.addTarget(self, action: #selector(selectorRepeatButton(_:)), for: .touchUpInside)
        self.view.addSubview(_repeatButton)
        
        _playlistButton.setImage(UIImage(named: "icon_playlist.png"), for: .normal)
        _playlistButton.frame = CGRect(x:180, y:y, width:40, height:40)
        _playlistButton.addTarget(self, action: #selector(selectorPlaylistButton(_:)), for: .touchUpInside)
        self.view.addSubview(_playlistButton)
        
        _twitterButton.setImage(UIImage(named: "icon_twitter.png"), for: .normal)
        _twitterButton.frame = CGRect(x:250, y:y, width:40, height:40)
        _twitterButton.addTarget(self, action: #selector(selectorTwitterButton(_:)), for: .touchUpInside)
        self.view.addSubview(_twitterButton)
        
        
        // 進捗の監視.
        _timer = Timer.scheduledTimer(timeInterval: 1.0,
                                      target: self,
                                      selector: #selector(selectorProgressCheck),
                                      userInfo: nil,
                                      repeats: true)
        // イヤホン接続監視.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(selectorAudioSessionRouteChanged),
                                               name: NSNotification.Name.AVAudioSessionRouteChange,
                                               object: nil)
        
        // 進捗の更新.
        selectorProgressCheck()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        layoutUpdate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -
    func layoutUpdate() {
        let audioManager = AudioPlayManager.sharedManager
        let assetData = audioManager._assetData
        if assetData == nil {
            return
        }
        
        // 曲情報.
        _titleLabel.text = audioManager._title
        _albumLabel.text = audioManager._album
        _artistLabel.text = audioManager._artist
        if audioManager._artwork == nil {
            _artwork.image = UIImage()
        }
        else {
            _artwork.image = audioManager._artwork
        }
        let min = audioManager._duration/60
        let sec = audioManager._duration%60
        _durationLabel.text = String(min) + ":" + String(format: "%02d", sec)
        
        // 再生ボタン.
        layoutPlayButton()
    }
    
    func layoutPlayButton() {
        if AudioPlayManager.sharedManager.isPlaying() {
            _playButton.setImage(UIImage(named: "pause.png"), for: .normal)
        }
        else {
            _playButton.setImage(UIImage(named: "play.png"), for: .normal)
        }
    }
    
    
    
    // MARK: -
    @objc func selectorPlayButton(_ sender: UIButton) {
        if AudioPlayManager.sharedManager.isPlaying() {
            AudioPlayManager.sharedManager.pause()
        }
        else {
            AudioPlayManager.sharedManager.play()
        }
        layoutPlayButton()
    }
    
    @objc func selectorRepeatButton(_ sender: UIButton) {
        let next: AudioPlayManager.RepeatType
        let type = AudioPlayManager.sharedManager._repeatType
        switch type {
        case .one:
            next = .list
        case .list:
            next = .one
        }
        
        switch next {
        case .one:
            _repeatButton.setImage(UIImage(named: "icon_repeat_one.png"), for: .normal)
        case .list:
            _repeatButton.setImage(UIImage(named: "icon_repeat.png"), for: .normal)
        }
        
        AudioPlayManager.sharedManager._repeatType = next
    }
    
    @objc func selectorPlaylistButton(_ sender: UIButton) {
        
    }
    
    @objc func selectorTwitterButton(_ sender: UIButton) {
        if AudioPlayManager.sharedManager._assetData == nil {
            return
        }
        
        func tweet() {
            let twitter = TWTRComposer()
            twitter.setText( _titleLabel.text! + " - " + _artistLabel.text! + "\n#DJさとし")
            if _artwork.image != nil {
                let image = _artwork.image?.resizeImage(reSize: CGSize(width: 128, height: 128))
                twitter.setImage(image)
            }
            twitter.show(from: self, completion: nil)
        }
        
        if TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers() {
            tweet()
        }
        else {
            TWTRTwitter.sharedInstance().logIn { success, error in
//                print(success)
//                print(error)
                tweet()
            }
        }
    }
    
    @objc func selectorProgressCheck() {
        let player = AudioPlayManager.sharedManager._audioPlayer
        if player != nil {
            let current = Double((player?.currentTime)!)
            let duration = Double(AudioPlayManager.sharedManager._duration)
            let v = current/duration
            _seakBar.setValue(Float(v), animated: true)
            
            let min = Int(current)/60
            let sec = Int(current)%60
            _currentTimeLabel.text = String(min) + ":" + String(format: "%02d", sec)
        }
    }
    
    @objc func selectorAudioSessionRouteChanged(_ notification: Notification) {
        let reasonObj = (notification as NSNotification).userInfo![AVAudioSessionRouteChangeReasonKey] as! NSNumber
        if let reason = AVAudioSessionRouteChangeReason(rawValue: reasonObj.uintValue) {
            switch reason {
            case .newDeviceAvailable:
                break
            case .oldDeviceUnavailable:
                AudioPlayManager.sharedManager.pause()
                layoutPlayButton()
                break
            default:
                break
            }
        }
    }
}
