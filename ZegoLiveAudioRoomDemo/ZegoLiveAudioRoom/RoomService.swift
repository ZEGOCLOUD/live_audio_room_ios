//
//  ZegoRoomService.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation
import ZIM
import ZegoExpressEngine

/// The delegate related to room status callbacks
///
/// Description: Callbacks that be triggered when room status changes.
protocol RoomServiceDelegate: AnyObject {
    /// Callback for the room status update
    ///
    /// Description: This callback will be triggered when the text chat is disabled or there is a speaker seat be closed in the room. And all uses in the room receive a notification through this callback.
    ///
    /// @param roomInfo refers to the updated room information.
    func receiveRoomInfoUpdate(_ info: RoomInfo?)
    
    /// Callback notification that Token authentication is about to expire.
    ///
    /// Description:The callback notification that the Token authentication is about to expire, please use [renewToken] to update the Token authentication.
    ///
    /// @param remainTimeInSecond The remaining time before the token expires.
    /// @param roomID Room ID where the user is logged in, a string of up to 128 bytes in length.
    func onRoomTokenWillExpire(_ remainTimeInSecond: Int32, roomID: String?)
}

/// Class LiveAudioRoom information management
///
/// Description: This class contains the room information management logics, such as the logic of create a room, join a room, leave a room, disable the text chat in room, etc.
class RoomService: NSObject {
    
    // MARK: - Private
    override init() {
        super.init()
        
        // RoomManager didn't finish init at this time.
        DispatchQueue.main.async {
            RoomManager.shared.addZIMEventHandler(self)
            RoomManager.shared.addExpressEventHandler(self)
        }
    }
    
    // MARK: - Public
    /// Room information, it will be assigned after join the room successfully. And it will be updated synchronously when the room status updates.
    var info: RoomInfo = RoomInfo()
    /// The delegate related to the room status
    weak var delegate: RoomServiceDelegate?
    
    /// Create a room
    ///
    /// Description: This method can be used to create a room. The room creator will be the Host by default when the room is created successfully.
    ///
    /// Call this method at: After user logs in
    ///
    /// @param roomID refers to the room ID, the unique identifier of the room. This is required to join a room and cannot be null.
    /// @param roomName refers to the room name. This is used for display in the room and cannot be null.
    /// @param token refers to the authentication token. To get this, see the documentation: https://doc-en.zego.im/article/11648
    /// @param callback refers to the callback for create a room.
    func createRoom(_ roomID: String, _ roomName: String, _ token: String, callback: RoomCallback?) {
        guard roomID.count != 0 else {
            guard let callback = callback else { return }
            callback(.failure(.paramInvalid))
            return
        }
        
        let parameters = getCreateRoomParameters(roomID, roomName)
        ZIMManager.shared.zim?.createRoom(parameters.0, config: parameters.1, callback: { fullRoomInfo, error in
            
            var result: ZegoResult = .success(())
            if error.code == .success {
                RoomManager.shared.roomService.info = parameters.2
                RoomManager.shared.userService.localInfo?.role = .host
                RoomManager.shared.speakerService.updateSpeakerSeats(parameters.1.roomAttributes)
                RoomManager.shared.loginRtcRoom(with: token)
            }
            else {
                if error.code == .roomModuleTheRoomAlreadyExists {
                    result = .failure(.roomExisted)
                } else {
                    result = .failure(.other(Int32(error.code.rawValue)))
                }
            }
            
            guard let callback = callback else { return }
            callback(result)
        })
        
    }
    
    /// Join a room
    ///
    /// Description: This method can be used to join a room, the room must be an existing room.
    ///
    /// Call this method at: After user logs in
    ///
    /// @param roomID refers to the ID of the room you want to join, and cannot be null.
    /// @param token refers to the authentication token. To get this, see the documentation: https://doc-en.zego.im/article/11648
    /// @param callback refers to the callback for join a room.
    func joinRoom(_ roomID: String, _ token: String, callback: RoomCallback?) {
        ZIMManager.shared.zim?.joinRoom(roomID, callback: { fullRoomInfo, error in
            if error.code != .success {
                guard let callback = callback else { return }
                if error.code == .roomModuleTheRoomDoseNotExist {
                    callback(.failure(.roomNotFound))
                } else {
                    callback(.failure(.other(Int32(error.code.rawValue))))
                }
                return
            }
            
            RoomManager.shared.roomService.info.roomID = fullRoomInfo.baseInfo.roomID
            RoomManager.shared.roomService.info.roomName = fullRoomInfo.baseInfo.roomName
            RoomManager.shared.loginRtcRoom(with: token)
            
            guard let callback = callback else { return }
            callback(.success(()))
        })
    }
    
    /// Leave the room
    ///
    /// Description: This method can be used to leave the room you joined. The room will be ended when the Host leaves, and all users in the room will be forced to leave the room.
    ///
    /// Call this method at: After joining a room
    ///
    /// @param callback refers to the callback for leave a room.
    func leaveRoom(callback: RoomCallback?) {
        guard let roomID = RoomManager.shared.roomService.info.roomID else {
            assert(false, "room ID can't be nil")
            guard let callback = callback else { return }
            callback(.failure(.failed))
            return
        }
        
        ZIMManager.shared.zim?.leaveRoom(roomID, callback: { _, error in
            var result: ZegoResult = .success(())
            if error.code == .success {
                RoomManager.shared.logoutRtcRoom()
            } else {
                result = .failure(.other(Int32(error.code.rawValue)))
            }
            guard let callback = callback else { return }
            callback(result)
        })
    }
        
    /// Disable text chat in the room
    ///
    /// Description: This method can be used to disable the text chat in the room.
    ///
    /// Call this method at: After joining a room
    ///
    /// @param disable refers to the parameter that whether to disable the text chat. To disable the text chat, set it to [true]; To allow the text chat, set it to [false].
    /// @param callback refers to the callback for disable text chat.
    func disableTextMessage(_ isDisabled: Bool, callback: RoomCallback?) {
        let parameters = getDisableTextMessageParameters(isDisabled)
        ZIMManager.shared.zim?.setRoomAttributes(parameters.0, roomID: parameters.1, config: parameters.2, callback: { _, _, error in
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
    
    /// Renew token.
    ///
    /// Description: After the developer receives [onRoomTokenWillExpire], they can use this API to update the token to ensure that the subsequent RTC&ZIM functions are normal.
    ///
    /// @param token The token that needs to be renew.
    /// @param roomID Room ID.
    func renewToken(_ token: String, roomID: String?) {
        if let roomID = roomID {
            ZegoExpressEngine.shared().renewToken(token, roomID: roomID)
        }
        ZIMManager.shared.zim?.renewToken(token, callback: { message, error in
            
        })
    }
}

// MARK: - Private
extension RoomService {
    
    private func getCreateRoomParameters(_ roomID: String, _ roomName: String) -> (ZIMRoomInfo, ZIMRoomAdvancedConfig, RoomInfo) {
        
        let zimRoomInfo = ZIMRoomInfo()
        zimRoomInfo.roomID = roomID
        zimRoomInfo.roomName = roomName
        
        let roomInfo = RoomInfo()
        roomInfo.hostID = RoomManager.shared.userService.localInfo?.userID
        roomInfo.roomID = roomID
        roomInfo.roomName = roomName.count > 0 ? roomName : roomID
        roomInfo.seatNum = 8
        
        let config = ZIMRoomAdvancedConfig()
        let roomInfoJson = ZegoJsonTool.modelToJson(toString: roomInfo) ?? ""
        
        config.roomAttributes = ["room_info" : roomInfoJson]
        
        return (zimRoomInfo, config, roomInfo)
    }
    
    private func getDisableTextMessageParameters(_ isDisabled: Bool) -> ([String:String], String, ZIMRoomAttributesSetConfig) {
        
        let roomInfo = self.info.copy() as? RoomInfo
        roomInfo?.isTextMessageDisabled = isDisabled
        
        let roomInfoJson = ZegoJsonTool.modelToJson(toString: roomInfo) ?? ""
        
        let attributes = ["room_info" : roomInfoJson]
        
        let roomID = roomInfo?.roomID ?? ""
        
        let config = ZIMRoomAttributesSetConfig()
        config.isDeleteAfterOwnerLeft = true
        config.isForce = true
        
        return (attributes, roomID, config)
    }
}

extension RoomService: ZIMEventHandler {
    
    func zim(_ zim: ZIM, connectionStateChanged state: ZIMConnectionState, event: ZIMConnectionEvent, extendedData: [AnyHashable : Any]) {
        // if host reconneted
    }
    
    func zim(_ zim: ZIM, roomAttributesUpdated updateInfo: ZIMRoomAttributesUpdateInfo, roomID: String) {
        if updateInfo.roomAttributes.keys.contains("room_info") {
            let roomJson = updateInfo.roomAttributes["room_info"] ?? ""
            let roomInfo = ZegoJsonTool.jsonToModel(type: RoomInfo.self, json: roomJson)
            
            // if the room info is nil, we should not set self.info = nil
            // because it can't get room info outside.
            if let roomInfo = roomInfo {
                self.info = roomInfo
            }
            delegate?.receiveRoomInfoUpdate(roomInfo)
        }
    }
    
    func zim(_ zim: ZIM, roomStateChanged state: ZIMRoomState, event: ZIMRoomEvent, extendedData: [AnyHashable : Any], roomID: String) {
        if state == .connected && event == .success {
            guard let roomID = RoomManager.shared.roomService.info.roomID else { return }
            ZIMManager.shared.zim?.queryRoomAllAttributes(byRoomID: roomID, callback: { _, dict, error in
                if error.code != .success { return }
                if dict.count == 0 {
                    self.delegate?.receiveRoomInfoUpdate(nil)
                }
            })
        } else if state == .disconnected && event == .enterFailed{
            delegate?.receiveRoomInfoUpdate(nil)
        }
    }
    
    func zim(_ zim: ZIM, tokenWillExpire second: UInt32) {
        delegate?.onRoomTokenWillExpire(Int32(second), roomID: nil)
    }
    
}

extension RoomService: ZegoEventHandler {
    func onRoomTokenWillExpire(_ remainTimeInSecond: Int32, roomID: String) {
        delegate?.onRoomTokenWillExpire(remainTimeInSecond, roomID: roomID)
    }
}
