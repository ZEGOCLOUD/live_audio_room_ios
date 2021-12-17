//
//  ZegoGiftService.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation
import ZIM

protocol GiftServiceDelegate: AnyObject {
    /// receive gift message
    func receiveGift(_ giftID: String, from userID: String, to userList: [String])
}

class GiftService: NSObject {
    weak var delegate: GiftServiceDelegate?
    
    override init() {
        super.init()
        
        // RoomManager didn't finish init at this time.
        DispatchQueue.main.async {
            RoomManager.shared.addZIMEventHandler(self)
        }
    }
    
    /// send gift message to corresponding users
    func sendGift(_ giftID: String, to userList: [String], callback: RoomCallback?) {
        
        guard let roomID = RoomManager.shared.roomService.info?.roomID else {
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
        
        let customMessage: ZIMCustomMessage = ZIMCustomMessage(message: messageData)
        
        ZIMManager.shared.zim?.sendRoomMessage(customMessage, toRoomID: roomID, callback: { _, error in
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


extension GiftService : ZIMEventHandler {
    func zim(_ zim: ZIM, receiveRoomMessage messageList: [ZIMMessage], fromRoomID: String) {
        for message in messageList {
            guard let message = message as? ZIMCustomMessage else { continue }
            guard let jsonStr = String(data: message.message, encoding: .utf8) else { continue }
            let customCommand: CustomCommand = CustomCommand(with: jsonStr)
            if customCommand.actionType != .gift { continue }
            guard let giftID = customCommand.giftID else { continue }
            delegate?.receiveGift(giftID, from: fromRoomID, to: customCommand.targetUserIDs)
        }
    }
}
