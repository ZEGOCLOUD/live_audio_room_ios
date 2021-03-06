//
//  CustomCommand.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/14.
//

import UIKit
import ZIM

enum CustomCommandType : UInt {
    case invitation = 1
    case gift = 2
}

/// Class custom signaling
///
/// Description: This class contains the custom signaling related logics, such as send virtual gift, send seat-taking invitation, etc.
class CustomCommand : NSObject {
    // Inherit from  ZIMCustomMessage
    /// Custom signaling type 1: Invite to take the speaker seat 2: Send virtual gifts
    var actionType: CustomCommandType = .invitation
    /// Target users
    var targetUserIDs: [String] = []
    /// Signaling content Invite to speak: {}, send gift: {"giftID": ""}
    var content: [String : Any] = [ : ]
    
    var giftID: String? {
        get {
            return content["giftID"] as? String
        }
        set {
            content["giftID"] = newValue
        }
    }
    
    init(type: CustomCommandType) {
        self.actionType = type
    }
    
    init(with jsonStr: String) {
        
        let dict = ZegoJsonTool.jsonToDictionary(jsonStr)
        
        guard let dict = dict else {
            return
        }
        
        let actionType = dict["actionType"] as? UInt ?? 1
        self.actionType = CustomCommandType(rawValue: actionType) ?? .invitation
        self.targetUserIDs = dict["target"] as? [String] ?? []
        self.content = dict["content"] as? [String : Any] ?? [:]
    }
    
    func josnString() -> String? {
        
        var dict: [String : Any] = [ : ]
        
        dict["actionType"] = actionType.rawValue
        dict["target"] = targetUserIDs
        
        if content.keys.contains("giftID") {
            dict["content"] = content
        }
        
        let jsonStr = ZegoJsonTool.dictionaryToJson(dict)
        
        guard let jsonStr = jsonStr else {
            return nil
        }
        
        return jsonStr
    }
}
