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
    @IBOutlet weak var loginButton: UINavigationItem!
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
        loginButton.titleView?.layer.cornerRadius = 12.0
        loginButton.titleView?.clipsToBounds = true
        
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
        let attributedText = NSAttributedString.init(string: ZGLocalizedString(key: ""), attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30.0),NSAttributedString.Key.paragraphStyle : paragraphStyle, NSAttributedString.Key.foregroundColor : UIColor.black])
        titleLabel.attributedText = attributedText
        
        let userIdPlaceHolder:NSAttributedString = NSAttributedString.init(string: ZGLocalizedString(key: ""), attributes: [NSAttributedString.Key.foregroundColor : UIColor.init(red: 152/255.0, green: 155/255.0, blue: 168/255.0, alpha: 1.0)])
        userIDTextField.attributedPlaceholder = userIdPlaceHolder
        
        let userNamePlaceHolder:NSAttributedString = NSAttributedString.init(string: ZGLocalizedString(key: ""), attributes: [NSAttributedString.Key.foregroundColor : UIColor.init(red: 152/255.0, green: 155/255.0, blue: 168/255.0, alpha: 1.0)])
        userNameTextField.attributedPlaceholder = userNamePlaceHolder
        
    }
    
    func getKeyWindow() -> UIWindow {
        var window:UIWindow = UIApplication.shared.keyWindow!
            if #available(iOS 13.0, *) {
                window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).last!
            }
        return window
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let window : UIWindow = getKeyWindow()
        window.endEditing(true)
    }
    
    @IBAction func userIDTextFieldChanged(_ sender: UITextField) {
        var userId : String = sender.text! as String
        if userId.count > 20 {
//            let beginIndex = userId.index(userId.startIndex, offsetBy: 0)
//            let endIndex = userId.index(userId.startIndex, offsetBy: 20)
            let index = userId.index(userId.startIndex, offsetBy: 20)
            userId = userId.substring(to: index)
            sender.text = userId;
        }
        myUserID = userId;
    }
    

    @IBAction func userNameTextFieldChanged(_ sender: UITextField) {
        var userName = sender.text! as String
        if userName.count > 32 {
            let index = userName.index(userName.startIndex, offsetBy: 32)
            userName = userName.substring(to: index)
            sender.text = userName
        }
        myUserName = userName
    }
    
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        //TODO: 需要补充实现逻辑
        let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LiveAudioRoomNavigationController")
        getKeyWindow().rootViewController = navVC
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

