//
//  UserInfo.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation

/// Enumeration values of the user role
/// User role definition enumeration value
enum UserRole: Codable {
    // Listener
    case listener
    // Speaker
    case speaker
    // Host
    case host
}

/// Class user information
///
/// Description: This class contains the user related information.
class UserInfo: NSObject, Codable {
    /// User ID, refers to the user unique ID, can only contains numbers and letters.
    var userID: String?
    
    /// User name, cannot be null.
    var userName: String?
    
    /// User role
    var role: UserRole = .listener
    
    init(_ userID: String, _ userName: String, _ role: UserRole) {
        self.userID = userID
        self.userName = userName
        self.role = role
    }
}
