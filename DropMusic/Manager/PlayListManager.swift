//
//  PlayListManager.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation
import SwiftyDropbox

class PlayListManager {
    
    //
    // MARK: - Singleton.
    //
    static let sharedManager = PlayListManager()
    private init() {
        _savePath = DownloadFileManager.sharedManager.getCachePath(storageType: .DropBox, add: "") + "/" + JSON_NAME_PLAYLIST
        _playlistFilePath = "/DropMusic/"
        _localTempPlaylistFilePath = DownloadFileManager.sharedManager.getCachePath(storageType: .DropBox, add: "") + "/temp_" + JSON_NAME_PLAYLIST
        _manageData = PlayListManageData()
    }
    
    
    
    //
    // MARK: - Properties.
    //
    var isLoaded: Bool = false
    private var _manageData: PlayListManageData!
    var playlistManageData: PlayListManageData! {
        get {
            return _manageData
        }
    }
    private let _savePath: String!
    private let _playlistFilePath: String!
    private let _localTempPlaylistFilePath: String!
    
    
    
    //
    // MARK: -
    //
    /// プレイリスト管理情報設定.
    private func setManageData(data: PlayListManageData) {
        _manageData = data
        isLoaded = true
    }

    /// プレイリストのインデックスを取得.
    private func getPlayListIndex(playListId: String) -> Int? {
        for i in 0..<_manageData.playlists.count {
            let d: PlayListData = _manageData.playlists[i]
            if d.id == playListId {
                return i
            }
        }
        return nil
    }
    
    /// プレイリスト情報取得.
    func getPlaylistData(id: String) -> (PlayListData?) {
        guard let index = getPlayListIndex(playListId: id) else {
            return nil
        }
        return _manageData.playlists[index]
    }
    
    /// プレイリストを追加.
    func addPlaylist(isSave: Bool = false) -> (String) {
        let latestId = String(Int(_manageData.latestId)!+1)
        _manageData.playlists.append(PlayListData(id: latestId,
                                                  name: "Playlist_" + latestId,
                                                  audioList: []))
        _manageData.latestId = latestId
        if isSave {
            save()
        }
        return latestId
    }

    /// プレイリストを更新.
    func updatePlaylist(id: String, name: String, isSave: Bool = false) {
        guard let index = getPlayListIndex(playListId: id) else {
            return
        }
        var playlist: PlayListData = _manageData.playlists[index]
        if playlist.id == id {
            if playlist.name != name {
                playlist.name = name
                _manageData.playlists[index] = playlist
                if isSave {
                    save()
                }
            }
            return
        }
    }
    
    /// プレイリストに楽曲が入っているか.
    func isIncludeAudio(playListId: String, data: AudioData) -> Bool {
        guard let index = getPlayListIndex(playListId: playListId) else {
            return false
        }
        let playlistData: PlayListData = _manageData.playlists[index]
        for i in 0..<playlistData.audioList.count {
            let d = playlistData.audioList[i]
            if d.id == data.id {
                return true
            }
        }
        return false
    }
    
    /// プレイリストの楽曲を追加.
    func addAudioToPlayList(playListId: String, addList: Array<AudioData>!, isSave: Bool = false) {
        if addList.count == 0 { return }

        guard let index = getPlayListIndex(playListId: playListId) else {
            return
        }
        var playlist: PlayListData = _manageData.playlists[index]
        if playlist.id == playListId {
            // 追加する曲リストの判定.
            var isAdd = false
            for i in 0..<addList.count {
                let addAudio = addList[i]
                if !isIncludeAudio(playListId: playListId, data: addAudio) {
                    isAdd = true
                    playlist.audioList = playlist.audioList + [addAudio]
                }
            }
            if isAdd && isSave {
                _manageData.playlists[index] = playlist
                save()
            }
        }
    }
    
    /// プレイリストから楽曲を削除.
    func deleteAudioFromPlayList(playListId: String, audioId: String, isSave: Bool = false) {
        guard let index = getPlayListIndex(playListId: playListId) else {
            return
        }
        var playlist: PlayListData = _manageData.playlists[index]
        for i in 0..<playlist.audioList.count {
            let d = playlist.audioList[i]
            if d.id == audioId {
                playlist.audioList.remove(at: i)
                _manageData.playlists[index] = playlist
                if isSave {
                    save()
                }
                return
            }
        }
    }
    
    /// プレイリスト削除.
    func deletePlaylist(id: String, isSave: Bool = false) {
        guard let index = getPlayListIndex(playListId: id) else {
            return
        }
        let d: PlayListData = _manageData.playlists[index]
        if d.id == id {
            _manageData.playlists.remove(at: index)
            if isSave {
                save()
            }
        }
    }
    
    /// 保存.
    func save() {
        // 保存する時にバージョンをあげる.
        _manageData.version = String(Int(_manageData.version)!+1)
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(_manageData)
            try data.write(to: URL(fileURLWithPath: _savePath))
        } catch {
            print("json convert failed in JSONEncoder", error.localizedDescription)
        }
    }
    
    
    //
    // MARK: - LoadPlayList.
    //
    /// プレイリストファイルの確認.
    func checkPlaylistFile() {
        isLoaded = false
        if DropboxClientsManager.authorizedClient == nil {
            return
        }
        let localFile = loadPlaylistData(path: _savePath)
        
        // 保存先.
        let destination : (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return URL(fileURLWithPath: self._localTempPlaylistFilePath)
        }
        
        // tempがあれば削除しておく.
        do {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: self._localTempPlaylistFilePath))
        }
        catch {}
        
        if let client = DropboxClientsManager.authorizedClient {
            client.files.download(path: self._playlistFilePath+JSON_NAME_PLAYLIST, destination: destination).response { response, error in
                if let (metadata, url) = response {
                    if let tempData = self.loadPlaylistData(path: self._localTempPlaylistFilePath) {
                        if let localFile = localFile {
                            // ローカルにある場合はバージョンのチェック.
                            if Int(tempData.version)! > Int(localFile.version)! {
                                // サーバーの方が上の場合はtempを使う.
                                self.setManageData(data: tempData)
                                self.save()
                            }
                            else {
                                self.setManageData(data: localFile)
                            }
                        }
                        else {
                            // ない場合は保存.
                            self.setManageData(data: tempData)
                            self.save()
                        }
                    }
                } else {
                    if let error = error {
                        print(error)
//                        if let callError = error {
//                            switch callError {
//                            case .clientError(let _clientError):
//                                print(_clientError)
//                            case .routeError(let _routeError):
//                                print("route error")
//                            default :
//                                print("unknown error")
//                            }
//                        }
//                        // エラー判定したい.
//                        print(error?.description)
                    }
                    
                    if let localFile = localFile {
                        // ローカルにある場合はとりあえず読み込んでおく.
                        self.setManageData(data: localFile)
                    }
                    else {
                        // プレイリストファイルがなかったら作成してアップロード.
                        self.createPlaylist()
                    }
                }
            }
        }
    }
    
    /// プレイリストファイルの読み込み.
    private func loadPlaylistData(path: String) -> (PlayListManageData?) {
        if let data = NSData(contentsOfFile: path) {
            let decoder: JSONDecoder = JSONDecoder()
            do {
                let newJson: PlayListManageData = try decoder.decode(PlayListManageData.self, from: data as Data)
                return newJson
            } catch {
                print("json convert failed in JSONDecoder", error.localizedDescription)
            }
        }
        return nil
    }
    
    /// プレイリストの初回作成.
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
    
    
    
    /// 更新チェック.
    func updateCheck(completion: @escaping () -> ()) {
        if !isLoaded || DropboxClientsManager.authorizedClient == nil {
            completion()
            return
        }
        guard let localFile = loadPlaylistData(path: _savePath) else {
            completion()
            return
        }
        
        // 保存先.
        let destination : (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return URL(fileURLWithPath: self._localTempPlaylistFilePath)
        }
        
        // tempがあれば削除しておく.
        do {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: self._localTempPlaylistFilePath))
        }
        catch {}
        
        // アップロード関数.
        func upload() {
            let encoder = JSONEncoder()
            let data = try! encoder.encode(PlayListManager.sharedManager._manageData)
            
            if let client = DropboxClientsManager.authorizedClient {
                client.files.upload(path: self._playlistFilePath+JSON_NAME_PLAYLIST, mode: .overwrite, autorename: false, clientModified: nil, mute: false, propertyGroups: nil, input: data).response { response, error in
                    if let metadata = response {
                        // おわり.
                        completion()
                    } else {
                        print(error!)
                        // おわり.
                        completion()
                    }
                }
            }
        }
        
        if let client = DropboxClientsManager.authorizedClient {
            client.files.download(path: self._playlistFilePath+JSON_NAME_PLAYLIST, destination: destination).response { response, error in
                if let (metadata, url) = response {
                    if let tempData = self.loadPlaylistData(path: self._localTempPlaylistFilePath) {
                        // バージョンチェック.
                        if Int(tempData.version)! > Int(localFile.version)! {
                            // サーバーの方が上の場合はtempを使う.
                            self.setManageData(data: tempData)
                            self.save()
                            // おわり.
                            completion()
                            }
                        else {
                            // ローカルが強い.
                            self.setManageData(data: localFile)
                            // アップロード.
                            upload()
                        }
                    }
                } else {
                    // とりあえず.
                    completion()
                }
            }
        }
    }
}
