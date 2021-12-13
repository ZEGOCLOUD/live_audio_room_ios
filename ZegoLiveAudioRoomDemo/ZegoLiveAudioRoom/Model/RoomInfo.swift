//
//  RoomInfo.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation

struct RoomInfo {
    /// room ID
    var roomID: String?
    
    /// room name
    var roomName: String?
    
    /// host user ID
    var hostID: String?
    
    // speaker seat count
    var seatCount: UInt = 0
    
    /// whether to mute mesage
    var isMuteMessage: Bool = false
    
    /// whether to lock all seat
    var isLock: Bool = false
}
