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
    @IBOutlet var favorite: UIImageView!
    @IBOutlet var progressView: UIProgressView!
    
    var isAudioFile: Bool = false
    var index: Int = 0
    weak var longpressTarget: NSObject? = nil
    var longpressSelector: Selector? = nil
    
    
    
    //
    // MARK: - Override.
    //
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // お気に入りアイコン.
        favorite.image = favorite.image?.withRenderingMode(.alwaysTemplate)
        favorite.isHidden = true
//        favorite.tintColor = .yellow
        
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
    // MARK: - Public.
    //
    func set(fileInfo: FileInfo?) {
        guard let fileInfo = fileInfo else {
            return
        }
        isAudioFile = fileInfo.isAudioFile()
        nameLabel.text = fileInfo.name()
        nameLabel.lineBreakMode = .byTruncatingTail
        
        var iconName = "icon_cell_question.png"
        if fileInfo.isFolder() {
            iconName = "icon_cell_folder.png"
        }
        else if fileInfo.isAudioFile() {
            iconName = "icon_cell_audio.png"
        }
        icon.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
//        favorite.isHidden = !AppDataManager.sharedManager.favorite.isFavorite(fileInfo)
        
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
    
    func set(favoriteData: FavoriteData?) {
        guard let favoriteData = favoriteData else {
            return
        }
        isAudioFile = favoriteData.fileType == .Audio
        // 文字列生成.
        let prefix = favoriteData.getParentFolderName()+"/"
        let attributeString = NSMutableAttributedString(string: prefix+favoriteData.name)
        attributeString.addAttribute(.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, prefix.count))
        nameLabel.attributedText = attributeString
        nameLabel.lineBreakMode = .byTruncatingHead
        
        var iconName = "icon_cell_question.png"
        if favoriteData.fileType == .Folder {
            iconName = "icon_cell_folder.png"
        }
        else if favoriteData.fileType == .Audio {
            iconName = "icon_cell_audio.png"
        }
        icon.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
//        favorite.isHidden = !AppDataManager.sharedManager.favorite.isFavorite(favoriteData)
        setProgress(0.0)
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
    
    
    
    //
    // MARK: -
    //
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
    
}
