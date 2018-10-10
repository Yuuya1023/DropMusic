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
        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().barTintColor = UIColor(displayP3Red: 20/255, green: 29/255, blue: 80/255, alpha: 1)
        
        
        // タブバーの設定.
        let vc1 = DropBoxRootNavigactionController()
        let vc2 = UINavigationController(rootViewController: PlayListViewController())
        let vc3 = UINavigationController(rootViewController:  SettingsViewController())
        
        let size = CGSize(width: 25, height: 25)
        vc1.tabBarItem = UITabBarItem(title: "Cloud",
                                      image: UIImage(named: "tab_cloud.png")?.resizeImage(reSize: size),
                                      tag: 1)
        vc2.tabBarItem = UITabBarItem(title: "Playlist",
                                      image: UIImage(named: "tab_playlist.png")?.resizeImage(reSize: size),
                                      tag: 2)
        vc3.tabBarItem = UITabBarItem(title: "Settings",
                                      image: UIImage(named: "tab_settings.png")?.resizeImage(reSize: size),
                                      tag: 3)
        
        let tabs = NSArray(objects: vc1, vc2, vc3)
        self.setViewControllers(tabs as? [UIViewController], animated: false)
        
        let statusView = AudioPlayStatusView(x: 0, y : self.view.bounds.height-98)
        self.view.addSubview(statusView)
        
        // プレイヤー表示.
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
