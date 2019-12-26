//
//  FavoriteData.swift
//  DropMusic
//
//  Copyright © 2019年 n.yuuya. All rights reserved.
//

import Foundation

struct FavoriteData: Codable {
    
    //
    // MARK: - Properties.
    //
    var path: String = ""
    
    
    
    //
    // MARK: -
    //
    static func createFromFileInfo(_ fileInfo: FileInfo) -> FavoriteData? {
        var ret = FavoriteData()
        ret.path = fileInfo.pathLower()
        
        return ret
    }
    
}
