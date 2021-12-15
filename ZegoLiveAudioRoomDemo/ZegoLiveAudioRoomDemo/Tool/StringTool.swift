//
//  StringTool.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/15.
//

import Foundation
import UIKit

extension NSString {
    func isUserIdValidated() -> Bool {
        let userIdRegex = "^[A-Za-z0-9]+$"
        if NSPredicate(format:"SELF MATCHES %@",userIdRegex).evaluate(with: self) {
            return true
        } else {
            return false
        }
    }
}
