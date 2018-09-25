//
//  PlayListManageData.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation

struct PlayListManageData: Codable {
    
    var updated: String = ""
    var latestId: String = "0"
    var version: String! = "0"
    var playlists: Array<PlayListData>! = []
    
}
