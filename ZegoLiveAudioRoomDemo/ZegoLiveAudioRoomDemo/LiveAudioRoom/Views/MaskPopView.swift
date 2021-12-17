//
//  MaskPopView.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/16.
//

import UIKit

typealias popViewCallback = () -> Void

enum MaskPopViewType {
    case lock
    case unLock
    case leave
    case take
    case invite
}

class MaskPopView: UIView {
    
    
    @IBOutlet weak var actionButton: UIButton!
    
    var block:popViewCallback?
    var _type:MaskPopViewType?
    var type:MaskPopViewType? {
        didSet {
            switch type {
            case .lock:
                actionButton.setTitle(ZGLocalizedString("room_page_lock_seat"), for: UIControl.State.normal)
                break
            case .unLock:
                actionButton.setTitle(ZGLocalizedString("room_page_unlock_seat"), for: UIControl.State.normal)
                break
            case .take:
                actionButton.setTitle(ZGLocalizedString("room_page_take_seat"), for: UIControl.State.normal)
                break
            case .leave:
                actionButton.setTitle(ZGLocalizedString("room_page_leave_speaker_seat"), for: UIControl.State.normal)
                break
            case .invite:
                actionButton.setTitle(ZGLocalizedString("room_page_invite_take_seat"), for: UIControl.State.normal)
                break
            case .none:
                break
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.removeFromSuperview()
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        if block != nil {
            block!()
        }
        self.removeFromSuperview()
    }
    

}
