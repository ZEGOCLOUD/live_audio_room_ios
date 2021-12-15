//
//  ViewController.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var userIDBackgroundView: UIView!
    @IBOutlet weak var userNameBackgroundView: UIView!
    @IBOutlet weak var userIDTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    var myUserID : String = ""
    var myUserName : String = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let a = arc4random_uniform(1000) + 1
        let userId:String = "Apple\(a)"
        userIDTextField.text = userId
        myUserID = userId;
        configUI()
    }
    
    func configUI() -> Void {
        loginButton.layer.cornerRadius = 12.0
        loginButton.clipsToBounds = true
        
        userIDBackgroundView.layer.borderWidth = 1.5
        userNameBackgroundView.layer.borderColor = UIColor.init(red: 240 / 255.0, green: 240 / 255.0, blue: 240 / 255.0, alpha: 1.0).cgColor
        userIDBackgroundView.layer.cornerRadius = 12.0
        userIDBackgroundView.clipsToBounds = true
        
        userNameBackgroundView.layer.borderWidth = 1.5
        userNameBackgroundView.layer.borderColor = UIColor.init(red: 240 / 255.0, green: 240 / 255.0, blue: 240 / 255.0, alpha: 1.0).cgColor
        userNameBackgroundView.layer.cornerRadius = 12.0
        userNameBackgroundView.clipsToBounds = true
        
        let paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.paragraphSpacing = 0
        paragraphStyle.minimumLineHeight = 42.0
        let attributedText = NSAttributedString.init(string: ZGLocalizedString("login_page_title"), attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30.0),NSAttributedString.Key.paragraphStyle : paragraphStyle, NSAttributedString.Key.foregroundColor : UIColor.black])
        titleLabel.attributedText = attributedText
        
        let userIdPlaceHolder:NSAttributedString = NSAttributedString.init(string: ZGLocalizedString("login_page_user_id"), attributes: [NSAttributedString.Key.foregroundColor : UIColor.init(red: 152/255.0, green: 155/255.0, blue: 168/255.0, alpha: 1.0)])
        userIDTextField.attributedPlaceholder = userIdPlaceHolder
        
        let userNamePlaceHolder:NSAttributedString = NSAttributedString.init(string: ZGLocalizedString("login_page_user_name"), attributes: [NSAttributedString.Key.foregroundColor : UIColor.init(red: 152/255.0, green: 155/255.0, blue: 168/255.0, alpha: 1.0)])
        userNameTextField.attributedPlaceholder = userNamePlaceHolder
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let window : UIWindow = getKeyWindow()
        window.endEditing(true)
    }
    
    @IBAction func userIDTextFieldChanged(_ sender: UITextField) {
        var userId : String = sender.text! as String
        if userId.count > 20 {
            let startIndex = userId.index(userId.startIndex, offsetBy: 0)
            let index = userId.index(userId.startIndex, offsetBy: 20)
            userId = String(userId[startIndex...index])
            sender.text = userId;
        }
        myUserID = userId;
    }
    

    @IBAction func userNameTextFieldChanged(_ sender: UITextField) {
        var userName = sender.text! as String
        if userName.count > 32 {
            let startIndex = userName.index(userName.startIndex, offsetBy: 0)
            let index = userName.index(userName.startIndex, offsetBy: 32)
            userName = String(userName[startIndex...index])
            sender.text = userName
        }
        myUserName = userName
    }
    
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        var userInfo = UserInfo.init(userID: myUserID, userName: myUserName, role: .listener)
        if userInfo.userName == nil || userInfo.userName?.count == 0 {
            userInfo.userName = userInfo.userID
        }
        
        var errMsg : String = ""
        if userInfo.userID == "" || userInfo.userID == nil {
            errMsg = ZGLocalizedString("toast_userid_login_fail")
        } else if (userInfo.userID?.isUserIdValidated() == false) {
            errMsg = ZGLocalizedString("toast_user_id_error")
        }
        
        if errMsg.count > 0 {
            HUDHelper.showMessage(message:errMsg)
            return
        }
        
        let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LiveAudioRoomNavigationController")
        getKeyWindow().rootViewController = navVC
        
        let token : String = ""
        RoomManager.shared.initWithAppID(appID: AppCenter.appID(), appSign: AppCenter.appSign()) { result in
            
        };
        RoomManager.shared.userService.login(userInfo, token) { result in
            switch result {
            case .success:
                let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LiveAudioRoomNavigationController")
                getKeyWindow().rootViewController = navVC
                break
            case .failure(let code):
                HUDHelper.showMessage(message: (ZGLocalizedString("toast_login_fail") + "\(code)"))
                break
            }
        }
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        var backView = userNameBackgroundView;
        if textField.isEqual(userNameTextField) {
            backView = userNameBackgroundView
        }
        backView?.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 85 / 255.0, blue: 255 / 255.0, alpha: 1.0).cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        userIDBackgroundView.layer.borderColor = UIColor.init(red: 240 / 255.0, green: 240 / 255.0, blue: 240 / 255.0, alpha: 1.0).cgColor
        userNameBackgroundView.layer.borderColor = UIColor.init(red: 240 / 255.0, green: 240 / 255.0, blue: 240 / 255.0, alpha: 1.0).cgColor
    }
}

