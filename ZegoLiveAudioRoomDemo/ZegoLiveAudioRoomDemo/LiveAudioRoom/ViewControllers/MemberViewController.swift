//
//  MemberViewController.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/20.
//

import UIKit

class MemberViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MemberTableViewCellDelegate{
    
    
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var roomMemberTableView: UITableView!
    @IBOutlet weak var inviteMaskView: UIView!
    @IBOutlet weak var bottomMaskView: UIView!
    
    var inviteRoomUser:UserInfo?
    var memberCount:Int = 0
    
    func updateMemberListData() -> Void {
        updateRoomName()
        roomMemberTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let bottomMaskTap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(bottomMaskTapClick))
        bottomMaskView.addGestureRecognizer(bottomMaskTap)
        let tap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapClick))
        inviteMaskView.addGestureRecognizer(tap)
    }
    
    @objc func bottomMaskTapClick() -> Void {
        self.view.isHidden = true
    }
    
    @objc func tapClick() -> Void {
        inviteMaskView.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        clipRoundCorners()
    }
    
    func updateRoomName() -> Void {
        RoomManager.shared.userService.queryOnlineRoomUsersCount { Result in
            switch Result {
            case .success(let count):
                self.memberCount = Int(count)
                self.roomMemberTableView.reloadData()
            case .failure:
                break
            }
        }
    }
    
    func clipRoundCorners() -> Void {
        let maskPath: UIBezierPath = UIBezierPath.init(roundedRect: CGRect.init(x: 0, y: 0, width: whiteView.bounds.size.width, height: whiteView.bounds.size.height), byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize.init(width: 12, height: 12))
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = whiteView.bounds
        maskLayer.path = maskPath.cgPath
        whiteView.layer.mask = maskLayer
    }
    
    func isOnSeat(userID: String) -> Bool {
        var isOnSeat:Bool = false
        for seat in RoomManager.shared.speakerService.seatList {
            if seat.userID == userID {
                isOnSeat = true
                break
            }
        }
        return isOnSeat
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RoomManager.shared.userService.userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomMemberTableViewCell") as! MemberTableViewCell
        cell.delegate = self as MemberTableViewCellDelegate
        let roomUser:UserInfo = RoomManager.shared.userService.userList.allObjects()[indexPath.row]
        let isHost:Bool = RoomManager.shared.userService.localInfo?.userID == RoomManager.shared.roomService.info.hostID
        cell.setRoomUser(user: roomUser, isSpeakerSeat: isOnSeat(userID: roomUser.userID ?? ""), isHost: isHost)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let secView:UIView = UIView()
        secView.backgroundColor = UIColor.white
        let titleLabel:UILabel = UILabel.init(frame: CGRect.init(x: 0, y: 10, width: self.view.bounds.size.width, height: 36))
        titleLabel.textAlignment = .center
        titleLabel.text = String(format: ZGLocalizedString("room_page_user_list"), memberCount)
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        secView.addSubview(titleLabel)
        return secView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
    //MARK: -MemberTableViewCellDelegate
    func MemberTableViewCellDidSelectedMoreAction(cell: MemberTableViewCell) {
        let index:NSIndexPath = roomMemberTableView.indexPath(for: cell)! as NSIndexPath
        inviteRoomUser = RoomManager.shared.userService.userList.allObjects()[index.row]
        inviteMaskView.isHidden = false
    }
    
    
    @IBAction func inviteSpeak(_ sender: UIButton) {
        
        if !isAnyFreeSeat(){
            inviteMaskView.isHidden = true
            HUDHelper.showMessage(message: ZGLocalizedString("room_page_no_more_seat_available"))
            return
        }
        
        let isHost:Bool = RoomManager.shared.userService.localInfo?.userID == RoomManager.shared.roomService.info.hostID
        let isSpeakerSeat:Bool = isOnSeat(userID: inviteRoomUser?.userID ?? "")
        if inviteRoomUser?.role == .listener && isHost && !isSpeakerSeat {
            if getCurrentSeatUserNum() < 8 {
                RoomManager.shared.userService.sendInvitation(inviteRoomUser?.userID ?? "") { result in
                    switch result {
                    case .success:
                        self.view.isHidden = true
                        HUDHelper.showMessage(message:ZGLocalizedString("room_page_invitation_has_sent"))
                        break
                    case .failure(let error):
                        HUDHelper.showMessage(message:"\(error.code)")
                        break
                    }
                }
            } else {
                HUDHelper.showMessage(message: ZGLocalizedString("room_page_no_more_seat_available"))
            }
        } else {
            inviteMaskView.isHidden = true
        }
        
    }
    
    func getCurrentSeatUserNum() -> Int {
        let array = RoomManager.shared.speakerService.seatList.filter { Value in
            return Value.userID.count > 0
        }
        return array.count
    }
    
    func isAnyFreeSeat() -> Bool {
        var hasFreeSeat: Bool = false
        for seat in RoomManager.shared.speakerService.seatList {
            if seat.userID.count == 0 && seat.status == .untaken {
                hasFreeSeat = true
                break
            }
        }
        return hasFreeSeat
    }
    
}
