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
    
    // speaker seat Number
    var seatNum: UInt = 0
    
    /// whether to disable text mesage
    var isTextMessageDisabled: Bool = false
    
    /// whether to close all seat
    var isSeatClosed: Bool = false
}
