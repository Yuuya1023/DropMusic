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
    
    
    var _isDownloading: Bool = false
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
        case .None:
            break
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
    
    func getFileCachePath(audioData: AudioData) -> (String) {
        let cachePath: String! = self.getCachePath(storageType: audioData.storageType, add: "/audio")
        let fileName: String! = audioData.localFileName()
        
        return cachePath+"/"+fileName
    }
    
    func getFileCachePath(fileInfo: FileInfo) -> (String) {
        let cachePath: String! = self.getCachePath(storageType: .DropBox, add: "/audio")
        let fileName: String! = fileInfo.localFileName()
        
        return cachePath+"/"+fileName
    }
    
    func isExistAudioFile(audioData: AudioData) -> (Bool){
        return FileManager.default.fileExists(atPath: getFileCachePath(audioData: audioData))
    }
    
    func isExistAudioFile(fileInfo: FileInfo) -> (Bool){
        if fileInfo.isFile() {
            return FileManager.default.fileExists(atPath: getFileCachePath(fileInfo: fileInfo))
        }
        return false
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
    
    
    func addQueue(audioData: AudioData){
        // スタックに積まれている場合はやめる.
        if isStackedQueue(audioData: audioData) {
            return
        }
        if DownloadFileManager.sharedManager.isExistAudioFile(audioData: audioData) {
            return
        }
        // 積む.
        _downloadQueue.append(DownloadQueueData.init(_audioData: audioData,
                                                         _request: nil))
        //  ダウンロード開始.
        downloadNext()
    }
    
    private func downloadNext(){
        // ダウンロード数を通知.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_DOWNLOAD_COUNT),
                                        object: String(_downloadQueue.count))
        if _isDownloading {
            return
        }
        if _downloadQueue.count == 0 {
            return
        }
        _isDownloading = true
        let audioData = _downloadQueue[0]._audioData
        if let client = DropboxClientsManager.authorizedClient {
            // 保存パス.
            let savePath = getFileCachePath(audioData: audioData)
            
            // 保存先.
            let destination : (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
                return URL(fileURLWithPath: savePath)
            }
            
            client.files.download(path: audioData.fullPath(), destination: destination)
                .progress { progressData in
//                    print("bytesRead = totalUnitCount: \(progressData.totalUnitCount)")
//                    print("totalBytesRead = completedUnitCount: \(progressData.completedUnitCount)")
//
//                    print("totalBytesExpectedToRead (Has to sub): \(progressData.totalUnitCount - progressData.completedUnitCount)")
//
//                    print("progressData.fractionCompleted (New)  = \(progressData.fractionCompleted)")
                    // ダウンロードの進捗を通知.
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: audioData.id),
                                                    object: progressData.fractionCompleted-0.1)
                }
                .response { response, error in
                    if let (metadata, url) = response {
//                        print("*** Download file ***")
//                        print("Downloaded file name: \(metadata.name)")
//                        print("Downloaded file url: \(url)")
                        
                        try! FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none], ofItemAtPath: savePath)
                        // キューから消す.
                        self.removeQueue(audioData: audioData)
                        
                        // ダウンロードの進捗を通知.
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: audioData.id),
                                                        object: 1.0)
                        // 次へ.
                        self._isDownloading = false
                        self.downloadNext()
                    } else {
                        print(error!)
                    }
            }
        }
    }
    
    func cancel(audioData: AudioData){
        removeQueue(audioData: audioData)
    }
    
    
}
