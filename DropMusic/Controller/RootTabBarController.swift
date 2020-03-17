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
    // MARK: - Enumeration.
    //
    enum Tab: Int {
        case File
        case Playlist
        case Favorite
        case Settings
        
        func title() -> String {
            switch self {
            case .File:
                return "File"
            case .Playlist:
                return "Playlist"
            case .Favorite:
                return "Favorite"
            case .Settings:
                return "Settings"
            }
        }
    }

    
    
    //
    // MARK: - Properties.
    //
    var _statusView: AudioPlayStatusView = AudioPlayStatusView()
    var _playerViewController: MusicPlayerViewController = MusicPlayerViewController()
    
    
    
    //
    // MARK: - Override.
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.delegate = self
        self.view.backgroundColor = .white
        UITabBar.appearance().tintColor = AppColor.sub
        UITabBar.appearance().barTintColor = AppColor.maintab
        
        // タブバーの設定.
        let vc1 = UINavigationController(rootViewController: FileListViewController(pathList: []))
        let vc2 = UINavigationController(rootViewController: PlayListViewController())
        let vc3 = UINavigationController(rootViewController: FavoriteListViewController())
        let vc4 = UINavigationController(rootViewController: SettingsViewController())
        
        let size = CGSize(width: 25, height: 25)
        vc1.tabBarItem = UITabBarItem(title: Tab.File.title(),
                                      image: UIImage(named: "tab_cloud.png")?.resizeImage(reSize: size),
                                      tag: Tab.File.rawValue)
        vc2.tabBarItem = UITabBarItem(title: Tab.Playlist.title(),
                                      image: UIImage(named: "tab_playlist.png")?.resizeImage(reSize: size),
                                      tag: Tab.Playlist.rawValue)
        vc3.tabBarItem = UITabBarItem(title: Tab.Favorite.title(),
                                      image: UIImage(named: "tab_favorite.png")?.resizeImage(reSize: CGSize(width: 30, height: 30)),
                                      tag: Tab.Favorite.rawValue)
        vc4.tabBarItem = UITabBarItem(title: Tab.Settings.title(),
                                      image: UIImage(named: "tab_settings.png")?.resizeImage(reSize: size),
                                      tag: Tab.Settings.rawValue)
        
        self.setViewControllers([vc1, vc2, vc3, vc4], animated: false)

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

    
    
    //
    // MARK: - Private.
    //
    @objc private func selectorShowAudioPlayer(notification: Notification) {
        present(_playerViewController, animated: true, completion: nil)
    }
    
    @objc private func selectorUpdateDownloadCount(notification: Notification) {
        let value = notification.object as! String
        self.tabBar.items![0].badgeValue = value == "0" ? nil : value
//        self.tabBarController?.viewControllers?[0].tabBarItem.badgeValue = value
    }
    
    /// UIViewControllerのアニメーション.
    private func animateTabContents(_ toIndex: Int) {
        guard let tabViewControllers = self.viewControllers else {
            return
        }
        guard let selectedViewController = self.selectedViewController else {
            return
        }
        guard let fromView = selectedViewController.view else {
            return
        }
        guard let toView = tabViewControllers[toIndex].view else {
            return
        }
        // タブ切り替え対象のインデックス値を取得.
        guard let fromIndex = tabViewControllers.lastIndex(of: selectedViewController) else {
            return
        }
        if fromIndex == toIndex {
            return
        }
        // 遷移元のViewの親Viewへ遷移先のViewを追加する.
        guard let superview = fromView.superview else {
            return
        }
        superview.addSubview(toView)
        
        
        // 左右どちらにスライドするかを決める.
        let screenWidth = UIScreen.main.bounds.size.width/2
        let shouldScrollRight = toIndex > fromIndex
        let moveWidth = shouldScrollRight ? screenWidth/2 : -screenWidth/2
        toView.center = CGPoint(x: fromView.center.x + moveWidth, y: toView.center.y)
        toView.alpha = 0.0
        
        view.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
//            fromView.alpha = 0.0
            toView.center = CGPoint(x: toView.center.x - moveWidth, y: toView.center.y)
            toView.alpha = 1.0
        }, completion: { finished in
            // 遷移元のViewを削除にしてUserInteractionを有効にする.
            fromView.removeFromSuperview()
            self.selectedIndex = toIndex
            self.view.isUserInteractionEnabled = true
        })
    }
    
}



////
//// MARK: - UIViewControllerTransitioningDelegate.
////
//extension RootTabBarController: UIViewControllerTransitioningDelegate {
//    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//        return AudioPlayerPresentationController(presentedViewController: presented, presenting: presenting)
//    }
//}



//
// MARK: - UITabBarControllerDelegate.
//
extension RootTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // 移動する先のインデックス値を取得する
        guard let tabViewControllers = tabBarController.viewControllers else {
            return false
        }
        guard let toIndex = tabViewControllers.lastIndex(of: viewController) else {
            return false
        }
        // アニメーション実行.
        animateTabContents(toIndex)
        return true
    }
}
