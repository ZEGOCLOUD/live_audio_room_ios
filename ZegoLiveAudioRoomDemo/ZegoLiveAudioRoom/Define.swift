//
//  ZegoDefine.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation

/// commonHandler, the parameter is ErrorCode
typealias CommonHandler = (UInt) -> Void

/// the first parameter is Count, the second parameter is errorCode
typealias MemberCountHandler = (UInt, UInt) -> Void
