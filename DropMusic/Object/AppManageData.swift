//
//  AppManageData.swift
//  DropMusic
//
//  Copyright © 2019年 n.yuuya. All rights reserved.
//

import Foundation

struct AppManageData: Codable {
    
    //
    // MARK: - Enumeration.
    //
    enum StorageType:Int,Codable {
        case None = 0
        case DropBox = 1
    }
    
    enum FileType:Int,Codable {
        case None = 0
        case Folder = 1
        case Audio = 2
        case Other = 99
    }
    
    
    
    //
    // MARK: - Properties.
    //
    var version: String = "0"
    var playlist: PlayListManageData = PlayListManageData()
    var favorite: FavoriteManageData = FavoriteManageData()
    
    
    
    //
    // MARK: - Static.
    //
    static func makeFromFile(path: String) -> AppManageData? {
        if let data = NSData(contentsOfFile: path) {
            let decoder: JSONDecoder = JSONDecoder()
            do {
                let newJson: AppManageData = try decoder.decode(AppManageData.self, from: data as Data)
                return newJson
            } catch {
                print("json convert failed in JSONDecoder", error.localizedDescription)
            }
        }
        return nil
    }
    
    
    
    //
    // MARK: - Public.
    //
    func writeFile(fileURLWithPath: String) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            try data.write(to: URL(fileURLWithPath: fileURLWithPath))
        } catch {
            print("json convert failed in JSONEncoder", error.localizedDescription)
        }
    }
    
}
