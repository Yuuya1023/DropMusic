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
    fileprivate(set) var fileId: String = ""
    fileprivate(set) var fileType: AppManageData.FileType = .None
    fileprivate(set) var storageType: AppManageData.StorageType = .None
    fileprivate(set) var name: String = ""
    fileprivate(set) var path: String = ""
    fileprivate(set) var extensionString: String = ""
    
    
    
    //
    // MARK: - Static.
    //
    static func createFromFileInfo(_ fileInfo: FileInfo) -> FavoriteData? {
        var ret = FavoriteData()
        ret.fileId = fileInfo.id
        ret.fileType = fileInfo.getType()
        ret.storageType = .DropBox
        ret.name = fileInfo.name
        ret.path = fileInfo.path
        ret.extensionString = ""
        if let str = fileInfo.fileExtension() {
            ret.extensionString = str
        }
        return ret
    }
    
    static func createFromAudioData(_ audioData: AudioData) -> FavoriteData? {
        var ret = FavoriteData()
        ret.fileId = audioData.id
        ret.fileType = .Audio
        ret.storageType = .DropBox
        ret.name = audioData.fileName
        ret.path = audioData.path
        ret.extensionString = audioData.extensionString
        
        return ret
    }
    
    
    //
    // MARK: - Public.
    //
    /// パス配列作成.
    func createPathList() -> Array<String> {
        var ret = path.components(separatedBy: "/")
        // 空文字を削除.
        ret.removeAll { (str) -> Bool in
            if str == "" {
                return true
            }
            return false
        }
        return ret
    }
    
    /// 親フォルダ名取得.
    func getParentFolderName() -> String {
        var pathList = createPathList()
        pathList.removeLast()   // 最後のはフォルダ名なので消す.
        if pathList.count > 0 {
            if let str = pathList.last {
                return str
            }
        }
        return ""
    }
    
}
