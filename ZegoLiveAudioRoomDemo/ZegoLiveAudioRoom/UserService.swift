//
//  ZegoUserService.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation

protocol UserServiceDelegate: AnyObject {
    /// user info update
    func userInfoUpdate(_ info: UserInfo?)
    /// receive member join room
    func roomMemberJoin(_ members: [UserInfo])
    /// reveive member leave room
    func roomMemberLeave(_ members: [UserInfo])
}

class UserService {
    // MARK: - Public
    weak var delegate: UserServiceDelegate?
    var localInfo: UserInfo?
    var userList: [UserInfo] = []
    
    /// user login with user info and `ZIM token`
    func login(_ info: UserInfo, _ token: String, callback: CommonHandler) {
        
    }
    
    /// user logout
    func logout() {
        
    }
}
