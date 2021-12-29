//
//  AppDefine.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/14.
//

import UIKit

typealias RoomUICallback = () -> Void

func BlueColor() -> UIColor {
    return UIColor.init(red: 0, green: 85/255.0, blue: 255/255.0, alpha: 1)
}

func BlackColor() -> UIColor {
    return UIColor.init(red: 27/255.0, green: 27/255.0, blue: 27/255.0, alpha: 1)
}


func ZGLocalizedString(_ key : String) -> String {
    return Bundle.main.localizedString(forKey: key, value: "", table: "Room")
}

func getKeyWindow() -> UIWindow {
    let window: UIWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).last!
    return window
}
