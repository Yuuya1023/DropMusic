//
//  PlayListManageData.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation

class PlayListManageData: Codable {
    
    //
    // MARK: - Properties.
    //
    private(set) var latestId: String = "0"
    private(set) var playlists: [PlayListData] = []
    
    
    
    //
    // MARK: - Public.
    //
    /// プレイリスト情報取得.
    func getPlaylistData(id: String) -> PlayListData? {
        guard let index = getPlayListIndex(playListId: id) else {
            return nil
        }
        return playlists[index]
    }
    
    /// プレイリストを追加.
    func addPlaylist() -> String {
        let id = String(Int(latestId)!+1)
        playlists.append(PlayListData(id: id,
                                      name: "Playlist_" + id,
                                      audioList: []))
        latestId = id
        return latestId
    }
    
    /// プレイリストを更新.
    func updatePlaylist(id: String, name: String) {
        guard let index = getPlayListIndex(playListId: id) else {
            return
        }
        
        if playlists[index].id == id {
            if playlists[index].name != name {
                playlists[index].name = name
            }
        }
    }
    
    /// プレイリストに楽曲が入っているか.
    func isIncludeAudio(playListId: String, data: AudioData) -> Bool {
        guard let index = getPlayListIndex(playListId: playListId) else {
            return false
        }
        return playlists[index].isIncludeAudio(audioId: data.id)
    }
    
    /// プレイリストの楽曲を追加.
    func addAudioToPlayList(playListId: String, addList: [AudioData]) {
        guard let index = getPlayListIndex(playListId: playListId) else {
            return
        }
        for addAudio in addList {
            playlists[index].addAudio(audioData: addAudio)
        }
    }
    
    /// プレイリストから楽曲を削除.
    func deleteAudioFromPlayList(playListId: String, audioId: String) {
        guard let index = getPlayListIndex(playListId: playListId) else {
            return
        }
        playlists[index].removeAudio(audioId: audioId)
    }
    
    /// プレイリスト削除.
    func deletePlaylist(id: String) {
        guard let index = getPlayListIndex(playListId: id) else {
            return
        }
        playlists.remove(at: index)
    }
    
    
    
    //
    // MARK: - Private.
    //
    /// プレイリストのインデックスを取得.
    private func getPlayListIndex(playListId: String) -> Int? {
        for i in 0..<playlists.count {
            let d: PlayListData = playlists[i]
            if d.id == playListId {
                return i
            }
        }
        return nil
    }
    
}
