//
//  RootTabBarController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class RootTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // アイコンの色.
//        UITabBar.appearance().tintColor = UIColor.yellow
        
        // 背景色.
        UITabBar.appearance().barTintColor = UIColor(displayP3Red: 20/255, green: 29/255, blue: 80/355, alpha: 1)

        
        
        // タブバーの設定.
        let vc1 = DropBoxRootNavigactionController()
        let vc2 = UINavigationController(rootViewController: PlayListViewController())
        let vc3 = SettingsViewController()
        
        vc1.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.featured, tag: 1)
        vc2.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.bookmarks, tag: 2)
        vc3.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.downloads, tag: 3)
        
        let tabs = NSArray(objects: vc1, vc2, vc3)
        self.setViewControllers(tabs as? [UIViewController], animated: false)
        
        let statusView = AudioPlayStatusView(x: 0, y : self.view.bounds.height-98)
        self.view.addSubview(statusView)
        
        // 曲監視.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(selectorShowAudioPlayer),
                                               name: NSNotification.Name(rawValue: NOTIFICATION_SHOW_AUDIO_PLAYER_VIEW),
                                               object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @objc private func selectorShowAudioPlayer(notification: Notification) {
        let modalViewController = MusicPlayerViewControlloer()
        modalViewController.modalPresentationStyle = .custom
        modalViewController.transitioningDelegate = self
        present(modalViewController, animated: true, completion: nil)
    }
}


extension RootTabBarController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AudioPlayerPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
