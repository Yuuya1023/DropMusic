//
//  AppDelegate.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox
import TwitterKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //
    // MARK: - Properties
    //
    var window: UIWindow?

    
    
    //
    // MARK: -
    //
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // DropBox.
        DropboxClientsManager.setupWithAppKey(DROPBOX_APP_KEY)
        // Twitter.
        TWTRTwitter.sharedInstance().start(withConsumerKey: TWITTER_CONSUMER_KEY,
                                           consumerSecret: TWITTER_CONSUMER_SECRET_KEY)
        // AudioPlayManager.
        _ = AudioPlayManager.sharedManager
        
        // ViewController.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = InitializeViewController()
        self.window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        // 再生状況の保存.
        AudioPlayManager.sharedManager.saveStatus()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success:
                print("Success! User is logged into Dropbox.")
                NotificationCenter.default.post(name: Notification.Name(NOTIFICATION_DROPBOX_LOGGED_IN), object: nil)
            case .cancel:
                print("Authorization flow was manually canceled by user!")
            case .error(_, let description):
                print("Error: \(description)")
            }
        }
        if TWTRTwitter.sharedInstance().application(app, open: url, options: options) {
            return true
        }
        return true
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        guard let event = event else {
            return
        }
        switch event.subtype {
        case .remoteControlPlay:
            _ = AudioPlayManager.sharedManager.play()
        case .remoteControlPause:
            AudioPlayManager.sharedManager.pause()
        case .remoteControlStop:
            AudioPlayManager.sharedManager.pause()
        case .remoteControlNextTrack:
            AudioPlayManager.sharedManager.playNext(isContinuePlay: AudioPlayManager.sharedManager.isPlaying())
        case .remoteControlPreviousTrack:
            AudioPlayManager.sharedManager.playBack()
            
        default:
            break
        }
    }
}

