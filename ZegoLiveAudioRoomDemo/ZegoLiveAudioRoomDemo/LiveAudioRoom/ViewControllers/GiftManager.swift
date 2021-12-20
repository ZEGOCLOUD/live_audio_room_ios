//
//  GiftManager.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/20.
//

import Foundation

class GiftManager : NSObject {
    
    static let shared = GiftManager()
    
    lazy var giftModels: [GiftModel] = {
        let model = GiftModel()
        model.imageName = "gift_logo"
        model.name = ZGLocalizedString("room_page_gift_heart")
        model.giftID = "0"
        return [model]
    }()
    
    private override init() {
        
    }
    
    func getGiftModel(_ giftID: String) -> GiftModel? {
        for model in giftModels {
            if model.giftID == giftID {
                return model
            }
        }
        return nil
    }
    
}
