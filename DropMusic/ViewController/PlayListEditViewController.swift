//
//  PlayListEditViewController.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation
import UIKit

class PlayListEditViewController: UIViewController, UITextFieldDelegate {
    
    //
    // MARK: - Properties.
    //
    @IBOutlet var _okButton: UIButton!
    @IBOutlet var _cancelButton: UIButton!
    @IBOutlet var _deleteButton: UIButton!
    @IBOutlet var _textField: UITextField!
    
    var _playlistId: String = ""
    weak var _rootViewController: UIViewController? = nil
    
    
    
    //
    // MARK: - Override.
    //
    override func loadView() {
        let nib = UINib(nibName: "PlayListEditView", bundle: .main)
        self.view = nib.instantiate(withOwner: self).first as? UIView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _cancelButton.addTarget(self, action: #selector(selectorCloseButton(_:)), for: UIControlEvents.touchUpInside)
        _okButton.addTarget(self, action: #selector(selectorApplyButton(_:)), for: UIControlEvents.touchUpInside)
        _deleteButton.addTarget(self, action: #selector(selectorDeleteButton(_:)), for: UIControlEvents.touchUpInside)
        
        _textField.delegate = self
        _textField.returnKeyType = .done
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let data = AppDataManager.sharedManager.playlist.getPlaylistData(id: _playlistId) {
            _textField.text = data.name
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self._textField.isFirstResponder) {
            self._textField.resignFirstResponder()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //
    // MARK: - Selector
    //
    @objc func selectorCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func selectorApplyButton(_ sender: UIButton) {
        AppDataManager.sharedManager.playlist.updatePlaylist(id: _playlistId,
                                                             name: _textField.text!)
        AppDataManager.sharedManager.save()
        
        // 呼び出し元の表示更新.
        if _rootViewController != nil {
            let vc = _rootViewController as! PlayListViewController
            vc.updateScrollView()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func selectorDeleteButton(_ sender: UIButton) {
        AppDataManager.sharedManager.playlist.deletePlaylist(id: _playlistId)
        AppDataManager.sharedManager.save()
        // 呼び出し元の表示更新.
        if _rootViewController != nil {
            let vc = _rootViewController as! PlayListViewController
            vc.updateScrollView()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    //
    // MARK: - TextField Delegate.
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
