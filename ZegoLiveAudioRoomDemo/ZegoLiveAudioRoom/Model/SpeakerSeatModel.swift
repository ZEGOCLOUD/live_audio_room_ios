//
//  SpeakerSeatModel.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/14.
//

import Foundation

enum SpeakerSeatStatus: Codable {
    case untaken
    case occupied
    case closed
}

enum NetworkQuality: Codable {
    case good
    case medium
    case bad
}

class SpeakerSeatModel: NSObject, Codable {
    /// user ID
    var userID: String?
    
    /// the index of speaker seat
    var index: Int?
    
    /// the mic status of speaker seat
    var isMicMuted: Bool = false
    
    /// the status of speaker seat
    var status: SpeakerSeatStatus = .untaken
    
    /// the sound level of mic `[0, 100]`
    var soundLevel: UInt = 0
    
    /// newwork quality of current seat
    var networkQuality: NetworkQuality = .good
    
    func updateModel(with newModel: SpeakerSeatModel?) {
        guard let newModel = newModel else {
            return
        }

        userID = newModel.userID
        index = newModel.index
        isMicMuted = newModel.isMicMuted
        status = newModel.status
        soundLevel = newModel.soundLevel
        networkQuality = newModel.networkQuality
    }
    
    func reset() {
        userID = ""
        isMicMuted = false
        status = .untaken
        soundLevel = 0
        networkQuality = .good
    }
}
