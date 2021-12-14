//
//  SettingViewController.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/14.
//

import UIKit
import ZegoExpressEngine
import ZIM

class SettingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var settingTableView: UITableView!
    
    var dataList : [[SettingCellModel]] {
        get {
            return [[configModel(type: .RTA),configModel(type: .ZIM)],[configModel(type: .Log)],[configModel(type: .Out)]];
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        settingTableView .register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        settingTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell1")
    }
    
    func setupNavBar() -> Void {
        self.title = ZGLocalizedString(key: "setting_page_settings")
        let backItem = UIBarButtonItem.init(image: UIImage.init(named: "nav_back"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = backItem
    }
    
    @objc func back() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    func configModel(type:SettingCellType) -> SettingCellModel {
        let model : SettingCellModel = SettingCellModel.init()
        switch type {
        case .RTA:
            let version : String = ZegoExpressEngine.getVersion().components(separatedBy: "_")[0]
            model.title = ZGLocalizedString(key: "setting_page_sdk_version")
            model.subTitle = "v\(version)"
            model.type = type
            break
        case .ZIM:
            model.title = ZGLocalizedString(key: "setting_page_zim_sdk_version")
            model.subTitle = "v\(ZIM.getVersion())"
            model.type = type
            break
        case .Log:
            model.title = ZGLocalizedString(key: "setting_page_upload_log")
            model.type = type
            break
        case .Out:
            model.title = ZGLocalizedString(key: "setting_page_logout")
            model.type = type
            break
        }
        return model
    }
    

    //MARK: - UITableViewDelegate UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arr : Array = dataList[section]
        return arr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let array : Array = dataList[indexPath.section];
        let model = array[indexPath.row]
        var cell : UITableViewCell
        if model.type == .Out {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let titleLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 49.0))
            titleLabel.text = model.title
            titleLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
            titleLabel.textColor = UIColor.init(red: 238/255.0, green: 21/255.0, blue: 21/255.0, alpha: 1.0)
            titleLabel.textAlignment = NSTextAlignment.center
            cell.contentView.addSubview(titleLabel)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
            cell.textLabel?.text = model.title
            cell.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
            cell.detailTextLabel?.text = model.subTitle
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        }
        let lineView = UIView.init(frame: CGRect.init(x: 0, y: 48.5, width: self.view.bounds.size.width, height: 0.5))
        lineView.backgroundColor = UIColor.init(red: 216/255.0, green: 216/255.0, blue: 216/255.0, alpha: 1.0)
        if model.type == .RTA {
            lineView.isHidden = false
        } else {
            lineView.isHidden = true
        }
        cell.contentView .addSubview(lineView)
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView.init()
        headView.backgroundColor = UIColor.init(red: 244 / 255.0, green: 245 / 255.0, blue: 246 / 255.0, alpha: 1.0)
        return headView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 49
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 16
        } else if section == 1 {
            return 10
        } else if section == 2 {
            return 60
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model : SettingCellModel = dataList[indexPath.section][indexPath.row]
        if (model.type == .Out) {
            // logout
            RoomManager.shared.userService.logout()
            RoomManager.shared.uninit()
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
            getKeyWindow().rootViewController = vc

        } else if (model.type == .Log) {
            // share log.
//            [ZGHUDHelper showNetworkLoading];
            RoomManager.shared.uploadLog { UInt in
                
            };
//            [[ZGZIMManager shared] uploadLog:^(ZIMError *_Nonnull errorInfo) {
//                [ZGHUDHelper hideNetworkLoading];
//                if (errorInfo.code == 0) {
//                    [ZGHUDHelper showMessage:ZGLocalizedString(toast_upload_log_success)];
//                } else {
//                    [ZGHUDHelper showMessage:[NSString stringWithFormat:ZGLocalizedString(toast_upload_log_fail), errorInfo.code]];
//                }
//            }];
        }
    }
}
