//
//  MusicPlayerViewControlloer.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import AVFoundation
import TwitterKit

class MusicPlayerViewControlloer: UIViewController {
    
    
    var _titleLabel: UILabel = UILabel()
    var _albumLabel: UILabel = UILabel()
    var _artistLabel: UILabel = UILabel()
    var _artwork: UIImageView = UIImageView()
    
    var _repeatButton: UIButton = UIButton()
    var _playlistButton: UIButton = UIButton()
    var _twitterButton: UIButton = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        
        _titleLabel.frame = CGRect(x:0, y:350, width:self.view.bounds.width, height:30)
        _titleLabel.textAlignment = .center
        _titleLabel.font = UIFont.systemFont(ofSize: 30)
        self.view.addSubview(_titleLabel)
        
        _artistLabel.frame = CGRect(x:0, y:390, width:self.view.bounds.width, height:30)
        _artistLabel.textAlignment = .center
        self.view.addSubview(_artistLabel)
        
        _albumLabel.frame = CGRect(x:0, y:410, width:self.view.bounds.width, height:30)
        _albumLabel.textAlignment = .center
        self.view.addSubview(_albumLabel)
        
        _artwork.frame = CGRect(x:self.view.bounds.width/2 - 125, y:50, width:250, height:250)
        self.view.addSubview(_artwork)
        
        let y = 460
        _repeatButton.setImage(UIImage(named: "icon_repeat_one.png"), for: .normal)
        _repeatButton.frame = CGRect(x:30, y:y, width:40, height:40)
        _repeatButton.addTarget(self, action: #selector(selectorRepeatButton(_:)), for: .touchUpInside)
        self.view.addSubview(_repeatButton)
        
        _playlistButton.setImage(UIImage(named: "icon_playlist.png"), for: .normal)
        _playlistButton.frame = CGRect(x:180, y:y, width:40, height:40)
        _playlistButton.addTarget(self, action: #selector(selectorPlaylistButton(_:)), for: .touchUpInside)
        self.view.addSubview(_playlistButton)
        
        _twitterButton.setImage(UIImage(named: "icon_twitter.png"), for: .normal)
        _twitterButton.frame = CGRect(x:250, y:y, width:40, height:40)
        _twitterButton.addTarget(self, action: #selector(selectorTwitterButton(_:)), for: .touchUpInside)
        self.view.addSubview(_twitterButton)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _titleLabel.text = ""
        _albumLabel.text = ""
        _artistLabel.text = ""
        _artwork.image = UIImage()
        
        let assetData = AudioPlayManager.sharedManager._assetData
        if assetData == nil {
            return
        }
        
        let metadata: Array = assetData!.commonMetadata
        
        for item in metadata {
            switch item.commonKey {
            case AVMetadataKey.commonKeyTitle:
                _titleLabel.text = item.stringValue
            case AVMetadataKey.commonKeyAlbumName:
                _albumLabel.text = item.stringValue
            case AVMetadataKey.commonKeyArtist:
                _artistLabel.text = item.stringValue
            case AVMetadataKey.commonKeyArtwork:
                _artwork.image = UIImage(data: item.dataValue!)
            default:
                break
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // MARK: -
    @objc func selectorRepeatButton(_ sender: UIButton) {
        let next: AudioPlayManager.RepeatType
        let type = AudioPlayManager.sharedManager._repeatType
        switch type {
        case .one:
            next = .list
        case .list:
            next = .one
        }
        
        switch next {
        case .one:
            _repeatButton.setImage(UIImage(named: "icon_repeat_one.png"), for: .normal)
        case .list:
            _repeatButton.setImage(UIImage(named: "icon_repeat.png"), for: .normal)
        }
        
        AudioPlayManager.sharedManager._repeatType = next
    }
    
    @objc func selectorPlaylistButton(_ sender: UIButton) {
        
    }
    
    @objc func selectorTwitterButton(_ sender: UIButton) {
        if !AudioPlayManager.sharedManager.isPlaying() {
            return
        }
        
        func tweet() {
            let twitter = TWTRComposer()
            twitter.setText( _titleLabel.text! + " - " + _albumLabel.text! + " #DJさとし")
            twitter.setImage(_artwork.image)
            twitter.show(from: self, completion: nil)
        }
        
        if TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers() {
            tweet()
        }
        else {
            TWTRTwitter.sharedInstance().logIn { success, error in
//                print(success)
//                print(error)
                tweet()
            }
        }
    
    }
}
