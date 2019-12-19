//
//  RootTabBarController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class RootTabBarController: UITabBarController {

    //
    // MARK: - Properties
    //
    var _statusView: AudioPlayStatusView = AudioPlayStatusView()
    
    
    
    //
    // MARK: -
    //
    
    /// viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().barTintColor = UIColor(displayP3Red: 20/255, green: 29/255, blue: 80/255, alpha: 1)
        
        // タブバーの設定.
        let vc1 = DropBoxRootNavigactionController()
        let vc2 = UINavigationController(rootViewController: PlayListViewController())
        let vc3 = UINavigationController(rootViewController: SettingsViewController())
        
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

        // ステータス表示.
        self.view.addSubview(_statusView)
        
        // プレイヤー表示.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(selectorShowAudioPlayer),
                                               name: NSNotification.Name(rawValue: NOTIFICATION_SHOW_AUDIO_PLAYER_VIEW),
                                               object: nil)
        // ダウンロード数更新.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(selectorUpdateDownloadCount),
                                               name: NSNotification.Name(rawValue: NOTIFICATION_DOWNLOAD_COUNT),
                                               object: nil)
    }
    
    /// viewWillLayoutSubviews
    override func viewWillLayoutSubviews() {
        // ステータス表示初期化.
        let tabbarHeight = self.tabBar.frame.size.height+_statusView.frame.height
        let frame = CGRect(x: 0,
                           y: self.view.bounds.height-tabbarHeight,
                           width: _statusView.frame.width,
                           height: _statusView.frame.height)
        _statusView.frame = frame
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
    
    @objc private func selectorUpdateDownloadCount(notification: Notification) {
        let value : String = notification.object as! String
        self.tabBar.items![0].badgeValue = value == "0" ? nil : value
//        self.tabBarController?.viewControllers?[0].tabBarItem.badgeValue = value
    }
}


extension RootTabBarController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AudioPlayerPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
