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
    func closeAllSeats(_ isClosed: Bool, callback: @escaping RoomCallback) {
       
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
        
        let config = ZIMRoomAttributesSetConfig()
        config.isForce = false
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
        config.isForce = false
        config.isDeleteAfterOwnerLeft = true
        config.isUpdateOwner = true
        
        setRoomAttributes(attributes, roomID, config, callback)
    }
    
    /// just turn off/on the local microphone
    func muteMic(_ isMuted: Bool, callback: RoomCallback?) {
        
        let roomID = RoomManager.shared.roomService.info.roomID
        let seatModel = SpeakerSeatModel(index: localSpeakerSeat?.index ?? -1)
        seatModel.mic = !isMuted
        
        if seatModel.index == -1 {
            guard let callback = callback else { return }
            callback(.failure(.failed))
            return
        }
        
        let key = String(seatModel.index)
        let seatModelJson = ZegoJsonTool.modelToJson(toString: seatModel) ?? ""
        let attributes = [key : seatModelJson]
        
        let config = ZIMRoomAttributesSetConfig()
        config.isForce = false
        config.isDeleteAfterOwnerLeft = true
        
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
        config.isForce = false
        config.isDeleteAfterOwnerLeft = true
        config.isUpdateOwner = false
        
        setRoomAttributes(attributes, roomID, config, callback)
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
        config.isForce = false
        config.isDeleteAfterOwnerLeft = true
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
    
    func updateSpeakerSeats(_ seatDict: [String:Any]?, _ action: ZIMRoomAttributesUpdateAction) {
        let localUser = RoomManager.shared.userService.localInfo
        for seatModel in seatList {
            let seatKey = String(seatModel.index)
            if seatDict?.keys.contains(seatKey) == false { continue }
            
            var isUpdateLocalUser = seatModel.userID == localUser?.userID
            if action == .set {
                guard let seatValue = seatDict?[seatKey] as? String else { continue }
                let newModel = ZegoJsonTool.jsonToModel(type: SpeakerSeatModel.self, json: seatValue)
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

extension SpeakerSeatService : ZIMEventHandler {
    func zim(_ zim: ZIM, roomAttributesUpdated updateInfo: ZIMRoomAttributesUpdateInfo, roomID: String) {
        updateSpeakerSeats(updateInfo.roomAttributes, updateInfo.action)
        
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
