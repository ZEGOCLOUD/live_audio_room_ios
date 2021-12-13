//
//  ZegoZIMManager.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation
import ZIM

class ZIMManager {
    static let shared = ZIMManager()
    private init() {}
    
    fileprivate(set) var zim: ZIM?
    
    func createZIM(appID: UInt32) {
        zim = ZIM.create(appID)
    }
    
    func destoryZIM() {
        zim?.destroy()
        zim = nil
    }
}
