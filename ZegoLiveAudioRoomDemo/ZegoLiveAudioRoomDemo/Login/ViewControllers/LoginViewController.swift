//
//  ViewController.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/13.
//

import UIKit

class LoginViewController: UIViewController {

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
        myUserID = userId
        configUI()
    }
    
    func configUI() -> Void {
        
        print(NSHomeDirectory());
        
        loginButton.layer.cornerRadius = 12.0
        loginButton.clipsToBounds = true
        loginButton.setTitle(ZGLocalizedString("login_page_login"), for: UIControl.State.normal)
        
        userIDBackgroundView.layer.borderWidth = 1.5
        userIDBackgroundView.layer.borderColor = UIColor.init(red: 240 / 255.0, green: 240 / 255.0, blue: 240 / 255.0, alpha: 1.0).cgColor
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
            let index = userId.index(userId.startIndex, offsetBy: 19)
            userId = String(userId[startIndex...index])
            sender.text = userId;
        }
        myUserID = userId;
    }
    

    @IBAction func userNameTextFieldChanged(_ sender: UITextField) {
        var userName = sender.text! as String
        if userName.count > 16 {
            let startIndex = userName.index(userName.startIndex, offsetBy: 0)
            let index = userName.index(userName.startIndex, offsetBy: 15)
            userName = String(userName[startIndex...index])
            sender.text = userName
        }
        myUserName = subStringOfBytes(userName: userName)
    }
    
    func subStringOfBytes(userName: String) -> String {
        var count:Int = 0
        var newStr:String = ""
        for i in 0..<userName.count {
            let startIndex = userName.index(userName.startIndex, offsetBy: i)
            let index = userName.index(userName.startIndex, offsetBy: i)
            let aStr:String = String(userName[startIndex...index])
            count += aStr.lengthOfBytes(using: .utf8)
            if count <= 32 {
                newStr.append(aStr)
            } else {
                break
            }
        }
        return newStr
    }
    
    // create a user and generate zim token when login button click.
    // the user default user role is listener.
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        let userInfo = UserInfo(myUserID, myUserName, .listener)
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
                
        let token: String = AppToken.getZIMToken(withUserID: userInfo.userID) ?? ""
        HUDHelper.showNetworkLoading()
        RoomManager.shared.userService.login(userInfo, token) { result in
            HUDHelper.hideNetworkLoading()
            switch result {
            case .success:
                let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LiveAudioRoomNavigationController")
                getKeyWindow().rootViewController = navVC
                break
            case .failure(let error):
                let message = String(format: ZGLocalizedString("toast_login_fail"), error.code)
                HUDHelper.showMessage(message: message)
                break
            }
        }
    }
}

extension LoginViewController : UITextFieldDelegate {
    //MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        var backView = userIDBackgroundView
        if textField.isEqual(userNameTextField) {
            backView = userNameBackgroundView
        }
        backView?.layer.borderColor = UIColor.init(red: 0 / 255.0, green: 85 / 255.0, blue: 255 / 255.0, alpha: 1.0).cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        userIDBackgroundView.layer.borderColor = UIColor.init(red: 240 / 255.0, green: 240 / 255.0, blue: 240 / 255.0, alpha: 1.0).cgColor
        userNameBackgroundView.layer.borderColor = UIColor.init(red: 240 / 255.0, green: 240 / 255.0, blue: 240 / 255.0, alpha: 1.0).cgColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let proposeLength = (textField.text?.lengthOfBytes(using: .utf8))! - range.length + string.lengthOfBytes(using: .utf8)
        if proposeLength > 32 {
            return false
        }
        return true
    }

}

