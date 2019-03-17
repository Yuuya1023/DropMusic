//
//  SettingsViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class SettingsViewController: UIViewController {
    
    var acccountTitle: UILabel = UILabel()
    var accountLabel: UILabel = UILabel()
    var accountButton: UIButton = UIButton()
    
    var cacheTitle: UILabel = UILabel()
    var fileCountTitle: UILabel = UILabel()
    var fileSizeTitle: UILabel = UILabel()
    var fileCountLabel: UILabel = UILabel()
    var fileSizeLabel: UILabel = UILabel()
    
    var playlistTitle: UILabel = UILabel()
    var playlistLabel: UILabel = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        if #available(iOS 10.0, *) {
            self.navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 40/255, green: 50/255, blue: 100/255, alpha: 1)
        } else {
            // Fallback on earlier versions
        }
        self.title = "Settings"
        
        acccountTitle.frame = CGRect(x: 20, y: 100, width: 100, height: 30)
        acccountTitle.textAlignment = .left
        acccountTitle.text = "Account"
        self.view.addSubview(acccountTitle)
        
        accountLabel.frame = CGRect(x: 30, y: 130, width: 100, height: 30)
        accountLabel.textAlignment = .left
        accountLabel.text = "..."
        self.view.addSubview(accountLabel)
        
        accountButton.frame = CGRect(x: 220, y: 130, width: 80, height: 30)
        accountButton.setTitle("login", for: UIControlState.normal)
        accountButton.setTitleColor(UIColor.black, for: .normal)
        accountButton.layer.cornerRadius = 10
        accountButton.layer.borderWidth = 1
        accountButton.addTarget(self, action: #selector(logout(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(accountButton)
        
        //
        cacheTitle.frame = CGRect(x: 20, y: 180, width: 100, height: 30)
        cacheTitle.textAlignment = .left
        cacheTitle.text = "Caches"
        self.view.addSubview(cacheTitle)
        
        fileCountTitle.frame = CGRect(x: 30, y: 210, width: 100, height: 30)
        fileCountTitle.textAlignment = .left
        fileCountTitle.text = "file count"
        self.view.addSubview(fileCountTitle)
        
        fileSizeTitle.frame = CGRect(x: 30, y: 240, width: 100, height: 30)
        fileSizeTitle.textAlignment = .left
        fileSizeTitle.text = "file size"
        self.view.addSubview(fileSizeTitle)
        
        
        fileCountLabel.frame = CGRect(x: 200, y: 210, width: 100, height: 30)
        fileCountLabel.textAlignment = .right
        self.view.addSubview(fileCountLabel)

        fileSizeLabel.frame = CGRect(x: 200, y: 240, width: 100, height: 30)
        fileSizeLabel.textAlignment = .right
        self.view.addSubview(fileSizeLabel)

        //
        playlistTitle.frame = CGRect(x: 20, y: 290, width: 150, height: 30)
        playlistTitle.textAlignment = .left
        playlistTitle.text = "Playlist save path"
        self.view.addSubview(playlistTitle)
        
        playlistLabel.frame = CGRect(x: 30, y: 320, width: 250, height: 30)
        playlistLabel.textAlignment = .left
        playlistLabel.text = "/DropMusic/playlist.json"
        self.view.addSubview(playlistLabel)
        
        
        
        loadUser()
        loadFiles()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    
    
    // MARK: -
    func loadFiles() {
        var fileCount = 0
        var totalFileSize: UInt64 = 0
        do {
            let path = DownloadFileManager.sharedManager.getCachePath(storageType: .DropBox, add: "/audio")
            let files: [String] = try FileManager.default.contentsOfDirectory(atPath: path)
//            print(files)
            fileCount = files.count
            for i in 0..<fileCount {
                let attr = try FileManager.default.attributesOfItem(atPath: path + "/" + files[i])
                let fileSize: UInt64 = attr[FileAttributeKey.size] as! UInt64
                totalFileSize = totalFileSize+fileSize
            }
        }
        catch {
            print("error")
        }
        fileCountLabel.text = String(fileCount) + "files"
        var s:Double = Double(totalFileSize)
        var unit = ""
        
        var index = 0
        let bytes = ["KB", "MB", "GB", "TB"]
        while s>1024 {
            s = s/1024
            unit = bytes[index]
            index = index+1
        }
        fileSizeLabel.text = String(format: "%.02f",s) + unit
    }
    
    
    private func loadUser() {
        if let client = DropboxClientsManager.authorizedClient {
            client.users.getCurrentAccount().response {
                (response, error) in
                if let account = response {
                    self.accountLabel.text = account.name.displayName
                    self.accountButton.setTitle("logout", for: UIControlState.normal)
                }
                else {
                    self.accountLabel.text = "not loggedin."
                    self.accountButton.setTitle("login", for: UIControlState.normal)
                }
            }
        }
    }
    
    
    
    // MARK: -
    @objc func logout(_ sender: UIButton) {
        let alert: UIAlertController = UIAlertController(title: "confirm",
                                                         message: "Will you unlink DropBox Account?",
                                                         preferredStyle: .alert)
        // アンリンク.
        let okAction:UIAlertAction =
            UIAlertAction(title: "Unlink",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            DropboxClientsManager.unlinkClients()
                            NotificationCenter.default.post(name: Notification.Name(NOTIFICATION_DROPBOX_LOGGED_OUT), object: nil)
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
    
}
