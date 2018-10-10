//
//  SettingsViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class SettingsViewController: UIViewController {
    
    var fileCountLabel: UILabel = UILabel()
    var fileSizeLabel: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 40/255, green: 50/255, blue: 100/255, alpha: 1)
        self.title = "Settings"
        
        fileCountLabel.frame = CGRect(x: 200, y: 200, width: 100, height: 60)
        fileCountLabel.textAlignment = .right
        self.view.addSubview(fileCountLabel)

        fileSizeLabel.frame = CGRect(x: 200, y: 230, width: 100, height: 60)
        fileSizeLabel.textAlignment = .right
        self.view.addSubview(fileSizeLabel)

        
        do{
            let button = UIButton()
            button.frame = CGRect(x: 200, y: 400, width: 60, height: 60)
            button.setTitle("logout", for: UIControlState.normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(logout(_:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(button)
        }
        
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
    
    
    
    // MARK: -
    @objc func logout(_ sender: UIButton) {
        DropboxClientsManager.unlinkClients()
        NotificationCenter.default.post(name: Notification.Name(NOTIFICATION_DROPBOX_LOGGED_OUT), object: nil)
    }
    
}
