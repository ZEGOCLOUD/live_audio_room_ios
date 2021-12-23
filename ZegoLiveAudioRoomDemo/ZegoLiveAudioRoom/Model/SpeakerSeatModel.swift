//
//  SpeakerSeatModel.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/14.
//

import Foundation

enum SpeakerSeatStatus: UInt, Codable {
    case untaken = 0
    case occupied = 1
    case closed = 2
}

enum NetworkQuality: Codable {
    case good
    case medium
    case bad
    case unknow
}

class SpeakerSeatModel: NSObject, Codable {
    /// user ID
    var userID: String = ""
    
    /// the index of speaker seat
    fileprivate(set) var index: Int
    
    /// the mic status of speaker seat
    var mic: Bool = false
    
    /// the status of speaker seat
    var status: SpeakerSeatStatus = .untaken
    
    /// the sound level of mic `[0, 100]`
    var soundLevel: UInt = 0
    
    /// newwork quality of current seat
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
