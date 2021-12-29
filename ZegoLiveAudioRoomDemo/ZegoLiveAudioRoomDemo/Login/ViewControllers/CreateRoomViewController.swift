//
//  CreateRoomViewController.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/14.
//

import UIKit
import ZIM


class CreateRoomViewController: UIViewController {
    
    @IBOutlet weak var roomIDBackgroundView: UIView!
    @IBOutlet weak var roomIDTextField: UITextField!
    @IBOutlet weak var joinRoomButton: UIButton!
    @IBOutlet weak var createRoomButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var settingButton: UIBarButtonItem!
    
    var myRoomID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // register userservice delegate
        RoomManager.shared.userService.addUserServiceDelegate(self)
        
        configUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func configUI() -> Void {
        joinRoomButton.layer.cornerRadius = 12.0
        joinRoomButton.clipsToBounds = true
        joinRoomButton.setTitle(ZGLocalizedString("create_page_join_room"), for: UIControl.State.normal)
        
        createRoomButton.layer.cornerRadius = 12.0
        createRoomButton.clipsToBounds = true
        createRoomButton.setTitle(ZGLocalizedString("create_page_create_room"), for: UIControl.State.normal)
        
        roomIDBackgroundView.layer.borderWidth = 1.5
        roomIDBackgroundView.layer.borderColor = UIColor.init(red: 240 / 255.0, green: 240 / 255.0, blue: 240 / 255.0, alpha: 1.0).cgColor
        roomIDBackgroundView.layer.cornerRadius = 12.0
        roomIDBackgroundView.clipsToBounds = true
        
        orLabel.text = ZGLocalizedString("create_page_or")
        
        settingButton.title = ZGLocalizedString("setting_page_settings")
        
        roomIDTextField.placeholder = ZGLocalizedString("create_page_room_id")
        roomIDTextField.addTarget(self, action: #selector(joinRoomIdTextFieldDidChange), for: UIControl.Event.editingChanged)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        getKeyWindow().endEditing(true)
    }
    
    // MARK: - Action
    @IBAction func chatRoomIDTextFieldChanged(_ sender: UITextField) {
        myRoomID = sender.text!
    }
    
    @objc func joinRoomIdTextFieldDidChange(textField:UITextField) -> Void {
        let text:String = textField.text! as String
        if text.count > 20 {
            let startIndex = text.index(text.startIndex, offsetBy: 0)
            let index = text.index(text.startIndex, offsetBy: 19)
            textField.text = String(text[startIndex...index])
        }
    }
    
    @objc func createRoomIdTextFieldDidChange(textField:UITextField) -> Void {
        let text:String = textField.text! as String
        if text.count > 20 {
            let startIndex = text.index(text.startIndex, offsetBy: 0)
            let index = text.index(text.startIndex, offsetBy: 19)
            textField.text = String(text[startIndex...index])
        }
    }
    
    @objc func createRoomNameTextFieldDidChange(textField:UITextField) -> Void {
        let text:String = textField.text! as String
        if text.count > 16 {
            let startIndex = text.index(text.startIndex, offsetBy: 0)
            let index = text.index(text.startIndex, offsetBy: 15)
            textField.text = String(text[startIndex...index])
        }
    }
    
    @IBAction func createButtonClicked(_ sender: UIButton) {
        roomIDTextField.resignFirstResponder()
        
        let alter:UIAlertController = UIAlertController.init(title: ZGLocalizedString("create_page_create_room"), message: "", preferredStyle: UIAlertController.Style.alert)
        let cancelAction:UIAlertAction = UIAlertAction.init(title: ZGLocalizedString("create_page_cancel"), style: UIAlertAction.Style.cancel, handler: nil)
        let createAction:UIAlertAction = UIAlertAction.init(title: ZGLocalizedString("create_page_create"), style: UIAlertAction.Style.default) { action in
            let roomIdTextField = (alter.textFields?.first)!
            let roomNameTextField = (alter.textFields?.last)!
            self.createRoomWithRoomID(roomID: roomIdTextField.text! as String, roomName: roomNameTextField.text! as String)
        }
        alter.addTextField { textField in
            textField.placeholder = ZGLocalizedString("create_page_room_id")
            textField.font = UIFont.systemFont(ofSize: 14)
            textField.keyboardType = .asciiCapable
            textField.addTarget(self, action: #selector(self.createRoomIdTextFieldDidChange), for: UIControl.Event.editingChanged)
        }
        alter.addTextField { textField in
            textField.placeholder = ZGLocalizedString("create_page_room_name")
            textField.font = UIFont.systemFont(ofSize: 14)
            textField.addTarget(self, action: #selector(self.createRoomNameTextFieldDidChange), for: UIControl.Event.editingChanged)
        }
        alter.addAction(cancelAction)
        alter.addAction(createAction)
        self.present(alter, animated: true, completion: nil)
    }
    
    @IBAction func joinRoomButtonClick(_ sender: UIButton) {
        
        if myRoomID.count == 0 {
            HUDHelper.showMessage(message: ZGLocalizedString("toast_room_id_enter_error"))
            return
        }
        
        let rtcToken = AppToken.getRtcToken(withRoomID: myRoomID) ?? ""
        
        HUDHelper.showNetworkLoading()
        RoomManager.shared.roomService.joinRoom(myRoomID, rtcToken) { result in
            HUDHelper.hideNetworkLoading()
            switch result {
            case .success:
                self.joinToChatRoom()
            case .failure(let error):
                var message = String(format: ZGLocalizedString("toast_join_room_fail"), error.code)
                if case .roomNotFound = error {
                    message = ZGLocalizedString("toast_room_not_exist_fail")
                }
                HUDHelper.showMessage(message: message)
            }
        }
    }
    
    func createRoomWithRoomID(roomID: String, roomName: String) -> Void {
        var message:String = ""
        if roomID.count == 0 {
            message = ZGLocalizedString("toast_room_id_enter_error")
        } else if roomName.count == 0 {
            message = ZGLocalizedString("toast_room_name_error")
        }
        if message.count > 0 {
            HUDHelper .showMessage(message: message)
            return
        }
        
        let rtcToken: String = AppToken.getRtcToken(withRoomID: roomID) ?? ""
        
        HUDHelper.showNetworkLoading()
        RoomManager.shared.roomService.createRoom(roomID, roomName, rtcToken) { result in
            HUDHelper.hideNetworkLoading()
            switch result {
            case .success:
                self.joinToChatRoom()
            case .failure(let error):
                var message = String(format: ZGLocalizedString("toast_create_room_fail"), error.code)
                if case .roomExisted = error {
                    message =  ZGLocalizedString("toast_room_existed")
                }
                HUDHelper.showMessage(message: message)
            }
        }
        
    }
        
    //MARK: - Jump
    func joinToChatRoom() -> Void {
        let vc = UIStoryboard(name: "LiveAudioRoom", bundle: nil).instantiateViewController(withIdentifier: "LiveAudioRoomViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func logout() -> Void {
        RoomManager.shared.userService.logout()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        getKeyWindow().rootViewController = vc
    }
}

extension CreateRoomViewController : UITextFieldDelegate {
    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        roomIDBackgroundView.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 85 / 255.0, blue: 255 / 255.0, alpha: 1.0).cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        roomIDBackgroundView.layer.borderColor = UIColor.init(red: 240 / 255.0, green: 240 / 255.0, blue: 240 / 255.0, alpha: 1.0).cgColor
    }
}

extension CreateRoomViewController : UserServiceDelegate {
    //MARK: - UserServiceDelegate
    func connectionStateChanged(_ state: ZIMConnectionState, _ event: ZIMConnectionEvent) {
        // logout and show toast when there is only one child controller(CreateRoom)
        let count = self.navigationController?.children.count ?? 0
        if count > 1 { return }
        if (state == .disconnected) {
            let message:String = event == .kickedOut ? ZGLocalizedString("toast_kickout_error") : ZGLocalizedString("toast_disconnect_tips")
            HUDHelper.showMessage(message: message)
            logout()
        }
    }
}
