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

    var _id: Int
    var _storageType: StorageType
    var _name: String
    var _path: String
    var _hash: String
}
