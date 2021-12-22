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
    func speakerSeatUpdate(_ models: [SpeakerSeatModel])
}

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
    /// seat service delegate
    weak var delegate: SpeakerSeatServiceDelegate?
    
    /// speaker seat list
    var seatList: [SpeakerSeatModel] = []
    
    /// get locak user's speaker model
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
    
    /// remove other user to leave his seat
    func removeUserFromSeat(_ index: Int, callback: RoomCallback?) {
        
        let roomID = RoomManager.shared.roomService.info.roomID
        
        let key = String(index)
        let seatModel = SpeakerSeatModel(index: index)
        seatModel.status = .untaken
        
        let seatModelJson = ZegoJsonTool.modelToJson(toString: seatModel) ?? ""
        let attributes = [key : seatModelJson]
        
        let config = ZIMRoomAttributesSetConfig()
        config.isForce = true
        
        setRoomAttributes(attributes, roomID, config, callback)
    }
    
    /// close all unused seat
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
        attributes["roomInfo"] = roomInfoJson
        
        let config = ZIMRoomAttributesSetConfig()
        config.isForce = true
        config.isDeleteAfterOwnerLeft = true
        config.isUpdateOwner = true
        
        setRoomAttributes(attributes, roomID, config, callback)
    }
    
    /// close the unused seat
    func closeSeat(_ isClosed: Bool, _ index: Int, callback: RoomCallback?) {
        
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
    
    /// just turn off/on the local microphone
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
    
    /// local user take the speaker seat
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
        newModel.userID = RoomManager.shared.userService.localInfo?.userID
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
    
    /// local user leave speaker seat
    func leaveSeat(callback: RoomCallback?) {
        
        let roomID = RoomManager.shared.roomService.info.roomID
        let seatModel = SpeakerSeatModel(index: localSpeakerSeat?.index ?? -1)
        seatModel.status = .untaken
        
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
    
    /// local user switch the speaker seat
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
        toSeatNew.userID = fromSeat?.userID
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
        let localUser = RoomManager.shared.userService.localInfo
        for seatModel in seatList {
            let seatKey = String(seatModel.index)
            if seatDict?.keys.contains(seatKey) == false { continue }
            
            var seatUserID = seatModel.userID
            var isUpdateLocalUser = seatModel.userID == localUser?.userID
            
            guard let seatValue = seatDict?[seatKey] as? String else { continue }
            let newModel = ZegoJsonTool.jsonToModel(type: SpeakerSeatModel.self, json: seatValue)
            seatModel.updateModel(with: newModel)
            
            if seatModel.userID != nil {
                seatUserID = seatModel.userID
                isUpdateLocalUser = seatModel.userID == localUser?.userID
            }
            
            // update user status
            if let user: UserInfo = RoomManager.shared.userService.userList.getObj(seatUserID ?? "") {
                if user.role != .host {
                    user.role = seatModel.status == .occupied ? .speaker : .listener
                }
            }
            
            if isUpdateLocalUser {
                // local user leave the seat, and stop publish
                if seatModel.status == .untaken {
                    ZegoExpressEngine.shared().stopPublishingStream()
                }
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
            guard let userID = seat.userID else { continue }
            let streamID = getPublishStreamID(userID)
            if streamID.count == 0 { continue }
            let soundLevel = soundLevels[streamID]?.uintValue ?? 0
            seat.soundLevel = soundLevel
        }
        delegate?.speakerSeatUpdate(seatList)
    }
    
    func onNetworkQuality(_ userID: String, upstreamQuality: ZegoStreamQualityLevel, downstreamQuality: ZegoStreamQualityLevel) {
        for seat in seatList {
            guard let seatUserID = seat.userID else { continue }
            if userID == seatUserID {
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
