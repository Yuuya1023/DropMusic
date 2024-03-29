//
//  AudioPlayStatus.swift
//  DropMusic
//
//  Copyright © 2020 n.yuuya. All rights reserved.
//

import Foundation

class AudioPlayStatus: Codable {
    
    //
    // MARK: - Enumeration.
    //
    enum AudioSelectType: Int,Codable {
        case None       = 0
        case Cloud      = 1
        case Playlist   = 2
        case Favorite   = 3
        case Suggest    = 4
        
        /// description.
        func description() -> String {
            var ret = ""
            switch self {
            case .Cloud:
                ret = "folder"
            case .Playlist:
                ret = "playlist"
            case .Favorite:
                ret = "favorite"
            default: break
            }
            return ret
        }
    }
    
    enum RepeatType: Int,Codable {
        case One        = 0
        case All        = 1
    }
    
    enum ShuffleType: Int,Codable {
        case None       = 0
        case All        = 1
    }
    
    
    
    //
    // MARK: - Properties.
    //
    var selectType: AudioSelectType = .None
    var selectValue: String = ""
    var repeatType: RepeatType = .One
    var shuffleType: ShuffleType = .None
    private var audioList: [AudioData] = []
    
    
    
    //
    // MARK: - Static.
    //
    /// データ型から変換.
    static func makeFromData(data: Data) -> AudioPlayStatus? {
        do {
            let newJson: AudioPlayStatus = try JSONDecoder().decode(AudioPlayStatus.self, from: data)
            return newJson
        } catch {
            print("json convert failed in JSONDecoder", error.localizedDescription)
        }
        return nil
    }
    
    
    
    //
    // MARK: - Public.
    //
    /// 楽曲リスト設定.
    func setAudioList(_ list: [AudioData]) {
        audioList = list
    }
    
    /// 楽曲リスト取得.
    func getAudioList() -> [AudioData] {
        return audioList
    }
    
    /// 選択場所が変更されたか.
    func isChanged(selectType: AudioSelectType, selectValue: String) -> Bool {
        if self.selectType != selectType {
            return true
        }
        if self.selectValue != selectValue {
            return true
        }        
        return false
    }
    
    /// 再生候補を作成.
    func makeQueList(exlusion: AudioData?) -> [AudioData] {
        var ret: [AudioData] = []
        if audioList.count == 0 {
            return ret
        }
        
        switch shuffleType {
        case .None:
            if let exlusion = exlusion {
                // プレイ中の曲から追加する.
                var temp: Array<AudioData> = []
                var flg: Bool = false
                for d in audioList {
                    if flg {
                        temp.append(d)
                    }
                    else {
                        if d.isEqualData(audioData: exlusion) {
                            flg = true
                        }
                    }
                }
                for d in audioList {
                    if d.isEqualData(audioData: exlusion) {
                        break
                    }
                    temp.append(d)
                }
                // 最後に積む.
                temp.append(exlusion)
                ret = temp
            }
            else {
                ret = audioList
            }
        case .All:
            ret = audioList.shuffled
        }
        
        return ret
    }
    
    /// 再生情報タイトル.
    func makeTitle() -> String {
        var ret = ""
        switch selectType {
        case .Cloud:
            ret = "from " + selectType.description() + " \"" + makeDisplayName() + "\" "
        case .Playlist:
            if let playlist = AppDataManager.sharedManager.playlist.getPlaylistData(id: selectValue) {
                ret = "from " + selectType.description() + " \"" + playlist.name + "\" "
            }
        case .Favorite:
            ret = "from " + selectType.description()
        default:
            break
        }
        return ret
    }
    
    
    
    //
    // MARK: - Private.
    //
    /// 表示名作成.
    private func makeDisplayName() -> String {
        var ret = ""
        var list = selectValue.components(separatedBy: "/")
        // 空文字を削除.
        list.removeAll { (str) -> Bool in
            if str == "" {
                return true
            }
            return false
        }

        if list.count >= 1 {
            ret = list[list.endIndex-1]
        }
        return ret
    }
    
}
