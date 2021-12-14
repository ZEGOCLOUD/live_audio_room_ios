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
        self.appSign = appSign
        ZIMManager.shared.createZIM(appID: appID)
        if ZIMManager.shared.zim == nil {
            callback(1)
        } else {
            callback(0)
        }
    }
    
    func uninit() {
        ZIMManager.shared.destoryZIM()
        ZegoExpressEngine .destroy(nil)
    }
    
    func uploadLog(callback: @escaping RoomCallback) {
        ZIMManager.shared.zim?.uploadLog({ errorCode in
            callback(errorCode.code.rawValue)
        })
    }
}
