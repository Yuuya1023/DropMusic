//
//  DropboxFileListManager.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation

class DropboxFileListManager {
    
    //
    // MARK: - Singleton.
    //
    static let sharedManager = DropboxFileListManager()
    private init() {
    }
    
    
    
    //
    // MARK: - Alias.
    //
    typealias FileListCache = [String: [FileInfo]]
    
    
    
    //
    // MARK: - Constant.
    //
    
    
    
    //
    // MARK: - Properties.
    //
    private var _pathDictionary: FileListCache = [:]
    
    
    
    //
    // MARK: -
    //
    /// ファイル一覧取得.
    func get(pathLower: String) -> [FileInfo]? {
        return _pathDictionary[pathLower.lowercased()]
    }
    /// AudioDataとして一覧を取得する.
    func getAudioList(pathLower: String) -> [AudioData] {
        var ret: [AudioData] = []
        if let fileList = get(pathLower: pathLower) {
            for file in fileList {
                if let d = AudioData.createFromFileInfo(file) {
                    ret.append(d)
                }
            }
        }
        return ret
    }
    /// 削除.
    func remove(pathLower: String) {
        _pathDictionary.removeValue(forKey: pathLower.lowercased())
    }
    /// 登録.
    func regist(pathLower: String, list: [FileInfo]) {
        if get(pathLower: pathLower) == nil {
            update(pathLower: pathLower, list: list)
        }
    }
    /// 更新.
    func update(pathLower: String, list: [FileInfo]) {
        _pathDictionary.updateValue(list, forKey: pathLower.lowercased())
    }
    /// UserDefaultsに保存.
    func save() {
        if let data = try? JSONEncoder().encode(_pathDictionary) {
            UserDefaults.standard.set(data, forKey: USER_DEFAULT_FILE_LIST_CACHE)
        }
    }
    /// UserDefaultsから取得.
    func load() {
        if let data = UserDefaults.standard.data(forKey: USER_DEFAULT_FILE_LIST_CACHE) {
            do {
                let dictionary = try JSONDecoder().decode(FileListCache.self, from: data)
                _pathDictionary = dictionary
            } catch {
                print("json convert failed in JSONDecoder", error.localizedDescription)
            }
        }
    }
    /// UserDefaultsを削除.
    func reset() {
        UserDefaults.standard.removeObject(forKey: USER_DEFAULT_FILE_LIST_CACHE)
    }
    
}
