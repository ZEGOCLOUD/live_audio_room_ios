//
//  SpeakerSeatModel.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/14.
//

import Foundation

/// Enumeration values of the speaker seat status
enum SpeakerSeatStatus: UInt, Codable {
    // The speaker seat is untaken.
    case untaken = 0   
    // The speaker seat is occupied.
    case occupied = 1
    // The speaker seat is closed.
    case closed = 2
}

enum NetworkQuality: Codable {
    case good
    case medium
    case bad
    case unknow
}

/// Class speaker seat status information
///
/// Description: This class contains the speaker seat status information.
class SpeakerSeatModel: NSObject, Codable {
    /// User ID, null indicates the current speaker seat is available/untaken.
    var userID: String = ""
    
    /// The seat index.
    fileprivate(set) var index: Int
    
    /// The speaker seat mic status.
    var mic: Bool = false
    
    /// The speaker seat status, it is unused by default.
    var status: SpeakerSeatStatus = .untaken
    
    /// Volume value, a local record attribute, used for displaying the sound level.
    var soundLevel: UInt = 0
    
    /// Network status, a local record attributes. It is calculated based on stream quality, can be used for displaying the network status.
    var networkQuality: NetworkQuality = .good
    
    init(index: Int) {
        self.index = index
    }
    
    enum CodingKeys: String, CodingKey {
        case userID = "id"
        case index = "index"
        case mic = "mic"
        case status = "status"
    }
    
    func updateModel(with newModel: SpeakerSeatModel?) {
        guard let newModel = newModel else { return }
        userID = newModel.userID
        index = newModel.index
        mic = newModel.mic
        status = newModel.status
    }
    
    func reset() {
        userID = ""
        mic = false
        status = .untaken
        soundLevel = 0
        networkQuality = .good
    }
}

extension SpeakerSeatModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = SpeakerSeatModel(index: self.index)
        copy.userID = userID
        copy.mic = mic
        copy.status = status
        return copy
    }
}
