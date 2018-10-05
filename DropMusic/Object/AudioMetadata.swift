//
//  AudioMetadata.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class AudioMetadata {
    
    var title: String = ""
    var album: String = ""
    var artist: String = ""
    var artwork: UIImage? = nil
    
    init(){
        internalInit()
    }
    
    private func internalInit() {
        title = ""
        album = ""
        artist = ""
        artwork = nil
    }
    
    func set(atPath: String) -> Bool {
        internalInit()
        if FileManager.default.fileExists(atPath: atPath) {
            let assetData: AVAsset = AVAsset(url: URL(fileURLWithPath:atPath))
            let metadata: Array = assetData.commonMetadata
            for item in metadata {
                switch item.commonKey {
                case AVMetadataKey.commonKeyTitle:
                    title = item.stringValue!
                case AVMetadataKey.commonKeyAlbumName:
                    album = item.stringValue!
                case AVMetadataKey.commonKeyArtist:
                    artist = item.stringValue!
                case AVMetadataKey.commonKeyArtwork:
                    artwork = UIImage(data: item.dataValue!)
                default:
                    break
                }
            }
            return true
        }
        return false
    }
}
