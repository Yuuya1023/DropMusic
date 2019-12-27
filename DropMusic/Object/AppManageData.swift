//
//  AppManageData.swift
//  DropMusic
//
//  Copyright © 2019年 n.yuuya. All rights reserved.
//

import Foundation

struct AppManageData: Codable {
    
    //
    // MARK: - Enumeration.
    //
    enum StorageType:Int,Codable {
        case None = 0
        case DropBox = 1
    }
    
    enum FileType:Int,Codable {
        case None = 0
        case Folder = 1
        case Audio = 2
        case Other = 99
    }
    
    
    
    //
    // MARK: - Properties.
    //
    var version: String = "0"
    var playlist: PlayListManageData = PlayListManageData()
    var favorite: FavoriteManageData = FavoriteManageData()
    
}
