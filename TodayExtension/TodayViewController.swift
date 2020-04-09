//
//  TodayViewController.swift
//  TodayExtension
//
//  Copyright © 2020 n.yuuya. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    //
    // MARK: - Properties.
    //
    @IBOutlet var _artwork: UIImageView!
    @IBOutlet var _titleLabel: UILabel!
    @IBOutlet var _descLabel: UILabel!
    @IBOutlet var _button: UIButton!
        
    
    
    //
    // MARK: - Override.
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("viewdidload")
//        self.preferredContentSize = CGSize(width: 0, height: 90)
//        view.translatesAutoresizingMaskIntoConstraints = true
        _button.addTarget(self, action: #selector(selectorButton(_:)), for: .touchUpInside)
    }
     
    
    
    //
    // MARK: -
    //
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        if let defaults = UserDefaults(suiteName: "group.DropMusic") {
            if let data = defaults.data(forKey: "data") {
                if let extensionData = TodayExtensionData.makeFromData(data: data) {
//                    print(extensionData)
//                    print("data loaded ")
                    // アートワーク.
                    if let imageData = extensionData.artwork {
                        _artwork.image = UIImage(data: imageData)
                    }
                    // タイトル.
                    _titleLabel.text = extensionData.title
                    // 説明.
                    _descLabel.text = extensionData.artist + " ─ " + extensionData.album
                }
            }
        }
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @objc func selectorButton(_ sender: UIButton) {
        let url = URL(string: "DropMusic://")
        extensionContext?.open(url!, completionHandler: nil)
    }
}
