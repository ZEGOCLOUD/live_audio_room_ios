//
//  LiveAudioRoomViewController.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/16.
//

import UIKit
import ZIM
import AVFoundation

class LiveAudioRoomViewController: UIViewController {
    
    @IBOutlet weak var bottomBar: UIView!
    
    @IBOutlet weak var giftButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var memberButton: UIButton!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    @IBOutlet weak var speakerSeatView: UIView!
    
    @IBOutlet weak var roomTitleLabel: UILabel!
    @IBOutlet weak var roomIdLabel: UILabel!
    
    @IBOutlet weak var giftTipView: GiftTipView!
    
    @IBOutlet weak var messageView: LiveAudioMessageView!
    
    @IBOutlet weak var settingButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var memberButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var giftButtonTrail: NSLayoutConstraint!
    @IBOutlet weak var memberButtonTrail: NSLayoutConstraint!
    @IBOutlet weak var messageHeightConstraint: NSLayoutConstraint!
    
    lazy var inputTextView: InputTextView = {
        let textView: InputTextView = UINib(nibName: "InputTextView", bundle: nil).instantiate(withOwner: self, options: nil).last as! InputTextView
        textView.frame = CGRect(x: 0, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: 55)
        textView.delegate = self
        return textView
    }()
    
    lazy var seatCollectionView: SeatCollectionView = {
        let seatCollectionView = UINib(nibName: "SeatCollectionView", bundle: nil).instantiate(withOwner: self, options: nil).last as! SeatCollectionView
        seatCollectionView.itemSpace = 10
        seatCollectionView.lineSpace = 5
        seatCollectionView.delegate = self
        seatCollectionView.setNumOfRows(numOfRows: 4, numOfLines: 2)
        return seatCollectionView
    }()
    
    lazy var settingsView: LiveAudioSettingView = {
       let settingsView = LiveAudioSettingView(frame: CGRect(x: 0,
                                                             y: 0,
                                                             width: self.view.bounds.size.width,
                                                             height: self.view.bounds.size.height))
        settingsView.isHidden = true
        return settingsView
    }()
    
    lazy var giftView: LiveAudioGiftView = {
        let giftView = LiveAudioGiftView(frame: CGRect(x: 0,
                                                       y: 0,
                                                       width: self.view.frame.size.width,
                                                       height: self.view.frame.size.height))
        giftView.isHidden = true
        giftView.delegate = self
        return giftView
    }()
    
    lazy var memberVC: MemberViewController = {
        let vc = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "MemberViewController") as! MemberViewController
        vc.view.frame = self.view.bounds
        vc.view.isHidden = true
        self.addChild(vc)
        self.view.addSubview(vc.view)
        return vc
    }()
    
    var messageList: [MessageModel] = []
    var isMuteAllMessage: Bool = false
    var localUserID: String {
        get {
            assert(RoomManager.shared.userService.localInfo?.userID != nil, "user ID shouldn't be nil.")
            return RoomManager.shared.userService.localInfo?.userID ?? ""
        }
    }
    var currentUserInfo: UserInfo? {
        get {
            RoomManager.shared.userService.localInfo
        }
    }
    var micAuthorizationTimer: ZegoTimer = ZegoTimer(500)
    
    var inviteAlter: UIAlertController?
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidShow(node:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidHide(node:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        RegisterServiceCallback()
        
        if localUserIsHost() {
            RoomManager.shared.speakerService.takeSeat(0, callback:{ result in
                self.micAuthorizationTimer.setEventHandler {
                    self.onMicAuthorizationTimerTriggered()
                }
                self.micAuthorizationTimer.start()
            })
        }
        
        configUI()

        if let myself = RoomManager.shared.userService.localInfo {
            let model: MessageModel = MessageModelBuilder.buildJoinMessageModel(user: myself)
            messageList.append(model)
            reloadMessageData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let inviteAlter = inviteAlter {
            inviteAlter.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        seatCollectionView.frame = speakerSeatView.bounds
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        getKeyWindow().endEditing(true)
    }
    
    // MARK: - UI
    
    func RegisterServiceCallback() -> Void {
        RoomManager.shared.roomService.delegate = self
        RoomManager.shared.userService.addUserServiceDelegate(self)
        RoomManager.shared.speakerService.delegate = self
        RoomManager.shared.messageService.delegate = self
        RoomManager.shared.giftService.delegate = self
    }
    
    func configUI() -> Void {
        roomTitleLabel.text = RoomManager.shared.roomService.info.roomName
        roomIdLabel.text = String(format: "ID: %@", RoomManager.shared.roomService.info.roomID ?? "")
        
        self.view.addSubview(settingsView)
        self.view.addSubview(giftView)
        speakerSeatView.addSubview(seatCollectionView)
        
        updateSpeakerSeatUI()
        displayBottomButtonByIdentify()
        
        self.view.addSubview(inputTextView)
        
        micButton.setImage(UIImage.init(named: "mic_open_icon"), for: .normal)
        micButton.setImage(UIImage.init(named: "close_mic"), for: .selected)
        
        if RoomManager.shared.roomService.info.isTextMessageDisabled && !localUserIsHost() {
            sendMessageButton .setImage(UIImage.init(named: "message_lock_icon"), for: .normal)
        } else {
            sendMessageButton .setImage(UIImage.init(named: "message_icon"), for: .normal)
        }
        
    }
    
    func reloadMessageData() -> Void {
        updateMessageHeightConstraint()
        messageView.reloadWithData(data: messageList)
        messageView.scrollToBottom()
    }
    
    func updateMessageHeightConstraint() -> Void {
        var height:CGFloat = 0
        for model:MessageModel in messageList {
            height += (model.messageHeight ?? 0) + 10*2 + 10
        }
        messageHeightConstraint.constant = height
    }
    
    func updateSpeakerSeatUI() {
        if let role = currentUserInfo?.role {
            seatCollectionView.role = role
        }
        seatCollectionView.updateDataSource(data: RoomManager.shared.speakerService.seatList)
        displayBottomButtonByIdentify()
    }
    
    func displayBottomButtonByIdentify() {
        guard let role = currentUserInfo?.role else { return }
        settingButton.isHidden = role == .listener
        memberButton.isHidden = role != .host
        micButton.isHidden = role == .listener
        giftButtonTrail.constant = role == .listener ? 0.0 : 18.0
        memberButtonTrail.constant = role == .host ? 18.0 : 0.0
        memberButtonWidth.constant = role == .host ? 34.0 : 0.0
        settingButtonWidth.constant = role == .listener ? 0.0 : 34.0
        
        let settingImageName = role == .host ? "setting_icon" : "more_icon"
        settingButton.setImage(UIImage(named: settingImageName), for: .normal)
    }
    
    // MARK: - Notification
    @objc func keyBoardDidShow(node : Notification){
        
        guard let userInfo = node.userInfo else { return }
        guard let keyboardValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardRect: CGRect = keyboardValue.cgRectValue
        
        guard let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        let duration: Double = durationValue.doubleValue
        
        UIView.animate(withDuration: duration) {
            self.inputTextView.frame = CGRect(x: 0,
                                           y: UIScreen.main.bounds.size.height - keyboardRect.size.height - 55,
                                           width: self.view.bounds.size.width,
                                           height: 55)
        }
    }
    
    @objc func keyBoardDidHide(node : Notification){
        UIView.animate(withDuration: 0.25) {
            self.inputTextView.frame = CGRect(x: 0,
                                           y: UIScreen.main.bounds.size.height,
                                           width: self.view.bounds.size.width,
                                           height: 55)
        }
    }
    
    //MARK: - Action
    @IBAction func giftButtonClick(_ sender: UIButton) {
        self.giftView.isHidden = false
    }
    
    @IBAction func settingButtonClick(_ sender: UIButton) {
        if RoomManager.shared.userService.localInfo?.role == .host {
            settingsView.isHidden = false
        } else if RoomManager.shared.userService.localInfo?.role == .speaker {
            if RoomManager.shared.speakerService.localSpeakerSeat != nil {
                leaveSeat(index: RoomManager.shared.speakerService.localSpeakerSeat!.index)
            }
        }
    }
    
    @IBAction func memberButtonClick(_ sender: UIButton) {
        memberVC.view.isHidden = false
    }
    
    @IBAction func micButtonClick(_ sender: UIButton) {
        if sender.isSelected && AuthorizedCheck.isMicrophoneAuthorizationDetermined() {
            AuthorizedCheck.takeMicPhoneAuthorityStatus(completion: nil)
        }
        
        if sender.isSelected && AuthorizedCheck.isMicrophoneAuthorizationDetermined() && !AuthorizedCheck.isMicrophoneAuthorized() {
            AuthorizedCheck.showMicrophoneUnauthorizedAlert(self)
            return
        }
        
        if AuthorizedCheck.isMicrophoneAuthorizationDetermined() {
            if AuthorizedCheck.isMicrophoneAuthorized() {
                RoomManager.shared.speakerService.muteMic(!sender.isSelected) { Result in
                    switch Result {
                    case .success:
                        sender.isSelected = !sender.isSelected
                    case .failure(_):
                        break
                    }
                }
            } else {
                RoomManager.shared.speakerService.muteMic(true) { Result in
                    switch Result {
                    case .success:
                        sender.isSelected = false
                    case .failure(_):
                        break
                    }
                }
            }
        }
    }
    
    
    @IBAction func messageButtonClick(_ sender: UIButton) {
        if RoomManager.shared.roomService.info.isTextMessageDisabled && !localUserIsHost() {
            HUDHelper.showMessage(message: ZGLocalizedString("room_page_bands_send_message"))
            return
        }
        inputTextView.isHidden = false
        inputTextView.textViewBecomeFirstResponse()
    }
    
    @IBAction func leaveRoomButtonClick(_ sender: UIButton) {
        if localUserIsHost() {
            let alterVC:UIAlertController = UIAlertController.init(title: ZGLocalizedString("room_page_destroy_room"), message: ZGLocalizedString("dialog_sure_to_destroy_room"), preferredStyle: .alert)
            let cancelAction:UIAlertAction = UIAlertAction.init(title: ZGLocalizedString("dialog_cancel"), style: .cancel, handler: nil)
            let okAction:UIAlertAction = UIAlertAction.init(title: ZGLocalizedString("dialog_confirm"), style: .default) { action in
                self.leaveChatRoom()
            }
            alterVC.addAction(cancelAction)
            alterVC.addAction(okAction)
            self.present(alterVC, animated: true, completion: nil)
        } else {
            leaveChatRoom()
        }
    }
    
}

// MARK: - Private
extension LiveAudioRoomViewController {
    func localUserIsHost() -> Bool {
        return RoomManager.shared.userService.localInfo?.userID == RoomManager.shared.roomService.info.hostID
    }
    
    func leaveChatRoom() {
        RoomManager.shared.roomService.leaveRoom(callback: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func onMicAuthorizationTimerTriggered() {
        if !AuthorizedCheck.isMicrophoneAuthorizationDetermined() {
            return
        }
        let on = AuthorizedCheck.isMicrophoneAuthorized()
        micButton.isSelected = (!on)
        RoomManager.shared.speakerService.muteMic(!on, callback: nil)
        updateCurrentUserMicStatus()
        micAuthorizationTimer.stop()
    }
    
    func updateCurrentUserMicStatus() {
        let model = RoomManager.shared.speakerService.getSeatModel(userID: self.currentUserInfo?.userID)
        guard let model = model else {
            return
        }
        
        if model.mic == micButton.isSelected {
            model.mic = !micButton.isSelected
        }
        seatCollectionView.reloadCollectionView()

    }
    
    func logout() -> Void {
        RoomManager.shared.userService.logout()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        getKeyWindow().rootViewController = vc
    }
    
    // find a mininum seat which is untaken
    func selectMinimumViableSeat() -> SpeakerSeatModel? {
        for seat in RoomManager.shared.speakerService.seatList {
            if seat.status == .untaken {
                return seat
            }
        }
        return nil
    }
}

extension LiveAudioRoomViewController : InputTextViewDelegate {
    //MARK: -InputTextViewDelegate
    func inputTextViewDidClickSend(_ message: String?) {
        if RoomManager.shared.roomService.info.isTextMessageDisabled && !localUserIsHost() {
            HUDHelper.showMessage(message: ZGLocalizedString("room_page_bands_send_message"))
            return
        }
        guard let message = message else  { return }
        if message.count == 0 { return }
        RoomManager.shared.messageService.sendTextMessage(message) { result in
            switch result {
            case .success(()):
                let model = MessageModelBuilder.buildModel(userID: self.localUserID, message: message)
                self.messageList.append(model)
                self.reloadMessageData()
            case .failure(let error):
                let message = String(format: ZGLocalizedString("toast_send_message_error"), error.code)
                HUDHelper.showMessage(message: message)
            }
        }
    }
}

extension LiveAudioRoomViewController : LiveAudioGiftViewDelegate {
    func sendGift(giftModel: GiftModel, targetUserList: [String]) {
        RoomManager.shared.giftService.sendGift(giftModel.giftID, to: targetUserList) { result in
            switch result {
            case .success(()):
                self.receiveGift(giftModel.giftID, from: self.localUserID, to: targetUserList)
            case .failure(let error):
                let message = String(format: ZGLocalizedString("toast_send_gift_error"), error.code)
                HUDHelper.showMessage(message: message)
            }
        }
    }
}

extension LiveAudioRoomViewController : SeatCollectionViewDelegate {
    func seatCollectionViewDidSelectedItem(itemIndex: Int) {
        inputTextView.endEditing(true)
        speakerSeatButtonClickedAssistant(seatIndex: itemIndex)
    }
    
    func speakerSeatButtonClickedAssistant(seatIndex: Int) -> Void {
        let seatModel:SpeakerSeatModel = RoomManager.shared.speakerService.seatList[seatIndex]
        switch seatModel.status {
        case .untaken :
            if RoomManager.shared.speakerService.localSpeakerSeat?.status == .occupied && RoomManager.shared.speakerService.localSpeakerSeat?.index != seatModel.index && !localUserIsHost() {
                takeSeat(index: seatIndex, isSwitch: true)
            } else if localUserIsHost() && seatModel.status == .untaken {
                lockSeat(index: seatIndex, isLock: true)
            } else if seatModel.status == .untaken {
                takeSeat(index: seatIndex, isSwitch: false)
            }
        case .occupied:
            if seatModel.userID != RoomManager.shared.roomService.info.hostID && localUserIsHost() {
                kickoutUser(seatModel: seatModel)
            } else if !localUserIsHost() && seatModel.userID == localUserID {
                leaveSeat(index: seatIndex)
            } else if !localUserIsHost() && seatModel.userID != localUserID {
                HUDHelper.showMessage(message: ZGLocalizedString("the_wheat_position_has_been_locked"))
            }
        case .closed:
            if localUserIsHost() {
                lockSeat(index: seatIndex, isLock: false)
            } else {
                HUDHelper.showMessage(message: ZGLocalizedString("the_wheat_position_has_been_locked"))
            }
        }
    }
    
    func takeSeat(index: Int, isSwitch: Bool) -> Void {

        let popView:MaskPopView = MaskPopView.loadFromNib()
        popView.type = .take
        popView.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        popView.block = {
            
            if !self.currentSeatIsFree(index: index) {return}
            
            if isSwitch {
                RoomManager.shared.speakerService.switchSeat(to: index, callback: nil)
            } else {
                RoomManager.shared.speakerService.takeSeat(index) { Result in
                    switch Result {
                    case .success:
                        self.micAuthorizationTimer.setEventHandler {
                            self.onMicAuthorizationTimerTriggered()
                        }
                        self.micAuthorizationTimer.start()
                        break
                    case .failure(let error):
                        let message:String = String(format: ZGLocalizedString("toast_take_speaker_seat_fail"), "\(error.code)")
                        HUDHelper.showMessage(message: message)
                    }
                }
            }
        }
        self.view.addSubview(popView)
    }
    
    func currentSeatIsFree(index: Int) -> Bool {
        var isFree: Bool = false
        let seatModel:SpeakerSeatModel = RoomManager.shared.speakerService.seatList[index]
        if seatModel.status == .untaken {
            isFree = true
        }
        return isFree
    }
    
    func lockSeat(index: Int, isLock: Bool) -> Void {
        let popView:MaskPopView = MaskPopView.loadFromNib()
        popView.type = isLock ? .lock:.unLock
        popView.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        popView.block = {
            RoomManager.shared.speakerService.closeSeat(isLock, index) { Result in
                switch Result {
                case .success:
                    break
                case .failure(let error):
                    var message: String
                    if case .setSeatInfoFailed = error {
                        message = String(format: ZGLocalizedString("toast_lock_seat_already_take_seat"), "\(error.code)")
                    } else {
                    message =  isLock ? String(format: ZGLocalizedString("toast_lock_seat_fail"), "\(error.code)") : String(format: ZGLocalizedString("toast_unlock_seat_fail"), "\(error.code)")
                    }
                    HUDHelper.showMessage(message: message)
                }
            }
        }
        self.view.addSubview(popView)
    }
    
    func leaveSeat(index: Int) -> Void {
        let popView:MaskPopView = MaskPopView.loadFromNib()
        popView.type = .leave
        popView.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        popView.block = {
            let seatModel:SpeakerSeatModel = RoomManager.shared.speakerService.seatList[index]
            self.sureAlter(seatModel: seatModel, title: ZGLocalizedString("room_page_leave_speaker_seat"), message: ZGLocalizedString("dialog_sure_to_leave_seat"), isHost: false)
        }
        self.view.addSubview(popView)
    }
    
    func kickoutUser(seatModel: SpeakerSeatModel) -> Void {
        let popView:MaskPopView = MaskPopView.loadFromNib()
        popView.type = .leave
        popView.frame = CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        popView.block = {
            let userName:String = RoomManager.shared.userService.userList.getObj(seatModel.userID ?? "")?.userName ?? ""
            let message:String = String(format: ZGLocalizedString("dialog_warning_leave_seat_message"), userName)
            self.sureAlter(seatModel: seatModel, title: ZGLocalizedString("room_page_leave_speaker_seat"), message: message, isHost: true)
        }
        self.view.addSubview(popView)
    }
    
    func sureAlter(seatModel: SpeakerSeatModel, title: String, message: String, isHost: Bool) -> Void {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: ZGLocalizedString("dialog_cancel"), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: ZGLocalizedString("dialog_confirm"), style: .default) { action in
            if isHost {
                if seatModel.status != .occupied || !self.localUserIsHost() || seatModel.userID == RoomManager.shared.userService.localInfo?.userID {
                    return
                }
                
                RoomManager.shared.speakerService.removeUserFromSeat(seatModel.index) { Result in
                    switch Result {
                    case .success:
                        if !RoomManager.shared.roomService.info.isSeatClosed {
                            RoomManager.shared.speakerService.closeSeat(true, seatModel.index, callback: nil)
                        }
                    case .failure(let error):
                        let userName:String = RoomManager.shared.userService.userList.getObj(seatModel.userID ?? "")?.userName ?? ""
                        let message:String = String(format: ZGLocalizedString("toast_kickout_leave_seat_error"), userName, error.code)
                        HUDHelper.showMessage(message: message)
                    }
                }
                
            } else {
                RoomManager.shared.speakerService.leaveSeat { Result in
                    switch Result {
                    case .success:
                        self.micButton.isSelected = false
                    case .failure(let error):
                        let message:String = String(format: ZGLocalizedString("toast_leave_seat_fail"), "\(error.code)")
                        HUDHelper.showMessage(message: message)
                    }
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension LiveAudioRoomViewController : RoomServiceDelegate {
    //MARK: -RoomServiceDelegate
    func receiveRoomInfoUpdate(_ info: RoomInfo?) {
        guard let info = info else {
            HUDHelper.showMessage(message: ZGLocalizedString("toast_room_has_destroyed"))
            self.leaveChatRoom()
            return
        }
        if localUserIsHost() {
            RoomManager.shared.speakerService.takeSeat(0, callback: nil)
        }
        roomTitleLabel.text = info.roomName
        roomIdLabel.text = String(format: "ID: %@", info.roomID ?? "")
        
        settingsView.settingTableView?.reloadData()
        
        if RoomManager.shared.roomService.info.isTextMessageDisabled && !localUserIsHost() {
            sendMessageButton .setImage(UIImage.init(named: "message_lock_icon"), for: .normal)
        } else {
            sendMessageButton .setImage(UIImage.init(named: "message_icon"), for: .normal)
        }
    }
}

extension LiveAudioRoomViewController : UserServiceDelegate {
    //MARK: -UserServiceDelegate
    func connectionStateChanged(_ state: ZIMConnectionState, _ event: ZIMConnectionEvent) {
        if state == .disconnected {
            HUDHelper.hideNetworkLoading()
            if event == .loginTimeout {
                showNetworkAlert()
            } else {
                // disconnect of room end
                var message = ZGLocalizedString("toast_disconnect_tips")
                if event == .success {
                    message = ZGLocalizedString("toast_room_has_destroyed")
                    HUDHelper.showMessage(message: message)
                    self.leaveChatRoom()
                    return
                }
                else if event == .kickedOut {
                    message = ZGLocalizedString("toast_kickout_error")
                }
                HUDHelper.showMessage(message: message)
                logout()
            }
        } else if state == .reconnecting {
            HUDHelper.showNetworkLoading(ZGLocalizedString("network_reconnect"))
        } else if state == .connected {
            HUDHelper.hideNetworkLoading()
        }
                
        func showNetworkAlert() {
            let title = ZGLocalizedString("network_connect_failed_title")
            let message = ZGLocalizedString("network_connect_failed")
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: ZGLocalizedString("dialog_confirm"), style: .default) { action in
                self.logout()
            }
            alert.addAction(confirmAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    func roomUserJoin(_ users: [UserInfo]) {
        
        var tempList: [MessageModel] = []
        for user in users {
            if user.userID == localUserID {
                tempList.removeAll()
                break
            }
            let model: MessageModel = MessageModelBuilder.buildJoinMessageModel(user: user)
            tempList.append(model)
        }
        messageList.append(contentsOf: tempList)
        
        reloadMessageData()
        memberVC.updateMemberListData()
        updateSpeakerSeatUI()
    }
    
    func roomUserLeave(_ users: [UserInfo]) {
        
        for user in users {
            if user.userID == localUserID { continue }
            let model: MessageModel = MessageModelBuilder.buildLeftMessageModel(user: user)
            messageList.append(model)
        }
        
        reloadMessageData()
        memberVC.updateMemberListData()
    }
    
    // reveive invitation for take a seat
    func receiveTakeSeatInvitation() {
        let title = ZGLocalizedString("dialog_invition_title")
        let message = ZGLocalizedString("dialog_invition_descrip")
        inviteAlter = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: ZGLocalizedString("dialog_refuse"), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: ZGLocalizedString("dialog_accept"), style: .default) { action in
            
            guard let model = self.selectMinimumViableSeat() else {
                HUDHelper.showMessage(message: ZGLocalizedString("room_page_no_more_seat_available"))
                return
            }
            
            if self.currentUserInfo?.role == .listener {
                RoomManager.shared.speakerService.takeSeat(model.index) { result in
                    switch result {
                    case .success:
                        self.micAuthorizationTimer.setEventHandler {
                            self.onMicAuthorizationTimerTriggered()
                        }
                        self.micAuthorizationTimer.start()
                    case .failure(let error):
                        let message = String(format: ZGLocalizedString("toast_to_be_a_speaker_seat_fail"), error.code)
                        HUDHelper.showMessage(message: message)
                    }
                }
            }
        }
        
        if let inviteAlter = inviteAlter {
            inviteAlter.addAction(cancelAction)
            inviteAlter.addAction(okAction)
            self.present(inviteAlter, animated: true, completion: nil)
        }
    }
}

extension LiveAudioRoomViewController : SpeakerSeatServiceDelegate {
    //MARK: -SpeakerSeatServiceDelegate
    func speakerSeatUpdate(_ models: [SpeakerSeatModel]) {
        updateCurrentUserMicStatus()
        updateSpeakerSeatUI()
        memberVC.updateMemberListData()
    }
    
}

extension LiveAudioRoomViewController : MessageServiceDelegate {
    func receiveTextMessage(_ message: TextMessage) {
        let model = MessageModelBuilder.buildModel(userID: message.userID, message: message.message)
        messageList.append(model)
        reloadMessageData()
    }
}

extension LiveAudioRoomViewController : GiftServiceDelegate {
    func receiveGift(_ giftID: String, from userID: String, to userList: [String]) {
        
        guard let gift = GiftManager.shared.getGiftModel(giftID) else { return }
        
        guard let fromUser = RoomManager.shared.userService.userList.getObj(userID) else {
            return
        }
        
        let toUsers: [UserInfo] = userList.compactMap { RoomManager.shared.userService.userList.getObj($0) }
        
        if toUsers.count == 0 { return }
        
        giftTipView.sendGift(gift, fromUser: fromUser, toUsers: toUsers)
    }
}
