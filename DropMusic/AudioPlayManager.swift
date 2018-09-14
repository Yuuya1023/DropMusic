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
    
    var _playing: AudioData?
    var _history: [AudioData] = []
    var _queue: [AudioData] = []
    
    var _assetData: AVAsset?
    
    
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
        } catch {
        }
    }
    
}
