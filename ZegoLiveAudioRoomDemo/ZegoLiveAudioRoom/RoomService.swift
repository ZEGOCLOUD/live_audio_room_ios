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
    func createRoom(_ roomID: String, _ roomName: String, _ token: String, callback: CommonHandler) {
        
    }
    
    /// Join a chat room
    /// You need to enter a generated `rtc token`
    func joinRoom(_ roomID: String, _ roomName: String, _ token: String, callback: CommonHandler) {
        
    }
    
    /// Leave the chat room , you need to enter your `roomID`
    func leaveRoom(_ roomID: String, callback: CommonHandler) {
        
    }
    
    /// Query the number of chat rooms available online
    func queryRoomMemberCount(_ roomID: String, callback: MemberCountHandler) {
        
    }
    
    /// Disable text chat for all users
    func muteMessage(_ isMuted: Bool, callback: CommonHandler) {
        
    }
}
