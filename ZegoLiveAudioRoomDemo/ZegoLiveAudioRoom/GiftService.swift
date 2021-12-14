//
//  ZegoGiftService.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation

protocol GiftServiceDelegate: AnyObject {
    /// receive gift message
    func receiveGift(_ giftID: String, to userList: [String])
}

class GiftService {
    weak var delegate: GiftServiceDelegate?
    
    /// send gift message to corresponding users
    func sendGift(_ giftID: String, to userList: [String]) {
        
    }
}
