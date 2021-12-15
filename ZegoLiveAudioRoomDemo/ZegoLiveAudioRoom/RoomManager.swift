//
//  ZegoRoomManager.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation
import ZIM
import ZegoExpressEngine

class RoomManager {
    static let shared = RoomManager()
    
    // MARK: - Private
    private var appSign: String?
    private var appID: UInt32 = 0
    
    private init() {
        roomService = RoomService()
        userService = UserService()
        speakerService = SpeakerSeatService()
        messageService = MessageService()
        giftService = GiftService()
    }
    
    // MARK: - Public
    var roomService: RoomService
    var userService: UserService
    var speakerService: SpeakerSeatService
    var messageService: MessageService
    var giftService: GiftService
    
    func initWithAppID(appID: UInt32, appSign: String, callback: RoomCallback) {
        if appSign.count == 0 {
            callback(.failure(.paramInvalid))
            return
        }
        
        self.appSign = appSign
        self.appID = appID
        
        ZIMManager.shared.createZIM(appID: appID)
        if ZIMManager.shared.zim == nil {
            callback(.failure(.other(1)))
        } else {
            callback(.success(()))
        }
    }
    
    func uninit() {
        ZIMManager.shared.destoryZIM()
        ZegoExpressEngine .destroy(nil)
    }
    
    func uploadLog(callback: @escaping RoomCallback) {
        ZIMManager.shared.zim?.uploadLog({ errorCode in
            if errorCode.code == .ZIMErrorCodeSuccess {
                callback(.success(()))
            } else {
                callback(.failure(.other(Int(errorCode.code.rawValue))))
            }
        })
    }
}

extension RoomManager {
    // MARK: - Private
    func setupRTCModule(with rtcToken: String) {
        ZegoExpressEngine.createEngine(withAppID: self.appID, appSign: self.appSign!, isTestEnv: false, scenario: .general, eventHandler: nil)
        
        guard let userID = RoomManager.shared.userService.localInfo?.userID else {
            assert(false, "user id can't be nil.")
            return
        }
        
        guard let roomID = RoomManager.shared.roomService.info?.roomID else {
            assert(false, "room ID can't be nil.")
            return
        }
        
        // login rtc room
        let user = ZegoUser(userID: userID)
        
        let config = ZegoRoomConfig()
        config.token = rtcToken
        config.maxMemberCount = 0
        ZegoExpressEngine.shared() .loginRoom(roomID, user: user, config: config)
        
        // monitor sound level
        ZegoExpressEngine.shared().startSoundLevelMonitor(1000)
    }
}
