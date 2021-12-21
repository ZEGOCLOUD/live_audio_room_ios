//
//  InputTextView.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/16.
//

import UIKit

protocol InputTextViewDelegate: AnyObject {
    func inputTextViewDidClickSend(_ message: String?)
}

class InputTextView: UIView,UITextFieldDelegate {

    weak var delegate: InputTextViewDelegate?
    
    @IBOutlet weak var inputTextView: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func textViewBecomeFirstResponse() -> Void {
        inputTextView.becomeFirstResponder()
    }
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        var textStr : String = sender.text! as String
        let startIndex = textStr.index(textStr.startIndex, offsetBy: 0)
        if textStr.count > 100 {
            let index = textStr.index(textStr.startIndex, offsetBy: 100)
            textStr = String(textStr[startIndex...index])
        }
        sender.text = textStr
        
        if textStr.count > 0 {
            sendButton.backgroundColor = UIColor.init(red: 0/255.0, green: 85/255.0, blue: 255/255.0, alpha: 1.0)
        } else {
            sendButton.backgroundColor = UIColor.init(red: 0/255.0, green: 85/255.0, blue: 255/255.0, alpha: 0.3)
        }
        
    }
    
    @IBAction func sendButtonClick(_ sender: UIButton) {
        if (inputTextView.text?.count ?? 0) > 0 {
            if delegate != nil {
                delegate?.inputTextViewDidClickSend(inputTextView.text)
            }
            inputTextView.endEditing(true)
            inputTextView.text = ""
            sendButton.backgroundColor = UIColor.init(red: 0/255.0, green: 85/255.0, blue: 255/255.0, alpha: 0.3)
        }
    }

}
