//
//  PlayListData.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation

struct PlayListData: Codable {
    
    var id: String = ""
    var name: String = ""
    var audioList: Array<AudioData> = []
    
    func tracks() -> (Int) {
        return audioList.count
    }
}
