//
//  AudioPlayManager.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import MediaPlayer

class AudioPlayManager: NSObject, AVAudioPlayerDelegate {
    
    static let sharedManager = AudioPlayManager()
    
    var _audioPlayer: AVAudioPlayer!
    
    enum RepeatType {
        case one
        case list
    }
    
    var _playing: AudioData?
    var _history: [AudioData] = []
    var _queue: [AudioData] = []
    
    var _assetData: AVAsset?
    
    var _title: String = ""
    var _album: String = ""
    var _artist: String = ""
    var _artwork: UIImage? = nil
    var _duration: Int = 0
    
    
    
    // MARK: -
    private override init() {
        super.init()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let session = AVAudioSession.sharedInstance()
        
        // ロック中の設定.
        do {
//            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
        }
        catch let error as NSError {
            print(error.description)
        }
        
        // 他アプリでの再生時通知.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSecondaryAudio),
                                               name: .AVAudioSessionSilenceSecondaryAudioHint,
                                               object: AVAudioSession.sharedInstance())
        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(ViewController.handleInterruption(_:)),
//                                               name: NSNotification.Name.AVAudioSessionInterruption,
//                                               object: nil)
    }
    
    var _repeatType: RepeatType = .one {
        didSet(p){
            self.settingRpeat()
        }
    }
    
    func isPlaying() -> (Bool) {
        if _audioPlayer != nil {
            return _audioPlayer.isPlaying
        }
        return false
    }
    
    func set(audioData: AudioData) {
        let cachePath = DownloadFileManager.sharedManager.getCachePath(storageType: audioData._storageType, add: "/audio")
        let fileName = audioData.localFileName()
        let url = URL(fileURLWithPath: cachePath+"/"+fileName)
        
        // 同じのだったら再生しない.
        if _playing != nil {
            if (_playing?.isEqualData(audioData: audioData))! {
                return
            }
        }
        
        _assetData = AVAsset(url: url)
        if _assetData == nil {
            return
        }
        
        _playing = audioData
        
        
        // 曲情報の取得.
        _title = ""
        _album = ""
        _artist = ""
        _artwork = nil
        let metadata: Array = _assetData!.commonMetadata
        for item in metadata {
            switch item.commonKey {
            case AVMetadataKey.commonKeyTitle:
                _title = item.stringValue!
            case AVMetadataKey.commonKeyAlbumName:
                _album = item.stringValue!
            case AVMetadataKey.commonKeyArtist:
                _artist = item.stringValue!
            case AVMetadataKey.commonKeyArtwork:
                _artwork = UIImage(data: item.dataValue!)
            default:
                break
            }
        }
        
        do {
            _audioPlayer = try AVAudioPlayer(contentsOf: url)
            _audioPlayer.currentTime = 0
            _audioPlayer.delegate = self
            _audioPlayer.prepareToPlay()

            _duration = Int(_audioPlayer.duration)
            
            settingRpeat()
            
            // コントロールセンターの表示.
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: _title,
                MPMediaItemPropertyArtist : _artist,
                MPMediaItemPropertyAlbumTitle: _album,
                MPNowPlayingInfoPropertyPlaybackRate : NSNumber(value: 1.0), //再生レート
                MPMediaItemPropertyPlaybackDuration : NSNumber(value: _duration) //シークバー
            ]
            if _artwork != nil {
                MPNowPlayingInfoCenter.default().nowPlayingInfo![MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: _artwork!)
            }
            // 曲が変更されたことを通知.
            NotificationCenter.default.post(name: Notification.Name(NOTIFICATION_DID_CHANGE_AUDIO), object: nil)
            
        } catch {
        }
    }
    
    func play() {
        if _audioPlayer != nil {
            if !_audioPlayer.isPlaying {
                _audioPlayer.play()
            }
        }
    }
    
    func pause() {
        if _audioPlayer != nil {
            if _audioPlayer.isPlaying {
                _audioPlayer.pause()
            }
        }
    }
    
    func settingRpeat() {
        switch _repeatType {
        case .one:
            _audioPlayer?.numberOfLoops = -1
        case .list:
            _audioPlayer?.numberOfLoops = 0
            // キューの生成.
        }
    }
    
    @objc func handleSecondaryAudio(notification: Notification) {
        // ヒントの種類を判定
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt,
            let type = AVAudioSessionSilenceSecondaryAudioHintType(rawValue: typeValue) else {
                return
        }
        
        if type == .begin {
            // 他のアプリケーションが再生を開始したため副次的なオーディオを消音.
            print("begin")
            _audioPlayer.volume = 0.5
        } else {
            // 他のアプリケーションが再生を停止したため副次的なオーディオを再開.
            print("end")
            _audioPlayer.volume = 1.0
        }
    }
    
    // MARK: -
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: 1.0)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
    
}
