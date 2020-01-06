//
//  MusicPlayerViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import TwitterKit
import MediaPlayer
import MarqueeLabel

class MusicPlayerViewController: UIViewController {
    
    @IBOutlet var _effectView: UIVisualEffectView!

    @IBOutlet var _artwork: UIImageView!

    @IBOutlet var _playButton: UIButton!
    @IBOutlet var _nextButton: UIButton!

    @IBOutlet var _seakBar: UISlider!
    @IBOutlet var _currentTimeLabel: UILabel!
    @IBOutlet var _durationLabel: UILabel!

    @IBOutlet var _repeatButton: UIButton!
    @IBOutlet var _shuffleButton: UIButton!
    
    @IBOutlet var _menuButton: UIButton!
    @IBOutlet var _twitterButton: UIButton!
    
    @IBOutlet var _titleView: UIView!
    @IBOutlet var _artistView: UIView!
    var _titleLabel: MarqueeLabel!
    var _artistLabel: MarqueeLabel!
    
    @IBOutlet var _airPlayView: UIView!
    
    var _timer: Timer = Timer()
    
    override func loadView() {
        let nib = UINib(nibName: "MusicPlayerView", bundle: .main)
        self.view = nib.instantiate(withOwner: self).first as? UIView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        // nibNameにはxibファイル名が入る。
//        let view:UIView = UINib(nibName: "MusicPlayerView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
//
//        // 呼び出したコントローラーのviewに設定する
//        self.view.addSubview(view)
        
//        self.view.backgroundColor = UIColor.clear
        
        // アートワーク.
        _artwork.contentMode = .scaleAspectFit
        _artwork.layer.shadowOpacity = 0.5
        _artwork.layer.shadowOffset = CGSize(width: 10, height: 10)
        // 曲名.
        _titleLabel = MarqueeLabel(frame: CGRect(x:0,
                                                 y:0,
                                                 width:_titleView.bounds.width,
                                                 height:_titleView.bounds.height),
                                   duration: 10,
                                   fadeLength: 10)
        _titleLabel.animationDelay = 2.0
        _titleLabel.textAlignment = .center
        _titleLabel.font = UIFont.systemFont(ofSize: 30)
        _titleView.addSubview(_titleLabel)
        // アーティスト.
        _artistLabel = MarqueeLabel(frame: CGRect(x:0,
                                                  y:0,
                                                  width:_artistView.bounds.width,
                                                  height:_artistView.bounds.height),
                                   duration: 10,
                                   fadeLength: 10)
        _artistLabel.animationDelay = 2.0
        _artistLabel.textAlignment = .center
        _artistLabel.textColor = UIColor(displayP3Red: 90/255, green: 90/255, blue: 255/255, alpha: 1)
        _artistView.addSubview(_artistLabel)
        
        do {
            // シークバーまわり.
            _seakBar.setThumbImage(UIImage(), for: .normal)
//            _seakBar.setThumbImage(UIColor.blue.circleImage(width: 20, height: 20), for: .normal)
            
            _currentTimeLabel.font = UIFont.systemFont(ofSize: 12)
            _currentTimeLabel.textAlignment = .center
            _currentTimeLabel.textColor = UIColor.gray
            _currentTimeLabel.text = "0:00"
            
            _durationLabel.font = UIFont.systemFont(ofSize: 12)
            _durationLabel.textAlignment = .center
            _durationLabel.textColor = UIColor.gray
            _durationLabel.text = "0:00"
        }
        
        do {
            _playButton.setImage(UIImage(named: AudioPlayManager.sharedManager.isPlaying() ? "pause.png" : "play.png"), for: .normal)
            _playButton.addTarget(self, action: #selector(selectorPlayButton(_:)), for: .touchUpInside)

            _nextButton.addTarget(self, action: #selector(selectorNextButton(_:)), for: .touchUpInside)
        }
        
        do {
            // メニュー.
            _menuButton.addTarget(self, action: #selector(selectorMenuButton(_:)), for: .touchUpInside)
            
            // リピート.
            switch AudioPlayManager.sharedManager._repeatType {
            case .One:
                _repeatButton.setImage(UIImage(named: "icon_repeat_one.png"), for: .normal)
            case .List:
                _repeatButton.setImage(UIImage(named: "icon_repeat.png"), for: .normal)
            }
            _repeatButton.addTarget(self, action: #selector(selectorRepeatButton(_:)), for: .touchUpInside)
            
            // シャッフル.
            switch AudioPlayManager.sharedManager._shuffleType {
            case .None:
                _shuffleButton.setImage(UIImage(named: "icon_nonshuffle.png"), for: .normal)
            case .List:
                _shuffleButton.setImage(UIImage(named: "icon_shuffle.png"), for: .normal)
            }
            _shuffleButton.addTarget(self, action: #selector(selectorShuffleButton(_:)), for: .touchUpInside)
            
            // ツイート.
            _twitterButton.addTarget(self, action: #selector(selectorTwitterButton(_:)), for: .touchUpInside)
            let tapGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(
                target: self,
                action: #selector(selectorLongpressTwitterButton(_:)))
            _twitterButton.addGestureRecognizer(tapGesture)
        }
        
        do {
            // AirPlay.
            if #available(iOS 11.0, *) {
                let view = AVRoutePickerView()
                view.frame = CGRect(x:0,
                                    y:0,
                                    width:_airPlayView.bounds.width,
                                    height:_airPlayView.bounds.height)
                _airPlayView.addSubview(view)
            } else {
                // Fallback on earlier versions
            }
        }
        
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
        // 曲監視.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(selectorDidChangeAudio),
                                               name: NSNotification.Name(rawValue: NOTIFICATION_DID_CHANGE_AUDIO),
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
        guard let metadata = AudioPlayManager.sharedManager._metadata else {
            return
        }
        // 曲情報.
        _titleLabel.text = metadata.title
        _artistLabel.text = metadata.artist + " ─ " + metadata.album
        if metadata.artwork == nil {
            _artwork.image = UIImage()
        }
        else {
            _artwork.image = metadata.artwork
        }
        let min = AudioPlayManager.sharedManager._duration/60
        let sec = AudioPlayManager.sharedManager._duration%60
        _durationLabel.text = String(min) + ":" + String(format: "%02d", sec)

        // 再生ボタン.
        layoutPlayButton()
    }
    
    func layoutPlayButton() {
        _playButton.setImage(UIImage(named: AudioPlayManager.sharedManager.isPlaying() ? "pause.png" : "play.png"), for: .normal)
    }
    
    
    func postTwitter(withImage: Bool) {
        guard let metadata = AudioPlayManager.sharedManager._metadata else {
            return
        }

        func tweet() {
            let twitter = TWTRComposer()
            twitter.setText(metadata.title + " ─ " + metadata.artist + "\n#DJさとし")
            if withImage && metadata.artwork != nil {
                twitter.setImage(_artwork.image)
            }
            twitter.show(from: self, completion: nil)
        }

        if TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers() {
            tweet()
        }
        else {
            TWTRTwitter.sharedInstance().logIn { success, error in
                if let _ = success {
                    tweet()
                }
            }
        }
    }
    
    
    // MARK: -
    @objc func selectorPlayButton(_ sender: UIButton) {
        if AudioPlayManager.sharedManager.isPlaying() {
            AudioPlayManager.sharedManager.pause()
        }
        else {
            _ = AudioPlayManager.sharedManager.play()
        }
        layoutPlayButton()
    }
    
    @objc func selectorNextButton(_ sender: UIButton) {
        AudioPlayManager.sharedManager.playNext()
        layoutUpdate()
    }
    
    @objc func selectorBackButton(_ sender: UIButton) {
        AudioPlayManager.sharedManager.playBack()
        layoutUpdate()
    }
    
    @objc func selectorRepeatButton(_ sender: UIButton) {
        let next: AudioPlayManager.RepeatType
        let type = AudioPlayManager.sharedManager._repeatType
        switch type {
        case .One:
            next = .List
        case .List:
            next = .One
        }

        switch next {
        case .One:
            _repeatButton.setImage(UIImage(named: "icon_repeat_one.png"), for: .normal)
        case .List:
            _repeatButton.setImage(UIImage(named: "icon_repeat.png"), for: .normal)
        }
        AudioPlayManager.sharedManager._repeatType = next
    }
    
    @objc func selectorShuffleButton(_ sender: UIButton) {
        let next: AudioPlayManager.ShuffleType
        let type = AudioPlayManager.sharedManager._shuffleType
        switch type {
        case .None:
            next = .List
        case .List:
            next = .None
        }

        switch next {
        case .None:
            _shuffleButton.setImage(UIImage(named: "icon_nonshuffle.png"), for: .normal)
        case .List:
            _shuffleButton.setImage(UIImage(named: "icon_shuffle.png"), for: .normal)
        }
        AudioPlayManager.sharedManager._shuffleType = next
    }
    
    @objc func selectorMenuButton(_ sender: UIButton) {
        guard let playing = AudioPlayManager.sharedManager._playing else {
            return
        }
        let alert: UIAlertController = UIAlertController(title: playing.fileName,
                                                         message: nil,
                                                         preferredStyle: .actionSheet)
        // プレイリストに追加.
        let playlistAction:UIAlertAction =
            UIAlertAction(title: "Add to playlist",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            let playlistvc = PlayListSelectViewController()
                            playlistvc.setAudioData(data: playing)
                            let vc = UINavigationController(rootViewController: playlistvc)
                            vc.modalTransitionStyle = .coverVertical
                            self.present(vc, animated: true, completion: nil)

            })
        // キャンセル.
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            // 閉じるだけ.
            })
        
        alert.addAction(playlistAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func selectorTwitterButton(_ sender: UIButton) {
        postTwitter(withImage: true)
    }
    
    @objc func selectorLongpressTwitterButton(_ sender: UILongPressGestureRecognizer) {
        postTwitter(withImage: false)
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
    
    
    @objc func selectorDidChangeAudio(_ notification: Notification) {
        layoutUpdate()
    }
}
