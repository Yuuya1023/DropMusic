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
            if fileInfo.path == item.path  {
                return true
            }
        }
        return false
    }
    
    /// お気に入りか.
    func isFavorite(_ audiodata: AudioData) -> Bool {
        for item in list {
            if item.fileType == .Audio {
                if audiodata.id == item.fileId {
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
                list.append(data)
            }
        }
    }
    
    /// お気に入りに追加.
    func addFavorite(_ audioData: AudioData) {
        if !isFavorite(audioData) {
            if let data = FavoriteData.createFromAudioData(audioData) {
                list.append(data)
            }
        }
    }
 
    /// お気に入りから削除.
    func deleteFavorite(_ fileInfo: FileInfo) {
        deleteFavorite(path: fileInfo.path)
    }
    
    /// お気に入りから削除.
    func deleteFavorite(_ favoriteData: FavoriteData) {
        deleteFavorite(path: favoriteData.path)
    }
    
    /// お気に入りから削除.
    func deleteFavorite(_ audioData: AudioData) {
        deleteFavorite(path: audioData.path)
    }
    
    /// 一覧取得.
    func getList(_ type: AppManageData.FileType) -> Array<FavoriteData> {
        var ret: Array<FavoriteData> = []
        for item in list {
            // 指定なしの場合は全部.
            if type == .None || type == item.fileType {
                ret.append(item)
            }
        }
        return ret
    }
    
    
    
    //
    // MARK: - Private.
    //
    private func deleteFavorite(path: String) {
        for i in 0..<list.count {
            if list[i].path == path {
                list.remove(at: i)
                return
            }
        }
    }
    
}
