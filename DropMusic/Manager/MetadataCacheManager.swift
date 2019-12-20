//
//  MetadataCacheManager.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation

class MetadataCacheManager {
    
    //
    // MARK: - Singleton.
    //
    static let sharedManager = MetadataCacheManager()
    private init() {
    }

    
    
    //
    // MARK: - Properties.
    //
    private var datas: Dictionary<String, AudioMetadata> = [:]
    
    
    
    //
    // MARK: -
    //
    /// 取得.
    func get(audioData: AudioData?) -> AudioMetadata? {
        guard let audioData = audioData else {
            return nil
        }
        if let metadata = datas[audioData.id] {
            return metadata
        }
        // 見つからなかった.
        let metadata = AudioMetadata()
        let success = metadata.set(atPath: DownloadFileManager.sharedManager.getFileCachePath(audioData: audioData))
        if success {
            datas[audioData.id] = metadata
            return metadata
        }
        return nil
    }
    
    /// 削除.
    func remove(audioData: AudioData!) {
        datas.removeValue(forKey: audioData.id)
    }
}
