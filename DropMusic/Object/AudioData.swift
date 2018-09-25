//
//  AudioData.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

//import UIKit

struct AudioData: Codable {
    
    enum StorageType:Int,Codable {
        case DropBox = 1
    }

    var id: String
    var storageType: StorageType
    var name: String
    var path: String
    var hash: String
    var extensionString: String
    
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
