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
    
    //
    // MARK: - Singleton.
    //
    static let sharedManager = DownloadFileManager()
    
    
    
    //
    // MARK: - Properties.
    //
    struct DownloadQueueData {
        var _audioData: AudioData
        var _request: DownloadRequestFile<Files.FileMetadataSerializer, Files.DownloadErrorSerializer>?
    }
    
    var _backgroundTaskIdentifier: UIBackgroundTaskIdentifier = 0
    var _isStartDownload: Bool = false
    var _isDownloading: Bool = false
    var _downloadQueue: [DownloadQueueData] = []
    
    
    
    //
    // MARK: -
    //
    
    private init() {
    }
    
    private func createDirectory(path: String) ->(Bool){
        do {
            if !FileManager.default.fileExists(atPath: path) {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: false , attributes: nil)
            }
            
        } catch {
            return false
        }
        return true
    }
    
    public func getCachePath(storageType: AppManageData.StorageType, add: String) ->(String){
        var storageTypePath = ""
        switch storageType {
        case .None:
            break
        case .DropBox:
            storageTypePath = "/dropbox"
            
        default:
            break
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
        let cachePath = self.getCachePath(storageType: audioData.storageType, add: "/audio")
        let fileName = audioData.localFileName()
        
        return cachePath+"/"+fileName
    }
    
    func getFileCachePath(fileInfo: FileInfo) -> (String) {
        guard let fileName = fileInfo.localFileName() else {
            return ""
        }
        let cachePath = self.getCachePath(storageType: .DropBox, add: "/audio")
        
        return cachePath+"/"+fileName
    }
    
    func isExistAudioFile(audioData: AudioData) -> (Bool){
        return FileManager.default.fileExists(atPath: getFileCachePath(audioData: audioData))
    }
    
    func isExistAudioFile(fileInfo: FileInfo) -> (Bool){
        if fileInfo.getType() == .Audio {
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
    
    /// キューからファイル削除.
    func removeQueue(audioData: AudioData){
        var index = 0
        for queue in _downloadQueue {
            if audioData.isEqualData(audioData: queue._audioData) {
                if let req = queue._request {
                    req.cancel()
                }
                _downloadQueue.remove(at: index)
                return
            }
            index = index+1
        }
    }
    
    /// ファイルが積まれているか.
    func isStackedQueue(audioData: AudioData) ->(Bool){
        for queue in _downloadQueue {
            if audioData.isEqualData(audioData: queue._audioData) {
                return true
            }
        }
        return false
    }
    
    /// キューにファイル追加.
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
    }
    
    /// ダウンロード開始.
    public func startDownload(){
        if _isStartDownload {
            return
        }
        _isStartDownload = true
        // バックグランド処理登録.
        _backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            self.endDownload()
        })
        // ダウンロードへ.
        downloadNext()
    }
    
    /// 次のファイルをダウンロード.
    private func downloadNext(){
        // ダウンロード数を通知.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_DOWNLOAD_COUNT),
                                        object: String(_downloadQueue.count))
        if _isDownloading {
            return
        }
        if _downloadQueue.count == 0 {
            endDownload()
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
                    if let (_, _) = response {
//                        print("*** Download file ***")
//                        print("Downloaded file name: \(metadata.name)")
//                        print("Downloaded file url: \(url)")
                        
                        try! FileManager.default.setAttributes([FileAttributeKey.protectionKey: FileProtectionType.none], ofItemAtPath: savePath)
                        // キューから消す.
                        self.removeQueue(audioData: audioData)
                        
                        // ダウンロードの進捗を通知.
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: audioData.id),
                                                        object: 1.0)
                    } else {
                        if (error != nil) {
                            print(error!)
                            // キューから消す.
                            self.removeQueue(audioData: audioData)
                        }
                    }
                    // 次へ.
                    self._isDownloading = false
                    self.downloadNext()
                }
        }
    }
    
    /// キャンセル.
    func cancel(audioData: AudioData){
        removeQueue(audioData: audioData)
    }
    
    /// ダウンロード終了処理.
    private func endDownload() {
        _isStartDownload = false
        UIApplication.shared.endBackgroundTask(_backgroundTaskIdentifier)
    }
    
}
