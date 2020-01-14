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
    private var list: Array<FavoriteData> = []
    
    
    
    //
    // MARK: - Public.
    //
    /// お気に入りか.
    func isFavorite(_ fileInfo: FileInfo) -> Bool {
        for item in list {
            if fileInfo.pathDisplay() == item.path  {
                return true
            }
        }
        return false
    }
    
    /// お気に入りか.
    func isFavorite(_ favoriteData: FavoriteData) -> Bool {
        for item in list {
            if favoriteData.path == item.path  {
                return true
            }
        }
        return false
    }
    
    /// お気に入りに追加.
    func addFavorite(_ fileInfo: FileInfo) {
        if !isFavorite(fileInfo) {
            if let data = FavoriteData.createFromFileInfo(fileInfo) {
                list.append(data)
            }
        }
    }
    
    /// お気に入りから削除.
    func deleteFavorite(_ fileInfo: FileInfo) {
        if isFavorite(fileInfo) {
            for i in 0..<list.count {
                if list[i].path == fileInfo.pathDisplay() {
                    list.remove(at: i)
                    return
                }
            }
        }
    }
    
    /// お気に入りから削除.
    func deleteFavorite(_ favoriteData: FavoriteData) {
        for i in 0..<list.count {
            if list[i].path == favoriteData.path {
                list.remove(at: i)
                return
            }
        }
    }
    
    /// 一覧取得.
    func getList(_ type: AppManageData.FileType) -> Array<FavoriteData> {
        var ret: Array<FavoriteData> = []
        for item in list {
            if type == item.fileType {
                ret.append(item)
            }
        }
        return ret
    }
    
    
    
    //
    // MARK: - Private.
    //
    
    
}
