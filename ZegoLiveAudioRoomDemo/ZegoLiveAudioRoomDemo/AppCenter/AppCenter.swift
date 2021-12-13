//
//  AppCenter.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation

struct AppCenter {
    
    private static var json : [String:Any]?
        
    static func appID() -> UInt {
        if let dict = getJsonDictionary() {
            let appID = dict["appID"] as! UInt
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
        if json != nil {
            return json
        }
        let jsonPath = Bundle.main.path(forResource: "AppCenter", ofType: "json")
        if jsonPath == nil {
            return nil
        }
        let jsonStr = try? String(contentsOfFile: jsonPath!)
        
        if let data = jsonStr!.data(using: .utf8) {
            do {
                json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                return json
            } catch {
                
            }
        }
        return nil
    }
}
