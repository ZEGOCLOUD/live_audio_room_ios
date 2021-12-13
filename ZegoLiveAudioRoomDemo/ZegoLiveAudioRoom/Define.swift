//
//  ZegoDefine.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation

/// commonHandler, the parameter is ErrorCode
typealias RoomCallback = (UInt) -> Void

/// the first parameter is Count, the second parameter is errorCode
typealias OnlineRoomUsersCallback = (UInt, UInt) -> Void
