//
//  RootVC.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class RootViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // アイコンの色.
//        UITabBar.appearance().tintColor = UIColor.yellow
        
        // 背景色.
        UITabBar.appearance().barTintColor = UIColor(red: 66/255, green: 74/255, blue: 93/255, alpha: 1.0)
        
        
        // タブバーの設定.
        let fileList = FileListViewController()
        let playList = PlayListViewController()
        let settings = SettingsViewController()
        
        fileList.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.featured, tag: 1)
        playList.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.bookmarks, tag: 2)
        settings.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.downloads, tag: 3)
        
        let tabs = NSArray(objects: fileList, playList, settings)
        self.setViewControllers(tabs as! [UIViewController], animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

