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
    /// receive custom command: invitation
    func receiveCustomCommand(_ command: CustomCommand, roomID: String)
}

class MessageService {
    
    // MARK: - Public
    weak var delegate: MessageServiceDelegate?
    var messageList: [String] = []
    
    /// send group chat message
    func sendTextMessage(_ message: String, callback: RoomCallback) {
        
    }
    
    /// send an invitation message to user to take a speaker seat
    func sendInvitation(_ userID: String, callback: RoomCallback) {
        
    }
}
