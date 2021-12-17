//
//  AppToken.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/17.
//

import Foundation

struct AppToken {
    static func getRtcToken(with roomID: String) -> String? {
        guard let userID = RoomManager.shared.userService.localInfo?.userID else { return nil }
        let token = ZegoToken.getRTCToken(withRoomID: roomID,
                                          userID: userID,
                                          appID: AppCenter.appID(),
                                          appSecret: AppCenter.appSecret())
        return token
    }
    
    static func getZIMToken(with userID: String) -> String? {
        
        let token = ZegoToken.getZIMToken(withUserID: userID,
                                          appID: AppCenter.appID(),
                                          appSecret: AppCenter.appSecret())
        
        return token
    }
}
