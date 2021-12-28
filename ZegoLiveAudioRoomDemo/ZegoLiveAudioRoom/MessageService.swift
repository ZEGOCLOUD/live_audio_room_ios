//
//  ZegoMessageService.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation
import ZIM

/// The delegate related to the message receiving callbacks
///
/// Description: Callbacks that be triggered when new IM messages received.
protocol MessageServiceDelegate: AnyObject {
    /// Callback for receive IM text messages
    ///
    /// Description: This callback will be triggered when existing users in the room send IM messages, and all users in the room will reveive a notification. The message list will be updated synchronously
    ///
    /// @param textMessage refers to the received text message information.
    func receiveTextMessage(_ message: TextMessage)
}

/// Class IM message management
///
/// Description: This class contains the logcis of the IM messages management, such as send or receive messages.
class MessageService: NSObject {
    
    // MARK: - Public
    /// The delegate related to message updates
    weak var delegate: MessageServiceDelegate?
    /// The message list
    var messageList: [TextMessage] = []
    
    override init() {
        super.init()
        
        // RoomManager didn't finish init at this time.
        DispatchQueue.main.async {
            RoomManager.shared.addZIMEventHandler(self)
        }
    }
    
    /// Send IM text message
    ///
    /// Description: This method can be used to send IM text message, and all users in the room will receive the message notification.
    ///
    /// Call this method at:  After joining the room
    ///
    /// @param message refers to the text message content, which is limited to 1kb.
    /// @param callback refers to the callback for send text messages.
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
