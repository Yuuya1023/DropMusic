//
//  AudioData.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

//import UIKit

struct AudioData: Codable {
    
    enum StorageType:Int,Codable {
        case None = 0
        case DropBox = 1
    }

    var id: String = ""
    var fileName: String = ""
    var storageType: StorageType = .None
    var path: String = ""
    var extensionString: String = ""
    
    // MARK: - static
    static func createFromFileInfo(fileInfo: FileInfo) -> (AudioData?) {
        var ret: AudioData = AudioData()
        if !fileInfo.isFile() { return ret }
        
        ret.id = fileInfo.id()!
        ret.fileName = fileInfo.name()
        ret.storageType = .DropBox
        ret.path = fileInfo.pathLower()
        ret.extensionString = fileInfo.fileExtension()!
        
        return ret
    }
    
    
    // MARK: -
    func isEqualData(audioData: AudioData?) ->(Bool){
        return id == audioData?.id
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
