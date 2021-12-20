//
//  LiveAudioSettingView.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/17.
//

import UIKit

class LiveAudioSettingView: UIView, UITableViewDelegate, UITableViewDataSource,SettingTableViewCellDelegate {
    
    var dataSource:Array<NSDictionary>?{
        get {
            return [["title": ZGLocalizedString("room_page_set_take_seat")],["title":ZGLocalizedString("room_page_set_silence")]]
        }
    }
    var settingTableView:UITableView?
    var grayView:UIView?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configUI() -> Void {
        self.backgroundColor = UIColor.clear
        
        let whiteView:UIView = UIView.init(frame: CGRect.init(x: 0, y: self.frame.size.height - 400, width: self.bounds.size.width, height: 400))
        whiteView.backgroundColor = UIColor.white
        
        let maskPath = UIBezierPath.init(roundedRect: CGRect.init(x: 0, y: 0, width: whiteView.bounds.size.width, height: whiteView.bounds.size.height), byRoundingCorners: [.topLeft,.topRight], cornerRadii: CGSize.init(width: 12, height: 12))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = whiteView.bounds
        maskLayer.path = maskPath.cgPath
        whiteView.layer.mask = maskLayer
        
        let width = self.frame.size.width
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 10, width: width, height: 36))
        let titleLabel = UILabel.init(frame: CGRect.init(x: width * 0.5 - 50, y: 0, width: 100, height: 36))
        titleLabel.text = ZGLocalizedString("setting_page_settings")
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleLabel.textColor = UIColor.init(red: 27/255.0, green: 27/255.0, blue: 27/255.0, alpha: 1.0)
        headerView.addSubview(titleLabel)
        
        
        settingTableView = UITableView.init(frame: CGRect.init(x: 0, y: headerView.frame.maxY + 10, width: whiteView.bounds.size.width, height: whiteView.bounds.size.height - 50), style: .plain)
        settingTableView?.delegate = self
        settingTableView?.dataSource = self
        settingTableView?.separatorStyle = .none
        settingTableView?.register(UINib.init(nibName: "SettingTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingTableViewCell")
        
        let maskView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height - 390))
        maskView.backgroundColor = UIColor.init(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.3)
        
        whiteView.addSubview(headerView)
        whiteView.addSubview(settingTableView ?? UITableView())
        self.addSubview(maskView)
        self.addSubview(whiteView)
    }
    
    //MARK: -UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
        cell.delegate = self as SettingTableViewCellDelegate
        
        let statusArray:Array = [RoomManager.shared.roomService.info.isSeatClosed,RoomManager.shared.roomService.info.isTextMessageDisabled]
        if indexPath.row < dataSource?.count ?? 0 {
            let statusDic:NSDictionary = (dataSource?[indexPath.row] ?? [:]) as NSDictionary
            let title:String = statusDic["title"] as! String
            let status:Bool = (statusArray[indexPath.row] ?? false) as Bool
            cell.updateCellWithTitle(title: title, status: status)
        }
        return cell
    }
    
    //MARK: - SettingTableViewCellDelegate
    func onSwitchButtonChange(_ status: Bool, cell: UITableViewCell) {
        let index:NSIndexPath = NSIndexPath.init(row: 0, section: 0)
        let firstCell:UITableViewCell = settingTableView?.cellForRow(at: index as IndexPath) ?? UITableViewCell()
        if firstCell == cell {
            
        } else {
            
        }
    }
    
}
