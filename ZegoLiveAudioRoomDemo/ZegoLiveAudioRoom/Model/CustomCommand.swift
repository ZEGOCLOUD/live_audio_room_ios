//
//  CustomCommand.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/14.
//

import UIKit
import ZIM

enum CustomCommandType: UInt {
    case invitation = 1
    case gift = 2
}

class CustomCommand: ZIMCustomMessage {
    var actionType: CustomCommandType = .invitation
    var targetUserIDs: [String] = []
    var content: [String : Any] = [ : ]
    
    init(type: CustomCommandType) {
        self.actionType = type
        super.init()
    }
    
    enum CodingKeys: String, CodingKey {
        case actionType = "actionType"
        case targetUserIDs = "target"
        case content = "content"
    }
    
    func josnString() -> String? {
        
        var dict: [String : Any] = [ : ]
        
        dict["actionType"] = actionType.rawValue
        dict["target"] = targetUserIDs
        
        if content.keys.contains("giftID") {
            dict["content"] = content
        }
        
        let jsonStr = ZegoModelTool.dictionaryToJson(dict)
        
        guard let jsonStr = jsonStr else {
            return nil
        }
        
        return jsonStr
    }
}
