//
//  RoomInfo.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation

/// Class room information
///
/// Description: This class contain the room status related information.
class RoomInfo: NSObject, Codable {
    /// Room ID, refers to the the unique identifier of the room, can be used when joining the room.
    var roomID: String?
    
    /// Room name, refers to the room title, can be used for display.
    var roomName: String?
    
    /// Host ID, refers to the ID of the room creator.
    var hostID: String?
    
    /// The number of speaker seats.
    var seatNum: UInt = 0
    
    /// Whether the text chat is disabled in the room.
    var isTextMessageDisabled: Bool = false
    
    /// whether the speaker seat is closed.
    var isSeatClosed: Bool = false
    
    
    enum CodingKeys: String, CodingKey {
        case roomID = "id"
        case roomName = "name"
        case hostID = "host_id"
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
