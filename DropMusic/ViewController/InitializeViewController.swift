//
//  InitializeViewController.swift
//  DropMusic
//
//  Copyright © 2020年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class InitializeViewController: UIViewController {
    
    //
    // MARK: - Constant.
    //
    
    
    
    //
    // MARK: - Enumeration.
    //
    enum State {
        case None
        case CheckDropbox
        case CheckDropboxUser
        case CheckAppData
        case Complete
    }
    
    
    
    //
    // MARK: - Properties.
    //
    var _state: State = .None

    
    
    //
    // MARK: - Override.
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = .gray
        
        // ログイン.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationDropboxLogin(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION_DROPBOX_LOGGED_IN),
                                               object: nil)
        
        changeState(.CheckDropbox)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    
    
    //
    // MARK: -
    //
    /// 状態変更.
    func changeState(_ state: State) {
        _state = state
        switch _state {
        case .CheckDropbox:
            // Dropbox読み込み.
            if DropboxClientsManager.authorizedClient != nil {
                self.changeState(.CheckDropboxUser)
            }
            else {
                // ログインボタン表示.
                let button = UIButton()
                button.frame = CGRect(x: self.view.center.x-30,
                                      y: self.view.center.y-30,
                                      width: 60,
                                      height: 60)
                button.setTitle("login",
                                for: .normal)
                button.addTarget(self,
                                 action: #selector(loginDropbox(_:)),
                                 for: .touchUpInside)
                self.view.addSubview(button)
            }
        case .CheckDropboxUser:
            // Dropboxユーザー確認.
            if AppDataManager.sharedManager.dropboxUserName == nil {
                if let client = DropboxClientsManager.authorizedClient {
                    client.users.getCurrentAccount().response {
                        (response, error) in
                        if let account = response {
                            AppDataManager.sharedManager.dropboxUserName = account.name.displayName
                        }
                    }
                }
            }
            self.changeState(.CheckAppData)
        case .CheckAppData:
            // アプリデータ読み込み.
            AppDataManager.sharedManager.checkFile {
                self.changeState(.Complete)
            }
        case .Complete:
            // 画面遷移.
            self.present(RootTabBarController(),
                         animated: false,
                         completion: nil)
            
        default:
            break
        }
    }

    /// ログイン.
    @objc func loginDropbox(_ sender: UIButton) {
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: self,
                                                      openURL: { (url: URL) -> Void in
                                                        UIApplication.shared.open(url,
                                                                                  options: [:],
                                                                                  completionHandler: nil)
        })
    }
    
    /// ログイン通知.
    @objc private func notificationDropboxLogin(notification: Notification) {
        changeState(.CheckDropboxUser)
    }
    
}
