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

class UserInfo: NSObject, Codable {
    /// user ID
    var userID: String?
    
    /// user name
    var userName: String?
    
    /// user role
    var role: UserRole = .listener
    
    init(_ userID: String, _ userName: String, _ role: UserRole) {
        self.userID = userID
        self.userName = userName
        self.role = role
    }
}
