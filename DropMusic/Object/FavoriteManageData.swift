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
    private var folder: Array<FavoriteData> = []
    private var audio: Array<FavoriteData> = []
    
    
    
    //
    // MARK: - Public.
    //
    /// お気に入りか.
    func isFavorite(_ fileInfo: FileInfo) -> Bool {
        if fileInfo.isFolder() {
            for item in folder {
                if fileInfo.pathLower() == item.path  {
                    return true
                }
            }
        }
        else if fileInfo.isFile() {
            for item in audio {
                if fileInfo.pathLower() == item.path  {
                    return true
                }
            }
        }
        return false
    }
    
    /// お気に入りに追加.
    func addFavorite(_ fileInfo: FileInfo) {
        if !isFavorite(fileInfo) {
            if let data = FavoriteData.createFromFileInfo(fileInfo) {
                if fileInfo.isFolder() {
                    folder.append(data)
                }
                else if fileInfo.isFile() {
                    audio.append(data)
                }
            }
        }
    }
    
    /// お気に入りから削除.
    func deleteFavorite(_ fileInfo: FileInfo) {
        if isFavorite(fileInfo) {
            if fileInfo.isFolder() {
                for i in 0..<folder.count {
                    if folder[i].path == fileInfo.pathLower() {
                        folder.remove(at: i)
                        return
                    }
                }
            }
            else if fileInfo.isFile() {
                for i in 0..<audio.count {
                    if audio[i].path == fileInfo.pathLower() {
                        audio.remove(at: i)
                        return
                    }
                }
            }
        }
    }
    
    
    
    //
    // MARK: - Private.
    //
    
    
}
