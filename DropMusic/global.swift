//
//  global.swift
//  DropMusic
//
//  Copyright © 2018年 n.yuuya. All rights reserved.
//

import UIKit

//
// MARK: - Accounts.
//
let DROPBOX_APP_KEY = ""
let TWITTER_CONSUMER_KEY = ""
let TWITTER_CONSUMER_SECRET_KEY = ""



//
// MARK: - Notification.
//
let NOTIFICATION_DROPBOX_LOGGED_IN  = "DropBoxLoggedIn"
let NOTIFICATION_DID_CHANGE_AUDIO = "DidChangeAudio"
let NOTIFICATION_DID_CHANGE_PLAY_STATUS = "DidChangePlayStatus"
let NOTIFICATION_SHOW_AUDIO_PLAYER_VIEW = "ShowAudioPlayerView"
let NOTIFICATION_DOWNLOAD_COUNT = "DownloadCount"



//
// MARK: - UserDefaults.
//
let USER_DEFAULT_TWITTER_NAME = "twittername"
let USER_DEFAULT_DROPBOX_USERNAME = "dropboxusername"
let USER_DEFAULT_AUDIO_STATUS = "audioplaystatus"
let USER_DEFAULT_PLAY_AUDIO = "audio"
let USER_DEFAULT_FILE_LIST_CACHE = "filelistcache"




//
// MARK: - Color.
//
class AppColor {
    
    static let main     = UIColor(red: 40/255, green: 50/255, blue: 100/255, alpha: 1)
    static let maintab  = UIColor(red: 20/255, green: 30/255, blue: 80/255, alpha: 1)
    static let sub      = UIColor.white
    static let accent   = UIColor(red: 230/255, green: 92/255, blue: 122/255, alpha: 1)

}
