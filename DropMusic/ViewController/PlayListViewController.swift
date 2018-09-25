//
//  PlayListViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class PlayListViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variable Declaration
    var _tableView: UITableView!
    
    let _playlistFilePath: String = "/DropMusic/"

    let _localTempPlaylistFilePath = DownloadFileManager.sharedManager.getCachePath(storageType: .DropBox, add: "") + "/temp_" + JSON_NAME_PLAYLIST
    
    
    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        self.title = "Playlist"
        
        var bounds = self.view.bounds
        bounds.size.height = bounds.size.height
        _tableView = UITableView(frame: bounds, style: .plain)
        _tableView.backgroundColor = UIColor.clear
        _tableView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        _tableView.rowHeight = 70
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.register(PlayListViewCell.self, forCellReuseIdentifier: NSStringFromClass(PlayListViewCell.self))
        
        self.view.addSubview(_tableView)
        
        checkPlaylistFile()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -
    // プレイリストファイルの確認.
    func checkPlaylistFile() {
        let pManager = PlayListManager.sharedManager
        let localFile = loadPlaylistData(path: pManager._savePath)
        
        // 保存先.
        let destination : (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            let path = self._localTempPlaylistFilePath
            return URL(fileURLWithPath: path)
        }
        
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
                            pManager.setManageData(data: tempData!)
                            // 保存.
                            pManager.save()
                        }
                        else {
                            pManager.setManageData(data: localFile!)
                        }
                    }
                    else {
                        // ない場合は保存.
                        pManager.setManageData(data: tempData!)
                        pManager.save()
                    }
                    // tempを削除.
                    try! FileManager.default.removeItem(at: URL(fileURLWithPath: self._localTempPlaylistFilePath))
                    self.updateScrollView()
                } else {
                    print(error!)
                
                    // エラー判定したい.
//                    print(error?.description)
                    
                    // プレイリストファイルがなかったら作成してアップロード.
                    self.createPlaylist()
                    
//                    // tempを削除.
//                    do {
//                        try FileManager.default.removeItem(at: URL(fileURLWithPath: self._localTempPlaylistFilePath))
//                    }
//                    catch {
//                        print("delete error")
//                    }
                }
            }
        }
    }
    
    // プレイリストファイルの読み込み.
    func loadPlaylistData(path: String) -> (PlayListManageData?) {
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
    func createPlaylist(){
        let playlist = PlayListManageData()
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(playlist)
//
        if let client = DropboxClientsManager.authorizedClient {
            client.files.upload(path: self._playlistFilePath+JSON_NAME_PLAYLIST, mode: .add, autorename: false, clientModified: nil, mute: false, propertyGroups: nil, input: data).response { response, error in
                    if let metadata = response {
                        print("Uploaded file name: \(metadata.name)")
                    } else {
                        print(error!)
                    }
                }
        }
    }
    
    func updateScrollView() {
        self._tableView.reloadData()
    }
    
    
    // MARK: - TableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlayListManager.sharedManager._manageData.playlists.count+1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let temp = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(PlayListViewCell.self))
            ?? UITableViewCell(style: .default, reuseIdentifier: NSStringFromClass(PlayListViewCell.self))
        let c = temp as! PlayListViewCell
        
        if PlayListManager.sharedManager._manageData.playlists.count > indexPath.row {
            let playList = PlayListManager.sharedManager._manageData.playlists[indexPath.row]
            c.nameLabel.text = playList.name
            c.tracksLabel.text = String(playList.audioList.count) + " tracks"
        }
        else {
            c.nameLabel.text = "+"
        }
        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        if PlayListManager.sharedManager._manageData.playlists.count > indexPath.row {
            
        }
        else {
            // 追加.
            PlayListManager.sharedManager.addPlaylist()
            PlayListManager.sharedManager.save()
            updateScrollView()
        }
    }
}
