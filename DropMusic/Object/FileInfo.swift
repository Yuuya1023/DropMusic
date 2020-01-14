//
//  FileInfo.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation
import SwiftyDropbox

class FileInfo {
    
    //
    // MARK: - Properties.
    //
    var _metaData: Files.Metadata!
    
    
    
    //
    // MARK: - Initialize.
    //
    init(metadata: Files.Metadata!){
        _metaData = metadata
    }
    
    
    
    //
    // MARK: -
    //
    internal func folderMetadata() -> (Files.FolderMetadata) {
        return _metaData as! Files.FolderMetadata
    }
    
    internal func fileMetadata() -> (Files.FileMetadata) {
        return _metaData as! Files.FileMetadata
    }
    
    
    
    //
    // MARK: -
    //
    func getFileType() -> AppManageData.FileType {
        if isFolder() {
            return .Folder
        }
        else if isAudioFile() {
            return .Audio
        }
        return .Other
    }
    
    func isFolder() -> (Bool) {
        return _metaData is Files.FolderMetadata
    }
    
    func isFile() -> (Bool) {
        return _metaData is Files.FileMetadata
    }
    
    func id() -> (String?) {
        if isFile() {
            return fileMetadata().id
        }
        return nil
    }
    
    func name() ->(String) {
        return _metaData.name
    }
    
    func pathLower() -> (String) {
        return _metaData.pathLower!
    }
    
    func pathDisplay() -> String {
        return _metaData.pathDisplay!
    }
    
    func contentHash() -> (String?) {
        if isFile() {
            return fileMetadata().contentHash!
        }
        return nil
    }
    
    func fileExtension() -> (String?) {
        if isFile() {
            return NSString(string: name()).pathExtension
        }
        return nil
    }
    
    func isAudioFile() -> (Bool) {
        if isFile() {
            let ext = fileExtension()
            if ext == "aif" || ext == "aiff" || ext == "caf" || ext == "mp3" || ext == "aac" || ext == "m4a" || ext == "mp4" || ext == "wav" {
                return true
            }
        }
        return false
    }
    
    func localFileName() ->(String?) {
        if isFile() {
            if var id = self.id() {
                if let range = id.range(of: "id:") {
                    id.replaceSubrange(range, with: "")
                }
                return id + "." + fileExtension()!
            }
        }
        return nil
    }
}
