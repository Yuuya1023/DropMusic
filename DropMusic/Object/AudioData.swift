//
//  AudioData.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

//import UIKit

struct AudioData {
    
    enum StorageType {
        case DropBox
    }

    var _id: String
    var _storageType: StorageType
    var _name: String
    var _path: String
    var _hash: String
    var _extension: String
    
    func isEqualData(audioData: AudioData?) ->(Bool){
        return _id == audioData?._id
    }
    
    func localFileName() ->(String){
        var id = _id
        if let range = id.range(of: "id:") {
            id.replaceSubrange(range, with: "")
        }
        return id + "." + _extension
    }
    
//    func localSavePath() ->(String){
//        
//        return ""
//    }
    
    func fullPath() -> (String){
        return _path
    }
    
}
