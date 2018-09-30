//
//  PlayListManager.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation
import SwiftyDropbox

class PlayListManager {
    
    // MARK: - singleton
    static let sharedManager = PlayListManager()
    private init() {
        _manageData = PlayListManageData()
    }
    
    
    
    // MARK: -
    var isLoaded: Bool = false
    private var _manageData: PlayListManageData!
    var playlistManageData: PlayListManageData! {
        get {
            return _manageData
        }
    }
    private let _savePath: String! = DownloadFileManager.sharedManager.getCachePath(storageType: .DropBox, add: "") + "/" + JSON_NAME_PLAYLIST
    
    private let _playlistFilePath: String = "/DropMusic/"
    private let _localTempPlaylistFilePath = DownloadFileManager.sharedManager.getCachePath(storageType: .DropBox, add: "") + "/temp_" + JSON_NAME_PLAYLIST
    
    
    
    // MARK: -
    //
    private func setManageData(data: PlayListManageData) {
        _manageData = data
        isLoaded = true
    }
    
    
    //
    func addPlaylist() {
        let latestId = String(Int(_manageData.latestId)!+1)
        _manageData.playlists.append(PlayListData(id: latestId,
                                                  name: "Playlist_" + String(Int(_manageData.latestId)!+1),
                                                  audioList: []))
        _manageData.latestId = latestId
        _manageData.version = String(Int(_manageData.version)!+1)
    }
    
    
    //
    func deletePlaylist(id: String) {
        
    }
    
    
    //
    func save() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(_manageData)
            try data.write(to: URL(fileURLWithPath: _savePath))
        } catch {
            print("json convert failed in JSONEncoder", error.localizedDescription)
        }
    }
    
    
    
    // MARK: - LoadPlayList.
    // プレイリストファイルの確認.
    func checkPlaylistFile() {
        isLoaded = false
        if DropboxClientsManager.authorizedClient == nil {
            return
        }
        let localFile = loadPlaylistData(path: _savePath)
        
        // 保存先.
        let destination : (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            let path = self._localTempPlaylistFilePath
            return URL(fileURLWithPath: path)
        }
        
        // tempがあれば削除しておく.
        do {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: self._localTempPlaylistFilePath))
        }
        catch {}
        
        if let client = DropboxClientsManager.authorizedClient {
            client.files.download(path: self._playlistFilePath+JSON_NAME_PLAYLIST, destination: destination).response { response, error in
                if let (metadata, url) = response {
                    print("Downloaded file name: \(metadata.name)")
                    print(url)
                    let tempData = self.loadPlaylistData(path: self._localTempPlaylistFilePath)
                    if localFile != nil {
                        // ローカルにある場合はバージョンのチェック.
                        if Int(tempData!.version)! > Int(localFile!.version)! {
                            // サーバーの方が上の場合はtempを使う.
                            self.setManageData(data: tempData!)
                            self.save()
                        }
                        else {
                            self.setManageData(data: localFile!)
                        }
                    }
                    else {
                        // ない場合は保存.
                        self.setManageData(data: tempData!)
                        self.save()
                    }
                } else {
                    print(error!)
                    //                    if let callError = error {
                    //                        switch callError {
                    //                        case .clientError(let _clientError):
                    //                            print(_clientError)
                    //                        case .routeError(let _routeError):
                    //                            print("route error")
                    //                        default :
                    //                            print("unknown error")
                    //                        }
                    //                    }
                    // エラー判定したい.
                    //                    print(error?.description)
                    
                    if localFile != nil {
                        // ローカルにある場合はとりあえず読み込んでおく.
                        self.setManageData(data: localFile!)
                    }
                    else {
                        // プレイリストファイルがなかったら作成してアップロード.
                        self.createPlaylist()
                    }
                }
            }
        }
    }
    
    
    // プレイリストファイルの読み込み.
    private func loadPlaylistData(path: String) -> (PlayListManageData?) {
        if let data = NSData(contentsOfFile: path) {
            let decoder: JSONDecoder = JSONDecoder()
            do {
                let newJson: PlayListManageData = try decoder.decode(PlayListManageData.self, from: data as Data)
                print(newJson) //Success!!!
                return newJson
            } catch {
                print("json convert failed in JSONDecoder", error.localizedDescription)
            }
        }
        return nil
    }
    
    
    // プレイリストの初回作成.
    private func createPlaylist(){
        let playlist = PlayListManager.sharedManager._manageData
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(playlist)
        //
        if let client = DropboxClientsManager.authorizedClient {
            client.files.upload(path: self._playlistFilePath+JSON_NAME_PLAYLIST, mode: .add, autorename: false, clientModified: nil, mute: false, propertyGroups: nil, input: data).response { response, error in
                if let metadata = response {
                    // 成功したら再チェック.
                    self.checkPlaylistFile()
                } else {
                    print(error!)
                }
            }
        }
    }
}
