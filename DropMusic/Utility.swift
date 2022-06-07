//
//  Utility.swift
//  DropMusic
//
//  Copyright © 2022 n.yuuya. All rights reserved.
//

import UIKit
import Foundation
import SwiftyDropbox

class Utility {

    static func topViewController() -> UIViewController? {
        var vc = UIApplication.shared.keyWindow?.rootViewController
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }
        return vc
    }
    
    static func topViewController(controller: UIViewController?) -> UIViewController? {
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }

        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }

        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }

        return controller
    }
    
    static func alertLinkDropbox(viewController: UIViewController?, title: String, message: String?) {
        guard let vc = viewController else {
            return
        }
        
        let alert: UIAlertController = UIAlertController(title: title,
                                                         message: (message != nil) ? message : "Would you link DropBox Account?",
                                                         preferredStyle: .alert)
        // リンク.
        let okAction:UIAlertAction =
            UIAlertAction(title: "Link Dropbox",
                          style: .default,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                                          controller: vc,
                                                                          openURL: { (url: URL) -> Void in
                                                                            UIApplication.shared.open(url,
                                                                                                      options: [:],
                                                                                                      completionHandler: nil)
                            })
            })
        
        // キャンセル.
        let cancelAction:UIAlertAction =
            UIAlertAction(title: "Close",
                          style: .cancel,
                          handler:{
                            (action:UIAlertAction!) -> Void in
                            // 閉じるだけ.
            })
        
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        // ipad.
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert.popoverPresentationController?.sourceView = vc.view
            let screenSize = UIScreen.main.bounds
            alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2,
                                                                     y: screenSize.size.height,
                                                                     width: 0,
                                                                     height: 0)
        }
        vc.present(alert, animated: true, completion: nil)
    }

}
