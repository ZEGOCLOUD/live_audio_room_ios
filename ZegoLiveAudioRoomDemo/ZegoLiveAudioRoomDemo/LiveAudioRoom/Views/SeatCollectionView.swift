//
//  SeatCollectionView.swift
//  ZegoLiveAudioRoomDemo
//
//  Created by zego on 2021/12/17.
//

import UIKit

protocol SeatCollectionViewDelegate: AnyObject {
    func seatCollectionViewDidSelectedItem(itemIndex:Int);
}

class SeatCollectionView: UIView,UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SeatCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SeatCollectionViewCell", for: indexPath) as! SeatCollectionViewCell
        let model: SpeakerSeatModel = (dataSource?[indexPath.item] ?? SpeakerSeatModel.init(index: 0)) as SpeakerSeatModel
        cell.setSpeakerSeat(seatModel: model, role: role)
        return cell
    }

    public var dataSource: Array<SpeakerSeatModel>?
    public var lineSpace: CGFloat = 0.0
    public var itemSpace: CGFloat = 0.0
    public var role: UserRole = .speaker
    weak var delegate: SeatCollectionViewDelegate?
    
    
    private var rows: Int = 0
    private var lines: Int = 0
    private var itemSize:CGSize?
    
    @IBOutlet weak var collectiomView: UICollectionView!
    
    public func updateDataSource(data: Array<SpeakerSeatModel>) -> Void {
        dataSource = data
    }
    
    public func reloadCollectionView() -> Void {
        collectiomView.reloadData()
    }
    
    public func setNumOfRows(numOfRows: Int, numOfLines: Int) -> Void {
        rows = numOfRows
        lines = numOfLines
        collectiomView.reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectiomView.register(UINib.init(nibName: "SeatCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SeatCollectionViewCell")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calculateItemSize()
    }
    
    private func calculateItemSize() -> Void {
        let width:CGFloat = self.bounds.size.width
        let height:CGFloat = self.bounds.size.height
        let itemWidth:CGFloat = CGFloat(width-CGFloat(CGFloat((rows-1)) * itemSpace)) / CGFloat(rows)
        let itemHeight:CGFloat = CGFloat(height-CGFloat(CGFloat((lines-1)) * lineSpace)) / CGFloat(lines)
        itemSize = CGSize.init(width: itemWidth, height: itemHeight)
    }
}
