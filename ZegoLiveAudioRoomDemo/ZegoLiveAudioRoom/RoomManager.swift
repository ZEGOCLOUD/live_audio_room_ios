//
//  ZegoRoomManager.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation
import ZIM
import ZegoExpressEngine

/// Class LiveAudioRoom business logic management
///
/// Description: This class contains the LiveAudioRoom business logics, manages the service instances of different modules, and also distributing the data delivered by the SDK.
class RoomManager: NSObject {
    /// Get the RoomManager singleton instance
    ///
    /// Description: This method can be used to get the RoomManager singleton instance.
    ///
    /// Call this method at: Any time
    ///
    /// @return RoomManager singleton instance
    static let shared = RoomManager()
    
    // MARK: - Private
    private let rtcEventDelegates: NSHashTable<ZegoEventHandler> = NSHashTable(options: .weakMemory)
    private let zimEventDelegates: NSHashTable<ZIMEventHandler> = NSHashTable(options: .weakMemory)
    
    private override init() {
        roomService = RoomService()
        userService = UserService()
        speakerService = SpeakerSeatService()
        messageService = MessageService()
        giftService = GiftService()
        
        super.init()
    }
    
    // MARK: - Public
    /// The room information management instance, contains the room information, room status and other business logics.
    var roomService: RoomService
    /// The user information management instance, contains the in-room user information management, logged-in user information and other business logics.
    var userService: UserService
    /// The room speaker seat management instance, contains the speaker seat management logic.
    var speakerService: SpeakerSeatService
    /// The message management instance, contains the IM messages management logic.
    var messageService: MessageService
    /// The gift management instance, contains the gift sending and receiving logics.
    var giftService: GiftService
    
    /// Initialize the SDK
    ///
    /// Description: This method can be used to initialize the ZIM SDK and the Express-audio SDK.
    ///
    /// Call this method at: Before you log in. We recommend you call this method when the application starts.
    ///
    /// @param appID refers to the project ID. To get this, go to ZEGOCLOUD Admin Console: https://console.zego.im/dashboard?lang=en
    func initWithAppID(appID: UInt32, callback: RoomCallback?) {
        
        ZIMManager.shared.createZIM(appID: appID)
        let profile: ZegoEngineProfile = ZegoEngineProfile()
        profile.appID = appID
        profile.scenario = .general
        ZegoExpressEngine.createEngine(with: profile, eventHandler: self)
        
        var result: ZegoResult = .success(())
        if ZIMManager.shared.zim == nil {
            result = .failure(.other(1))
        } else {
            ZIMManager.shared.zim?.setEventHandler(self)
        }
        guard let callback = callback else { return }
        callback(result)
    }
    
    /// The method to deinitialize the SDK
    ///
    /// Description: This method can be used to deinitialize the SDK and release the resources it occupies.
    ///
    /// Call this method at: When the SDK is no longer be used. We recommend you call this method when the application exits.
    ///
    func uninit() {
        logoutRtcRoom(true)
        ZIMManager.shared.destoryZIM()
        ZegoExpressEngine.destroy(nil)
    }
    
    /// Upload local logs to the ZEGOCLOUD server
    ///
    /// Description: You can call this method to upload the local logs to the ZEGOCLOUD Server for troubleshooting when exception occurs.
    ///
    /// Call this method at: When exceptions occur
    ///
    /// @param fileName refers to the name of the file you upload. We recommend you name the file in the format of "appid_platform_timestamp".
    /// @param completion refers to the callback that be triggered when the logs are upload successfully or failed to upload logs.
    func uploadLog(callback: RoomCallback?) {
        ZIMManager.shared.zim?.uploadLog({ errorCode in
            guard let callback = callback else { return }
            if errorCode.code == .success {
                callback(.success(()))
            } else {
                callback(.failure(.other(Int32(errorCode.code.rawValue))))
            }
        })
    }
}

extension RoomManager {
    func loginRtcRoom(with token: String) {
        guard let userID = RoomManager.shared.userService.localInfo?.userID else {
            assert(false, "user id can't be nil.")
            return
        }
        
        guard let roomID = RoomManager.shared.roomService.info.roomID else {
            assert(false, "room id can't be nil.")
            return
        }
        
        // login rtc room
        let user = ZegoUser(userID: userID)
        
        let config = ZegoRoomConfig()
        config.token = token
        config.maxMemberCount = 0
        ZegoExpressEngine.shared().loginRoom(roomID, user: user, config: config)
        
        // monitor sound level
        ZegoExpressEngine.shared().startSoundLevelMonitor(1000)
    }
        
    func logoutRtcRoom(_ containsUserService: Bool = false) {
        ZegoExpressEngine.shared().logoutRoom()
        
        if containsUserService {
            userService = UserService()
        } else {
            userService.userList = DictionaryArrary<String, UserInfo>()
        }
        roomService = RoomService()
        speakerService = SpeakerSeatService()
        messageService = MessageService()
        giftService = GiftService()
    }
    
    // MARK: - event handler
    func addZIMEventHandler(_ eventHandler: ZIMEventHandler?) {
        zimEventDelegates.add(eventHandler)
    }
    
    func addExpressEventHandler(_ eventHandler: ZegoEventHandler?) {
        rtcEventDelegates.add(eventHandler)
    }
}

extension RoomManager: ZegoEventHandler {
    
    func onCapturedSoundLevelUpdate(_ soundLevel: NSNumber) {
        for delegate in rtcEventDelegates.allObjects {
            delegate.onCapturedSoundLevelUpdate?(soundLevel)
        }
    }
    
    func onRemoteSoundLevelUpdate(_ soundLevels: [String : NSNumber]) {
        for delegate in rtcEventDelegates.allObjects {
            delegate.onRemoteSoundLevelUpdate?(soundLevels)
        }
    }
    
    func onRoomStreamUpdate(_ updateType: ZegoUpdateType, streamList: [ZegoStream], extendedData: [AnyHashable : Any]?, roomID: String) {
        for delegate in rtcEventDelegates.allObjects {
            delegate.onRoomStreamUpdate?(updateType, streamList: streamList, extendedData: extendedData, roomID: roomID)
        }
        
        for stream in streamList {
            if updateType == .add {
                ZegoExpressEngine.shared().startPlayingStream(stream.streamID)
            } else {
                ZegoExpressEngine.shared().stopPlayingStream(stream.streamID)
            }
        }
    }
    
    func onNetworkQuality(_ userID: String, upstreamQuality: ZegoStreamQualityLevel, downstreamQuality: ZegoStreamQualityLevel) {
        for delegate in rtcEventDelegates.allObjects {
            delegate.onNetworkQuality?(userID, upstreamQuality: upstreamQuality, downstreamQuality: downstreamQuality)
        }
    }
    
    func onRoomTokenWillExpire(_ remainTimeInSecond: Int32, roomID: String) {
        for delegate in rtcEventDelegates.allObjects {
            delegate.onRoomTokenWillExpire?(remainTimeInSecond, roomID: roomID)
        }
    }

}

extension RoomManager: ZIMEventHandler {
    func zim(_ zim: ZIM, connectionStateChanged state: ZIMConnectionState, event: ZIMConnectionEvent, extendedData: [AnyHashable : Any]) {
        for delegate in zimEventDelegates.allObjects {
            delegate.zim?(zim, connectionStateChanged: state, event: event, extendedData: extendedData)
        }
    }
    
    // MARK: - Main
    func zim(_ zim: ZIM, errorInfo: ZIMError) {
        for delegate in zimEventDelegates.allObjects {
            delegate.zim?(zim, errorInfo: errorInfo)
        }
    }
    
    func zim(_ zim: ZIM, tokenWillExpire second: UInt32) {
        for delegate in zimEventDelegates.allObjects {
            delegate.zim?(zim, tokenWillExpire: second)
        }
    }
    
    // MARK: - Message
    func zim(_ zim: ZIM, receivePeerMessage messageList: [ZIMMessage], fromUserID: String) {
        for delegate in zimEventDelegates.allObjects {
            delegate.zim?(zim, receivePeerMessage: messageList, fromUserID: fromUserID)
        }
    }
    
    func zim(_ zim: ZIM, receiveRoomMessage messageList: [ZIMMessage], fromRoomID: String) {
        for delegate in zimEventDelegates.allObjects {
            delegate.zim?(zim, receiveRoomMessage: messageList, fromRoomID: fromRoomID)
        }
    }
    
    // MARK: - Room
    func zim(_ zim: ZIM, roomMemberJoined memberList: [ZIMUserInfo], roomID: String) {
        for delegate in zimEventDelegates.allObjects {
            delegate.zim?(zim, roomMemberJoined: memberList, roomID: roomID)
        }
    }
    
    func zim(_ zim: ZIM, roomMemberLeft memberList: [ZIMUserInfo], roomID: String) {
        for delegate in zimEventDelegates.allObjects {
            delegate.zim?(zim, roomMemberLeft: memberList, roomID: roomID)
        }
    }
    
    func zim(_ zim: ZIM, roomStateChanged state: ZIMRoomState, event: ZIMRoomEvent, extendedData: [AnyHashable : Any], roomID: String) {
        for delegate in zimEventDelegates.allObjects {
            delegate.zim?(zim, roomStateChanged: state, event: event, extendedData: extendedData, roomID: roomID)
        }
    }
    
    func zim(_ zim: ZIM, roomAttributesUpdated updateInfo: ZIMRoomAttributesUpdateInfo, roomID: String) {
        for delegate in zimEventDelegates.allObjects {
            delegate.zim?(zim, roomAttributesUpdated: updateInfo, roomID: roomID)
        }
    }
}
