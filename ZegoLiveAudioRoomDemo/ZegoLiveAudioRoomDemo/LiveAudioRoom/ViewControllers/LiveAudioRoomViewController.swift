//
//  LiveAudioRoomViewController.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/16.
//

import UIKit
import ZIM

class LiveAudioRoomViewController: UIViewController, RoomServiceDelegate, UserServiceDelegate, SpeakerSeatServiceDelegate,InputTextViewDelegate {
    
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
    
    var _inputTextView:InputTextView?
    var inputTextView:InputTextView? {
        get {
            if _inputTextView == nil {
                _inputTextView = UINib.init(nibName: "InputTextView", bundle: nil).instantiate(withOwner: self, options: nil).last as? InputTextView
                _inputTextView?.frame = CGRect.init(x: 0, y: self.view.bounds.size.height, width: self.view.bounds.size.width, height: 55)
                _inputTextView?.delegate = self as InputTextViewDelegate
            }
            return _inputTextView
        }
    }
    
    var _messageList:Array<LiveAudioMessageModel>?
    var messageList:Array<LiveAudioMessageModel>? {
        get {
            if _messageList == nil {
                _messageList = Array()
            }
            return _messageList
        }
        set {
            _messageList = newValue
        }
    }
    var onseatUserList:Array<Any>?
    var isMuteAllMessage:Bool = false
    var localUserID:String?
    var currentUserInfo:UserInfo?
    var micAuthorizationTimer:DispatchSourceTimer?
    
    deinit {
        
    }
    
    func RegisterServiceCallback() -> Void {
        RoomManager.shared.roomService.delegate = self
        RoomManager.shared.userService.delegate = self
        RoomManager.shared.speakerService.delegate = self
    }
    
    //MARK: -SpeakerSeatServiceDelegate
    func speakerSeatUpdate(_ model: SpeakerSeatModel) {

    }
    
    //MARK: -UserServiceDelegate
    func userInfoUpdate(_ info: UserInfo?) {
        
    }

    func roomUserJoin(_ users: [UserInfo]) {
        
    }
    
    func roomUserLeave(_ users: [UserInfo]) {
        
    }
    
    //MARK: -RoomServiceDelegate
    func receiveRoomInfoUpdate(_ info: RoomInfo?) {
        
    }
    
    func connectionStateChanged(_ state: ZIMConnectionState, _ event: ZIMConnectionEvent) {
        
    }
    
    //MARK: -InputTextViewDelegate
    func inputTextViewDidClickSend(_ message: String?) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
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

        let myself:UserInfo? = RoomManager.shared.userService.localInfo ?? nil
        if myself != nil {
            let model:LiveAudioMessageModel = LiveAudioMessageModelBuilder.buildJoinMessageModelWithUser(user: myself!)
            messageList?.append(model)
            reloadMessageData()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        getKeyWindow().endEditing(true)
    }
    
    func reloadMessageData() -> Void {
        updateMessageHeightConstraint()
        messageView.reloadWithData(data: messageList ?? [])
        messageView.scrollToBottom()
    }
    
    func updateMessageHeightConstraint() -> Void {
        var height:CGFloat = 0
        for model:LiveAudioMessageModel in messageList! {
            height += (model.messageHeight ?? 0) + 10*2 + 10
        }
        messageHeightConstraint.constant = height
    }
    
    @objc func keyBoardDidShow(node : Notification){
        let keyboardRect:CGRect = (node.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let duration:Double = node.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            self.inputView?.frame = CGRect.init(x: 0, y: UIScreen.main.bounds.size.height - keyboardRect.size.height - 55, width: self.view.bounds.size.width, height: 55)
        }
    }
    
    @objc func keyBoardDidHide(node : Notification){
        UIView.animate(withDuration: 0.25) {
            self.inputView?.frame = CGRect.init(x: 0, y: UIScreen.main.bounds.size.height, width: self.view.bounds.size.width, height: 55)
        }
    }
    
    func localUserIsHost() -> Bool {
        return RoomManager.shared.userService.localInfo?.userID == RoomManager.shared.roomService.info?.hostID
    }
    
    func configUI() -> Void {
        roomTitleLabel.text = RoomManager.shared.roomService.info?.roomName
        roomIdLabel.text = RoomManager.shared.roomService.info?.roomID
        
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
