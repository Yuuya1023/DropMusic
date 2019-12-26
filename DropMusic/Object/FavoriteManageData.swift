//
//  FavoriteManageData.swift
//  DropMusic
//
//  Copyright © 2019年 n.yuuya. All rights reserved.
//

import Foundation

class FavoriteManageData: Codable {
    
    //
    // MARK: - Properties.
    //
    var folder: Array<FavoriteData> = []
    var audio: Array<FavoriteData> = []
    
    
    
    //
    // MARK: -
    //
    func isFavorite(_ path: String) -> Bool {
        for item in folder {
            if path == item.path  {
                return true
            }
        }
        for item in audio {
            if path == item.path  {
                return true
            }
        }
        return false
    }
    
}
