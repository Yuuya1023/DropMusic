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
    
    //
    // MARK: - Outlets.
    //
    @IBOutlet var _effectView: UIVisualEffectView!
    @IBOutlet var _infoTitle: UILabel!
    @IBOutlet var _artwork: UIImageView!
    @IBOutlet var _playButton: UIButton!
    @IBOutlet var _nextButton: UIButton!
    @IBOutlet var _playlistButton: UIButton!
    @IBOutlet var _favoriteButton: UIButton!
    @IBOutlet var _seakBar: UISlider!
    @IBOutlet var _currentTimeLabel: UILabel!
    @IBOutlet var _durationLabel: UILabel!
    @IBOutlet var _repeatButton: UIButton!
    @IBOutlet var _shuffleButton: UIButton!
    @IBOutlet var _menuButton: UIButton!
    @IBOutlet var _twitterButton: UIButton!
    @IBOutlet var _titleView: UIView!
    @IBOutlet var _artistView: UIView!
    @IBOutlet var _airPlayView: UIView!
    
    
    
    //
    // MARK: - Properties.
    //
    private var _titleLabel: MarqueeLabel!
    private var _artistLabel: MarqueeLabel!
    private var _timer: Timer = Timer()
    private let _color: UIColor = UIColor(displayP3Red: 29/255, green: 70/255, blue: 143/255, alpha: 0.8)
    
    
    
    //
    // MARK: - Override.
    //
    override func loadView() {
        let nib = UINib(nibName: "MusicPlayerView", bundle: .main)
        self.view = nib.instantiate(withOwner: self).first as? UIView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        _titleLabel.font = UIFont(name: "Avenir Heavy", size: 30.0)
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
        _artistLabel.font = UIFont(name: "Avenir Book", size: 17.0)
        _artistLabel.textColor = _color
        _artistView.addSubview(_artistLabel)
        
        // シークバーまわり.
        _seakBar.setThumbImage(UIImage(), for: .normal)
        
        // 再生ボタン.
        updatePlayButton()
        _playButton.addTarget(self, action: #selector(selectorPlayButton(_:)), for: .touchUpInside)
        
        // ネクストボタン.
        _nextButton.addTarget(self, action: #selector(selectorNextButton(_:)), for: .touchUpInside)
        
        // プレイリストボタン.
        updatePlaylistButton()
        _playlistButton.addTarget(self, action: #selector(selectorPlaylistButton(_:)), for: .touchUpInside)
        
        // お気に入りボタン.
        _favoriteButton.addTarget(self, action: #selector(selectorFavoriteButton(_:)), for: .touchUpInside)
        
        // メニュー.
        updateMenuButton()
        _menuButton.addTarget(self, action: #selector(selectorMenuButton(_:)), for: .touchUpInside)
        
        // リピート.
        updateRepeatButton()
        _repeatButton.addTarget(self, action: #selector(selectorRepeatButton(_:)), for: .touchUpInside)
        
        // シャッフル.
        updateShuffleButton()
        _shuffleButton.addTarget(self, action: #selector(selectorShuffleButton(_:)), for: .touchUpInside)
        
        // ツイート.
        updateTwitterButton()
        _twitterButton.addTarget(self, action: #selector(selectorTwitterButton(_:)), for: .touchUpInside)
        let tapGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(selectorLongpressTwitterButton(_:)))
        _twitterButton.addGestureRecognizer(tapGesture)
        
        // AirPlay.
        if #available(iOS 11.0, *) {
            let view = AVRoutePickerView()
            view.tintColor = _color
            view.activeTintColor = AppColor.accent
            view.frame = CGRect(x:0,
                                y:0,
                                width:_airPlayView.bounds.width,
                                height:_airPlayView.bounds.height)
            _airPlayView.addSubview(view)
        } else {
            // Fallback on earlier versions
        }
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateFavoriteButton()
        updateLayout()
        if !_timer.isValid {
            _timer = Timer.scheduledTimer(timeInterval: 1.0 / 30.0,
                                          target: self,
                                          selector: #selector(update),
                                          userInfo: nil,
                                          repeats: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if _timer.isValid {
            _timer.invalidate()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //
    // MARK: - Private.
    //
    /// 更新.
    @objc private func update() {
        updateProgress()
    }
    
    /// レイアウト更新.
    private func updateLayout() {
        guard let metadata = AudioPlayManager.sharedManager._metadata else {
            return
        }
        // info.
        _infoTitle.text = AudioPlayManager.sharedManager._manageData.makeTitle()
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
        updatePlayButton()
    }
    
    /// 再生ボタン更新.
    private func updatePlayButton() {
        _playButton.setImage(UIImage(named: AudioPlayManager.sharedManager.isPlaying() ? "pause.png" : "play.png"),
                             for: .normal)
    }
    
    /// 進捗更新.
    private func updateProgress() {
        guard let player = AudioPlayManager.sharedManager.audioPlayer else {
            _seakBar.setValue(0.0, animated: false)
            _currentTimeLabel.text = "0:00"
            _durationLabel.text = "0:00"
            return
        }
        let current = Double((player.currentTime))
        let duration = Double(AudioPlayManager.sharedManager._duration)
        let v = current/duration
        _seakBar.setValue(Float(v), animated: true)
        
        let min = Int(current)/60
        let sec = Int(current)%60
        _currentTimeLabel.text = String(min) + ":" + String(format: "%02d", sec)
    }
    
    /// リピートボタン更新.
    private func updateRepeatButton() {
        switch AudioPlayManager.sharedManager._repeatType {
        case .One:
            _repeatButton.setImage(UIImage(named: "icon_repeat_one.png")?.withRenderingMode(.alwaysTemplate),
                                   for: .normal)
        case .All:
            _repeatButton.setImage(UIImage(named: "icon_repeat.png")?.withRenderingMode(.alwaysTemplate),
                                   for: .normal)
        }
        _repeatButton.imageView?.tintColor = _color
    }
    
    /// シャッフルボタン更新.
    private func updateShuffleButton() {
        switch AudioPlayManager.sharedManager._shuffleType {
        case .None:
            _shuffleButton.setImage(UIImage(named: "icon_nonshuffle.png")?.withRenderingMode(.alwaysTemplate),
                                    for: .normal)
        case .All:
            _shuffleButton.setImage(UIImage(named: "icon_shuffle.png")?.withRenderingMode(.alwaysTemplate),
                                    for: .normal)
        }
        _shuffleButton.imageView?.tintColor = _color
    }
    
    /// メニューボタン更新.
    private func updateMenuButton() {
        _menuButton.setImage(UIImage(named: "icon_menu.png")?.withRenderingMode(.alwaysTemplate),
                             for: .normal)
        _menuButton.imageView?.tintColor = _color
    }
    
    /// twitterボタン更新.
    private func updateTwitterButton() {
        _twitterButton.setImage(UIImage(named: "twitter.png")?.withRenderingMode(.alwaysTemplate),
                                for: .normal)
        _twitterButton.imageView?.tintColor = _color
    }
    
    /// プレイリストボタン更新.
    private func updatePlaylistButton() {
        _playlistButton.setImage(UIImage(named: "icon_playlist_plus.png")?.withRenderingMode(.alwaysTemplate),
                                for: .normal)
        _playlistButton.imageView?.tintColor = _color
    }
    
    /// お気に入りボタン更新.
    private func updateFavoriteButton() {
        guard let playing = AudioPlayManager.sharedManager._playing else {
            return
        }
        var color: UIColor = .lightGray
        if AppDataManager.sharedManager.favorite.isFavorite(playing) {
            color = AppColor.accent
        }
        _favoriteButton.setImage(UIImage(named: "icon_favorite.png")?.withRenderingMode(.alwaysTemplate),
                                for: .normal)
        _favoriteButton.imageView?.tintColor = color
    }
    
    /// twitter投稿.
    private func postTwitter(withImage: Bool) {
        updateTwitterButton()
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
            TWTRTwitter.sharedInstance().logIn { (session, error) in
                if let session = session {
                    UserDefaults.standard.set(session.userName, forKey: USER_DEFAULT_TWITTER_NAME)
                    tweet()
                }
            }
        }
    }
    
    
    
    //
    // MARK: -
    //
    @objc func selectorPlayButton(_ sender: UIButton) {
        if AudioPlayManager.sharedManager.isPlaying() {
            AudioPlayManager.sharedManager.pause()
        }
        else {
            _ = AudioPlayManager.sharedManager.play()
        }
        updatePlayButton()
    }
    
    @objc func selectorNextButton(_ sender: UIButton) {
        AudioPlayManager.sharedManager.playNext()
        updateLayout()
    }
    
    @objc func selectorBackButton(_ sender: UIButton) {
        AudioPlayManager.sharedManager.playBack()
        updateLayout()
    }
    
    @objc func selectorPlaylistButton(_ sender: UIButton) {
        updatePlaylistButton()
        guard let playing = AudioPlayManager.sharedManager._playing else {
            return
        }
        let playlistvc = PlayListSelectViewController()
        playlistvc.setAudioData(data: playing)
        let vc = UINavigationController(rootViewController: playlistvc)
        vc.modalTransitionStyle = .coverVertical
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func selectorFavoriteButton(_ sender: UIButton) {
        guard let playing = AudioPlayManager.sharedManager._playing else {
            return
        }
        if AppDataManager.sharedManager.favorite.isFavorite(playing) {
            AppDataManager.sharedManager.favorite.deleteFavorite(playing)
        }
        else {
            AppDataManager.sharedManager.favorite.addFavorite(playing)
        }
        AppDataManager.sharedManager.save()
        updateFavoriteButton()
    }
    
    @objc func selectorRepeatButton(_ sender: UIButton) {
        let next: AudioPlayStatus.RepeatType
        let type = AudioPlayManager.sharedManager._repeatType
        switch type {
        case .One:
            next = .All
        case .All:
            next = .One
        }
        
        AudioPlayManager.sharedManager._repeatType = next
        updateRepeatButton()
    }
    
    @objc func selectorShuffleButton(_ sender: UIButton) {
        let next: AudioPlayStatus.ShuffleType
        let type = AudioPlayManager.sharedManager._shuffleType
        switch type {
        case .None:
            next = .All
        case .All:
            next = .None
        }
        AudioPlayManager.sharedManager._shuffleType = next
        updateShuffleButton()
    }
    
    @objc func selectorMenuButton(_ sender: UIButton) {
        updateMenuButton()
        guard let playing = AudioPlayManager.sharedManager._playing else {
            return
        }
        let alert: UIAlertController = UIAlertController(title: playing.fileName,
                                                         message: nil,
                                                         preferredStyle: .actionSheet)
        // プレイリストに追加.
        alert.addAction(
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
        )
        // キャンセル.
        alert.addAction(
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            // 閉じるだけ.
            })
        )
        present(alert, animated: true, completion: nil)
    }
    
    @objc func selectorTwitterButton(_ sender: UIButton) {
        postTwitter(withImage: true)
    }
    
    @objc func selectorLongpressTwitterButton(_ sender: UILongPressGestureRecognizer) {
        postTwitter(withImage: false)
    }
    
    @objc func selectorAudioSessionRouteChanged(_ notification: Notification) {
        let reasonObj = (notification as NSNotification).userInfo![AVAudioSessionRouteChangeReasonKey] as! NSNumber
        if let reason = AVAudioSessionRouteChangeReason(rawValue: reasonObj.uintValue) {
            switch reason {
            case .newDeviceAvailable:
                break
            case .oldDeviceUnavailable:
                AudioPlayManager.sharedManager.pause()
                updatePlayButton()
                break
            default:
                break
            }
        }
    }
    
    @objc func selectorDidChangeAudio(_ notification: Notification) {
        updateLayout()
    }
}
