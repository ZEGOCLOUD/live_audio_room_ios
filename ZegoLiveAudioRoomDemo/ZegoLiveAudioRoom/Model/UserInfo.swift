//
//  UserInfo.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation

enum UserRole: Codable {
    case listener
    case speaker
    case host
}

struct UserInfo: Codable {
    /// user ID
    var userID: String?
    
    /// user name
    var userName: String?
    
    /// user role
    var role: UserRole = .listener
}
