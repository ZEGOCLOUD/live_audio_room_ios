//
//  AppCenter.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation

struct AppCenter {
    
    private static var dict : [String:Any]?
        
    static func appID() -> UInt32 {
        if let dict = getJsonDictionary() {
            let appID = dict["appID"] as! UInt32
            return appID
        }
        return 0
    }
    
    static func appSign() -> String {
        if let dict = getJsonDictionary() {
            let appSign = dict["appSign"] as! String
            return appSign
        }
        return ""
    }
    
    static func appSecret() -> String {
        if let dict = getJsonDictionary() {
            let appSecret = dict["appSecret"] as! String
            return appSecret
        }
        return ""
    }
    
    // MARK: - Private
    private static func getJsonDictionary() -> [String:Any]? {
        if dict != nil {
            return dict
        }
        let jsonPath = Bundle.main.path(forResource: "AppCenter", ofType: "json")
        guard let jsonPath = jsonPath else {
            assert(false)
            return nil
        }
        let jsonStr = try? String(contentsOfFile: jsonPath)
        
        dict = ZegoJsonTool.jsonToDictionary(jsonStr)
        
        return dict
    }
}
