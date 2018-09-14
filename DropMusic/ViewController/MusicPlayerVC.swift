//
//  MusicPlayerViewControlloer.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import AVFoundation

class MusicPlayerViewControlloer: UIViewController {
    
    var _titleLabel: UILabel = UILabel()
    var _albumLabel: UILabel = UILabel()
    var _artistLabel: UILabel = UILabel()
    var _artwork: UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.white
        
        _titleLabel.frame = CGRect(x:0, y:400, width:self.view.bounds.width, height:30)
        _titleLabel.textAlignment = .center
        _titleLabel.font = UIFont.systemFont(ofSize: 30)
        self.view.addSubview(_titleLabel)
        
        _artistLabel.frame = CGRect(x:0, y:440, width:self.view.bounds.width, height:30)
        _artistLabel.textAlignment = .center
        self.view.addSubview(_artistLabel)
        
        _albumLabel.frame = CGRect(x:0, y:460, width:self.view.bounds.width, height:30)
        _albumLabel.textAlignment = .center
        self.view.addSubview(_albumLabel)
        
        _artwork.frame = CGRect(x:self.view.bounds.width/2 - 125, y:100, width:250, height:250)
        self.view.addSubview(_artwork)
        
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
    
    
}
