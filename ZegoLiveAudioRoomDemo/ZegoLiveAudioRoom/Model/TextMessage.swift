//
//  TextMessage.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/14.
//

import Foundation
import ZIM

class TextMessage: ZIMTextMessage {
    init(_ message: String) {
        super.init()
        self.message = message
    }
}
