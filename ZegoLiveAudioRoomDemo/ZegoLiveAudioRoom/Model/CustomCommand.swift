//
//  CustomCommand.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/14.
//

import UIKit
import ZIM

enum CustomCommandType {
    case Invitation
    case Gift
}

class CustomCommand: ZIMCustomMessage {
    var actionType: CustomCommandType?
    var targetUserIDs: [String] = []
    var content: [String : Any]?
}
