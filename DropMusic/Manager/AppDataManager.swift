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
    private let _manageDataFilePath: String!
    private let _localTempFilePath: String!
    private var _manageData: AppManageData = AppManageData()
    var playlist: PlayListManageData! {
        get {
            return _manageData.playlist
        }
        set(p) {
            _manageData.playlist = p
        }
    }
    var favorite: FavoriteManageData! {
        get {
            return _manageData.favorite
        }
        set(p) {
            _manageData.favorite = p
        }
    }
    
    
    
    //
    // MARK: - Initialize.
    //
    private init() {
        _savePath = DownloadFileManager.sharedManager.getCachePath(storageType: .DropBox, add: "") + "/" + JSON_NAME
        _manageDataFilePath = "/DropMusic/"
        _localTempFilePath = DownloadFileManager.sharedManager.getCachePath(storageType: .DropBox, add: "") + "/temp_" + JSON_NAME
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
    
    /// 初回作成.
    private func createManageData(){
        let encoder = JSONEncoder()
        let data = try! encoder.encode(_manageData)
        //
        if let client = DropboxClientsManager.authorizedClient {
            client.files.upload(path: self._manageDataFilePath+JSON_NAME, mode: .add, autorename: false, clientModified: nil, mute: false, propertyGroups: nil, input: data).response { response, error in
                if let _ = response {
                    // 成功したら再チェック.
                    self.checkFile() {}
                } else {
                    print(error!)
                }
            }
        }
    }
    
    
    
    //
    // MARK: - Public.
    //
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
        func upload() {
            let encoder = JSONEncoder()
            let data = try! encoder.encode(_manageData)
            
            if let client = DropboxClientsManager.authorizedClient {
                client.files.upload(path: self._manageDataFilePath+JSON_NAME, mode: .overwrite, autorename: false, clientModified: nil, mute: false, propertyGroups: nil, input: data).response { response, error in
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
            client.files.download(path: self._manageDataFilePath+JSON_NAME, destination: destination).response { response, error in
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
                                self.save()
                            }
                            else {
                                // ローカルの方が強い場合、保存してアップロード.
                                self.setManageData(data: localFile)
                                upload()
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
                    }
                    
                    if let localFile = localFile {
                        // ローカルにある場合はとりあえず読み込んでおく.
                        self.setManageData(data: localFile)
                        upload()
                    }
                    else {
                        // ファイルがなかったら作成してアップロード.
                        self.createManageData()
                    }
                }
                self._isLoading = false
                completion()
            }
        }
    }
    
}
