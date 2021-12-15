//
//  ZegoDefine.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation

/// common room callback
typealias RoomCallback = (Result<Void, ZegoError>) -> Void

/// online room users callback
typealias OnlineRoomUsersCallback = (Result<UInt, ZegoError>) -> Void


enum ZegoError: Error {
    /// common failed
    case failed
    case roomExisted
    case roomNotFound
    case takeSeatFailed
    case setSeatInfoFailed
    case alreadyOnSeat
    case noPermission
    case notOnSeat
    case paramInvalid
    
    /// other error code
    case other(_ rawValue: Int)
    
}
