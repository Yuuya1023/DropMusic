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
        
        /// メッセージ取得.
        func getMessage() -> String {
            var ret = ""
            switch self {
            case .CheckDropbox:
                ret = "Checking Dropbox..."
            case .CheckDropboxUser:
                ret = "Checking Dropbox Account..."
            case .CheckAppData:
                ret = "Checking App Data..."
            case .Complete:
                ret = "Complete!"
                
            default:
                break
            }
            return ret
        }
        
        /// スキップが有効か.
        func isEnableSkip() -> Bool {
            var ret = false
            switch self {
            case .CheckDropboxUser,
                 .CheckAppData:
                ret = true

            default:
                break
            }
            return ret
        }
        
    }
    
    
    
    //
    // MARK: - Properties.
    //
    @IBOutlet var _launchView: LaunchView!
    @IBOutlet var _messageLabel: UILabel!
    @IBOutlet var _skilButton: UIButton!
    @IBOutlet var _loginButton: UIButton!
    private var _state: State = .None
    
    
    
    //
    // MARK: - Override.
    //
    override func loadView() {
        let nib = UINib(nibName: "InitializeView", bundle: .main)
        self.view = nib.instantiate(withOwner: self).first as? UIView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = .gray
        
        // ログインボタン.
        _loginButton.isHidden = true
        _loginButton.addTarget(self,
                               action: #selector(loginDropbox(_:)),
                               for: .touchUpInside)
        // スキップボタン.
        _skilButton.isHidden = true
        _skilButton.addTarget(self,
                              action: #selector(skip(_:)),
                              for: .touchUpInside)
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
        _messageLabel.text = _state.getMessage()
        _skilButton.isHidden = !_state.isEnableSkip()
        
        switch _state {
        case .CheckDropbox:
            // Dropbox読み込み.
            if DropboxClientsManager.authorizedClient != nil {
                self.changeState(.CheckDropboxUser)
            }
            else {
                // ログインへ.
                _messageLabel.text = ""
//                _launchView.isHidden = true
//                _loginButton.isHidden = false
                loginDropbox()
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
                if self._state == .CheckAppData {
                    self.changeState(.Complete)
                }
            }
            // ファイルリストのキャッシュを読み込み.
            DropboxFileListManager.sharedManager.load()
        case .Complete:
            // 画面遷移.
            let vc = RootTabBarController()
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc,
                         animated: true,
                         completion: nil)
            
        default:
            break
        }
    }

    /// ログイン.
    @objc func loginDropbox(_ sender: UIButton) {
        loginDropbox()
    }
    func loginDropbox() {
        DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                      controller: self,
                                                      openURL: { (url: URL) -> Void in
                                                        UIApplication.shared.open(url,
                                                                                  options: [:],
                                                                                  completionHandler: nil)
        })
    }
    
    /// スキップ.
    @objc func skip(_ sender: UIButton) {
        if !_state.isEnableSkip() {
            return
        }
        switch _state {
        case .CheckAppData:
            changeState(.Complete)
    
        default:
            break
        }
    }
    
    /// ログイン通知.
    @objc private func notificationDropboxLogin(notification: Notification) {
        _launchView.isHidden = false
        _loginButton.isHidden = true
        changeState(.CheckDropboxUser)
    }
    
}
