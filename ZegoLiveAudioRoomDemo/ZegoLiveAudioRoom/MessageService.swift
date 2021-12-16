//
//  ZegoMessageService.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation
import ZIM

protocol MessageServiceDelegate: AnyObject {
    /// receive text message
    func receiveTextMessage(_ message: TextMessage, _ roomID: String)
}

class MessageService: NSObject {
    
    // MARK: - Public
    weak var delegate: MessageServiceDelegate?
    var messageList: [TextMessage] = []
    
    /// send group chat message
    func sendTextMessage(_ message: String, callback: RoomCallback) {
        
    }
}
