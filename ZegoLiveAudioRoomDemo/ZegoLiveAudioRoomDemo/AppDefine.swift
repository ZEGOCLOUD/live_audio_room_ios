//
//  AppDefine.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/14.
//

import Foundation

func ZGLocalizedString(key : String) -> String {
    return Bundle.main.localizedString(forKey: key, value: "", table: "Room")
}
