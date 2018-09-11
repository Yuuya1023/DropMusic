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
        self.view.backgroundColor = UIColor.yellow
        
        do{
            let button = UIButton()
            button.frame = CGRect(x: 200, y: 100, width: 60, height: 60)
            button.setTitle("logout", for: UIControlState.normal)
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
