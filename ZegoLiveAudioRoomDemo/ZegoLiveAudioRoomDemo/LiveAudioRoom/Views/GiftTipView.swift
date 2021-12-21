//
//  GiftTipView.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by Kael Ding on 2021/12/20.
//

import UIKit

class GiftTipView: UIView {

    private var label: UILabel = UILabel()
    
    lazy private var backLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 0)
        layer.locations = [NSNumber(value: 0.5), NSNumber(value: 1.0)]
        let color1 = UIColor(red: 108/255.0, green: 0, blue: 255/255.0, alpha: 1.0)
        let color2 = UIColor(red: 165/255.0, green: 0, blue: 255/255.0, alpha: 1.0)
        layer.colors = [color1.cgColor, color2.cgColor]
        return layer
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label = subviews.first as! UILabel
        layer.cornerRadius = 5.0
        clipsToBounds = true
        
        layer.insertSublayer(backLayer, at: 0)
        isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backLayer.frame = bounds
    }
    
    // MARK: - Public
    func sendGift(_ gift: GiftModel, fromUser: UserInfo, toUsers: [UserInfo]) {
        
        let str: NSAttributedString = getAttributedStr(gift, fromUser: fromUser, toUsers: toUsers)
        label.attributedText = str
        
        let width = UIScreen.main.bounds.size.width - 89.0 - 16.0 - 10.0 * 2
        var size = str.boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)),
                                    options: .usesLineFragmentOrigin,
                                    context: nil).size
        
        // if lines > 2
        if size.height > 30 {
            size.height = 30.0
            size.width = width
        }
        
        // update label constraint
        labelConstraintWidth.constant = size.width + 1.0
        labelConstraintHeight.constant = size.height + 1.0
        
        isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.isHidden = true
        }
    }
    
    // MARK: - Private
    private func getAttributedStr(_ gift: GiftModel, fromUser: UserInfo, toUsers: [UserInfo]) -> NSAttributedString {
        
        let attributedStr = NSMutableAttributedString()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 0.0
        paragraphStyle.minimumLineHeight = 15.0
        
        let attributes: [NSAttributedString.Key : Any] = [.font : UIFont.systemFont(ofSize: 12),
                                                          .paragraphStyle : paragraphStyle,
                                                          .foregroundColor : UIColor.white]
        let nameStr: String = getToString(with: toUsers)
        
        let giftName = gift.name ?? ""
        let fromUserName = fromUser.userName ?? ""
        
        var allStr = String(format: ZGLocalizedString("room_page_received_gift_tips"), nameStr, giftName, fromUserName)
        if giftName.contains("爱心") {
            allStr = String(format: ZGLocalizedString("room_page_received_gift_tips"), nameStr, fromUserName, giftName)
        }
        
        let allAttributeStr: NSAttributedString = NSAttributedString(string: allStr, attributes: attributes)
        attributedStr.append(allAttributeStr)
        
        var range: Range<String.Index>? = allStr.range(of: "HEART")
        if allStr.contains("爱心") {
            range = allStr.range(of: "爱心")
        }
        
        if let range = range {
            let giftAttrites: [NSAttributedString.Key : Any] = [.font : UIFont.systemFont(ofSize: 12.0),
                                                                .paragraphStyle : paragraphStyle,
                                                                .foregroundColor : UIColor(red: 255/255.0,
                                                                                           green: 206/255.0,
                                                                                           blue: 0,
                                                                                           alpha: 1)]
            
            let nsrange = NSRange(range, in: allStr)
            attributedStr.setAttributes(giftAttrites, range: nsrange)
        }
                
        return attributedStr as NSAttributedString
    }
    
    private func getToString(with users: [UserInfo]) -> String {
        if users.count == 0 { return "" }
        
        let str: NSMutableString = NSMutableString()
        for user in users {
            let userName = user.userName ?? ""
            str.append("\(userName), ")
        }
        str.deleteCharacters(in: NSRange(location: str.length-2, length: 2))
        return String(str)
    }
    
    private lazy var labelConstraintWidth: NSLayoutConstraint = {
        var constraint: NSLayoutConstraint?
        
        for cons in label.constraints {
            if cons.identifier == "giftLabelConstraintWidth" {
                constraint = cons
                break
            }
        }
        guard let constraint = constraint else {
            assert(false, "gift label constraint can't be nil, please check.")
            return NSLayoutConstraint()
        }
        
        return constraint
    }()
    
    private lazy var labelConstraintHeight: NSLayoutConstraint = {
        var constraint: NSLayoutConstraint?
        
        for cons in label.constraints {
            if cons.identifier == "giftLabelConstraintHeight" {
                constraint = cons
                break
            }
        }
        guard let constraint = constraint else {
            assert(false, "gift label constraint can't be nil, please check.")
            return NSLayoutConstraint()
        }
        
        return constraint
    }()
}
