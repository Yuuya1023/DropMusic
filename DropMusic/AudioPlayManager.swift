//
//  AudioPlayManager.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation
import AVFoundation

class AudioPlayManager {
    
    static let sharedManager = AudioPlayManager()
    private init() {
    }
    
    var _audioPlayer: AVAudioPlayer!
    
    enum RepeatType {
        case one
        case list
    }
    
    var _playing: AudioData?
    var _history: [AudioData] = []
    var _queue: [AudioData] = []
    
    var _assetData: AVAsset?
    
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
    
    func play(audioData: AudioData) {
        let cachePath = DownloadFileManager.sharedManager.getCachePath(storageType: audioData._storageType, add: "/audio")
        let fileName = audioData.localFileName()
        let url = URL(fileURLWithPath: cachePath+"/"+fileName)
        
        _assetData = AVAsset(url: url)
        if _assetData == nil {
            return
        }
        _playing = audioData
        
        

        do {
            // AVAudioPlayerのインスタンス化
            _audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            // AVAudioPlayerのデリゲートをセット
//            audioPlayer.delegate = self

            // 音声の再生
            _audioPlayer.prepareToPlay()
            _audioPlayer.play()
            
            settingRpeat()
        } catch {
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
    
}
