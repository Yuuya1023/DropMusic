//
//  DropBoxLinkViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class DropBoxLinkViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.blue
        
        do{
            let button = UIButton()
            button.frame = CGRect(x: 100, y: 100, width: 60, height: 60)
            button.setTitle("login", for: UIControlState.normal)
            button.addTarget(self, action: #selector(login(_:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(button)
        }
        do{
            let button = UIButton()
            button.frame = CGRect(x: 200, y: 350, width: 60, height: 60)
            button.setTitle("userinfo", for: UIControlState.normal)
            button.addTarget(self, action: #selector(userinfo(_:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(button)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func login(_ sender: UIButton) {
        print("login")
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: self,
                                                      openURL: { (url: URL) -> Void in
                                                        UIApplication.shared.openURL(url)
        })
    }
    
    @objc func userinfo(_ sender: UIButton) {
        print("userinfo")
    }
}
