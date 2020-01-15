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
    
    //
    // MARK: - Properties.
    //
    fileprivate(set) var title: String = ""
    fileprivate(set) var album: String = ""
    fileprivate(set) var artist: String = ""
    fileprivate(set) var artwork: UIImage? = nil
    
    
    
    //
    // MARK: - Initialize.
    //
    /// 初期化.
    init(){
        internalInit()
    }
    
    
    
    //
    // MARK: - Private.
    //
    /// 変数初期化.
    private func internalInit() {
        title = ""
        album = ""
        artist = ""
        artwork = nil
    }
    
    
    
    //
    // MARK: - Public.
    //
    /// 曲情報を設定.
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
