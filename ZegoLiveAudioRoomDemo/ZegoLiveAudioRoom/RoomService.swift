//
//  ZegoRoomService.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation
import ZIM

protocol RoomServiceDelegate: AnyObject {
    func receiveRoomInfoUpdate(_ info: RoomInfo?)
    func connectionStateChanged(_ state: ZIMConnectionState, _ event: ZIMConnectionEvent)
}

class RoomService: NSObject {
    // MARK: - Public
    
    var info: RoomInfo?
    weak var delegate: RoomServiceDelegate?
    
    /// Create a chat room
    /// You need to enter a generated `rtc token`
    func createRoom(_ roomID: String, _ roomName: String, _ token: String, callback: @escaping RoomCallback) {
        guard roomID.count != 0 else {
            callback(.failure(.paramInvalid))
            return
        }
        
        let parameters = getCreateRoomParameters(roomID, roomName)
        ZIMManager.shared.zim?.createRoom(parameters.0, config: parameters.1, callback: { fullRoomInfo, error in
            if error.code == .ZIMErrorCodeSuccess {
                
                RoomManager.shared.roomService.info = parameters.2
                RoomManager.shared.userService.localInfo?.role = .host
                RoomManager.shared.speakerService.updateSpeakerSeats(parameters.1.roomAttributes, .set)
                RoomManager.shared.setupRTCModule(with: token)
                
                callback(.success(()))
            }
            
            else {
                if error.code == .ZIMErrorCodeCreateExistRoom {
                    callback(.failure(.roomExisted))
                } else {
                    callback(.failure(.other(Int(error.code.rawValue))))
                }
            }
        })
        
    }
    
    /// Join a chat room
    /// You need to enter a generated `rtc token`
    func joinRoom(_ roomID: String, _ roomName: String, _ token: String, callback: RoomCallback) {
        
    }
    
    /// Leave the chat room
    func leaveRoom(callback: RoomCallback) {
        
    }
    
    /// Query the number of chat rooms available online
    func queryOnlineRoomUsers(callback: OnlineRoomUsersCallback) {
        
    }
    
    /// Disable text chat for all users
    func disableTextMessage(_ isDisabled: Bool, callback: RoomCallback) {
        
    }
}

extension RoomService {
    // MARK: - Private
    
    func getCreateRoomParameters(_ roomID: String, _ roomName: String) -> (ZIMRoomInfo, ZIMRoomAdvancedConfig, RoomInfo) {
        
        let zimRoomInfo = ZIMRoomInfo()
        zimRoomInfo.roomID = roomID
        zimRoomInfo.roomName = roomName
        
        var roomInfo = RoomInfo()
        roomInfo.hostID = RoomManager.shared.userService.localInfo?.userID
        roomInfo.roomID = roomID
        roomInfo.roomName = roomName.count > 0 ? roomName : roomID
        roomInfo.seatNum = 8
        
        let config = ZIMRoomAdvancedConfig()
        var roomInfoJson = ZegoModelTool.modelToJson(toString: roomInfo)
        if roomInfoJson == nil {
            roomInfoJson = ""
        }
        config.roomAttributes = ["room_info" : roomInfoJson!]
        
        return (zimRoomInfo, config, roomInfo)
    }
}
