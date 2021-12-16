//
//  RoomInfo.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation

class RoomInfo: NSObject, Codable {
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
    
    
    enum CodingKeys: String, CodingKey {
        case roomID = "id"
        case roomName = "name"
        case hostID = "hostID"
        case seatNum = "num"
        case isTextMessageDisabled = "disable"
        case isSeatClosed = "close"
    }
}

extension RoomInfo: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = RoomInfo()
        copy.roomID = roomID
        copy.roomName = roomName
        copy.hostID = hostID
        copy.seatNum = seatNum
        copy.isTextMessageDisabled = isTextMessageDisabled
        copy.isSeatClosed = isSeatClosed
        return copy
    }
}
