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
    private var latestId: String = "0"
    func getLatestId() -> String {
        return latestId
    }
    private var playlists: Array<PlayListData> = []
    func getPlaylists() -> Array<PlayListData> {
        return playlists
    }
    
    //
    // MARK: -
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
    
    /// プレイリスト情報取得.
    func getPlaylistData(id: String) -> (PlayListData?) {
        guard let index = getPlayListIndex(playListId: id) else {
            return nil
        }
        return playlists[index]
    }
    
    /// プレイリストを追加.
    func addPlaylist() -> (String) {
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
        var playlist: PlayListData = playlists[index]
        if playlist.id == id {
            if playlist.name != name {
                playlist.name = name
                playlists[index] = playlist
            }
            return
        }
    }
    
    /// プレイリストに楽曲が入っているか.
    func isIncludeAudio(playListId: String, data: AudioData) -> Bool {
        guard let index = getPlayListIndex(playListId: playListId) else {
            return false
        }
        let playlistData = playlists[index]
        for i in 0..<playlistData.audioList.count {
            let d = playlistData.audioList[i]
            if d.id == data.id {
                return true
            }
        }
        return false
    }
    
    /// プレイリストの楽曲を追加.
    func addAudioToPlayList(playListId: String, addList: Array<AudioData>!) {
        if addList.count == 0 { return }
        
        guard let index = getPlayListIndex(playListId: playListId) else {
            return
        }
        var playlist: PlayListData = playlists[index]
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
            if isAdd {
                playlists[index] = playlist
            }
        }
    }
    
    /// プレイリストから楽曲を削除.
    func deleteAudioFromPlayList(playListId: String, audioId: String) {
        guard let index = getPlayListIndex(playListId: playListId) else {
            return
        }
        var playlist = playlists[index]
        for i in 0..<playlist.audioList.count {
            let d = playlist.audioList[i]
            if d.id == audioId {
                playlist.audioList.remove(at: i)
                playlists[index] = playlist
                return
            }
        }
    }
    
    /// プレイリスト削除.
    func deletePlaylist(id: String) {
        guard let index = getPlayListIndex(playListId: id) else {
            return
        }
        let d = playlists[index]
        if d.id == id {
            playlists.remove(at: index)
        }
    }
}
