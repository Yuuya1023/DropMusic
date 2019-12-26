//
//  PlayListEditViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation
import UIKit

class PlayListEditViewController: UIViewController, UITextFieldDelegate {
    
    private var textField: UITextField! = UITextField()
    private var playlistId: String! = ""
    
    var rootViewController: UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            let button = UIButton()
            button.frame = CGRect(x: 60, y: 300, width: 80, height: 40)
            button.setTitle("close", for: UIControlState.normal)
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1
            button.addTarget(self, action: #selector(selectorCloseButton(_:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(button)
        }
        do{
            let button = UIButton()
            button.frame = CGRect(x: 160, y: 300, width: 80, height: 40)
            button.setTitle("apply", for: UIControlState.normal)
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1
            button.addTarget(self, action: #selector(selectorApplyButton(_:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(button)
        }
        do{
            let button = UIButton()
            button.frame = CGRect(x: 160, y: 400, width: 80, height: 40)
            button.setTitle("delete", for: UIControlState.normal)
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1
            button.addTarget(self, action: #selector(selectorDeleteButton(_:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(button)
        }
        
        textField.frame = CGRect(x: self.view.frame.width / 2 - 100, y: 200, width: 200, height: 30)
        textField.delegate = self
        textField.returnKeyType = .done
        textField.borderStyle = .roundedRect
        
        self.view.addSubview(textField)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: -
    func setPlaylistId(id: String) {
        playlistId = id
        
        let data: PlayListData? = AppDataManager.sharedManager.playlist.getPlaylistData(id: playlistId)
        if data != nil {
            textField.text = data?.name
        }
    }
    
    
    
    // MARK: - Selector
    @objc func selectorCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func selectorApplyButton(_ sender: UIButton) {
        AppDataManager.sharedManager.playlist.updatePlaylist(id: playlistId,
                                                             name: textField.text!)
        AppDataManager.sharedManager.save()
        
        // 呼び出し元の表示更新.
        if rootViewController != nil {
            let vc = rootViewController as! PlayListViewController
            vc.updateScrollView()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func selectorDeleteButton(_ sender: UIButton) {
        AppDataManager.sharedManager.playlist.deletePlaylist(id: playlistId)
        AppDataManager.sharedManager.save()
        // 呼び出し元の表示更新.
        if rootViewController != nil {
            let vc = rootViewController as! PlayListViewController
            vc.updateScrollView()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // MARK: - TextField Delegate.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    // MARK: -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.textField.isFirstResponder) {
            self.textField.resignFirstResponder()
        }
    }
}
