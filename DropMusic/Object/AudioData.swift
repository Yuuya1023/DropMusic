//
//  AudioData.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

struct AudioData: Codable {
    
    //
    // MARK: - Properties.
    //
    fileprivate(set) var id: String = ""
    fileprivate(set) var fileName: String = ""
    fileprivate(set) var storageType: AppManageData.StorageType = .None
    fileprivate(set) var path: String = ""
    fileprivate(set) var extensionString: String = ""
    
    
    
    //
    // MARK: - Static.
    //
    static func createFromFileInfo(_ fileInfo: FileInfo) -> AudioData? {
        guard fileInfo.getType() == .Audio else {
            return nil
        }
        
        var ret: AudioData = AudioData()
        ret.id = fileInfo.id
        ret.fileName = fileInfo.name
        ret.storageType = .DropBox
        ret.path = fileInfo.path
        ret.extensionString = fileInfo.fileExtension()!
        
        return ret
    }
    
    static func createFromFavorite(_ favoriteData: FavoriteData) -> AudioData? {
        guard favoriteData.fileType == .Audio else {
            return nil
        }
        
        var ret: AudioData = AudioData()
        ret.id = favoriteData.fileId
        ret.fileName = favoriteData.name
        ret.storageType = .DropBox
        ret.path = favoriteData.path
        ret.extensionString = favoriteData.extensionString
        
        return ret
    }
    
    //
    // MARK: - Public.
    //
    func isEqualData(audioData: AudioData?) -> Bool {
        guard let audioData = audioData else {
            return false
        }
        return id == audioData.id
    }
    
    func localFileName() -> String {
        var _id = self.id
        if let range = _id.range(of: "id:") {
            _id.replaceSubrange(range, with: "")
        }
        return _id + "." + extensionString
    }
    
    func fullPath() -> String {
        return self.path
    }
    
}
