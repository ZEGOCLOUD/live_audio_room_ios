//
//  giftCollectionViewCell.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/20.
//

import UIKit

class GiftCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var giftImage: UIImageView!
    
    var model: GiftModel? {
        didSet {
            guard let imageName = model?.imageName else { return }
            giftImage.image = UIImage(named: imageName)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
