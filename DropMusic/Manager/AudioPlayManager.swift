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
    
    // MARK: -
    private let MAX_HISTORY_LENGTH: Int = 32
    private let MIN_QUEUE_LENGTH: Int = 2
    
    // MARK: -
    static let sharedManager = AudioPlayManager()
    
    var _audioPlayer: AVAudioPlayer!
    
    enum AudioSelectType {
        case None
        case Cloud
        case Playlist
    }
    
    enum RepeatType {
        case One
        case List
    }
    
    enum ShuffleType {
        case None
        case List
    }
    
    var _playing: AudioData?
    var _audioSelect: AudioSelectType = .None
    var _audioSelectPath: String = ""
    var _audioList: Array<AudioData> = []
    
    private var _history: Array<AudioData> = []
    private var _queue: Array<AudioData> = []
    
    var _repeatType: RepeatType = .One {
        didSet(p){
            self.settingRpeat()
        }
    }
    var _shuffleType: ShuffleType = .None {
        didSet(p){
            self.settingShuffle()
        }
    }
    
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
    
    func isPlaying() -> (Bool) {
        if _audioPlayer != nil {
            return _audioPlayer.isPlaying
        }
        return false
    }
    
    func set(selectType: AudioSelectType, selectPath: String, audioList: Array<AudioData>, playIndex: Int) {
        if _audioSelect != selectType || _audioSelectPath != selectPath {
            // 選択した場所が変わった場合はそこのリストを保存しておく.
            _audioSelect = selectType
            _audioSelectPath = selectPath
            _audioList = audioList
            // 再生.
            set(audioData: audioList[playIndex], isRefresh: true)
        }
        else {
            // 再生.
            set(audioData: audioList[playIndex], isRefresh: false)
        }
    }
    
    func set(audioData: AudioData, isRefresh: Bool) {
        let cachePath = DownloadFileManager.sharedManager.getCachePath(storageType: audioData.storageType, add: "/audio")
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
        
        // 履歴に追加.
        addHistory(_playing)
        // 再生中を保持.
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
            updateCheckQueue(isRefresh: isRefresh)
            
            // コントロールセンターの表示.
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [
                MPMediaItemPropertyTitle: _title,
                MPMediaItemPropertyArtist : _artist,
                MPMediaItemPropertyAlbumTitle: _album,
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
    
    func play() -> (Bool) {
        if _audioPlayer != nil {
            if !_audioPlayer.isPlaying {
                _audioPlayer.play()
                MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: 1.0)
                return true
            }
        }
        return false
    }
    
    func playNext() {
        if _queue.count == 0 {
            set(audioData:_playing!, isRefresh: false)
        }
        else {
            let d = _queue[0]
            set(audioData: d, isRefresh: false)
            _queue.remove(at: 0)
        }
        play()
    }
    
    func playBack() {
        if _history.count == 0 {
            set(audioData:_playing!, isRefresh: false)
        }
        else {
            _queue.insert(_playing!, at: 0)
            let d = _history[0]
            set(audioData: d, isRefresh: false)
            _history.remove(at: 0)
        }
        play()
    }
    
    func pause() {
        if _audioPlayer != nil {
            if _audioPlayer.isPlaying {
                _audioPlayer.pause()
            }
        }
    }
    
    // MARK: - private function
    private func settingRpeat() {
        switch _repeatType {
        case .One:
            _audioPlayer?.numberOfLoops = 0
        case .List:
            _audioPlayer?.numberOfLoops = 0
        }
    }
    
    private func settingShuffle() {
        updateCheckQueue(isRefresh: true)
    }
    
    private func addHistory(_ d: AudioData?) {
        if d == nil { return }
        _history.insert(d!, at: 0)
        
        // 多すぎるので消す.
        if _history.count > MAX_HISTORY_LENGTH {
            _history.removeLast()
        }
    }
    
    private func addQueue(add: Array<AudioData>!, exlusion: AudioData?) {
        var temp: Array<AudioData> = add
        if exlusion != nil {
            // 同じデータを見つけて削除.
            for i in 0..<add.count {
                let d = add[i]
                if d.isEqualData(audioData: exlusion) {
                    temp.remove(at: i)
                    break
                }
            }
        }
        // 追加.
        _queue = _queue + temp
        
    }
    
    // リフレッシュするときは初回作成時なのでプレイ中を含めない、しないときはループが一周したときなのでプレイ中の曲を含める.
    private func updateCheckQueue(isRefresh: Bool) {
        if _audioList.count == 0 { return }
        
        var exlusion: AudioData? = nil
        if isRefresh {
            exlusion = _playing
            _queue.removeAll()
        }
        // キューの残数が多い時はなにもしない.
        if _queue.count > MIN_QUEUE_LENGTH { return }
        
        let add: Array<AudioData>
        switch _shuffleType {
        case .None:
            if exlusion != nil {
                // プレイ中の曲から追加する.
                var temp: Array<AudioData> = []
                var flg: Bool = false
                for i in 0..<_audioList.count {
                    let d = _audioList[i]
                    if flg {
                        temp.append(d)
                    }
                    else {
                        if d.isEqualData(audioData: exlusion) {
                            flg = true
                        }
                    }
                }
                add = temp
            }
            else {
                add = _audioList
            }
        case .List:
            add = _audioList.shuffled
        }
        // 追加.
        addQueue(add: add, exlusion: exlusion)
        // もっかいチェック.
        updateCheckQueue(isRefresh: false)
    }
    
    
    
    
    // MARK: -
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
        switch _repeatType {
        case .One:
            _audioPlayer.currentTime = 0
            _audioPlayer.play()
            
            if _artwork != nil {
                MPNowPlayingInfoCenter.default().nowPlayingInfo![MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: _artwork!)
            }
            MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: 0.0)
        case .List:
            // 次へ.
            playNext()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
    
}
