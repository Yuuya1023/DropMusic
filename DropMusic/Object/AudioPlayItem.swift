//
//  AudioPlayItem.swift
//  DropMusic
//
//  Copyright © 2020 n.yuuya. All rights reserved.
//

import Foundation

struct AudioPlayItem: Codable {

    //
    // MARK: - Properties.
    //
    var audioData: AudioData?
    var selectType: AudioPlayStatus.AudioSelectType = .None
    var selectValue: String = ""
    
    
    
    //
    // MARK: - Public.
    //
    func isEqual(_ item: AudioPlayItem) -> Bool {
        if let audioData = audioData {
            return audioData.isEqualData(audioData: item.audioData)
        }
        return false
    }
    
}
