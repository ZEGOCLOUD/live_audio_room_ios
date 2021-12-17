//
//  CreateRoomViewController.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/14.
//

import UIKit
import ZIM


class CreateRoomViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var roomIDBackgroundView: UIView!
    @IBOutlet weak var roomIDTextField: UITextField!
    @IBOutlet weak var joinRoomButton: UIButton!
    @IBOutlet weak var createRoomButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var settingButton: UIBarButtonItem!
    
    var rtcToken : String = ""
    var myRoomID : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        RoomManager.shared.roomService.delegate = self
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
    
    @IBAction func chatRoomIDTextFieldChanged(_ sender: UITextField) {
        myRoomID = sender.text!
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
    
    func createRoomWithRoomID(roomID:String,roomName:String) -> Void {
        joinToChatRoom()
        return
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
        
        //TODO: - need add logic
        rtcToken = ""
        
        HUDHelper.showNetworkLoading()
        RoomManager.shared.roomService .createRoom(roomID, roomName, rtcToken) { result in
            switch result {
            case .success:
                self.joinToChatRoom()
            case .failure(let error):
                HUDHelper.showMessage(message: ZGLocalizedString("toast_create_room_fail") + "\(error.code)")
//                switch error {
//                case .other
//                }
//                if code == 1001 {
//                    HUDHelper.showMessage(message: ZGLocalizedString("toast_create_room_success"))
//                } else {
//
//                }
//                break
            }
        }
        
    }
    
    //MARK: - action
    @objc func joinRoomIdTextFieldDidChange(textField:UITextField) -> Void {
        let text:String = textField.text! as String
        if text.count > 20 {
            let startIndex = text.index(text.startIndex, offsetBy: 0)
            let index = text.index(text.startIndex, offsetBy: 20)
            textField.text = String(text[startIndex...index])
        }
    }
    
    @objc func createRoomIdTextFieldDidChange(textField:UITextField) -> Void {
        let text:String = textField.text! as String
        if text.count > 20 {
            let startIndex = text.index(text.startIndex, offsetBy: 0)
            let index = text.index(text.startIndex, offsetBy: 20)
            textField.text = String(text[startIndex...index])
        }
    }
    
    @objc func createRoomNameTextFieldDidChange(textField:UITextField) -> Void {
        let text:String = textField.text! as String
        if text.count > 32 {
            let startIndex = text.index(text.startIndex, offsetBy: 0)
            let index = text.index(text.startIndex, offsetBy: 32)
            textField.text = String(text[startIndex...index])
        }
    }
    
    //MARK: - Jump
    func joinToChatRoom() -> Void {
        let vc = UIStoryboard(name: "LiveAudioRoom", bundle: nil).instantiateViewController(withIdentifier: "LiveAudioRoomViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func logout() -> Void {
        RoomManager.shared.userService.logout()
        RoomManager.shared.uninit()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        getKeyWindow().rootViewController = vc
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        roomIDBackgroundView.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 85 / 255.0, blue: 255 / 255.0, alpha: 1.0).cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        roomIDBackgroundView.layer.borderColor = UIColor.init(red: 240 / 255.0, green: 240 / 255.0, blue: 240 / 255.0, alpha: 1.0).cgColor
    }
}

extension CreateRoomViewController : RoomServiceDelegate, UserServiceDelegate {
    //MARK: - RoomServiceDelegate
    func receiveRoomInfoUpdate(_ info: RoomInfo?) {
        
    }
    
    //MARK: - UserServiceDelegate
    func connectionStateChanged(_ state: ZIMConnectionState, _ event: ZIMConnectionEvent) {
        if (state == .disconnected) {
            let message:String = event == .kickedOut ? ZGLocalizedString("toast_kickout_error") : ZGLocalizedString("toast_disconnect_tips")
            HUDHelper.showMessage(message: message)
            logout()
        }
    }
}
