//
//  DropboxFileListManager.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation

class DropboxFileListManager {
    
    static let sharedManager = DropboxFileListManager()
    private init() {
    }
    
    var _pathDictionary: Dictionary = [String: Array<FileInfo>]()
    
    
    
    func get(pathLower: String) -> (Array<FileInfo>?){
        return _pathDictionary[pathLower]
    }
    
    func regist(pathLower: String, list: Array<FileInfo>){
        if get(pathLower: pathLower) == nil {
            _pathDictionary.updateValue(list, forKey: pathLower)
        }
    }
    
    func update(pathLower: String, list: Array<FileInfo>){
        _pathDictionary.updateValue(list, forKey: pathLower)
    }
    
}
