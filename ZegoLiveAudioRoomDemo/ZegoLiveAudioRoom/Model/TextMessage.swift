//
//  TextMessage.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/14.
//

import Foundation
import ZIM

/// Class IM message
///
/// Description: This class contains the IM message related information.
class TextMessage: NSObject {
    //  Inherit from the ZIMTextMessage
    
    var userID: String = ""
    var message: String = ""
    
    init(_ message: String) {
        super.init()
        self.message = message
    }
}
