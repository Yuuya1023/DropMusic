//
//  TodayExtensionData.swift
//  DropMusic
//
//  Copyright © 2020 n.yuuya. All rights reserved.
//

import Foundation

struct TodayExtensionData: Codable {
    
    //
    // MARK: - Properties.
    //
    var title: String = ""
    var album: String = ""
    var artist: String = ""
    var artwork: Data? = nil
    
    
    
    //
    // MARK: - Static.
    //
    /// データ型から変換.
    static func makeFromData(data: Data) -> TodayExtensionData? {
        do {
            let newJson: TodayExtensionData = try JSONDecoder().decode(TodayExtensionData.self, from: data)
            return newJson
        } catch {
            print("json convert failed in JSONDecoder", error.localizedDescription)
        }
        return nil
    }
    
    
}
