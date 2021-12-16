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
    
    /// send gift message to corresponding users
    func sendGift(_ giftID: String, to userList: [String], callback: RoomCallback?) {
        
        let command: CustomCommand = CustomCommand(type: .gift)
        command.targetUserIDs = userList
        command.content["giftID"] = giftID
        
        guard let message = command.josnString() else {
            guard let callback = callback else { return }
            callback(.failure(.failed))
            return
        }
        
        let textMessage: ZIMTextMessage = ZIMTextMessage(message: message)
        guard let roomID = RoomManager.shared.roomService.info?.roomID else {
            assert(false, "room ID can't be nil.")
            guard let callback = callback else { return }
            callback(.failure(.failed))
            return
        }
        
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
