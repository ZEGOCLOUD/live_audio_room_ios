//
//  AppToken.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/17.
//

import Foundation

struct AppToken {
    
    /// Get the rtc token, the token is used to login the rtc room.
    /// - Parameter roomID: the room ID that you want create or join.
    /// - Returns: token
    static func getRtcToken(withRoomID roomID: String?) -> String? {
        guard let roomID = roomID else { return nil }
        guard let userID = RoomManager.shared.userService.localInfo?.userID else { return nil }
        let token = ZegoToken.getRTCToken(withRoomID: roomID,
                                          userID: userID,
                                          appID: AppCenter.appID(),
                                          appSecret: AppCenter.serverSecret())
        return token
    }
    
    
    /// Get the zim token, the token is used to login ZIM server
    /// - Parameter userID: the user ID that you want to use.
    /// - Returns: token
    static func getZIMToken(withUserID userID: String?) -> String? {
        guard let userID = userID else { return nil }

        let token = ZegoToken.getZIMToken(withUserID: userID,
                                          appID: AppCenter.appID(),
                                          appSecret: AppCenter.serverSecret())
        
        return token
    }
}
