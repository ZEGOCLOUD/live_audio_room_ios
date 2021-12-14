//
//  SpeakerSeatModel.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/14.
//

import Foundation

enum SpeakerSeatStatus {
    case Untaken
    case Occupied
    case Closed
}

enum NetworkQuality {
    case Good
    case Medium
    case Bad
}

struct SpeakerSeatModel {
    /// user ID
    var userID: String?
    
    /// the index of speaker seat
    var index: Int?
    
    /// the mic status of speaker seat
    var isMuteMic: Bool = false
    
    /// the status of speaker seat
    var status: SpeakerSeatStatus = .Untaken
    
    /// the sound level of mic `[0, 100]`
    var soundLevel: UInt = 0
    
    /// newwork quality of current seat
    var networkQuality: NetworkQuality = .Good
}
