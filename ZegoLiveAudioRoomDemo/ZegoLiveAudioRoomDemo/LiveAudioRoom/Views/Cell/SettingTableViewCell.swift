//
//  SettingTableViewCell.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/17.
//

import UIKit

protocol SettingTableViewCellDelegate: AnyObject {
    func onSwitchButtonChange(_ status: Bool, cell: UITableViewCell)
}

class SettingTableViewCell: UITableViewCell {
    
    weak var delegate: SettingTableViewCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchChange(_ sender: UISwitch) {
        if delegate != nil {
            delegate?.onSwitchButtonChange(sender.isOn, cell: self)
        }
    }
    
    func updateCellWithTitle(title: String, status: Bool) -> Void {
        titleLabel.text = title
        switchButton.isOn = status
    }
}
