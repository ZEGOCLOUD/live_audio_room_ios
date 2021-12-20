//
//  giftCollectionViewCell.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/20.
//

import UIKit

class giftCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var giftImage: UIImageView!
    
    var model:GiftModel? {
        didSet {
            giftImage.image = UIImage.init(named: model?.imageName ?? "")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
