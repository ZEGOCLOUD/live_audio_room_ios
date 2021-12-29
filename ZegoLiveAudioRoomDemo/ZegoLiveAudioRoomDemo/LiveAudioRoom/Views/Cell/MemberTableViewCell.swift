//
//  MemberTableViewCell.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/20.
//

import UIKit

protocol MemberTableViewCellDelegate: AnyObject {
    func MemberTableViewCellDidSelectedMoreAction(cell: MemberTableViewCell)
}

class MemberTableViewCell: UITableViewCell {
    
    weak var delegate: MemberTableViewCellDelegate?
    

    @IBOutlet weak var moreActionButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var identityLabel: UILabel!
    @IBOutlet weak var headImage: UIImageView!
    
    var _isSpeakerSeat: Bool = false
    var _isHost: Bool = false
    var _roomUser: UserInfo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public func setRoomUser(user: UserInfo,isSpeakerSeat: Bool, isHost: Bool) -> Void {
        _roomUser = user
        _isSpeakerSeat = isSpeakerSeat
        _isHost = isHost
        userName.text = user.userName
        let imageName:String = String.getHeadImageName(userName: user.userName ?? "")
        headImage.image = UIImage.init(named: imageName)
        updateRoleInfo()
    }
    
    var identifyTitle:String = ""
    
    func updateRoleInfo() -> Void {
        moreActionButton.isHidden = true
        switch _roomUser?.role {
        case .listener:
            if _isHost {
                if !_isSpeakerSeat {
                    identifyTitle = ""
                    moreActionButton.isHidden = false
                } else {
                    identifyTitle = ZGLocalizedString("room_page_role_speaker");
                    moreActionButton.isHidden = true
                }
            } else {
                moreActionButton.isHidden = true
            }

        case .speaker:
            identifyTitle =  ZGLocalizedString("room_page_role_speaker");
            moreActionButton.isHidden = true
        case .none:
            break
        case .some(.host):
            identifyTitle = ZGLocalizedString("room_page_role_owner");
            moreActionButton.isHidden = true
            break
        }

        identityLabel.text = identifyTitle
    }
    
    
    @IBAction func moreActionButtonClick(_ sender: UIButton) {
        delegate?.MemberTableViewCellDidSelectedMoreAction(cell: self)
    }
    
}
