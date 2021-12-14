//
//  AppDefine.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/14.
//

import UIKit

func ZGLocalizedString(key : String) -> String {
    return Bundle.main.localizedString(forKey: key, value: "", table: "Room")
}

func getKeyWindow() -> UIWindow {
    var window:UIWindow = UIApplication.shared.keyWindow!
        if #available(iOS 13.0, *) {
            window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).last!
        }
    return window
}
