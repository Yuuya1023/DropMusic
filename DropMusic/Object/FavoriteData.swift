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
    var fileId: String = ""
    var fileType: AppManageData.FileType = .None
    var storageType: AppManageData.StorageType = .None
    var name: String = ""
    var path: String = ""
    var extensionString: String = ""
    
    
    
    //
    // MARK: -
    //
    static func createFromFileInfo(_ fileInfo: FileInfo) -> FavoriteData? {
        var ret = FavoriteData()
        ret.fileId = ""
        if let id = fileInfo.id() {
            ret.fileId = id
        }
        ret.fileType = fileInfo.getFileType()
        ret.storageType = .DropBox
        ret.name = fileInfo.name()
        ret.path = fileInfo.pathLower()
        ret.extensionString = ""
        if let str = fileInfo.fileExtension() {
            ret.extensionString = str
        }
        return ret
    }
    
    
    
    //
    // MARK: -
    //
    /// パス配列作成.
    func createPathList() -> Array<String> {
        return path.components(separatedBy: "/")
    }
    
}
