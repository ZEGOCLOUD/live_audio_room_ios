//
//  LiveAudioRoomViewController.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/16.
//

import UIKit
import ZIM

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
                                                             width:
                                                                self.view.bounds.size.width,
                                                             height: self.view.bounds.size.height))
        settingsView.isHidden = true
        return settingsView
    }()
    lazy var giftView: LiveAudioGiftView = {
        let giftView = LiveAudioGiftView(frame: CGRect(x: 0,
                                                       y: 0,
                                                       width:
                                                        self.view.frame.size.width,
                                                       height: self.view.frame.size.height))
        giftView.isHidden = true
        giftView.delegate = self
        return giftView
    }()
    
    var messageList: [MessageModel] = []
    var isMuteAllMessage: Bool = false
    var localUserID: String {
        get {
            assert(RoomManager.shared.userService.localInfo?.userID != nil, "user ID shouldn't be nil.")
            return RoomManager.shared.userService.localInfo?.userID ?? ""
        }
    }
    var currentUserInfo: UserInfo?
    var micAuthorizationTimer: ZegoTimer = ZegoTimer(500)
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardDidShow(node:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyBoardDidHide(node:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        RegisterServiceCallback()
        
        if localUserIsHost() {
            RoomManager.shared.speakerService.takeSeat(0, callback:nil)
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
        roomIdLabel.text = RoomManager.shared.roomService.info.roomID
        
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
            self.inputView?.frame = CGRect(x: 0,
                                           y: UIScreen.main.bounds.size.height - keyboardRect.size.height - 55,
                                           width: self.view.bounds.size.width,
                                           height: 55)
        }
    }
    
    @objc func keyBoardDidHide(node : Notification){
        UIView.animate(withDuration: 0.25) {
            self.inputView?.frame = CGRect(x: 0,
                                           y: UIScreen.main.bounds.size.height,
                                           width: self.view.bounds.size.width,
                                           height: 55)
        }
    }
    
    //MARK: - Action
    @IBAction func giftButtonClick(_ sender: UIButton) {
        
    }
    
    @IBAction func settingButtonClick(_ sender: UIButton) {
        
    }
    
    @IBAction func memberButtonClick(_ sender: UIButton) {
        
    }
    
    @IBAction func micButtonClick(_ sender: UIButton) {
        
    }
    
    
    @IBAction func messageButtonClick(_ sender: UIButton) {
        
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
        micButton.select(!on)
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
    func sendGift(giftModel: GiftModel, targetUserList: Array<GiftMemberModel>) {
        
    }
}

extension LiveAudioRoomViewController : SeatCollectionViewDelegate {
    func seatCollectionViewDidSelectedItem(itemIndex: Int) {
        
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
            RoomManager.shared.speakerService.takeSeat(0) { result in
                self.micAuthorizationTimer.setEventHandler {
                    self.onMicAuthorizationTimerTriggered()
                }
            }
        }
        roomTitleLabel.text = info.roomName
        roomIdLabel.text = String(format: "ID: %@", info.roomID ?? "")
    }
}

extension LiveAudioRoomViewController : UserServiceDelegate {
    //MARK: -UserServiceDelegate
    func connectionStateChanged(_ state: ZIMConnectionState, _ event: ZIMConnectionEvent) {
        if (state == .disconnected) {
            let message:String = event == .kickedOut ? ZGLocalizedString("toast_kickout_error") : ZGLocalizedString("toast_disconnect_tips")
            HUDHelper.showMessage(message: message)
            logout()
        }
    }

    func roomUserJoin(_ users: [UserInfo]) {
        
        for user in users {
            if user.userID == localUserID { continue }
            let model: MessageModel = MessageModelBuilder.buildJoinMessageModel(user: user)
            messageList.append(model)
        }
        
        reloadMessageData()
        //TODO: need reload memebr list
        
    }
    
    func roomUserLeave(_ users: [UserInfo]) {
        
        for user in users {
            if user.userID == localUserID { continue }
            let model: MessageModel = MessageModelBuilder.buildLeftMessageModel(user: user)
            messageList.append(model)
        }
        
        reloadMessageData()
        //TODO: need reload memebr list
    }
    
    // reveive invitation for take a seat
    func receiveTakeSeatInvitation() {
        let title = ZGLocalizedString("dialog_invition_title")
        let message = ZGLocalizedString("dialog_invition_descrip")
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: ZGLocalizedString("dialog_refuse"), style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: ZGLocalizedString("dialog_accept"), style: .default) { action in
            
            guard let model = self.selectMinimumViableSeat() else {
                HUDHelper.showMessage(message: ZGLocalizedString("room_page_no_more_seat_available"))
                return
            }
            
            RoomManager.shared.speakerService.takeSeat(model.index) { result in
                guard let error = result.failure else { return }
                let message = String(format: ZGLocalizedString("toast_to_be_a_speaker_seat_fail"), error.code)
                HUDHelper.showMessage(message: message)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension LiveAudioRoomViewController : SpeakerSeatServiceDelegate {
    //MARK: -SpeakerSeatServiceDelegate
    func speakerSeatUpdate(_ models: [SpeakerSeatModel]) {
        updateCurrentUserMicStatus()
        updateSpeakerSeatUI()
        //TODO: need reload memebr list
        
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
        let model = GiftManager.shared.getGiftModel(giftID)
        //TODO: need update gift tips view
        
    }
}
