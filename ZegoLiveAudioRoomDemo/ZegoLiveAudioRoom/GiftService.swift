//
//  ZegoGiftService.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation
import ZIM

/// The delegate related to gift receiving callbacks
///
/// Description: Callbacks that triggered when receiving virtual gifts.
protocol GiftServiceDelegate: AnyObject {
    /// Callback for receive a virtual gift
    ///
    /// Description: This callback will be triggered when there is a virtual gifting event occurs, all room users will receive a notification. You can define your own logic here for UI display.
    ///
    /// Call this method at:  After joining the room and when there is a virtual gifting event occurs
    ///
    /// @param giftID refers to the gift type.
    /// @param fromUserID refers to the gift sender.
    /// @param toUserList refers to the gift recipient list.
    func receiveGift(_ giftID: String, from userID: String, to userList: [String])
}

/// Class gift management
///
/// Description: This class contains the logics of send and receive gifts.
class GiftService: NSObject {
    /// The delegate related to gift updates
    weak var delegate: GiftServiceDelegate?
    
    override init() {
        super.init()
        
        // RoomManager didn't finish init at this time.
        DispatchQueue.main.async {
            RoomManager.shared.addZIMEventHandler(self)
        }
    }
    
    /// Send virtual gift
    ///
    /// Description: This method can be used to send a virtual gift, all room users will receive a notification. You can determine whether you are the gift recipient by the toUserList parameter.
    ///
    /// Call this method at:  After joining the room
    ///
    /// @param giftID refers to the gift type.
    /// @param toUserList refers to the gift recipient.
    /// @param callback refers to the callback for send a virtual gift.
    func sendGift(_ giftID: String, to userList: [String], callback: RoomCallback?) {
        
        guard let roomID = RoomManager.shared.roomService.info.roomID else {
            assert(false, "room ID can't be nil.")
            guard let callback = callback else { return }
            callback(.failure(.failed))
            return
        }
        
        let command: CustomCommand = CustomCommand(type: .gift)
        command.targetUserIDs = userList
        command.giftID = giftID
        
        guard let message = command.josnString() else {
            guard let callback = callback else { return }
            callback(.failure(.failed))
            return
        }
        
        guard let messageData = message.data(using: .utf8) else {
            guard let callback = callback else { return }
            callback(.failure(.failed))
            return
        }
        
        let customMessage: ZIMCommandMessage = ZIMCommandMessage(message: messageData)
        let config = ZIMMessageSendConfig()
        config.priority = .low
        ZIMManager.shared.zim?.sendRoomMessage(customMessage, toRoomID: roomID, config: config, callback: { _, error in
            var result: ZegoResult
            if error.code == .success {
                result = .success(())
            } else {
                result = .failure(.other(Int32(error.code.rawValue)))
            }
            guard let callback = callback else { return }
            callback(result)
        })
    }
}


extension GiftService : ZIMEventHandler {
    func zim(_ zim: ZIM, receiveRoomMessage messageList: [ZIMMessage], fromRoomID: String) {
        for message in messageList {
            guard let message = message as? ZIMCommandMessage else { continue }
            guard let jsonStr = String(data: message.message, encoding: .utf8) else { continue }
            let customCommand: CustomCommand = CustomCommand(with: jsonStr)
            if customCommand.actionType != .gift { continue }
            guard let giftID = customCommand.giftID else { continue }
            delegate?.receiveGift(giftID, from: message.senderUserID, to: customCommand.targetUserIDs)
        }
    }
}
