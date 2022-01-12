//
//  ZegoSpeakerSeatService.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation
import ZIM
import ZegoExpressEngine

/// The delegate related to speaker seat status callbacks
///
/// Description: Callbacks that triggered when speaker seat status updates.
protocol SpeakerSeatServiceDelegate: AnyObject {
    /// Callback for the updates on the speaker seat status
    ///
    /// Description: The callback will be triggered when the speaker seat is be taken, or user ID, microphone status, volume, network status of a speaker seat changes.
    ///
    /// @param speakerSeatModel refers to the updated speaker seat info.
    func speakerSeatUpdate(_ models: [SpeakerSeatModel])
}

/// Class speaker seat management
///
/// Description: This class contains the logics related to speaker seat management, such as take/leave a speaker seat, close a speaker seat, remove user from seat, change speaker seats, etc.
class SpeakerSeatService: NSObject {
    // MARK: - Private
    override init() {
        for index in 0..<8 {
            let model = SpeakerSeatModel(index: index)
            seatList.append(model)
        }
        super.init()
        // RoomManager didn't finish init at this time.
        DispatchQueue.main.async {
            RoomManager.shared.addZIMEventHandler(self)
            RoomManager.shared.addExpressEventHandler(self)
        }
    }
    
    // MARK: - Public
    /// The delegate related to speaker seat status
    weak var delegate: SpeakerSeatServiceDelegate?
    
    /// The speaker seat list
    var seatList: [SpeakerSeatModel] = []
    
    /// Get the speaker seat info of the current logged-in user.
    ///
    /// Description: It returns the seat info when the current logged-in user takes a speaker seat; If the currently logged-in user does not take any speaker seat, it returns null.
    ///
    /// Call this method at: After the listener takes a speaker seat
    ///
    /// @return refers to the speaker seat info of the current logged-in user.
    var localSpeakerSeat: SpeakerSeatModel? {
        get {
            guard let userID = RoomManager.shared.userService.localInfo?.userID else {
                return nil
            }
            
            for model in seatList {
                if model.userID == userID {
                    return model
                }
            }
            return nil
        }
    }
    
    /// Remove a user from speaker seat
    ///
    /// Description: This method can be used to remove a specified user (except the host) from the speaker seat.
    ///
    /// Call this method at: After joining the room
    ///
    /// @param seatIndex refers to the seat index of the user you want to remove.
    /// @param callback refers to the callback for remove a user from the speaker seat.
    func removeUserFromSeat(_ index: Int, callback: RoomCallback?) {
        
        let roomID = RoomManager.shared.roomService.info.roomID
        
        let key = String(index)
        let seatModel = SpeakerSeatModel(index: index)
        seatModel.status = RoomManager.shared.roomService.info.isSeatClosed ? .closed : .untaken
        
        let seatModelJson = ZegoJsonTool.modelToJson(toString: seatModel) ?? ""
        let attributes = [key : seatModelJson]
        
        let config = ZIMRoomAttributesSetConfig()
        config.isForce = true
        
        setRoomAttributes(attributes, roomID, config, callback)
    }
    
    /// Close all untaken speaker seat/Open all closed speaker seat
    ///
    /// Description: This method can be used to close all untaken seats or open all closed seats. And the status of the isSeatClosed will also be updated automatically.
    ///
    /// Call this method at: After joining the room
    ///
    /// @param isClosed can be used to close all untaken speaker seats.
    /// @param callback refers to the callback for close all speaker seats.
    func closeAllSeats(_ isClosed: Bool, callback: RoomCallback?) {
       
        let roomID = RoomManager.shared.roomService.info.roomID
        
        var attributes: [String : String] = [:]
        for model in seatList {
            if model.status == .occupied { continue }
            let key = String(model.index)
            let copyModel = SpeakerSeatModel(index: model.index)
            copyModel.status = isClosed ? .closed : .untaken
            let jsonValue = ZegoJsonTool.modelToJson(toString: copyModel) ?? ""
            attributes[key] = jsonValue
        }
        let roomInfo:RoomInfo = RoomManager.shared.roomService.info.copy() as! RoomInfo
        roomInfo.isSeatClosed = isClosed
        let roomInfoJson = ZegoJsonTool.modelToJson(toString: roomInfo) ?? ""
        attributes["room_info"] = roomInfoJson
        
        let config = ZIMRoomAttributesSetConfig()
        config.isForce = true
        config.isDeleteAfterOwnerLeft = true
        config.isUpdateOwner = true
        
        setRoomAttributes(attributes, roomID, config, callback)
    }
    
    /// lose specified untaken speaker seat/Open specified closed speaker seat
    ///
    /// Description: You can call this method to close untaken speaker seats, and the status of the specified speaker seat will change to closed or unused.
    ///
    /// Call this method at: After joining the room
    ///
    /// @param isClosed can be used to close specified untaken speaker seats.
    /// @param seatIndex refers to the seat index of the seat that you want to close/open.
    /// @param callback  refers to the callback for close/open specified speaker seats.
    func convertClosedOpenSeat(_ isClosed: Bool, _ index: Int, callback: RoomCallback?) {
        
        let roomID = RoomManager.shared.roomService.info.roomID
        
        let key = String(index)
        let seatModel = getSeatModel(index)
        
        // the seat already be taken
        if seatModel?.status == .occupied {
            guard let callback = callback else { return }
            callback(.failure(.setSeatInfoFailed))
            return
        }
        
        let newModel = SpeakerSeatModel(index: seatModel?.index ?? -1)
        newModel.status = isClosed ? .closed : .untaken
        let seatModelJson = ZegoJsonTool.modelToJson(toString: newModel) ?? ""
        let attributes = [key : seatModelJson]
        
        let config = ZIMRoomAttributesSetConfig()
        config.isForce = true
        config.isDeleteAfterOwnerLeft = false
        config.isUpdateOwner = true
        
        setRoomAttributes(attributes, roomID, config, callback)
    }
    
    /// Mute/Unmute your own microphone
    ///
    /// Description: This method can be used to mute/unmute your own microphone.
    ///
    /// Call this method at:  After the host enters the room/listener takes a speaker seat
    ///
    /// @param isMuted can be set to [true] to mute the microphone; or set it to [false] to unmute the microphone.
    /// @param callback refers to the callback for mute/unmute the microphone.
    func muteMic(_ isMuted: Bool, callback: RoomCallback?) {
        
        let roomID = RoomManager.shared.roomService.info.roomID
        let seatModel = localSpeakerSeat?.copy() as? SpeakerSeatModel
        guard let seatModel = seatModel else {
            guard let callback = callback else { return }
            callback(.failure(.failed))
            return
        }
        seatModel.mic = !isMuted
        
        let key = String(seatModel.index)
        let seatModelJson = ZegoJsonTool.modelToJson(toString: seatModel) ?? ""
        let attributes = [key : seatModelJson]
        
        let config = ZIMRoomAttributesSetConfig()
        config.isForce = true
        config.isDeleteAfterOwnerLeft = false
        
        setRoomAttributes(attributes, roomID, config) { result in
            if result.isSuccess {
                ZegoExpressEngine.shared().muteMicrophone(isMuted)
            }
            guard let callback = callback else {
                return
            }
            callback(result)
        }
    }
    
    /// Take the speaker seat
    ///
    /// Description: This method can be used to help a listener to take a speaker seat to speak. And at the same time, the microphone will be enabled, the audio streams will be published.
    ///
    /// Call this method at:  After joining the room
    ///
    /// @param seatIndex refers to the seat index of the seat that will be taken, only the open and untaken speaker seats can be taken.
    /// @param callback refers to the callback for take a speaker seat.
    func takeSeat(_ index: Int, callback: RoomCallback?) {
        let roomID = RoomManager.shared.roomService.info.roomID
        let key = String(index)
        
        let seatModel = getSeatModel(index)
        
        if seatModel?.status == .occupied {
            guard let callback = callback else { return }
            callback(.failure(.takeSeatFailed))
            return
        }
        
        let newModel = SpeakerSeatModel(index: seatModel?.index ?? -1)
        newModel.mic = true
        newModel.userID = RoomManager.shared.userService.localInfo?.userID ?? ""
        newModel.status = .occupied
        
        let seatModelJson = ZegoJsonTool.modelToJson(toString: newModel) ?? ""
        let attributes = [key : seatModelJson]
        
        let config = ZIMRoomAttributesSetConfig()
        config.isForce = true
        config.isDeleteAfterOwnerLeft = false
        config.isUpdateOwner = true
        
        setRoomAttributes(attributes, roomID, config) { result in
            if result.isSuccess {
                ZegoExpressEngine.shared().muteMicrophone(false)
                let userID = RoomManager.shared.userService.localInfo?.userID
                ZegoExpressEngine.shared().startPublishingStream(self.getPublishStreamID(userID))
            }
            guard let callback = callback else { return }
            callback(result)
        }
    }
    
    /// leave the speaker seat
    ///
    /// Description: This method can be used to help a speaker to leave the speaker seat to become a listener again. And at the same time, the microphone will be disabled, the audio stream publishing will be stopped.
    ///
    /// Call this method at:  After the listener takes a speaker seat
    ///
    /// @param callback refers to the callback for leave the speaker seat.
    func leaveSeat(callback: RoomCallback?) {
        
        let roomID = RoomManager.shared.roomService.info.roomID
        let seatModel = SpeakerSeatModel(index: localSpeakerSeat?.index ?? -1)
        seatModel.status = RoomManager.shared.roomService.info.isSeatClosed ? .closed : .untaken
        
        if seatModel.index == -1 {
            guard let callback = callback else { return }
            callback(.failure(.failed))
            return
        }
        
        let key = String(seatModel.index)
        let seatModelJson = ZegoJsonTool.modelToJson(toString: seatModel) ?? ""
        let attributes = [key : seatModelJson]
        
        let config = ZIMRoomAttributesSetConfig()
        config.isForce = true
        
        setRoomAttributes(attributes, roomID, config) { result in
            if result.isSuccess {
                // stop publish
                ZegoExpressEngine.shared().stopPublishingStream()
            }
            guard let callback = callback else {
                return
            }
            callback(result)
        }
    }
    
    /// Change the speaker seats
    ///
    /// Description: This method can be used for users to change from the current speaker seat to another speaker seat, and make the current seat available.
    ///
    /// Call this method at: After the listener takes a speaker seat
    ///
    /// @param seatIndex refers to the seat index of the seat that you want to switch to, you can only change to the open and untaken speaker seats.
    /// @param callback refers to the callback for change the speaker seats.
    func switchSeat(to index: Int, callback: RoomCallback?) {
        let roomID = RoomManager.shared.roomService.info.roomID
        
        let fromSeat = localSpeakerSeat
        let toSeat = getSeatModel(index)
        
        guard let fromIndex = fromSeat?.index else {
            guard let callback = callback else { return }
            callback(.failure(.setSeatInfoFailed))
            return
        }
        
        // the local seat index is same as target index
        if fromIndex == index {
            guard let callback = callback else { return }
            callback(.success(()))
            return
        }
        
        // if the target seat is already taken
        if toSeat?.status == .occupied {
            guard let callback = callback else { return }
            callback(.failure(.takeSeatFailed))
            return
        }
        
        let toSeatNew = SpeakerSeatModel(index: index)
        toSeatNew.userID = fromSeat?.userID ?? ""
        toSeatNew.status = .occupied
        toSeatNew.mic = fromSeat?.mic ?? false
        let fromSeatNew = SpeakerSeatModel(index: fromIndex)
        
        let key1 = String(fromSeatNew.index)
        let key2 = String(toSeatNew.index)
        
        let json1 = ZegoJsonTool.modelToJson(toString: fromSeatNew) ?? ""
        let json2 = ZegoJsonTool.modelToJson(toString: toSeatNew) ?? ""
        
        var attributes: [String : String] = [ : ]
        attributes[key1] = json1
        attributes[key2] = json2
        
        let config = ZIMRoomAttributesSetConfig()
        config.isForce = true
        config.isDeleteAfterOwnerLeft = false
        config.isUpdateOwner = true
        
        setRoomAttributes(attributes, roomID, config, callback)
    }
}

// MARK: - Private
extension SpeakerSeatService {
        
    func getSeatModel(_ index: Int) -> SpeakerSeatModel? {
        if index >= seatList.count || index < 0 {
            return nil
        }
        return seatList[index]
    }
    
    func getSeatModel(userID: String?) -> SpeakerSeatModel? {
        guard let userID = userID else {
            return nil
        }
        
        for model in seatList {
            if model.userID == userID {
                return model
            }
        }
        return nil
    }
    
    func setRoomAttributes(_ attributes: [String : String], _ roomID: String?, _ config: ZIMRoomAttributesSetConfig, _ callback: RoomCallback?) {
        
        guard let roomID = RoomManager.shared.roomService.info.roomID else {
            assert(false, "room ID cann't be nil")
            if callback != nil {
                callback!(.failure(.failed))
            }
            return
        }
        
        ZIMManager.shared.zim?.setRoomAttributes(attributes, roomID: roomID, config: config, callback: { error in
            guard let callback = callback else {
                return
            }
            if error.code == .ZIMErrorCodeSuccess {
                callback(.success(()))
            } else {
                callback(.failure(.other(Int32(error.code.rawValue))))
            }
        })
    }
    
    func updateSpeakerSeats(_ seatDict: [String:Any]?) {
        for seatModel in seatList {
            let seatKey = String(seatModel.index)
            if seatDict?.keys.contains(seatKey) == false { continue }
            
            guard let seatValue = seatDict?[seatKey] as? String else { continue }
            let newModel = ZegoJsonTool.jsonToModel(type: SpeakerSeatModel.self, json: seatValue)
            seatModel.updateModel(with: newModel)
            
            if seatModel.userID == localSpeakerSeat?.userID && seatModel.status == .occupied && seatModel.mic {
                ZegoExpressEngine.shared().muteMicrophone(false)
                let userID = RoomManager.shared.userService.localInfo?.userID
                ZegoExpressEngine.shared().startPublishingStream(self.getPublishStreamID(userID))
            } else if seatModel.userID == localSpeakerSeat?.userID {
                ZegoExpressEngine.shared().stopPublishingStream()
            }
        }
        updateLocalUserInfo()
    }
    
    private func updateLocalUserInfo() -> Void {
        let localUser = RoomManager.shared.userService.localInfo
        if let localUser = localUser {
            if localUser.role != .host {
                localUser.role = .listener
            }
            for seatModel in seatList {
                // update user status
                if seatModel.userID == localUser.userID && localUser.role != .host {
                    localUser.role = seatModel.status == .occupied ? .speaker : .listener
                    break
                }
            }
            if localSpeakerSeat == nil {
                // local user leave the seat, and stop publish
                ZegoExpressEngine.shared().stopPublishingStream()
            }
        }
    }
    
    func getPublishStreamID(_ userID: String?) -> String {
        guard let roomID = RoomManager.shared.roomService.info.roomID else {
            assert(false, "room ID can't be nil")
            return ""
        }
        guard let userID = userID else {
            assert(false, "local user ID can't be nil")
            return ""
        }
        let streamID = roomID + "_" + userID + "_main"
        return streamID
    }
}

extension SpeakerSeatService : ZIMEventHandler {
    func zim(_ zim: ZIM, roomAttributesUpdated updateInfo: ZIMRoomAttributesUpdateInfo, roomID: String) {
        updateSpeakerSeats(updateInfo.roomAttributes)
        
        // the seat key is the index
        // if the roomAttributes's keys don't have seat key, then we don't need call back
        let seatKeys = seatList.map() { String($0.index) }
        for key in seatKeys {
            if updateInfo.roomAttributes.keys.contains(key) {
                delegate?.speakerSeatUpdate(seatList)
                return
            }
        }
    }
}

extension SpeakerSeatService : ZegoEventHandler {
    func onCapturedSoundLevelUpdate(_ soundLevel: NSNumber) {
        localSpeakerSeat?.soundLevel = soundLevel.uintValue
        delegate?.speakerSeatUpdate(seatList)
    }
    
    func onRemoteSoundLevelUpdate(_ soundLevels: [String : NSNumber]) {
        for seat in seatList {
            if seat != localSpeakerSeat {
                seat.soundLevel = 0
            }
            let streamID = getPublishStreamID(seat.userID)
            if streamID.count == 0 { continue }
            let soundLevel = soundLevels[streamID]?.uintValue ?? 0
            seat.soundLevel = soundLevel
        }
        delegate?.speakerSeatUpdate(seatList)
    }
    
    func onNetworkQuality(_ userID: String, upstreamQuality: ZegoStreamQualityLevel, downstreamQuality: ZegoStreamQualityLevel) {
        for seat in seatList {
            if userID == seat.userID {
                seat.networkQuality = setNetWorkQuality(upstreamQuality: upstreamQuality)
            }
        }
        delegate?.speakerSeatUpdate(seatList)
    }
    
    private func setNetWorkQuality(upstreamQuality: ZegoStreamQualityLevel) -> NetworkQuality {
        if upstreamQuality == .excellent || upstreamQuality == .good {
            return .good
        } else if upstreamQuality == .medium {
            return .medium
        } else if upstreamQuality == .unknown {
            return .unknow
        } else {
            return .bad
        }
    }
}
