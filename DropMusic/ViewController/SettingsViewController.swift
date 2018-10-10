//
//  SettingsViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 40/255, green: 50/255, blue: 100/255, alpha: 1)

//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        UINavigationBar.appearance().tintColor = UIColor.red
        self.title = "Settings"
        
//        do{
//            let label = UILabel(frame: CGRect(x: 200, y: 200, width: 60, height: 60))
//            self.view.addSubview(label)
//            
//            let path = DownloadFileManager.sharedManager.getCachePath(storageType: .DropBox, add: "/audio")
//            let attr = try FileManager.default.attributesOfItem(atPath: path)
//            let fileSize : UInt64 = attr[FileAttributeKey.size] as! UInt64
////            label.text = (attr[.size] as? String)
//            label.text = String(fileSize)
//        }
//        catch {
//            print("error")
//        }
        
        do{
            let button = UIButton()
            button.frame = CGRect(x: 200, y: 400, width: 60, height: 60)
            button.setTitle("logout", for: UIControlState.normal)
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(logout(_:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(button)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func logout(_ sender: UIButton) {
        DropboxClientsManager.unlinkClients()
        NotificationCenter.default.post(name: Notification.Name(NOTIFICATION_DROPBOX_LOGGED_OUT), object: nil)
    }
    
}
