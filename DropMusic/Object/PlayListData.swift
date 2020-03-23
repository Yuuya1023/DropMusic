//
//  PlayListData.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation

struct PlayListData: Codable {
    
    //
    // MARK: - Properties.
    //
    var id: String = ""
    var name: String = ""
    var audioList: Array<AudioData> = []
    
    
    
    //
    // MARK: - Public.
    //
    /// 曲数.
    func tracks() -> Int {
        return audioList.count
    }
    
    /// ひとつめの楽曲データを取得.
    func getHeadData() -> AudioData? {
        if tracks() > 0 {
            return audioList[0]
        }
        return nil
    }
    
    /// 楽曲が入っているか.
    func isIncludeAudio(audioId: String) -> Bool {
        for d in audioList {
            if d.id == audioId {
                return true
            }
        }
        return false
    }
    
    /// 楽曲追加.
    mutating func addAudio(audioData: AudioData) {
        if !isIncludeAudio(audioId: audioData.id) {
            audioList.append(audioData)
        }
    }
    
    /// 楽曲削除
    mutating func removeAudio(audioId: String) {
        for i in 0..<audioList.count {
            if audioList[i].id == audioId {
                audioList.remove(at: i)
                return
            }
        }
    }
    
}
