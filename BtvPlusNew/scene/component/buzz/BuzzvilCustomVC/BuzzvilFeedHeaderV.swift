//
//  BuzzvilCustomFeedHeaderV.swift
//  BtvPlus
//
//  Created by jklee on 2021/06/16.
//  Copyright © 2021 skb. All rights reserved.
//

import UIKit
import BuzzAdBenefitFeed

class BuzzvilFeedHeaderV: BABFeedHeaderView {
    var viewTest: UIView!
    
    @IBOutlet weak var mBcashLabel: UILabel!
    @IBOutlet weak var mPointLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder )
        loadFromNib()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadFromNib()
    }
    
    override class func desiredHeight() -> CGFloat {
        return 46.0
    }
    
    override func availableRewardDidUpdate(_ reward: Double) {
        mBcashLabel.text = "지금 받을 수 있는 B캐쉬 "
        mPointLabel.text = String(DecimalWon(value: Int(reward))) + "P"

    }
    
    func loadFromNib() {
        let headerView = Bundle(for: type(of: self)).loadNibNamed("BuzzvilFeedHeaderV", owner: self, options: nil)?.first as! UIView
    
        headerView.frame = self.bounds
        addSubview(headerView)
        self.mBcashLabel.font = UIFont(name: "SKBtvMedium", size: 16)
        self.mPointLabel.font = UIFont(name: "SKBtvBold", size: 16)
    }
    
    func DecimalWon(value: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(from: NSNumber(value: value))!
        return result
    }

}
