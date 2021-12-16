//
//  ZegoSpeakerSeatService.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation
import ZIM
import ZegoExpressEngine

protocol SpeakerSeatServiceDelegate: AnyObject {
    /// speaker seat upate
    func speakerSeatUpdate(_ model: SpeakerSeatModel)
}

class SpeakerSeatService: NSObject {
    // MARK: - Private
    override init() {
        super.init()
        
    }
    
    // MARK: - Public
    /// seat service delegate
    weak var delegate: SpeakerSeatServiceDelegate?
    
    /// speaker seat list
    var seatList: [SpeakerSeatModel] = []
    
    /// remove other user to leave his seat
    func removeUserFromSeat(_ index: UInt, callback: RoomCallback) {
        
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
    func takeSeat(_ index: UInt, callback: RoomCallback?) {
        
    }
    
    /// local user leave speaker seat
    func leaveSeat(callback: RoomCallback) {
        
    }
    
    /// local user switch the speaker seat
    func switchSeat(to index: UInt, callback: RoomCallback) {
        
    }
}

extension SpeakerSeatService {
    // MARK: - Private
    func updateSpeakerSeats(_ seatDict: [String:Any]?, _ action: ZIMRoomAttributesUpdateAction) {
        let localUser = RoomManager.shared.userService.localInfo
        for seatModel in seatList {
            let seatKey = "seat_\(String(describing: seatModel.index))"
            if seatDict?.keys.contains(seatKey) == false { continue }
            
            var isUpdateLocalUser = seatModel.userID == localUser?.userID
            if action == .set {
                guard let seatValue = seatDict?[seatKey] as? String else { continue }
                let newModel = ZegoModelTool.jsonToModel(type: SpeakerSeatModel.self, json: seatValue)
                seatModel.updateModel(with: newModel)
                isUpdateLocalUser = seatModel.userID == localUser?.userID
            }
            
            else {
                seatModel.reset()
            }
            
            if isUpdateLocalUser {
                if localUser?.role != .host {
                    localUser?.role = seatModel.status == .occupied ? .speaker : .listener
                }
                // local user leave the seat, and stop publish
                if action == .delete {
                    ZegoExpressEngine.shared().stopPublishingStream()
                }
            }
        }
    }
}
