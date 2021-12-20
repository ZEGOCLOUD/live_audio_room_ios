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
    
    @IBOutlet weak var messageView: LiveAudioMessageView!
    
    @IBOutlet weak var settingButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var memberButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var giftButtonTrail: NSLayoutConstraint!
    @IBOutlet weak var memberButtonTrail: NSLayoutConstraint!
    @IBOutlet weak var messageHeightConstraint: NSLayoutConstraint!
    
    lazy var inputTextView: InputTextView? = {
        let textView: InputTextView = UINib(nibName: "InputTextView", bundle: nil).instantiate(withOwner: self, options: nil).last as! InputTextView
        textView.frame = CGRect(x: 0, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: 55)
        textView.delegate = self
        return textView
    }()
    
    var messageList: [LiveAudioMessageModel] = []
    var isMuteAllMessage: Bool = false
    var localUserID: String?
    var currentUserInfo: UserInfo?
    var micAuthorizationTimer: DispatchSourceTimer?
    
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
            let model: LiveAudioMessageModel = LiveAudioMessageModelBuilder.buildJoinMessageModelWithUser(user: myself)
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
    }
    
    func configUI() -> Void {
        roomTitleLabel.text = RoomManager.shared.roomService.info.roomName
        roomIdLabel.text = RoomManager.shared.roomService.info.roomID
    }
    
    func reloadMessageData() -> Void {
        updateMessageHeightConstraint()
        messageView.reloadWithData(data: messageList)
        messageView.scrollToBottom()
    }
    
    func updateMessageHeightConstraint() -> Void {
        var height:CGFloat = 0
        for model:LiveAudioMessageModel in messageList {
            height += (model.messageHeight ?? 0) + 10*2 + 10
        }
        messageHeightConstraint.constant = height
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
}

extension LiveAudioRoomViewController : InputTextViewDelegate {
    //MARK: -InputTextViewDelegate
    func inputTextViewDidClickSend(_ message: String?) {
        
    }
}

extension LiveAudioRoomViewController : RoomServiceDelegate {
    //MARK: -RoomServiceDelegate
    func receiveRoomInfoUpdate(_ info: RoomInfo?) {
        
    }
}

extension LiveAudioRoomViewController : UserServiceDelegate {
    //MARK: -UserServiceDelegate
    func connectionStateChanged(_ state: ZIMConnectionState, _ event: ZIMConnectionEvent) {
        
    }

    func roomUserJoin(_ users: [UserInfo]) {
        
    }
    
    func roomUserLeave(_ users: [UserInfo]) {
        
    }
    
    func receiveTakeSeatInvitation() {
        
    }
}

extension LiveAudioRoomViewController : SpeakerSeatServiceDelegate {
    //MARK: -SpeakerSeatServiceDelegate
    func speakerSeatUpdate(_ models: [SpeakerSeatModel]) {
        
    }
}

