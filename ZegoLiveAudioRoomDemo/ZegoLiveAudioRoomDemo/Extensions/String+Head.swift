//
//  String+Head.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/20.
//

import Foundation

extension String {
    
    static func getHeadImageName(userName: String) -> String {
        if userName.count == 0 {
            return ""
        }
        let data = userName.cString(using: String.Encoding.utf8)
        let len = CC_LONG(userName.lengthOfBytes(using: String.Encoding.utf8))
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 16)
        CC_MD5(data!,len, result)
        let hash = NSMutableString()
        for i in 0..<1 {
            hash.appendFormat("%02x", result[i])
        }
        
        let headImageArray:Array = [
            "seat_1_icon",
            "seat_2_icon",
            "seat_3_icon",
            "seat_4_icon",
            "seat_5_icon",
            "seat_6_icon",
            "seat_7_icon",
            "seat_8_icon",
        ]
        
        let n = (Int(String(hash)) ?? 0) % 8
        return headImageArray[n]
        
    }
    
}
