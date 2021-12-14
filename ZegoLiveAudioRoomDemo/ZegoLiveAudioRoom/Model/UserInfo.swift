//
//  UserInfo.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation

enum UserRole {
    case Listener
    case Speaker
    case Host
}

struct UserInfo {
    /// user ID
    var userID: String?
    
    /// user name
    var userName: String?
    
    /// user role
    var role: UserRole = .Listener
}
