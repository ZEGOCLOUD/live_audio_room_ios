//
//  ZegoDefine.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import Foundation

typealias ZegoResult = Result<Void, ZegoError>
/// Callback methods
///
/// Description: When the called method is asynchronous processing, If you are making and processing asynchronous calls,
/// the following callbacks will be triggered when a method has finished its execution and returns the execution result.
///
/// @param error refers to the operation status code.
///            0: Operation successful.
///            100xxxx: The Express SDK error code. For details, refer to the error code documentation. [iOS]: https://doc-en.zego.im/article/5547 [Android]: https://doc-en.zego.im/article/5548
///            600xxxx: The ZIM SDK error code. For details, refer to the error code documentation. [iOS]: https://doc-en.zego.im/article/13791 [Android]: https://doc-en.zego.im/article/13792
typealias RoomCallback = (ZegoResult) -> Void

/// Callback for get the total number of in-room users
///
/// Description: This callback will be triggered when the method call that get the total number of in-room users has finished its execution.
///
/// @param error refers to the operation status code.
///            0: Operation successful.
///            600xxxx stands for ZIM SDK error code, refer to iOS: https://doc-zh.zego.im/article/11605 android: https://doc-zh.zego.im/article/11606
               
/// @param num refers to the total number of in-room users
typealias OnlineRoomUsersNumCallback = (Result<UInt32, ZegoError>) -> Void

/// Callback for get the user list
///
/// Description: This callback will be triggered when the method call that get the user list has finished its execution.
///
/// @param error refers to the operation status code.
///            0: Operation successful.
///            600xxxx: The ZIM SDK error code. For details, refer to the error code documentation. [iOS]: https://doc-en.zego.im/article/13791 [Android]: https://doc-en.zego.im/article/13792
///
/// @param userList refers to the in-room user list
typealias OnlineRoomUsersCallback = (Result<[UserInfo], ZegoError>) -> Void


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
    case other(_ rawValue: Int32)
    
    var code: Int32 {
        switch self {
        case .failed: return 1
        case .roomExisted: return 1001
        case .roomNotFound: return 1002
        case .takeSeatFailed: return 2001
        case .setSeatInfoFailed: return 2002
        case .alreadyOnSeat: return 2003
        case .noPermission: return 2004
        case .notOnSeat: return 2005
        case .paramInvalid: return 2006
        case .other(let rawValue): return rawValue
        }
    }
}
