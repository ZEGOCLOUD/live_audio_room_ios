//
//  TokenManager.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2022/4/9.
//

import UIKit

typealias TokenCallback = (Result<String, ZegoError>) -> Void

class TokenManager: NSObject {
    
    static let shared = TokenManager()
    
    private var token: String?
    private var expiryTime: Int = 0
    private var userID: String?
    
    override init() {
        super.init()
    }
    
    func getToken(_ userID: String, isForceUpdate: Bool = false, callback: TokenCallback?) {
        let currentTime = Int(Date().timeIntervalSince1970)
        
        if self.userID != nil && self.userID == userID && token != nil && expiryTime - currentTime > 10 * 60 && !isForceUpdate {
            guard let callback = callback else { return }
            callback(.success(token!))
            return
        }
        
        let effectiveTimeInSeconds: Int = 24 * 3600 // 24h
        self.getTokenFromServer(userID, effectiveTimeInSeconds) { result in
            if result.isSuccess {
                let newToken: String? = result.success
                self.token = newToken
                self.userID = userID
                self.expiryTime = Int(Date().timeIntervalSince1970) + effectiveTimeInSeconds
                guard let callback = callback,
                      let newToken = newToken
                else { return }
                callback(.success(newToken))
            } else {
                guard let callback = callback else { return }
                callback(.failure(.failed))
            }
        }
        
    }
    
    private func getTokenFromServer(_ userID: String, _ effectiveTimeInSeconds: Int, callback: TokenCallback?) {
        let newToken: String? = AppToken.getToken(withUserID: userID, effectiveTimeInSeconds: effectiveTimeInSeconds)
        guard let callback = callback else { return }
        var tokenResult: Result<String, ZegoError> = .failure(.failed)
        if let newToken = newToken {
            tokenResult = .success(newToken)
        }
        callback(tokenResult)
    }
    
}
