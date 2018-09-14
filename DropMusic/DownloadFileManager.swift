//
//  DownloadFileManager.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit
import Foundation
import SwiftyDropbox

class DownloadFileManager  {
    
    struct DownloadQueueData {
        var _audioData: AudioData
        var _request: DownloadRequestFile<Files.FileMetadataSerializer, Files.DownloadErrorSerializer>?
    }
    
    var _downloadQueue: [DownloadQueueData] = []
    
    static let sharedManager = DownloadFileManager()
    private init() {
    }
    
    func createDirectory(path: String) ->(Bool){
        do {
            if !FileManager.default.fileExists(atPath: path) {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false , attributes: nil)
            }
            
        } catch {
            return false
        }
        return true
    }
    
    public func getCachePath(storageType: AudioData.StorageType, add: String) ->(String){
        var storageTypePath = ""
        switch storageType {
            case .DropBox:
                storageTypePath = "/dropbox"
//            default: break
        }
        
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + storageTypePath
        if createDirectory(path: path) {
            if add != "" {
                let p = path + add
                if createDirectory(path: p) {
                    return p
                }
            }
            return path
        }
        return ""
    }
    
    func isExistAudioFile(audioData: AudioData) -> (Bool){
        let cachePath = getCachePath(storageType: audioData._storageType, add: "/audio")
        let fileName = audioData.localFileName()
        
        return FileManager.default.fileExists(atPath: cachePath+"/"+fileName)
    }
    
//    func removeAllDownloadTask(){
//        for queue in _downloadQueue {
//            queue._request?.cancel()
//            _downloadQueue.remove(at: index)
//        }
//    }
    
    func removeQueue(audioData: AudioData){
        var index = 0
        for queue in _downloadQueue {
            if audioData.isEqualData(audioData: queue._audioData) {
                queue._request?.cancel()
                _downloadQueue.remove(at: index)
                return
            }
            index = index+1
        }
    }
    
    func isStackedQueue(audioData: AudioData) ->(Bool){
        for queue in _downloadQueue {
            if audioData.isEqualData(audioData: queue._audioData) {
                return true
            }
        }
        return false
    }
    
    func download(audioData: AudioData) {
        // スタックに積まれている場合はやめる.
        if isStackedQueue(audioData: audioData) {
            return
        }
        
        if let client = DropboxClientsManager.authorizedClient {
            // 保存先.
            let destination : (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
                let cachePath = self.getCachePath(storageType: audioData._storageType, add: "/audio")
                let fileName = audioData.localFileName()
                return URL(fileURLWithPath: cachePath+"/"+fileName)
            }
            
            // 積む.
            _downloadQueue.append(DownloadQueueData(_audioData: audioData,
                                                    _request: client.files.download(path: audioData.fullPath(), destination: destination)
                                                        .progress { progressData in
                                                            
                                                            print("bytesRead = totalUnitCount: \(progressData.totalUnitCount)")
                                                            print("totalBytesRead = completedUnitCount: \(progressData.completedUnitCount)")
                                                            
                                                            print("totalBytesExpectedToRead (Has to sub): \(progressData.totalUnitCount - progressData.completedUnitCount)")
                                                            
                                                            print("progressData.fractionCompleted (New)  = \(progressData.fractionCompleted)")
                                                        }
                                                        .response { response, error in
                                                            
                                                            if let (metadata, url) = response {
                                                                print("*** Download file ***")
                                                                print("Downloaded file name: \(metadata.name)")
                                                                print("Downloaded file url: \(url)")
                                                                // キューから消す.
                                                                self.removeQueue(audioData: audioData)
                                                                
                                                                AudioPlayManager.sharedManager.play(audioData: audioData)
                                                            } else {
                                                                print(error!)
                                                            }
            }))
        }
    }
    
    func cancel(audioData: AudioData){
        removeQueue(audioData: audioData)
    }
    
}
