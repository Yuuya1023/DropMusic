//
//  DropBoxRootNavigactionController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import SwiftyDropbox

class DropBoxRootNavigactionController: UINavigationController, UINavigationControllerDelegate {
    
    var _currentFolder: String = ""
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init (){
        var viewController:UIViewController! = nil
        if DropboxClientsManager.authorizedClient != nil {
            viewController = FileListViewController(pathList: [])
        }
        else {
            viewController = DropBoxLinkViewController()
        }
        super.init(rootViewController: viewController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        UINavigationBar.appearance().barTintColor = UIColor.gray
        
        // ログイン.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationLogin(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION_DROPBOX_LOGGED_IN),
                                               object: nil)
        // ログアウト.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(notificationLogout(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION_DROPBOX_LOGGED_OUT),
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc private func notificationLogin(notification: Notification) {
        let controllers = NSArray(object: FileListViewController(pathList: []))
        self.setViewControllers(controllers as! [UIViewController],
                                animated: false)
    }
    
    @objc private func notificationLogout(notification: Notification) {
        let controllers = NSArray(object: DropBoxLinkViewController())
        self.setViewControllers(controllers as! [UIViewController],
                                animated: false)
    }
    
    
}
