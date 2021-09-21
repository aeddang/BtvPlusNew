//
//  ImageViewPager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
extension TopBanner{
    static let height:CGFloat = SystemEnvironment.isTablet ? 456 : 528
    static let heightHorizontal:CGFloat = 532
    static let uiRange:CGFloat = 350
    static let uiRangeHorizontal:CGFloat = 400
    static let barWidth:CGFloat = Dimen.bar.medium
    static let imageHeight:CGFloat = SystemEnvironment.isTablet ? 500 : 750
    static let imageHeightHorizontal:CGFloat = 667
    static let barHeight = Dimen.line.medium
    static let quickMenuMarginTop =  SystemEnvironment.isTablet ?  Dimen.margin.regular :  Dimen.margin.heavyExtra
    static let quickMenuHeight = (SystemEnvironment.isTablet ? 52 : 46) +  quickMenuMarginTop
    static let marginBottom = SystemEnvironment.isTablet ? Dimen.margin.regularExtra : Dimen.margin.medium
    static let marginBottomBar = SystemEnvironment.isTablet ? Dimen.margin.mediumExtra : Dimen.margin.heavy
    static let marginBottomBarVertical = Self.marginBottomBar + Self.imageHeight - Self.height
    static let marginBottomBarHorizontal = Self.marginBottomBar + Self.imageHeightHorizontal - Self.heightHorizontal
    static let maginBottomLogo = Self.marginBottomBarVertical + Dimen.margin.medium
    static let maginBottomLogoHorizontal = Self.marginBottomBarHorizontal + Dimen.margin.medium
}
struct TopBanner: PageComponent {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var pageObservable:PageObservable 
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var datas: [BannerData]
   
    @State var pages: [PageViewProtocol] = []
    @State var isHorizontal:Bool = false
   
    var action:((_ idx:Int) -> Void)? = nil
    var body: some View {
        LoopSwipperView(
            viewModel : self.viewModel,
            pages: self.pages
            )
        .modifier(MatchHorizontal(height: isHorizontal ? TopBanner.uiRangeHorizontal : TopBanner.uiRange))
       
        .onReceive(self.pagePresenter.$currentTopPage){ page in
            self.isTop = self.pageObservable.pageObject?.id == page?.id
            self.isTop ? self.autoChange() : self.autoChangeCancel()
        }
        .onReceive(self.sceneObserver.$isUpdated) { update in
            if !update {return}
            if !SystemEnvironment.isTablet {return}
            self.isHorizontal = self.sceneObserver.sceneOrientation == .landscape
        }
        .onReceive(self.viewModel.$status){ status in
            switch status {
            case .stop : self.autoChange()
            case .move : self.autoChangeCancel()
            default : break
            }
        }
        .onReceive(self.infinityScrollModel.$event){evt in
            guard let evt = evt else {return}
            if self.isTop {
                switch evt {
                case .top : self.autoChange()
                case .down : self.autoChangeCancel()
                default : break
                }
                self.viewModel.request = .reset
            }
        }
    
        .onReceive(self.pageObservable.$status){status in
            
            switch status {
            case .enterBackground : self.autoChangeCancel()
            case .enterForeground : self.autoChange()
            case .becomeActive : self.autoChange()
            case .resignActive : self.autoChangeCancel()
            case .disconnect : self.autoChangeCancel()
            default : return
            }
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                self.isInit = true
                self.pages = datas.map{data in
                    TopBannerItem(data: data)
                }
                self.autoChange()
            }
        }
        .onAppear(){
            if SystemEnvironment.isTablet {
                self.isHorizontal = self.sceneObserver.sceneOrientation == .landscape
            }
        }
        .onDisappear(){
            self.autoChangeCancel()
        }

    }
    
    @State var isInit = false
    @State var isTop = false
    @State var autoChangeSubscription:AnyCancellable?
    func autoChange(){
       //ComponentLog.d("autoChange isTop " + self.isTop.description, tag:self.tag)
       // ComponentLog.d("autoChange isInit " + self.isInit.description, tag:self.tag)
        self.autoChangeCancel()
        if !self.isTop { return }
        if !self.isInit { return }
        
        //ComponentLog.d("autoChange init " + self.pageID, tag:self.tag)
        self.autoChangeSubscription = Timer.publish(
            every: 5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.viewModel.request = .next
                //ComponentLog.d("autoChange com " + self.pageID, tag:self.tag)
            }
        
    }
    
    func autoChangeCancel(){
        //ComponentLog.d("autoChangeCancel" + self.pageID, tag:self.tag)
        self.autoChangeSubscription?.cancel()
        self.autoChangeSubscription = nil
    }
    
}

struct TopBannerItem: PageComponent, Identifiable {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var sceneObserver:PageSceneObserver
    let id = UUID().uuidString
    let data: BannerData
   
    var body: some View {
        //ZStack(alignment: .top) {
           Spacer()
            .modifier(MatchParent())
            .background(Color.transparent.clearUi)
            .onTapGesture {
                BannerData.move(
                    pagePresenter: self.pagePresenter,
                    dataProvider: self.dataProvider,
                    data: self.data)
                /*
                if let move = data.move {
                    switch move {
                    case .home, .category:
                        if let gnbTypCd = data.moveData?[PageParam.id] as? String {
                            if let band = dataProvider.bands.getData(gnbTypCd: gnbTypCd) {
                                self.pagePresenter.changePage(
                                    PageProvider
                                        .getPageObject(move)
                                        .addParam(params: data.moveData)
                                        .addParam(key: .id, value: band.menuId)
                                        .addParam(key: UUID().uuidString , value: "")
                                )
                            }
                        }
                        
                    default :
                        let pageObj = PageProvider.getPageObject(move)
                        pageObj.params = data.moveData
                        self.pagePresenter.openPopup(pageObj)
                    }
                }
                else if let link = data.outLink {
                    AppUtil.openURL(link)
                }
                else if let link = data.inLink {
                    self.pagePresenter.openPopup(
                        PageProvider
                            .getPageObject(.webview)
                            .addParam(key: .data, value: link)
                            .addParam(key: .title , value: data.title)
                    )
                }*/
            }
        //}
        //.modifier(MatchParent())
        
    }
}


