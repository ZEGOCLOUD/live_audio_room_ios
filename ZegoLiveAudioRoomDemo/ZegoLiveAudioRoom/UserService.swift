//
//  ZegoUserService.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation
import ZIM

protocol UserServiceDelegate : AnyObject  {
    func connectionStateChanged(_ state: ZIMConnectionState, _ event: ZIMConnectionEvent)
    /// user info update
    func userInfoUpdate(_ info: UserInfo?)
    /// receive user join room
    func roomUserJoin(_ users: [UserInfo])
    /// reveive user leave room
    func roomUserLeave(_ users: [UserInfo])
    /// receive custom command: invitation
    func receiveTakeSeatInvitation()
}

extension UserServiceDelegate {
    func userInfoUpdate(_ info: UserInfo?) { }
    func roomUserJoin(_ users: [UserInfo]) { }
    func roomUserLeave(_ users: [UserInfo]) { }
    func receiveTakeSeatInvitation() { }
}

class UserService: NSObject {
    // MARK: - Public
    private let delegates = NSHashTable<AnyObject>.weakObjects()
    var localInfo: UserInfo?
    var userList: [UserInfo] = []
    
    func addUserServiceDelegate(_ delegate: UserServiceDelegate) {
        self.delegates.add(delegate)
    }
    
    /// user login with user info and `ZIM token`
    func login(_ user: UserInfo, _ token: String, callback: RoomCallback?) {
        
        guard let userID = user.userID else {
            guard let callback = callback else { return }
            callback(.failure(.paramInvalid))
            return
        }
        
        guard let userName = user.userName else {
            guard let callback = callback else { return }
            callback(.failure(.paramInvalid))
            return
        }
        
        let zimUser = ZIMUserInfo()
        zimUser.userID = userID
        zimUser.userName = userName
        
        ZIMManager.shared.zim?.login(zimUser, token: token, callback: { error in
            var result: ZegoResult
            if error.code == .ZIMErrorCodeSuccess {
                self.localInfo = user
                result = .success(())
            } else {
                result = .failure(.other(Int32(error.code.rawValue)))
            }
            guard let callback = callback else { return }
            callback(result)
        })
    }
    
    /// user logout
    func logout() {
        ZIMManager.shared.zim?.logout()
        RoomManager.shared.logoutRtcRoom(true)
    }
    
    /// send an invitation to user to take a speaker seat
    func sendInvitation(_ userID: String, callback: RoomCallback?) {
        let command: CustomCommand = CustomCommand(type: .invitation)
        command.targetUserIDs = [userID]
        guard let message = command.josnString() else {
            guard let callback = callback else { return }
            callback(.failure(.failed))
            return
        }
        
        let textMessage: ZIMTextMessage = ZIMTextMessage(message: message)
        
        ZIMManager.shared.zim?.sendPeerMessage(textMessage, toUserID: userID, callback: { _, error in
            var result: ZegoResult
            if error.code == .ZIMErrorCodeSuccess {
                result = .success(())
            } else {
                result = .failure(.other(Int32(error.code.rawValue)))
            }
            guard let callback = callback else { return }
            callback(result)
        })
        
    }
}
