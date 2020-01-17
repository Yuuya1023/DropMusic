//
//  SettingsViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import TwitterKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //
    // MARK: -
    //
    struct RowInfo {
        var title: String = ""
        var sub: String = ""
    }
    
    
    
    //
    // MARK: - Properties.
    //
    private var _sections: Array<String> = []
    private var _sectionCache: Array<RowInfo> = []
    private var _sectionDropbox: Array<RowInfo> = []
    private var _sectionTwitter: Array<RowInfo> = []
    private var _fileCount: Int = 0
    private var _fileSize: String = ""
    
    private var _tableView: UITableView!
    
    
    
    //
    // MARK: - Override.
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: AppColor.sub]
        self.navigationController?.navigationBar.barTintColor = AppColor.main
        self.navigationController?.navigationBar.tintColor = AppColor.sub
        self.title = "Settings"
        
        // section設定.
        _sections.append("Cache")
        _sections.append("DropBox")
        _sections.append("Twitter")
        
        // tableview.
        _tableView = UITableView()
        _tableView.backgroundColor = UIColor.clear
        _tableView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.register(UINib(nibName: SettingViewCell.cellIdentifier, bundle: nil),
                            forCellReuseIdentifier: SettingViewCell.cellIdentifier)
        
        self.view.addSubview(_tableView)
    }
    override func viewWillAppear(_ animated: Bool) {
        loadFiles()
        // row設定.
        _sectionDropbox.removeAll()
        _sectionDropbox.append(RowInfo(title: "Account",
                                       sub: AppDataManager.sharedManager.dropboxUserName ?? ""))
        _sectionDropbox.append(RowInfo(title: "AppData",
                                       sub: AppDataManager.sharedManager.manageDataPath))
        
        _sectionTwitter.removeAll()
        if let session = TWTRTwitter.sharedInstance().sessionStore.session() {
            if let name = UserDefaults.standard.string(forKey: USER_DEFAULT_TWITTER_NAME) {
                self._sectionTwitter.append(RowInfo(title: "Account",
                                                    sub: name))
            }
            else {
                self._sectionTwitter.append(RowInfo(title: "Account",
                                                    sub: session.userID))
            }
        }
        
        _sectionCache.removeAll()
        _sectionCache.append(RowInfo(title: "FileCount",
                                     sub: String(_fileCount)+" files"))
        _sectionCache.append(RowInfo(title: "FileSize",
                                     sub: String(_fileSize)))
        _tableView.reloadData()
    }
    override func viewWillLayoutSubviews() {
        // tableview.
        var frame = self.view.frame
        var margin = AudioPlayStatusView._height
        if let val = self.tabBarController {
            margin += val.tabBar.frame.size.height
        }
        frame.size.height = frame.size.height-margin
        _tableView.frame = frame
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //
    // MARK: - Private.
    //
    private func loadFiles() {
        var fileCount = 0
        var totalFileSize: UInt64 = 0
        do {
            let cachepath = DownloadFileManager.sharedManager.getCachePath(storageType: .DropBox, add: "/audio")
            let files = try FileManager.default.contentsOfDirectory(atPath: cachepath)
            fileCount = files.count
            for filePath in files {
                let attr = try FileManager.default.attributesOfItem(atPath: cachepath + "/" + filePath)
                let fileSize = attr[FileAttributeKey.size] as! UInt64
                totalFileSize = totalFileSize+fileSize
            }
        }
        catch {
            print("error")
        }
        _fileCount = fileCount
        var s = Double(totalFileSize)
        var unit = ""
        
        var index = 0
        let bytes = ["KB", "MB", "GB", "TB"]
        while s>1024 {
            s = s/1024
            unit = bytes[index]
            index = index+1
        }
        _fileSize = String(format: "%.02f",s) + unit
    }
    
    private func confirmLogoutDropbox() {
        let alert: UIAlertController = UIAlertController(title: "Confirm",
                                                         message: "Will you unlink DropBox Account?",
                                                         preferredStyle: .alert)
        // アンリンク.
        let okAction:UIAlertAction =
            UIAlertAction(title: "Unlink",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            AppDataManager.sharedManager.reset()
                            self.present(InitializeViewController(),
                                         animated: false,
                                         completion: nil)
                            
            })
        
        // キャンセル.
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            // 閉じるだけ.
            })
        
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func confirmLogoutTwitter() {
        let alert: UIAlertController = UIAlertController(title: "Confirm",
                                                         message: "Will you logout Twitter Account?",
                                                         preferredStyle: .alert)
        // アンリンク.
        let okAction:UIAlertAction =
            UIAlertAction(title: "Logout",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            if let session = TWTRTwitter.sharedInstance().sessionStore.session() {
                                TWTRTwitter.sharedInstance().sessionStore.logOutUserID(session.userID)
                            }
                            UserDefaults.standard.removeObject(forKey: USER_DEFAULT_TWITTER_NAME)
                            self._sectionTwitter.removeAll()
                            self._tableView.reloadData()
            })
        
        // キャンセル.
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            // 閉じるだけ.
            })
        
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    //
    // MARK: - TableView.
    //
    func numberOfSections(in tableView: UITableView) -> Int {
        return _sections.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return _sections[section]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return _sectionCache.count
        case 1:
            return _sectionDropbox.count
        case 2:
            return _sectionTwitter.count
            
        default:
            break
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: SettingViewCell.cellIdentifier ) as! SettingViewCell
        
        var rowinfo: RowInfo? = nil
        switch indexPath.section {
        case 0:
            rowinfo = _sectionCache[indexPath.row]
        case 1:
            rowinfo = _sectionDropbox[indexPath.row]
        case 2:
            rowinfo = _sectionTwitter[indexPath.row]
            
        default:
            break
        }
        
        if let rowinfo = rowinfo {
            c.set(title: rowinfo.title, sub: rowinfo.sub)
        }
        
        return c
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            if indexPath.row == 0 {
                // ログアウト.
                confirmLogoutDropbox()
            }
        case 2:
            // ログアウト.
            confirmLogoutTwitter()
            break
            
        default:
            break
        }
    }
    
}
