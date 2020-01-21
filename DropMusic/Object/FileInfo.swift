//
//  FileInfo.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import Foundation
import SwiftyDropbox

class FileInfo: Codable {
    
    //
    // MARK: - Properties.
    //
    private(set) var isFile: Bool = false
    private(set) var id: String = ""
    private(set) var name: String = ""
    private(set) var path: String = ""
    private(set) var hash: String = ""
    
    
    
    //
    // MARK: - Static.
    //
    static func make(metadata: Files.Metadata?) -> FileInfo? {
        guard let metadata = metadata else {
            return nil
        }
        
        let ret = FileInfo()
        if metadata is Files.FolderMetadata {
            ret.isFile = false
            let folder = metadata as! Files.FolderMetadata
            ret.id = folder.id
            ret.name = folder.name
            ret.path = folder.pathDisplay ?? ""
        }
        else if metadata is Files.FileMetadata {
            ret.isFile = true
            let file = metadata as! Files.FileMetadata
            ret.id = file.id
            ret.name = file.name
            ret.path = file.pathLower ?? ""
            ret.hash = file.contentHash ?? ""
        }
        return ret
    }
    
    
    
    //
    // MARK: - Public.
    //
    /// ファイルタイプの取得.
    func getType() -> AppManageData.FileType {
        if isFile {
            if isAudioFile() {
                return .Audio
            }
            else {
                return .Other
            }
        }
        return .Folder
    }
    
    /// 拡張子の取得.
    func fileExtension() -> (String?) {
        if isFile {
            return NSString(string: name).pathExtension
        }
        return nil
    }
    
    /// 音楽ファイルか.
    func isAudioFile() -> Bool {
        if isFile {
            let ext = fileExtension()
            if ext == "aif" || ext == "aiff" || ext == "caf" || ext == "mp3" || ext == "aac" || ext == "m4a" || ext == "mp4" || ext == "wav" {
                return true
            }
        }
        return false
    }
    
    /// ローカルファイル名.
    func localFileName() -> String? {
        if isFile {
            var id = self.id
            if let range = id.range(of: "id:") {
                id.replaceSubrange(range, with: "")
            }
            return id + "." + fileExtension()!
        }
        return nil
    }
    
}
