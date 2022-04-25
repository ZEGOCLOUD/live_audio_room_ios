//
//  AppToken.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/17.
//

import Foundation

struct AppToken {
    
    static func getToken(withUserID userID: String?, effectiveTimeInSeconds:Int) -> String? {
        guard let userID = userID else { return nil }
        
        let token = ZegoToken.getWithUserID(userID, appID: AppCenter.appID(), appSecret: AppCenter.serverSecret(),effectiveTimeInSeconds: Int64(effectiveTimeInSeconds))
        
        return token
    }
}
