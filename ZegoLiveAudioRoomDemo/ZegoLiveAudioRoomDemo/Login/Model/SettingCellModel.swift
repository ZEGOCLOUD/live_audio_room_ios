//
//  SettingCellModel.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/14.
//

import UIKit

enum SettingCellType {
    case express
    case zim
    case shareLog
    case logOut
    case app
    case terms
    case privacy
}

class SettingCellModel: NSObject {
    
    var title : String?
    var subTitle : String?
    var type : SettingCellType = .express
}
