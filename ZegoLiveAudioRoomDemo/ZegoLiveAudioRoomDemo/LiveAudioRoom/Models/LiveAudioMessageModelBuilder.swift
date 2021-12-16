//
//  LiveAudioMessageModelBuilder.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/16.
//

import UIKit

let hostWidth:CGFloat = 42.0

class LiveAudioMessageModelBuilder: NSObject {
    
    

    static var _messageViewWidth:CGFloat?
    static var messageViewWidth:CGFloat? {
        set {
            _messageViewWidth = newValue
        }
        get {
            return _messageViewWidth
        }
    }
    
    static func buildModelWithUserID(userID:String,message:String) -> LiveAudioMessageModel {
        let user:UserInfo? = LiveAudioMessageModelBuilder.getUserWithUserID(userID:userID)
        let isHost:Bool = user?.role == .host;
        let attributedStr:NSMutableAttributedString = NSMutableAttributedString()
        
        let nameAttributes:NSDictionary = LiveAudioMessageModelBuilder.getNameAttributes(isHost: isHost)
        let nameStr:NSAttributedString = NSAttributedString.init(string: user?.userName ?? "", attributes: nameAttributes as! [NSAttributedString.Key : Any])
        
        let contentAttributes:NSDictionary = LiveAudioMessageModelBuilder.getContentAttributes(isHost: isHost)
        let content:String = ": " + message
        let contentStr:NSAttributedString = NSAttributedString.init(string: content, attributes: contentAttributes as! [NSAttributedString.Key : Any])
        
        attributedStr.append(nameStr)
        attributedStr.append(contentStr)
        
        let labelWidth = (messageViewWidth ?? 0) - 16 - 30 - 10*2
        var size:CGSize = attributedStr.boundingRect(with: CGSize.init(width: labelWidth, height: CGFloat(MAXFLOAT)), options:[NSStringDrawingOptions.usesLineFragmentOrigin,NSStringDrawingOptions.usesFontLeading], context: nil).size
        
        if size.height <= 15 {
            size.width += isHost ? hostWidth : 0
        }
        
        let model:LiveAudioMessageModel = LiveAudioMessageModel()
        model.isOwner = isHost
        model.content = content
        model.attributedContent = attributedStr
        model.messageWidth = size.width + 1.0
        model.messageHeight = size.height + 1.0
        
        return model
    }
    
    static func buildLeftMessageModelWithUser(user:UserInfo) -> LiveAudioMessageModel {
        let message = ZGLocalizedString("room_page_has_left_the_room") + (user.userName ?? "")
        return LiveAudioMessageModelBuilder._buildLeftOrJoinMessageModelWithMessage(message: message)
    }
    
    static func buildJoinMessageModelWithUser(user:UserInfo) -> LiveAudioMessageModel {
        let message  = ZGLocalizedString("room_page_joined_the_room") + (user.userName ?? "")
        return LiveAudioMessageModelBuilder._buildLeftOrJoinMessageModelWithMessage(message: message)
    }
    
    static func getUserWithUserID(userID:String) -> UserInfo? {
        for user:UserInfo in RoomManager.shared.userService.userList {
            if user.userID == userID {
                return user
            }
        }
        return nil
    }
    
    static func getNameAttributes(isHost:Bool) -> NSDictionary {
        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.paragraphSpacing = 0
        paragraphStyle.minimumLineHeight = 15.0
        paragraphStyle.firstLineHeadIndent = isHost ? hostWidth : 0
        return [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12.0),NSAttributedString.Key.paragraphStyle:paragraphStyle,NSAttributedString.Key.foregroundColor:BlueColor()]
    }
    
    static func getContentAttributes(isHost:Bool) -> NSDictionary {
        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.paragraphSpacing = 0
        paragraphStyle.minimumLineHeight = 15.0
        paragraphStyle.firstLineHeadIndent = isHost ? hostWidth : 0
        return [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12.0),NSAttributedString.Key.paragraphStyle:paragraphStyle,NSAttributedString.Key.foregroundColor:BlackColor()]
        
    }
    
    static func _buildLeftOrJoinMessageModelWithMessage(message:String) -> LiveAudioMessageModel {
        let model:LiveAudioMessageModel = LiveAudioMessageModel()
        model.content = message
        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 0
        paragraphStyle.minimumLineHeight = 16.5
        
        let attributes:NSDictionary = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12.0),NSAttributedString.Key.paragraphStyle:paragraphStyle,NSAttributedString.Key.foregroundColor:BlueColor()]
        let attributedStr:NSAttributedString = NSAttributedString.init(string: message, attributes: attributes as! [NSAttributedString.Key : Any])
        
        let labelWidth = (messageViewWidth ?? 0) - 16 - 30 - 10 * 2
        let size:CGSize = attributedStr.boundingRect(with: CGSize.init(width: labelWidth, height: CGFloat(MAXFLOAT)), options: [NSStringDrawingOptions.usesLineFragmentOrigin], context: nil).size
        
        model.attributedContent = attributedStr
        model.messageWidth = size.width + 1.0
        model.messageHeight = size.height + 1.0
        return model
    }
    
}
