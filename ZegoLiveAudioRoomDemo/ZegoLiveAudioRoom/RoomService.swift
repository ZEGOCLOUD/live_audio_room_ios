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
}

class RoomService: NSObject {
    
    // MARK: - Private
    override init() {
        super.init()
        
        // RoomManager didn't finish init at this time.
        DispatchQueue.main.async {
            RoomManager.shared.addZIMEventHandler(self)
        }
    }
    
    // MARK: - Public
    
    var info: RoomInfo?
    weak var delegate: RoomServiceDelegate?
    
    /// Create a chat room
    /// You need to enter a generated `rtc token`
    func createRoom(_ roomID: String, _ roomName: String, _ token: String, callback: RoomCallback?) {
        guard roomID.count != 0 else {
            guard let callback = callback else { return }
            callback(.failure(.paramInvalid))
            return
        }
        
        let parameters = getCreateRoomParameters(roomID, roomName)
        ZIMManager.shared.zim?.createRoom(parameters.0, config: parameters.1, callback: { fullRoomInfo, error in
            
            var result: ZegoResult = .success(())
            if error.code == .ZIMErrorCodeSuccess {
                RoomManager.shared.roomService.info = parameters.2
                RoomManager.shared.userService.localInfo?.role = .host
                RoomManager.shared.speakerService.updateSpeakerSeats(parameters.1.roomAttributes, .set)
                RoomManager.shared.loginRtcRoom(with: token)
            }
            else {
                if error.code == .ZIMErrorCodeCreateExistRoom {
                    result = .failure(.roomExisted)
                } else {
                    result = .failure(.other(Int32(error.code.rawValue)))
                }
            }
            
            guard let callback = callback else { return }
            callback(result)
        })
        
    }
    
    /// Join a chat room
    /// You need to enter a generated `rtc token`
    func joinRoom(_ roomID: String, _ roomName: String, _ token: String, callback: RoomCallback?) {
        ZIMManager.shared.zim?.joinRoom(roomID, callback: { fullRoomInfo, error in
            if error.code != .ZIMErrorCodeSuccess {
                guard let callback = callback else { return }
                callback(.failure(.other(Int32(error.code.rawValue))))
                return
            }
            
            RoomManager.shared.roomService.info?.roomID = roomID
            RoomManager.shared.roomService.info?.roomName = roomName
            RoomManager.shared.loginRtcRoom(with: token)
            
            guard let callback = callback else { return }
            callback(.success(()))
        })
    }
    
    /// Leave the chat room
    func leaveRoom(callback: RoomCallback?) {
        guard let roomID = RoomManager.shared.roomService.info?.roomID else {
            assert(false, "room ID can't be nil")
            guard let callback = callback else { return }
            callback(.failure(.failed))
            return
        }
        
        ZIMManager.shared.zim?.leaveRoom(roomID, callback: { error in
            var result: ZegoResult = .success(())
            if error.code == .ZIMErrorCodeSuccess {
                RoomManager.shared.logoutRtcRoom()
            } else {
                result = .failure(.other(Int32(error.code.rawValue)))
            }
            guard let callback = callback else { return }
            callback(result)
        })
    }
        
    /// Disable text chat for all users
    func disableTextMessage(_ isDisabled: Bool, callback: RoomCallback?) {
        let parameters = getDisableTextMessageParameters(isDisabled)
        ZIMManager.shared.zim?.setRoomAttributes(parameters.0, roomID: parameters.1, config: parameters.2, callback: { error in
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
        
        let roomInfo = self.info?.copy() as? RoomInfo
        roomInfo?.isTextMessageDisabled = isDisabled
        
        let roomInfoJson = ZegoJsonTool.modelToJson(toString: roomInfo) ?? ""
        
        let attributes = ["room_info" : roomInfoJson]
        
        let roomID = roomInfo?.roomID ?? ""
        
        let config = ZIMRoomAttributesSetConfig()
        config.isDeleteAfterOwnerLeft = true
        config.isForce = false
        
        return (attributes, roomID, config)
    }
}

extension RoomService: ZIMEventHandler {
    
    
}
