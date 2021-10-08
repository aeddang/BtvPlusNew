//
//  BuzzvilFeedItemV.swift
//  BtvPlus
//
//  Created by Youngsoo Park on 2021/06/10.
//  Copyright © 2021 skb. All rights reserved.
//

import UIKit
import BuzzAdBenefit
import BuzzAdBenefitNative
import BuzzAdBenefitFeed
import SDWebImage

class BuzzvilFeedItemAdsPointV: BABAdViewHolder, BABNativeAdViewDelegate {
    // MARK: - Outlet
    @IBOutlet var container: UIView!
    @IBOutlet weak var carouselView: CarouselView!
    @IBOutlet weak var adView: BABNativeAdView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lblSponsered: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var ctaButton: UIButton!
    @IBOutlet weak var mediaView: BABMediaView!
    @IBOutlet weak var rewardIcon: UIImageView!
    @IBOutlet weak var ctaLabel: UILabel!
    @IBOutlet weak var ctaBackView: UIView!
    @IBOutlet weak var titleWidth: NSLayoutConstraint!
    @IBOutlet weak var shouldClickSwitch: UILabel!
    
    // MARK: - Variable
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.viewInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.viewInit()
    }
    
    private func viewInit() {
        let vc = Bundle.main.loadNibNamed(String(describing: BuzzvilFeedItemAdsPointV.self), owner: self, options: nil)?.first as? UIView
        self.adView.delegate = self
        vc?.backgroundColor = .red
        AppUtil.setAutolayoutSamesize(item: vc!, toitem: self)
        self.addSubview(vc!)
        
        self.mediaView.layer.cornerRadius = 25
        self.ctaBackView.layer.cornerRadius = 25

        self.descriptionLabel.font = UIFont(name: "SKBtvBold", size: 18)
        self.titleLabel.font = UIFont(name: "SKBtvMedium", size: 16)
        self.ctaLabel.font = UIFont(name: "SKBtvBold", size: 16)
        self.ctaButton.isEnabled = true
    }
    func loadFromNib() {
        
    }
    
    // MARK: - Action
    
    // MARK: - Function
    // Bind view with ad, 광고 리스트 아이템 영역 Customization - 일반 광고
    override func renderAd(_ ad: BABAd) {
        super.renderAd(ad)
        
        self.titleLabel.text = ad.creative.title
        self.lblSponsered.text = "Sponsered"
        
        // description 필드가 objc 객체에 기본으로 있어서 body로 컨버팅 하여 사용
        self.descriptionLabel.text = ad.creative.body
        
        self.iconImageView.sd_setImage(with: URL(string: ad.creative.iconUrl!))
        
        // reward > 0 인지 확인
        if ad.reward > 0 {
            if ad.isParticipated() {
                self.ctaButton.isEnabled = false
                self.ctaLabel.text = "참여 완료"
                self.rewardIcon.image = UIImage(named: "icCategoryBtnCheck")
            
            } else {
                self.ctaButton.isEnabled = true
                self.ctaLabel.text = "+\(self.numberToDecimalString(number: Int(ad.reward)))P \(ad.creative.callToAction!)"
                self.rewardIcon.image = UIImage(named: "021IconIcCategoryBtnBcash")
            }
        } else {
            self.ctaLabel.text = ad.creative.callToAction
            self.rewardIcon.image = nil
        }
        
        self.adView.ad = ad
        self.adView.mediaView = self.mediaView
        self.adView.clickableViews = [self.ctaButton, self.iconImageView]
    }
    
    
    // MARK: - Delegate
    // Handle ad callbacks
    func babNativeAdView(_ adView: BABNativeAdView, didImpress ad: BABAd) {
    }
    
    func babNativeAdView(_ adView: BABNativeAdView, didClick ad: BABAd) {
    }
    
    func babNativeAdView(_ adView: BABNativeAdView, willRequestRewardFor ad: BABAd) {
    }
    
    func babNativeAdView(_ adView: BABNativeAdView, didRewardFor ad: BABAd, with result: BABRewardResult) {
    }
    
    func babNativeAdView(_ adView: BABNativeAdView, didParticipateAd ad: BABAd) {
        self.ctaButton.isEnabled = false
        self.ctaLabel.text = "참여 완료"
        self.rewardIcon.image = UIImage(named: "icCategoryBtnCheck")
        //self.ctaButton.bounds = .init(x: 0, y: 0, width: 76, height: 50)
    }
    
    // MARK: - Sub Function
    private func numberToDecimalString(number: Int) -> String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf.string(from: NSNumber(value: number)) ?? "0"
    }
}
