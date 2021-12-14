//
//  SettingCellModel.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/14.
//

import UIKit

enum SettingCellType {
    case RTA
    case ZIM
    case Log
    case Out
}

class SettingCellModel: NSObject {
    
    var title : String?
    var subTitle : String?
    var type : SettingCellType = .RTA
}
