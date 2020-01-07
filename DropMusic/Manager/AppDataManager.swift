//
//  AppDataManager.swift
//  DropMusic
//
//  Copyright © 2019年 n.yuuya. All rights reserved.
//

import Foundation
import SwiftyDropbox

class AppDataManager {
    
    //
    // MARK: - Singleton.
    //
    static let sharedManager = AppDataManager()
    
    
    
    //
    // MARK: - Constant.
    //
    private let JSON_NAME = "appdata.json"
    private let USER_DEFAULT_DROPBOX_USERNAME = "dropboxusername"
    
    
    
    //
    // MARK: - Properties.
    //
    private var _isLoading: Bool = false
    var isLoading: Bool {
        get {
            return _isLoading
        }
    }
    private var _isLoaded: Bool = false
    var isLoaded: Bool {
        get {
            return _isLoaded
        }
    }
    
    private let _savePath: String!
    private let _manageDataFilePathPrefix: String!
    private let _localTempFilePath: String!
    private var _dropboxUserName: String = ""
    var dropboxUserName: String? {
        get {
            if _dropboxUserName == "" {
                return nil
            }
            return _dropboxUserName
        }
        set {
            if let v = newValue {
                _dropboxUserName = v
                UserDefaults.standard.set(_dropboxUserName, forKey: USER_DEFAULT_DROPBOX_USERNAME)
            }
        }
    }
    var manageDataPath: String {
        get {
            return _manageDataFilePathPrefix+JSON_NAME
        }
    }
    
    private var _manageData: AppManageData = AppManageData()
    var playlist: PlayListManageData! {
        get {
            return _manageData.playlist
        }
    }
    var favorite: FavoriteManageData! {
        get {
            return _manageData.favorite
        }
    }
    
    
    
    //
    // MARK: - Initialize.
    //
    private init() {
        if let username = UserDefaults.standard.string(forKey: USER_DEFAULT_DROPBOX_USERNAME) {
            _dropboxUserName = username
        }
        _savePath = DownloadFileManager.sharedManager.getCachePath(storageType: .DropBox, add: "") + "/" + JSON_NAME
        _manageDataFilePathPrefix = "/DropMusic/"
        _localTempFilePath = DownloadFileManager.sharedManager.getCachePath(storageType: .DropBox, add: "") + "/temp_" + JSON_NAME
        // 通信環境などにより読み込めなかった時のためにローカルファイルを読み込んでおく.
        if let data = loadData(path: _savePath) {
            _manageData = data
        }
    }
    
    
    
    //
    // MARK: - Private.
    //
    /// プレイリスト管理情報設定.
    private func setManageData(data: AppManageData) {
        _manageData = data
        _isLoaded = true
    }
    
    /// ファイルの読み込み.
    private func loadData(path: String) -> (AppManageData?) {
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
    /// 保存.
    func save(isUpdate: Bool = true) {
        // 読み込みが成功していない場合は事故防止のためセーブしない.
        if !isLoaded {
            return
        }
        // 保存する時にバージョンをあげる.
        if isUpdate {
            _manageData.version = String(Int(_manageData.version)!+1)
        }
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(_manageData)
            try data.write(to: URL(fileURLWithPath: _savePath))
        } catch {
            print("json convert failed in JSONEncoder", error.localizedDescription)
        }
    }
    
    /// ファイルの確認.
    func checkFile(completion: @escaping () -> ()) {
        if _isLoading {
            completion()
            return
        }
        if DropboxClientsManager.authorizedClient == nil {
            completion()
            return
        }
        _isLoading = true
        let localFile = loadData(path: _savePath)
        
        // 保存先.
        let destination : (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return URL(fileURLWithPath: self._localTempFilePath)
        }
        
        // tempがあれば削除しておく.
        do {
            try FileManager.default.removeItem(at: URL(fileURLWithPath: self._localTempFilePath))
        }
        catch {}
        
        // アップロード関数.
        func upload(isFirst: Bool) {
            let encoder = JSONEncoder()
            let data = try! encoder.encode(_manageData)
            
            if let client = DropboxClientsManager.authorizedClient {
                client.files.upload(path: self.manageDataPath,
                                    mode: isFirst ? .add : .overwrite,
                                    autorename: false,
                                    clientModified: nil,
                                    mute: false,
                                    propertyGroups: nil,
                                    input: data)
                    .response { response, error in
                    if let response = response {
                        // おわり.
                        print(response)
                    } else {
                        // おわり.
                        print(error!)
                    }
                }
            }
        }
        
        // ダウンロード.
        if let client = DropboxClientsManager.authorizedClient {
            client.files.download(path: self.manageDataPath,
                                  destination: destination)
                .response{ response, error in
                    if let (_, _) = response {
                        if let tempData = self.loadData(path: self._localTempFilePath) {
                            if let localFile = localFile {
                                // ローカルにある場合はバージョンのチェック.
                                if Int(tempData.version)! == Int(localFile.version)! {
                                    // セットだけする.
                                    self.setManageData(data: localFile)
                                }
                                else if Int(tempData.version)! > Int(localFile.version)! {
                                    // サーバーの方が上の場合はtempを使う.
                                    self.setManageData(data: tempData)
                                    self.save(isUpdate: false)
                                }
                                else {
                                    // ローカルの方が強い場合、保存してアップロード.
                                    self.setManageData(data: localFile)
                                    upload(isFirst: false)
                                }
                            }
                            else {
                                // ない場合は保存.
                                self.setManageData(data: tempData)
                                self.save(isUpdate: false)
                            }
                        }
                    } else {
                        if let error = error {
                            print(error)
                        }
                        
                        if let localFile = localFile {
                            // ローカルにある場合はとりあえず読み込んでおく.
                            self.setManageData(data: localFile)
                        }
                        else {
                            // ファイルがなかったら作成してアップロード.
                            self.setManageData(data: AppManageData())
                            self.save(isUpdate: false)
                        }
                        upload(isFirst: true)
                    }
                    self._isLoading = false
                    completion()
            }
        }
    }
    
    /// リセット.
    func reset() {
        DropboxClientsManager.unlinkClients()
        _isLoaded = false
        _manageData = AppManageData()
        _dropboxUserName = ""
        UserDefaults.standard.removeObject(forKey: USER_DEFAULT_DROPBOX_USERNAME)
        // ファイル削除.
        try! FileManager.default.removeItem(at: URL(fileURLWithPath: self._savePath))
        try! FileManager.default.removeItem(at: URL(fileURLWithPath: self._localTempFilePath))
    }
    
}