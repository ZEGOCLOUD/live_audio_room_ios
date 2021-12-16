//
//  LiveAudioMessageModel.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/16.
//

import UIKit

class LiveAudioMessageModel: NSObject {

    var content:String?
    var attributedContent:NSAttributedString?
    var messageWidth:CGFloat?
    var messageHeight:CGFloat?
    var isOwner:Bool = false
}
