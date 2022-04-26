//
//  ZegoUserService.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation
import ZIM

/// The delegate related to the user status callbacks
///
/// Description: Callbacks that be triggered when in-room user status change.
protocol UserServiceDelegate : AnyObject  {
    /// Callbacks related to the user connection status
    ///
    /// Description: This callback will be triggered when user gets disconnected due to network error, or gets offline due to the operations in other clients.
    ///
    /// @param state refers to the current connection state.
    /// @param event refers to the the event that causes the connection status changes.
    func connectionStateChanged(_ state: ZIMConnectionState, _ event: ZIMConnectionEvent)
    /// Callback for new user joins the room
    ///
    /// Description: This callback will be triggered when a new user joins the room, and all users in the room will receive a notification. The in-room user list data will be updated automatically.
    ///
    /// @param userList refers to the latest new-comer user list. Existing users are not included.
    func roomUserJoin(_ users: [UserInfo])
    /// Callback for existing user leaves the room
    ///
    /// Description: This callback will be triggered when an existing user leaves the room, and all users in the room will receive a notification. The in-room user list data will be updated automatically.
    ///
    /// @param userList refers to the list of users who left the room.
    func roomUserLeave(_ users: [UserInfo])
    /// The notification of seat-taking invitation
    ///
    /// Description: The invitee receives a notification when he is be invited to take a speaker seat to speak.
    ///
    func receiveTakeSeatInvitation()
}


/// Class user information management
///
/// Description: This class contains the user information management logics, such as the logic of log in, log out, get the logged-in user info, get the in-room user list, and add co-hosts, etc.
class UserService: NSObject {
    // MARK: - Public
    /// The delegate related to user status
    private let delegates = NSHashTable<AnyObject>.weakObjects()
    /// The local logged-in user information.
    var localInfo: UserInfo?
    /// In-room user list, can be used when displaying the user list in the room.
    var userList = DictionaryArrary<String, UserInfo>()
    
    override init() {
        super.init()
        
        // RoomManager didn't finish init at this time.
        DispatchQueue.main.async {
            RoomManager.shared.addZIMEventHandler(self)
        }
    }
    
    func addUserServiceDelegate(_ delegate: UserServiceDelegate) {
        self.delegates.add(delegate)
    }
    
    /// User to log in
    ///
    /// Description: Call this method with user ID and username to log in to the LiveAudioRoom service.
    ///
    /// Call this method at: After the SDK initialization
    ///
    /// @param userInfo refers to the user information. You only need to enter the user ID and username.
    /// @param token refers to the authentication token. To get this, refer to the documentation: https://doc-en.zego.im/article/11648
    /// @param callback refers to the callback for log in.
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
        
        ZIMManager.shared.zim?.login(with: zimUser, token: token, callback: { error in
            var result: ZegoResult
            if error.code == .success {
                self.localInfo = user
                result = .success(())
            } else {
                result = .failure(.other(Int32(error.code.rawValue)))
            }
            guard let callback = callback else { return }
            callback(result)
        })
    }
    
    /// User to log out
    ///
    /// Description: This method can be used to log out from the current user account.
    ///
    /// Call this method at: After the user login
    func logout() {
        ZIMManager.shared.zim?.logout()
        RoomManager.shared.logoutRtcRoom(true)
    }
    
    /// Invite users to speak
    ///
    /// Description: This method can be called to invite users to take a speaker seat to speak, and the invitee will receive an invitation.
    ///
    /// Call this method at:  After joining a room
    ///
    /// @param userID refers to the ID of the user that you want to invite
    ///
    /// @param callback refers to the callback for invite users to speak
    func sendInvitation(_ userID: String, callback: RoomCallback?) {
        let command: CustomCommand = CustomCommand(type: .invitation)
        command.targetUserIDs = [userID]
        guard let message = command.josnString() else {
            guard let callback = callback else { return }
            callback(.failure(.failed))
            return
        }
        
        guard let messageData = message.data(using: .utf8) else {
            guard let callback = callback else { return }
            callback(.failure(.failed))
            return
        }
        
        let customMessage: ZIMCommandMessage = ZIMCommandMessage(message: messageData)
        let config = ZIMMessageSendConfig()
        config.priority = .low
        ZIMManager.shared.zim?.sendPeerMessage(customMessage, toUserID: userID, config: config, callback: { _, error in
            var result: ZegoResult
            if error.code == .success {
                result = .success(())
            } else {
                result = .failure(.other(Int32(error.code.rawValue)))
            }
            guard let callback = callback else { return }
            callback(result)
        })
    }
    
    /// Get the total number of in-room users
    ///
    /// Description: This method can be called to get the total number of the in-room users.
    ///
    /// Call this method at: After joining a room
    ///
    /// @param callback refers to the callback for get the total number of in-room users.
    func queryOnlineRoomUsersCount(callback: OnlineRoomUsersNumCallback?) {
        guard let roomID = RoomManager.shared.roomService.info.roomID else {
//            assert(false, "room ID can't be nil")
            guard let callback = callback else { return }
            callback(.failure(.failed))
            return
        }
        
        ZIMManager.shared.zim?.queryRoomOnlineMemberCount(byRoomID: roomID, callback: { _, count, error in
            var result: Result<UInt32, ZegoError>
            if error.code == .success {
                result = .success(count)
            } else {
                result = .failure(.other(Int32(error.code.rawValue)))
            }
            guard let callback = callback else { return }
            callback(result)
        })
    }
    
    /// Get the in-room user list
    ///
    /// Description: This method can be called to get the in-room user list.
    ///
    /// Call this method at:  After joining the room
    ///
    /// @param page refers to the page of the in-room user list. Starts from 0, it contains 100 entries of data every page. When the [nextpage] is returned in the callback, it indicates that the user list has a next page, and you need to increase the [page] and call the method again.
    /// @param callback refers to the callback for get the in-room user list.
    func queryOnlineRoomUsersCount(_ page: UInt, callback: OnlineRoomUsersCallback?) {
        guard let roomID = RoomManager.shared.roomService.info.roomID else {
            assert(false, "room ID can't be nil")
            guard let callback = callback else { return }
            callback(.failure(.failed))
            return
        }
        let config = ZIMRoomMemberQueryConfig()
        config.count = 100
        config.nextFlag = String(page)
        ZIMManager.shared.zim?.queryRoomMemberList(byRoomID: roomID, config: config, callback: { _, zimUsers, nextFlag, error in
            if error.code != .success {
                guard let callback = callback else { return }
                callback(.failure(.other(Int32(error.code.rawValue))))
                return
            }
            var users: [UserInfo] = []
            
            for zimUser in zimUsers {
                let role: UserRole = zimUser.userID == RoomManager.shared.roomService.info.hostID ? .host : .listener
                let user = UserInfo(zimUser.userID, zimUser.userName, role)
                users.append(user)
            }
            guard let callback = callback else { return }
            callback(.success(users))
        })
    }
}

extension UserService : ZIMEventHandler {
    func zim(_ zim: ZIM, connectionStateChanged state: ZIMConnectionState, event: ZIMConnectionEvent, extendedData: [AnyHashable : Any]) {
        for obj  in delegates.allObjects {
            let delegate = obj as? UserServiceDelegate
            guard let delegate = delegate else { continue }
            delegate.connectionStateChanged(state, event)
        }
    }
    
    func zim(_ zim: ZIM, roomMemberJoined memberList: [ZIMUserInfo], roomID: String) {
        var addUsers: [UserInfo] = []
        for zimUser in memberList {
            let role: UserRole = zimUser.userID == RoomManager.shared.roomService.info.hostID ? .host : .listener
            let user = UserInfo(zimUser.userID, zimUser.userName, role)
            
            if let oldUserID = user.userID {
                let oldUser = userList.getObj(oldUserID)
                if oldUser == nil {
                    addUsers.append(user)
                }
            }

            guard let userID = user.userID else { continue }
            userList.addObj(userID, user)
            if localInfo?.userID == userID {
                localInfo = user
            }
        }
        
        for obj in delegates.allObjects {
            if let delegate = obj as? UserServiceDelegate {
                delegate.roomUserJoin(addUsers)
            }
        }
    }
    
    func zim(_ zim: ZIM, roomMemberLeft memberList: [ZIMUserInfo], roomID: String) {
        var leftUsers: [UserInfo] = []
        for zimUser in memberList {
            let role: UserRole = zimUser.userID == RoomManager.shared.roomService.info.hostID ? .host : .listener
            let user = UserInfo(zimUser.userID, zimUser.userName, role)
            leftUsers.append(user)
            guard let userID = user.userID else { continue }
            userList.removeObj(userID)
            
            for leftUser in leftUsers {
                for seatModel in RoomManager.shared.speakerService.seatList {
                    if leftUser.userID != "" && leftUser.userID == seatModel.userID {
                        seatModel.userID = ""
                        seatModel.status = RoomManager.shared.roomService.info.isSeatClosed ? .closed : .untaken
                        break
                    }
                }
            }
            
        }
        
        for obj in delegates.allObjects {
            if let delegate = obj as? UserServiceDelegate {
                delegate.roomUserLeave(leftUsers)
            }
        }
    }
    
    // recevie a invitation via this method
    func zim(_ zim: ZIM, receivePeerMessage messageList: [ZIMMessage], fromUserID: String) {
        for message in messageList {
            guard let message = message as? ZIMCommandMessage else { continue }
            guard let jsonStr = String(data: message.message, encoding: .utf8) else { continue }
            guard let dict = ZegoJsonTool.jsonToDictionary(jsonStr) else { continue }
            let type: UInt = dict["actionType"] as? UInt ?? 0
            guard let actionType = CustomCommandType(rawValue: type)  else { continue }
            if actionType != .invitation { continue }
            
            for delegate in delegates.allObjects {
                guard let delegate = delegate as? UserServiceDelegate else { continue }
                delegate.receiveTakeSeatInvitation()
            }
        }
    }
}
