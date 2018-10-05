//
//  MetadataCacheManager.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation

class MetadataCacheManager {
    
    // MARK: - singleton
    static let sharedManager = MetadataCacheManager()
    private init() {
    }

    
    
    // MARK: -
    private var datas: Dictionary<String, AudioMetadata>! = [:]
    
    
    
    // MARK: -
    func get(audioData: AudioData) -> AudioMetadata! {
        var ret: AudioMetadata? = datas[audioData.id]
        if ret != nil{
            return ret
        }

        // 見つからなかった.
        ret = AudioMetadata()
        let success = ret?.set(atPath: DownloadFileManager.sharedManager.getFileCachePath(audioData: audioData))
        if success! {
            datas[audioData.id] = ret
            return ret
        }
        return ret
    }
    
}
