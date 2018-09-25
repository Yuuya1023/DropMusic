//
//  PlayListManager.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation

class PlayListManager {
    
    // MARK: - singleton
    static let sharedManager = PlayListManager()
    private init() {
        _manageData = PlayListManageData()
    }
    
    // MARK: -
    var _manageData: PlayListManageData!
    let _savePath: String! = DownloadFileManager.sharedManager.getCachePath(storageType: .DropBox, add: "") + "/" + JSON_NAME_PLAYLIST
    
    
    // MARK: -
    func setManageData(data: PlayListManageData) {
        _manageData = data
    }
    
    func addPlaylist() {
        let latestId = String(Int(_manageData.latestId)!+1)
        _manageData.playlists.append(PlayListData(id: latestId,
                                                  name: "Playlist_" + String(Int(_manageData.latestId)!+1),
                                                  audioList: []))
        _manageData.latestId = latestId
        _manageData.version = String(Int(_manageData.version)!+1)
    }
    
    func deletePlaylist(id: String) {
        
    }
    
    func save() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(_manageData)
            try data.write(to: URL(fileURLWithPath: _savePath))
        } catch {
            print("json convert failed in JSONEncoder", error.localizedDescription)
        }
        
    }
}
