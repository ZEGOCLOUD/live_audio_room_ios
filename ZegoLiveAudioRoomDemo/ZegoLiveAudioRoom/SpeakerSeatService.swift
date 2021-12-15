//
//  ZegoSpeakerSeatService.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation
import ZIM

protocol SpeakerSeatServiceDelegate: AnyObject {
    /// speaker seat upate
    func speakerSeatUpdate(_ model: SpeakerSeatModel)
}

class SpeakerSeatService: NSObject {
    
    // MARK: - Public
    /// seat service delegate
    weak var delegate: SpeakerSeatServiceDelegate?
    
    /// speaker seat list
    var seatList: [SpeakerSeatModel] = []
    
    /// remove other user to leave his seat
    func removeUserFromSeat(_ userID: String, callback: RoomCallback) {
        
    }
    
    /// close all unused seat
    func closeAllSeats(_ isClosed: Bool, callback: RoomCallback) {
        
    }
    
    /// close the unused seat
    func closeSeat(_ isClosed: Bool, _ index: UInt, callback: RoomCallback) {
        
    }
    
    /// just turn off/on the local microphone
    func muteSeatMic(_ isMuted: Bool, callback: RoomCallback) {
        
    }
    
    /// local user take the speaker seat
    func takeSeat(_ index: UInt, callback: RoomCallback) {
        
    }
    
    /// local user leave speaker seat
    func leaveSeat(_ index: UInt, callback: RoomCallback) {
        
    }
    
    /// local user switch the speaker seat
    func switchSeat(to index: UInt, callback: RoomCallback) {
        
    }
}

extension SpeakerSeatService {
    // MARK: - Private
    func updateSpeakerSeats(_ seatDict: [String:Any]?, _ action: ZIMRoomAttributesUpdateAction) {
        
        
    }
}
