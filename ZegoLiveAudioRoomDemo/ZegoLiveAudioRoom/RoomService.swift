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

class RoomService {
    // MARK: - Public
    
    var info: RoomInfo?
    weak var delegate: RoomServiceDelegate?
    
    /// Create a chat room
    /// You need to enter a generated `rtc token`
    func createRoom(_ roomID: String, _ roomName: String, _ token: String, callback: RoomCallback) {
        
    }
    
    /// Join a chat room
    /// You need to enter a generated `rtc token`
    func joinRoom(_ roomID: String, _ roomName: String, _ token: String, callback: RoomCallback) {
        
    }
    
    /// Leave the chat room , you need to enter your `roomID`
    func leaveRoom(_ roomID: String, callback: RoomCallback) {
        
    }
    
    /// Query the number of chat rooms available online
    func queryOnlineRoomUsers(_ roomID: String, callback: OnlineRoomUsersCallback) {
        
    }
    
    /// Disable text chat for all users
    func disableTextMessage(_ isDisabled: Bool, callback: RoomCallback) {
        
    }
}
