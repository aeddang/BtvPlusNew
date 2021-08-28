//
//  BuzzvilCustomFeedVC.swift
//  BtvPlus
//
//  Created by Youngsoo Park on 2021/06/08.
//  Copyright © 2021 skb. All rights reserved.
//

import UIKit
import BuzzAdBenefit
import BuzzAdBenefitNative
import BuzzAdBenefitFeed

class BuzzvilCustomFeedVC: UIViewController {
    // MARK: - Outlet
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var viewModel:BuzzViewModel? = nil
    // MARK: - Variable
    
    // MARK: - Life Cycle
    override func viewDidLoad() {super.viewDidLoad()
        // MARK: Set UI
        self.setUI()
        
        // MARK: Load FeedVC
        //DispatchQueue.main.async {
            let config = self.buzzAdConfigSetting()
            config.adViewHolderClass = BuzzvilFeedItemAdsPointV.self
            config.cpsAdViewHolderClass = BuzzvilFeedItemCpsV.self
            config.headerViewClass = BuzzvilFeedHeaderV.self
            let feedHandler = BABFeedHandler(config: config)
            feedHandler.preloadWith(onSuccess: {
                DispatchQueue.main.async {
                    let feedVC = feedHandler.populateViewController()
                    feedVC.view.backgroundColor = .white
                    feedVC.view.frame = self.viewContent.frame
                    self.addChild(feedVC)
                    self.view.addSubview(feedVC.view)
                }
            }, onFailure: { error in
              // 광고가 없을 때에 대한 처리
                ComponentLog.e(error.debugDescription, tag: "BuzzBill")
            })
            
        //}//DispatchQueue.main.async
    }

    // MARK: - Action
    @IBAction func actBtnBack(_ sender: Any) {
        //self.navigationController?.popViewController(animated: true)
        viewModel?.event = .close
    }
    
    @IBAction func actBtnInfo(_ sender: Any) {
        viewModel?.event = .info(self)
    }
    
    
    // MARK: - Function
    private func setUI() {
        
    }
    private func buzzAdConfigSetting() -> BABFeedConfig {
        let unitid: String = SystemEnvironment.isStage
            ? Buzz.BAB_SDK_KR_iOS_DEV_UNIT_ID : Buzz.BAB_SDK_KR_iOS_PRD_UNIT_ID 
        let config = BABFeedConfig(unitId: unitid)
        //툴바 타이틀 내용
        config.title = String.pageTitle.cashCharge //"꿀 피드"
        //툴바 타이틀의 폰트
        config.titleFont = UIFont.boldSystemFont(ofSize: 30)
        //툴바 높이값
        config.topBarHeight = 0

        //??
        config.shouldShowAppTrackingTransparencyGuideBanner = false
        config.shouldShowAppTrackingTransparencyDialog = false
        
        //퍼블리셔 자체 컨텐츠 노출
        config.articlesEnabled = true
        //탭 배경색
        //        config.tabBackgroundColor = .darkGray
        //탭 폰트 기본색
        config.tabDefaultColor = UIColor(displayP3Red: 136/255, green: 136/255, blue: 136/255, alpha: 1)//.black
        //탭 선택 색
        config.tabSelectedColor = UIColor(displayP3Red: 244/255, green: 101/255, blue: 52/255, alpha: 1)//.gray
        //탭 노출
        config.tabUiEnabled = true
        //탭에 home탭 추가
//        config.homeTabEnabled = true
        config.tabTextArray = ["광고 적립", "쇼핑 적립"]
        
        //필터 켬
        config.filterUiEnabled = true
        config.filterBackgroundDefaultColor = UIColor(displayP3Red: 253/255, green: 224/255, blue: 214/255, alpha: 1)//.black
        config.filterBackgroundSelectedColor =  UIColor(displayP3Red: 244/255, green: 101/255, blue: 52/255, alpha: 1)//.black
        config.filterTextDefaultColor = UIColor(displayP3Red: 244/255, green: 101/255, blue: 52/255, alpha: 1)
        config.filterTextSelectedColor = UIColor.white
        
        
        //??
        config.autoLoadingEnabled = true
        
//        let header = CustomHeaderView.self
//        config.headerViewClass = header
//        config.adViewHolderClass = CustomAdViewHolder.self
        
        config.separatorColor = UIColor(displayP3Red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        config.separatorHeight = 1
//        config.separatorHorizontalMargin = 0
        return config
    }
    
    
    // MARK: - Sub Function
    override var shouldAutorotate: Bool {
        return SystemEnvironment.isTablet ? true : false
    }
}
