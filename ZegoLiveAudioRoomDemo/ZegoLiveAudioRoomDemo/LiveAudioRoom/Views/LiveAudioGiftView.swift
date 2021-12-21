//
//  LiveAudioGiftView.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/17.
//

import UIKit

protocol LiveAudioGiftViewDelegate: AnyObject {
    func sendGift(giftModel: GiftModel, targetUserList: [String]);
}

class LiveAudioGiftView: UIView, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    //MARK: -UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seatUserList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let model:GiftMemberModel = self.seatUserList?[indexPath.row] ?? GiftMemberModel();
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
            cell?.selectionStyle = .none
            cell?.contentView.backgroundColor = UIColor.init(red: 247/255.0, green: 247/255.0, blue: 248/255.0, alpha: 1.0)
            let lineView:UIView = UIView.init(frame: CGRect.init(x: 16, y: 41.5, width: messageTableView?.bounds.size.width ?? 0 - 32, height: 0.5))
            lineView.backgroundColor = UIColor.init(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1.0)
            cell?.contentView.addSubview(lineView)
        }
        if model.userID != nil {
            cell?.textLabel?.text = model.userName;
        } else {
            cell?.textLabel?.text = ZGLocalizedString("room_page_select_all_speakers");
        }
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model:GiftMemberModel = seatUserList?[indexPath.row] ?? GiftMemberModel()
        changeSelectedStatus(index: indexPath.row)
        if model.userID == nil {
            messageLabel?.text = ZGLocalizedString("room_page_select_all_speakers")
        } else {
            messageLabel?.text = model.userName
        }
        messageTableView?.isHidden = true
        arrowButton?.transform = CGAffineTransform.init(rotationAngle: 0)
    }
    
    
    //MARK: -UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return giftArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:GiftCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "giftCollectionViewCell", for: indexPath) as! GiftCollectionViewCell
        cell.model = giftArray[indexPath.item]
        return cell
    }
    
    //MARK: -UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 74, height: 74)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 18, bottom: 0, right: 18)
    }
    
    weak var delegate: LiveAudioGiftViewDelegate?
    
    var titleLabel: UILabel?
    var sendButton: UIButton?
    var giftCollectionView: UICollectionView?
    
    var giftArray: Array<GiftModel> {
        get {
            GiftManager.shared.giftModels
        }
    }
    var seatUserList: Array<GiftMemberModel>? {
        get {
            return configSeatUserListData()
        }
    }
    
    var targetUserList: Array<String> {
        get {
            let list: [String] = seatUserList?.filter({ $0.isSelected }).compactMap({ $0.userID }) ?? []
            return list
        }
    }
    var sendGift: GiftModel?
    var messageLabel: UILabel?
    var arrowButton: UIButton?
    var messageTableView: UITableView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sendGift = giftArray.first
        configUI()
    }
    
    func configSeatUserListData() -> Array<GiftMemberModel> {
        var array: Array<GiftMemberModel> = []
        array.append(GiftMemberModel())
        for seat in RoomManager.shared.speakerService.seatList {
            if seat.status != .occupied {
                continue
            }
            if seat.userID == RoomManager.shared.userService.localInfo?.userID {
                continue
            }
            let model:GiftMemberModel = GiftMemberModel()
            model.userID = seat.userID
            model.headImageName = "touxiang1"
            model.userName = RoomManager.shared.userService.userList.getObj(seat.userID ?? "")?.userName
            array.append(model)
        }
        return array
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configUI() -> Void {
        self.backgroundColor = UIColor.clear
        
        let whiteView:UIView = UIView.init(frame: CGRect.init(x: 0, y: self.frame.size.height - 400, width: self.bounds.size.width, height: 400))
        whiteView.backgroundColor = UIColor.white
        
        let maskPath:UIBezierPath = UIBezierPath.init(roundedRect: CGRect.init(x: 0, y: 0, width: whiteView.bounds.size.width, height: whiteView.bounds.size.height), byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize.init(width: 12, height: 12))
        let maskLayer:CAShapeLayer = CAShapeLayer()
        maskLayer.frame = whiteView.bounds
        maskLayer.path = maskPath.cgPath
        whiteView.layer.mask = maskLayer
        
        let width = self.frame.size.width
        
        titleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 10, width: whiteView.bounds.size.width, height: 36))
        titleLabel?.text = ZGLocalizedString("room_page_gift")
        titleLabel?.textColor = UIColor.init(red: 27/255.0, green: 27/255.0, blue: 27/255.0, alpha: 1.0)
        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleLabel?.textAlignment = .center
        whiteView.addSubview(titleLabel!)
        
        sendButton = UIButton.init(frame: CGRect.init(x: width - 112, y: 349, width: 94, height: 40))
        sendButton?.layer.masksToBounds = true
        sendButton?.layer.cornerRadius = 12.0
        sendButton?.backgroundColor = UIColor.init(red: 0/255.0, green: 85/255.0, blue: 255/255.0, alpha: 0.3)
        sendButton?.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        sendButton?.setTitle(ZGLocalizedString("room_page_send_gift"), for: .normal)
        sendButton?.addTarget(self, action: #selector(pressSendButton), for: .touchUpInside)
        whiteView.addSubview(sendButton!)
        
        let messageView:UIView = UIView.init(frame: CGRect.init(x: 18, y: 349, width: whiteView.bounds.size.width - 18 - 11 - 112, height: 40))
        messageView.layer.masksToBounds = true
        messageView.layer.cornerRadius = 12.0
        messageView.backgroundColor = UIColor.init(red: 247/255.0, green: 247/255.0, blue: 248/255.0, alpha: 1.0)
        whiteView.addSubview(messageView)
        
        arrowButton = UIButton.init(type: .custom)
        arrowButton?.frame = CGRect.init(x: messageView.bounds.size.width - 12 - 16, y: 12, width: 16, height: 16)
        arrowButton?.setImage(UIImage.init(named: "pull_arrow"), for: .normal)
        arrowButton?.addTarget(self, action: #selector(arrowClick), for: .touchUpInside)
        messageView.addSubview(arrowButton!)
        
        messageLabel = UILabel.init(frame: CGRect.init(x: 15, y: 11, width: messageView.bounds.size.width - 15 - 12 - 16 - 30, height: 15))
        messageLabel?.isUserInteractionEnabled = true
        messageLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        messageView.addSubview(messageLabel!)
        
        let messageLabelTap:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(messageLabelTapClick))
        messageLabel?.addGestureRecognizer(messageLabelTap)
        setMessageLabelNomalTitle()
        
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        giftCollectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: titleLabel?.frame.maxY ?? 0 + 10, width: width, height: 74), collectionViewLayout: layout)
        giftCollectionView?.backgroundColor = UIColor.white
        let nib = UINib(nibName: "GiftCollectionViewCell", bundle: nil)
        giftCollectionView?.register(nib, forCellWithReuseIdentifier: "giftCollectionViewCell")
        giftCollectionView?.delegate = self
        giftCollectionView?.dataSource = self
        whiteView.addSubview(giftCollectionView!)
        
        messageTableView = UITableView.init(frame: CGRect.init(x: 18, y: giftCollectionView?.frame.maxY ?? 0 + 9, width: width - 18 - 123, height: 400 - (giftCollectionView?.frame.maxY ?? 0) - 9 - 61), style: .plain)
        messageTableView?.delegate = self as UITableViewDelegate
        messageTableView?.dataSource = self as UITableViewDataSource
        messageTableView?.isHidden = true
        messageTableView?.separatorStyle = .none
        messageTableView?.layer.masksToBounds = true
        messageTableView?.layer.cornerRadius = 12.0
        messageTableView?.backgroundColor = UIColor.init(red: 247/255.0, green: 247/255.0, blue: 248/255.0, alpha: 1.0)
        whiteView.addSubview(messageTableView!)
        messageTableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let maskView:UIView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height - 390))
        maskView.backgroundColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.3)
        
        let tapClick:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(tapClick))
        maskView.addGestureRecognizer(tapClick)
        
        self.addSubview(maskView)
        self.addSubview(whiteView)
    }
    
    override var isHidden: Bool {
        didSet {
            if isHidden == false {
                reset()
            } else {
                messageTableView?.isHidden = true
                arrowButton?.transform = CGAffineTransform.init(rotationAngle: 0)
            }
        }
    }
    
    func reset() -> Void {
        messageTableView?.reloadData()
        setMessageLabelNomalTitle()
        sendButton?.backgroundColor = UIColor.init(red: 0/255.0, green: 85/255.0, blue: 255/255.0, alpha: 0.3)
    }
    
    func setMessageLabelNomalTitle() -> Void {
        if RoomManager.shared.userService.localInfo?.role == .host && seatUserList?.count == 1 {
            messageLabel?.text = ZGLocalizedString("room_page_gift_no_speaker")
        } else {
            messageLabel?.text = ZGLocalizedString("room_page_select_default")
        }
    }
    
    func changeSelectedStatus(index: Int) -> Void {
        if index == 0 {
            for i in 1...seatUserList!.count - 1  {
                let model:GiftMemberModel = seatUserList![i]
                model.isSelected = true
            }
        } else {
            for i in 1...seatUserList!.count - 1 {
                let model:GiftMemberModel = seatUserList![i]
                if i == index {
                    model.isSelected = true
                } else {
                    model.isSelected = false
                }
            }
        }
        if targetUserList.count > 0 {
            sendButton?.backgroundColor = UIColor.init(red: 0/255.0, green: 85/255.0, blue: 255/255.0, alpha: 1.0)
        } else {
            sendButton?.backgroundColor = UIColor.init(red:0/255.0, green:85/255.0, blue:255/255.0, alpha:0.3)
        }
    }
    
    
    @objc func tapClick() -> Void {
        self.isHidden = true
    }
    
    @objc func arrowClick(_ sender: UIButton) -> Void {
        if RoomManager.shared.userService.localInfo?.role == .host && RoomManager.shared.speakerService.seatList.count == 1 {
            messageLabel?.text = ZGLocalizedString("room_page_select_default");
        } else {
            messageLabel?.text = ZGLocalizedString("room_page_gift_no_speaker");
        }
    }
    
    @objc func messageLabelTapClick() -> Void {
        if messageTableView?.isHidden == false {
            messageTableView?.isHidden = true
            arrowButton?.transform = CGAffineTransform.init(rotationAngle: 0)
        } else {
            messageTableView?.isHidden = false
            arrowButton?.transform = CGAffineTransform.init(rotationAngle: Double.pi)
        }
    }
    
    @objc func pressSendButton() -> Void {
        if targetUserList.count > 0 {
            messageTableView?.isHidden = true
            arrowButton?.transform = CGAffineTransform.init(rotationAngle: 0)
            guard let gift = sendGift else { return }
            delegate?.sendGift(giftModel: gift, targetUserList: targetUserList)
        }
        self.isHidden = true
    }
    
}
