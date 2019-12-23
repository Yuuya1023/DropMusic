//
//  DropboxFileListManager.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation

class DropboxFileListManager {
    
    //
    // MARK: - Singleton.
    //
    static let sharedManager = DropboxFileListManager()
    private init() {
    }
    
    
    
    //
    // MARK: - Properties.
    //
    private var _pathDictionary: Dictionary = [String: Array<FileInfo>]()
    
    
    
    //
    // MARK: -
    //
    /// ファイル一覧取得.
    func get(pathLower: String) -> (Array<FileInfo>?){
        return _pathDictionary[pathLower]
    }
    /// 削除.
    func remove(pathLower: String) {
        _pathDictionary.removeValue(forKey: pathLower)
    }
    /// 登録.
    func regist(pathLower: String, list: Array<FileInfo>){
        if get(pathLower: pathLower) == nil {
            update(pathLower: pathLower, list: list)
        }
    }
    /// 更新.
    func update(pathLower: String, list: Array<FileInfo>){
        _pathDictionary.updateValue(list, forKey: pathLower)
    }
}
