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
    func receiveTextMessage(_ message: TextMessage)
}

class MessageService: NSObject {
    
    // MARK: - Public
    weak var delegate: MessageServiceDelegate?
    var messageList: [TextMessage] = []
    
    override init() {
        super.init()
        
        // RoomManager didn't finish init at this time.
        DispatchQueue.main.async {
            RoomManager.shared.addZIMEventHandler(self)
        }
    }
    
    /// send group chat message
    func sendTextMessage(_ message: String, callback: RoomCallback?) {
        
        guard let roomID = RoomManager.shared.roomService.info.roomID else {
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

extension MessageService : ZIMEventHandler {
    
    func zim(_ zim: ZIM, receiveRoomMessage messageList: [ZIMMessage], fromRoomID: String) {
        for message in messageList {
            guard let message = message as? ZIMTextMessage else { continue }
            let textMessage = TextMessage(message.message)
            textMessage.userID = message.userID
            delegate?.receiveTextMessage(textMessage)
        }
    }
}
