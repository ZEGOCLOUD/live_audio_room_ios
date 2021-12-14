//
//  ZegoSpeakerSeatService.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation

protocol SpeakerSeatServiceDelegate: AnyObject {
    /// speaker seat upate
    func speakerSeatUpdate(_ model: SpeakerSeatModel)
}

class SpeakerSeatService {
    
    // MARK: - Public
    /// seat service delegate
    weak var delegate: SpeakerSeatServiceDelegate?
    
    /// speaker seat list
    var seatList: [SpeakerSeatModel] = []
    
    /// remove other user to leave his seat
    func removeUserFromSeat(_ userID: String, callback: CommonHandler) {
        
    }
    
    /// lock all unused seat
    func lockAllSeat(_ isLocked: Bool, callback: CommonHandler) {
        
    }
    
    /// lock the unused seat
    func lockSeat(_ isLocked: Bool, _ index: UInt, callback: CommonHandler) {
        
    }
    
    /// just turn off/on the local microphone
    func muteSeatMic(_ isMuted: Bool, callback: CommonHandler) {
        
    }
    
    /// local user take the speaker seat
    func takeSeat(_ index: UInt, callback: CommonHandler) {
        
    }
    
    /// local user leave speaker seat
    func leaveSeat(_ index: UInt, callback: CommonHandler) {
        
    }
    
    /// local user switch the speaker seat
    func switchSeat(to index: UInt, callback: CommonHandler) {
        
    }
}
