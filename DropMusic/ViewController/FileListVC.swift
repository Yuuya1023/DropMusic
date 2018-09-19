//
//  FileListViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class FileListViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
//    var _path: String = ""
    var _pathList: [String] = []
    
    var _tableView: UITableView = UITableView()
    var _datas: Array<FileInfo> = []
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(pathList: [String]){
        super.init(nibName: nil, bundle: nil)
        self._pathList = pathList
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = _pathList.last
        self.navigationController?.delegate = self
        
        //
        var bounds = self.view.bounds
        bounds.size.height = bounds.size.height
        _tableView = UITableView(frame: bounds, style: .plain)
        _tableView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.register(FileListViewCell.self, forCellReuseIdentifier: NSStringFromClass(FileListViewCell.self))
        
        self.view.addSubview(_tableView)
        
        
        load()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func load(){
        let path = makePath()
        let cacheData = DropboxFileListManager.sharedManager.get(pathLower: path)
        if cacheData != nil && cacheData?.count != 0 {
            // キャッシュから.
            self._datas = cacheData!
            sortAndReloadList()
        }
        else {
            if let client = DropboxClientsManager.authorizedClient {
                client.files.listFolder(path: path).response { response, error in
                    if let metadata = response {
                        self._datas = []
//                        print("Entries: \(metadata.entries)")
                        for entry in metadata.entries {
                            let info = FileInfo(metadata: entry)
                            if info.isFolder() || info.isAudioFile() {
                                // フォルダか音声ファイルのみ.
                                self._datas.append(FileInfo(metadata: entry))
                            }
                        }
                    } else {
                        print(error!)
                        self.navigationController?.popViewController(animated: true)
                        return
                    }
                    
                    if self._datas.count != 0 {
                        // 登録.
                        DropboxFileListManager.sharedManager.regist(pathLower: path, list: self._datas)
                        // 更新.
                        self.sortAndReloadList()
                    }
                }
            }
        }
    }
    
    func sortAndReloadList() {
        self._datas.sort(by: {$0.name().lowercased() < $1.name().lowercased()})
        self._tableView.reloadData()
        self._tableView.contentSize.height = self._tableView.contentSize.height+49
    }
    
    func makePath() -> (String) {
        var ret: String = ""
        for v in _pathList {
            ret += "/" + v
        }
        return ret
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        print("もどった")
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {

    }


    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _datas.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let temp = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(FileListViewCell.self))
            ?? UITableViewCell(style: .default, reuseIdentifier: NSStringFromClass(FileListViewCell.self))
        let c = temp as! FileListViewCell
        
        let fileInfo = _datas[indexPath.row]
        c.nameLabel.text = fileInfo.name()
        
        var iconName = "icon_cell_question.png"
        if fileInfo.isFolder() {
            iconName = "icon_cell_folder.png"
        }
        else if fileInfo.isAudioFile() {
            iconName = "icon_cell_audio.png"
        }
        c.icon.image = UIImage(named: iconName)
        
        if DownloadFileManager.sharedManager.isExistAudioFile(fileInfo: fileInfo) {
            c.progress.progress = 1
        }
        else {
            c.progress.progress = 0
            c.updateObserber(identifier: fileInfo.name())
        }
        
        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileInfo = _datas[indexPath.row]
        if fileInfo.isFolder() {
            // フォルダ.
            var l: [String] = _pathList
            l.append(fileInfo.name())
            self.navigationController?.pushViewController(FileListViewController(pathList: l),
                                                          animated: true)
        }
        else if fileInfo.isFile() {
            // ファイル.
            let audioData = AudioData(_id: fileInfo.id()!,
                                      _storageType: .DropBox,
                                      _name: fileInfo.name(),
                                      _path: fileInfo.pathLower(),
                                      _hash: fileInfo.contentHash()!,
                                      _extension: fileInfo.fileExtension()!)
            
            if DownloadFileManager.sharedManager.isExistAudioFile(audioData: audioData) {
                AudioPlayManager.sharedManager.set(audioData: audioData)
                AudioPlayManager.sharedManager.play()
            }
            else {
                DownloadFileManager.sharedManager.download(audioData: audioData)
            }
        }
    }
}
