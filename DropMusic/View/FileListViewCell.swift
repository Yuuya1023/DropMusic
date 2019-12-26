//
//  FileListViewCell.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

class FileListViewCell: UITableViewCell {
    
    //
    // MARK: - Properties.
    //
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var icon: UIImageView!
    @IBOutlet var progressView: UIProgressView!
    
    var isAudioFile: Bool = false
    var index: Int = 0
    weak var longpressTarget: NSObject? = nil
    var longpressSelector: Selector? = nil
    
    
    
    //
    // MARK: -
    //
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 長押し.
        let tapGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(selectorLongpressLayer(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    
    //
    // MARK: -
    //
    func set(fileInfo: FileInfo?) {
        guard let fileInfo = fileInfo else {
            return
        }
        isAudioFile = fileInfo.isAudioFile()
        nameLabel.text = fileInfo.name()
        
        var iconName = "icon_cell_question.png"
        if fileInfo.isFolder() {
            iconName = "icon_cell_folder.png"
        }
        else if fileInfo.isAudioFile() {
            iconName = "icon_cell_audio.png"
        }
        icon.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        
        var progress: Float = 0.0
        if isAudioFile {
            if DownloadFileManager.sharedManager.isExistAudioFile(fileInfo: fileInfo) {
                progress = 1.0
            }
        }
        setProgress(progress)
        
        if fileInfo.isFile() {
            updateObserber(identifier: fileInfo.id()!)
        }
    }
    
    func setProgress(_ progress: Float) {
        var p = progress
        if p < 0.0 { p = 0.0 }
        else if p > 1.0 { p = 1.0 }
        if isAudioFile {
            if 1.0 == p {
                p = 0.0
                icon.tintColor = UIColor(displayP3Red: 46/255, green: 123/255, blue: 255/255, alpha: 1)
            }
            else {
                icon.tintColor = .lightGray
            }
        }
        else {
            icon.tintColor = .black
        }
        progressView.progress = p
    }
    
    
    func updateObserber(identifier: String) {
        NotificationCenter.default.removeObserver(self)
        if isAudioFile {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(setDownloadProgress(notification:)),
                                                   name: NSNotification.Name(rawValue: identifier),
                                                   object: nil)
        }
    }
    
    
    
    // MARK: -
    @objc func setDownloadProgress(notification: Notification) {
        let p = Float(truncating: notification.object as! NSNumber)
        self.setProgress(p)
    }
    
    @objc func selectorLongpressLayer(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            if longpressTarget != nil && longpressSelector != nil {
                longpressTarget?.perform(longpressSelector, with: self)
            }
        default:
            break
        }
    }
    
    
    // MARK: -
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
