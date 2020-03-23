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
    // MARK: - Constant.
    //
    private let MAX_HISTORY_LENGTH: Int = 64
    private let MIN_QUEUE_LENGTH: Int = 16
    
    
    
    //
    // MARK: - Properties.
    //
    private(set) var _audioPlayer: AVAudioPlayer!
    private(set) var _playing: AudioData?
    private(set) var _metadata: AudioMetadata?
    private(set) var _manageData: AudioPlayStatus = AudioPlayStatus()
    private(set) var _duration: Int = 0
    private(set) var _deviceName: String = ""
    
    private var _beginData: AudioData?
    private var _history: Array<AudioData> = []
    private var _queue: Array<AudioData> = []
    
    var repeatType: AudioPlayStatus.RepeatType {
        get {
            _manageData.repeatType
        }
        set {
            _manageData.repeatType = newValue
            self.settingRepeat()
        }
    }
    var shuffleType: AudioPlayStatus.ShuffleType {
        get {
            return _manageData.shuffleType
        }
        set {
            _manageData.shuffleType = newValue
            self.settingShuffle()
        }
    }
    
    
    
    //
    // MARK: - Override.
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
        
        // 前回の設定を引き継ぐ.
        if let data = UserDefaults.standard.data(forKey: USER_DEFAULT_AUDIO_STATUS) {
            if let manageData = AudioPlayStatus.makeFromData(data: data) {
                _manageData = manageData
            }
        }
        
        // 前回再生していた曲情報を取得.
        do {
            if let data = UserDefaults.standard.data(forKey: USER_DEFAULT_PLAY_AUDIO) {
                let audioData = try JSONDecoder().decode(AudioData.self, from: data)
                _beginData = audioData
                setAudio(audioData: audioData, isAddHistory: false, isRefresh: false)
            }
        } catch {
            print("json convert failed in JSONDecoder", error.localizedDescription)
        }
        
        // 停止通知.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: .AVAudioSessionInterruption,
                                               object: nil)
        // 接続デバイス検知.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAudioRouteChange),
                                               name: .AVAudioSessionRouteChange,
                                               object: nil)
    }
    
    
    
    //
    // MARK: - Public.
    //
    /// 再生中か.
    func isPlaying() -> (Bool) {
        if _audioPlayer != nil {
            return _audioPlayer.isPlaying
        }
        return false
    }
    
    /// 曲を設定.
    func set(selectType: AudioPlayStatus.AudioSelectType,
             selectPath: String,
             audioList: Array<AudioData>,
             playIndex: Int)
    {
        if _manageData.isChanged(selectType: selectType, selectName: selectPath) {
            // 選択した場所が変わった場合は新しいリストを保存しておく.
            _manageData.selectType = selectType
            _manageData.selectName = selectPath
            _manageData.setAudioList(audioList)
        }
        if audioList.indices.contains(playIndex) {
            // 初回選択されたデータを保存.
            _beginData = audioList[playIndex]
            // 再生.
            setAudio(audioData: audioList[playIndex], isAddHistory: true, isRefresh: true)
        }
    }
    
    /// 再生.
    func play() -> Bool {
        if !isPlaying() {
            _audioPlayer.play()
            updateInfoCenter()
            return true
        }
        return false
    }
    
    /// 次へ.
    func playNext(isContinuePlay: Bool) {
        if _queue.count == 0 {
            setAudio(audioData:_playing!, isAddHistory: false, isRefresh: false)
        }
        else {
            // キュー操作.
            let d = _queue[0]
            setAudio(audioData: d, isAddHistory: true, isRefresh: false)
            _queue.remove(at: 0)
        }
        if isContinuePlay {
            _ = play()
        }
    }
    
    /// 前へ.
    func playBack() {
        // 変更前の再生状況を確認しておく.
        let playing = isPlaying()
        
        if _history.count == 0 {
            setAudio(audioData:_playing!, isAddHistory: false, isRefresh: false)
        }
        else {
            // キューに追加.
            if let playing = _playing {
                _queue.insert(playing, at: 0)
            }
            // 履歴操作.
            let d = _history[0]
            setAudio(audioData: d, isAddHistory: false, isRefresh: false)
            _history.remove(at: 0)
        }
        if playing {
            _ = play()
        }
    }
    
    /// 停止.
    func pause() {
        if isPlaying() {
            _audioPlayer.pause()
            updateInfoCenter()
        }
    }
    
    /// 再生状況を保存.
    func saveStatus() {
        // 曲情報.
        do {
            let data = try JSONEncoder().encode(_playing)
            UserDefaults.standard.set(data, forKey: USER_DEFAULT_PLAY_AUDIO)
        }
        catch{
        }
        // 再生情報.
        do {
            let data = try JSONEncoder().encode(_manageData)
            UserDefaults.standard.set(data, forKey: USER_DEFAULT_AUDIO_STATUS)
        }
        catch{
        }
    }
    
    
    
    //
    // MARK: - Private.
    //
    /// 曲を設定.
    private func setAudio(audioData: AudioData?, isAddHistory: Bool, isRefresh: Bool) {
        guard let audioData = audioData else {
            return
        }
        let cachePath = DownloadFileManager.sharedManager.getFileCachePath(audioData: audioData)
        let url = URL(fileURLWithPath: cachePath)
        
        if !FileManager.default.fileExists(atPath: cachePath) {
            return
        }
        // 同じのだったら再生しない.
        if let playing =  _playing {
            if playing.isEqualData(audioData: audioData) {
                return
            }
        }
        
        // 履歴に追加.
        if isAddHistory {
            addHistory(_playing)
        }
        // 再生中を保持.
        _playing = audioData
        // 曲情報の取得.
        _metadata = MetadataCacheManager.sharedManager.get(audioData: audioData)
        do {
            _audioPlayer = try AVAudioPlayer(contentsOf: url)
//            _audioPlayer.isMeteringEnabled = true
            _audioPlayer.currentTime = 0
            _audioPlayer.delegate = self
            _audioPlayer.prepareToPlay()
            _duration = Int(_audioPlayer.duration)
            
            settingRepeat()
            updateCheckQueue(isRefresh: isRefresh)
            
            // コントロールセンター表示.
            updateInfoCenter()
            // 曲が変更されたことを通知.
            NotificationCenter.default.post(name: Notification.Name(NOTIFICATION_DID_CHANGE_AUDIO), object: nil)
        } catch {
        }
    }
    
    /// コントロールセンターの表示更新.
    private func updateInfoCenter() {
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
    
    /// リピート設定.
    private func settingRepeat() {
        switch _manageData.repeatType {
        case .One:
            _audioPlayer.numberOfLoops = 0
        case .All:
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
    private func addQueue(_ add: Array<AudioData>) {
        // ファイルが存在しない楽曲を候補から除外
        var list: Array<AudioData> = []
        for d in add {
            if DownloadFileManager.sharedManager.isExistAudioFile(audioData: d) {
                list.append(d)
            }
        }
        // 追加.
        _queue = _queue + list
    }
    
    /// キューの残数を確認して再生候補を積む.
    private func updateCheckQueue(isRefresh: Bool) {
        if isRefresh {
            _queue.removeAll()
        }
        // キューの残数が多い時はなにもしない.
        if _queue.count > MIN_QUEUE_LENGTH { return }
        
        let add = _manageData.makeQueList(exlusion: _beginData)
        if add.count == 0 { return }
        
        // 追加.
        addQueue(add)
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
    // MARK: - handle AudioRouteChange.
    //
    @objc func handleAudioRouteChange(notification: Notification) {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        for output in currentRoute.outputs {
            switch output.portType {
            case AVAudioSessionPortAirPlay,
                 AVAudioSessionPortHeadphones,
                 AVAudioSessionPortBluetoothA2DP,
                 AVAudioSessionPortBluetoothLE,
                 AVAudioSessionPortBluetoothHFP:
                // 接続機器がある場合、機器名をもっておく.
                _deviceName = output.portName
                return
            
            default:
                break
            }
        }
        _deviceName = ""
    }
    
    
    
    //
    // MARK: - AVAudioPlayer Delegate.
    //
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        switch repeatType {
        case .One:
            _audioPlayer.currentTime = 0
            _audioPlayer.play()
            // コントロールセンター表示.
            updateInfoCenter()
        case .All:
            // 次へ.
            playNext(isContinuePlay: true)
        }
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    }
    
}
