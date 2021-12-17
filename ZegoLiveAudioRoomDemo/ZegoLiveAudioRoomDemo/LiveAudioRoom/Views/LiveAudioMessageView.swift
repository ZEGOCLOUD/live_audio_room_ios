//
//  LiveAudioMessageView.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/16.
//

import UIKit

class LiveAudioMessageView: UIView,UITableViewDataSource,UITableViewDelegate {
    
    
//    var _tableView:UITableView?
    var messageTableView:UITableView?
    var dataSource:Array<LiveAudioMessageModel>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        LiveAudioMessageModelBuilder.messageViewWidth = self.frame.size.width
    }
    
    var constraintLeft:NSLayoutConstraint!
    //MARK: -Private
    private func configUI() -> Void {
        self.backgroundColor = UIColor.clear
        setupTableView()
        let constraintLeft:NSLayoutConstraint = equallyRelatedConstraint(view: messageTableView ?? UITableView(), attribute: .left)
        let constraintRight:NSLayoutConstraint = equallyRelatedConstraint(view: messageTableView ?? UITableView(), attribute: .right)
        let constraintTop:NSLayoutConstraint = equallyRelatedConstraint(view: messageTableView ?? UITableView(), attribute: .top)
        let constraintBottom:NSLayoutConstraint = equallyRelatedConstraint(view: messageTableView ?? UITableView(), attribute: .bottom)
        self.addConstraints([constraintLeft,constraintRight,constraintTop,constraintBottom])
    }
    
    func setupTableView() -> Void {
        messageTableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height), style: UITableView.Style.plain)
        messageTableView?.delegate = self as UITableViewDelegate
        messageTableView?.dataSource = self as UITableViewDataSource
        messageTableView?.backgroundColor = UIColor.init(red: 244/255.0, green: 244/255.0, blue: 244/255.0, alpha: 1.0)
        messageTableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        messageTableView?.showsHorizontalScrollIndicator = false
        messageTableView?.showsVerticalScrollIndicator = false
        messageTableView?.estimatedRowHeight = 0
        messageTableView?.estimatedSectionFooterHeight = 0
        messageTableView?.estimatedSectionHeaderHeight = 0
        if #available(iOS 11.0, *) {
            messageTableView?.contentInsetAdjustmentBehavior = .never
            messageTableView?.insetsContentViewsToSafeArea = false
        }
        messageTableView?.translatesAutoresizingMaskIntoConstraints = false
        messageTableView?.register(UINib.init(nibName: "LiveAudioMessageCell", bundle: nil), forCellReuseIdentifier:"LiveAudioMessageCell")
        self.addSubview(messageTableView ?? UITableView())
    }
    
    private func equallyRelatedConstraint(view:UIView,attribute:NSLayoutConstraint.Attribute) -> NSLayoutConstraint {
        return NSLayoutConstraint.init(item: view, attribute: attribute, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: attribute, multiplier: 1.0, constant: 0.0)
    }

    //MARK: -Public
    func reloadWithData(data:Array<LiveAudioMessageModel>) -> Void {
        dataSource = data
        messageTableView?.reloadData()
    }
    
    func scrollToBottom() -> Void {
        if dataSource?.count == 0 {
            return
        }
        self.layoutIfNeeded()
        let indexPath:IndexPath = IndexPath.init(row: dataSource!.count - 1, section: 0)
        messageTableView?.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: true)
    }
    
    
    //MARK: -UITableViewDelegate UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageCell:LiveAudioMessageCell = tableView.dequeueReusableCell(withIdentifier:"LiveAudioMessageCell", for: indexPath) as! LiveAudioMessageCell
        if indexPath.row < dataSource!.count {
            let index:Int = indexPath.row
            messageCell.model = dataSource![index]
        }
        return messageCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model:LiveAudioMessageModel = dataSource![indexPath.row]
        return model.messageHeight! + 10*2 + 10
    }

}
