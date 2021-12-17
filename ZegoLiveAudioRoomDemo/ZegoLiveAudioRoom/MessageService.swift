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
    func sendTextMessage(_ message: String, callback: RoomCallback?) {
        
        guard let roomID = RoomManager.shared.roomService.info?.roomID else {
            guard let callback = callback else { return }
            callback(.failure(.failed))
            return
        }
        
        let textMessage = ZIMTextMessage(message: message)
        ZIMManager.shared.zim?.sendRoomMessage(textMessage, toRoomID: roomID, callback: { _, error in
            var result: ZegoResult
            if error.code == .ZIMErrorCodeSuccess {
                result = .success(())
            } else {
                result = .failure(.other(Int32(error.code.rawValue)))
            }
            guard let callback = callback else { return }
            callback(result)
        })
    }
}
