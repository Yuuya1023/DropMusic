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
    var id: String = ""
    var fileName: String = ""
    var storageType: AppManageData.StorageType = .None
    var path: String = ""
    var extensionString: String = ""
    
    
    
    //
    // MARK: - Static
    //
    static func createFromFileInfo(fileInfo: FileInfo) -> (AudioData?) {
        guard fileInfo.isFile() else {
            return nil
        }
        
        var ret: AudioData = AudioData()
        ret.id = fileInfo.id()!
        ret.fileName = fileInfo.name()
        ret.storageType = .DropBox
        ret.path = fileInfo.pathLower()
        ret.extensionString = fileInfo.fileExtension()!
        
        return ret
    }
    
    
    
    //
    // MARK: -
    //
    func isEqualData(audioData: AudioData?) ->(Bool){
        guard let audioData = audioData else {
            return false
        }
        return id == audioData.id
    }
    
    func localFileName() ->(String){
        var _id = self.id
        if let range = _id.range(of: "id:") {
            _id.replaceSubrange(range, with: "")
        }
        return _id + "." + extensionString
    }
    
    func fullPath() -> (String){
        return self.path
    }
    
}
