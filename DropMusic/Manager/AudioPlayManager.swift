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
    
    //
    // MARK: - Singleton.
    //
    static let sharedManager = AudioPlayManager()
    
    
    
    //
    // MARK: - Properties
    //
    private let USER_DEFAULT_KEY = "audio"
    private let MAX_HISTORY_LENGTH: Int = 32
    private let MIN_QUEUE_LENGTH: Int = 2

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
    
    var _metadata: AudioMetadata?
    var _duration: Int = 0
    
    
    
    //
    // MARK: -
    //
    private override init() {
        super.init()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let session = AVAudioSession.sharedInstance()
        
        // ロック中の設定.
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
        }
        catch let error as NSError {
            print(error.description)
        }
        
        // 前回再生していた曲情報を取得.
        do {
            let decoder: JSONDecoder = JSONDecoder()
            let defaults = UserDefaults.standard
            if let data = defaults.data(forKey: USER_DEFAULT_KEY) {
                let audioData = try decoder.decode(AudioData.self, from: data)
                set(audioData: audioData, isRefresh: false)
            }
        } catch {
            print("json convert failed in JSONDecoder", error.localizedDescription)
        }
        
        // 停止通知.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: .AVAudioSessionInterruption,
                                               object: nil)
    }
    
    /// 再生中か.
    func isPlaying() -> (Bool) {
        if _audioPlayer != nil {
            return _audioPlayer.isPlaying
        }
        return false
    }
    
    /// 曲を設定.
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
    
    /// 曲を設定.
    func set(audioData: AudioData?, isRefresh: Bool) {
        guard let audioData = audioData else {
            return
        }
        let cachePath = DownloadFileManager.sharedManager.getFileCachePath(audioData: audioData)
        let url = URL(fileURLWithPath: cachePath)
        
        if !FileManager.default.fileExists(atPath: cachePath) {
            return
        }
        // 同じのだったら再生しない.
        if _playing != nil {
            if (_playing?.isEqualData(audioData: audioData))! {
                return
            }
        }
        // 履歴に追加.
        addHistory(_playing)
        // 再生中を保持.
        _playing = audioData
        // 曲情報を保存.
        do {
            let encoder = JSONEncoder()
            let data = try! encoder.encode(_playing)
            let defaults = UserDefaults.standard
            defaults.set(data, forKey: USER_DEFAULT_KEY)
        }
        // 曲情報の取得.
        _metadata = MetadataCacheManager.sharedManager.get(audioData: audioData)
        do {
            _audioPlayer = try AVAudioPlayer(contentsOf: url)
            _audioPlayer.currentTime = 0
            _audioPlayer.delegate = self
            _audioPlayer.prepareToPlay()
            _duration = Int(_audioPlayer.duration)
        
            settingRpeat()
            updateCheckQueue(isRefresh: isRefresh)
        
            // コントロールセンター表示.
            updateInfoCenter()
            // 曲が変更されたことを通知.
            NotificationCenter.default.post(name: Notification.Name(NOTIFICATION_DID_CHANGE_AUDIO), object: nil)
        
        } catch {
        }
    }
    
    /// コントロールセンターの表示更新.
    func updateInfoCenter() {
        guard let metadata = _metadata else {
            return
        }
        guard let player = _audioPlayer else {
            return
        }
        var info = [String : Any]()
        info[MPMediaItemPropertyTitle] = metadata.title
        info[MPMediaItemPropertyArtist] = metadata.artist
        info[MPMediaItemPropertyAlbumTitle] = metadata.album
        
        let image = metadata.artwork ?? UIImage()
        info[MPMediaItemPropertyArtwork] =
            MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
        }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        info[MPMediaItemPropertyPlaybackDuration] = player.duration
        info[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        // Set the metadata.
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    /// 再生.
    func play() -> (Bool) {
        if _audioPlayer != nil {
            if !_audioPlayer.isPlaying {
                _audioPlayer.play()
                MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = _audioPlayer.currentTime
                MPNowPlayingInfoCenter.default().nowPlayingInfo![MPMediaItemPropertyPlaybackDuration] = _audioPlayer.duration
                MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = _audioPlayer.rate
                return true
            }
        }
        return false
    }
    
    /// 次へ.
    func playNext() {
        if _queue.count == 0 {
            set(audioData:_playing!, isRefresh: false)
        }
        else {
            let d = _queue[0]
            set(audioData: d, isRefresh: false)
            _queue.remove(at: 0)
        }
        _ = play()
    }
    
    /// 前へ.
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
        _ = play()
    }
    
    /// 停止.
    func pause() {
        if _audioPlayer != nil {
            if _audioPlayer.isPlaying {
                _audioPlayer.pause()
                MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = _audioPlayer.currentTime
                MPNowPlayingInfoCenter.default().nowPlayingInfo![MPMediaItemPropertyPlaybackDuration] = _audioPlayer.duration
                MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = _audioPlayer.rate
            }
        }
    }
    
    
    
    //
    // MARK: - private function
    //
    /// リピート設定.
    private func settingRpeat() {
        switch _repeatType {
        case .One:
            _audioPlayer.numberOfLoops = 0
        case .List:
            _audioPlayer.numberOfLoops = 0
        }
    }
    
    /// シャッフル設定.
    private func settingShuffle() {
        updateCheckQueue(isRefresh: true)
    }
    
    /// 履歴に追加.
    private func addHistory(_ d: AudioData?) {
        guard let d = d else {
            return
        }
        _history.insert(d, at: 0)
        
        // 多すぎるので消す.
        if _history.count > MAX_HISTORY_LENGTH {
            _history.removeLast()
        }
    }
    
    /// キューに追加.
    private func addQueue(add: Array<AudioData>!, exlusion: AudioData?) {
        var temp: Array<AudioData> = add
        if exlusion != nil {
            // 同じデータを見つけて削除.
            for i in 0..<add.count {
                if add[i].isEqualData(audioData: exlusion) {
                    temp.remove(at: i)
                    break
                }
            }
        }
        // ファイルが存在しない楽曲を候補から除外
        var list: Array<AudioData> = []
        for i in 0..<temp.count {
            let d = temp[i]
            if DownloadFileManager.sharedManager.isExistAudioFile(audioData: d) {
                list.append(d)
            }
        }
        // 追加.
        _queue = _queue + list
    }
    
    /// リフレッシュするときは初回作成時なのでプレイ中を含めない、しないときはループが一周したときなのでプレイ中の曲を含める.
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
    
    
    
    //
    // MARK: - handle interruption.
    //
    /// 再生終了検知.
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            // Interruption began, take appropriate actions
        }
        else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSessionInterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Interruption Ended - playback should resume
                    if _audioPlayer != nil {
                        _audioPlayer.play()
                    }
                } else {
                    // Interruption Ended - playback should NOT resume
                }
            }
        }
    }
    
    //
    // MARK: - AVAudioPlayer Delegate.
    //
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        switch _repeatType {
        case .One:
            _audioPlayer.currentTime = 0
            _audioPlayer.play()
            // コントロールセンター表示.
            updateInfoCenter()
        case .List:
            // 次へ.
            playNext()
        }
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    }
    
}
