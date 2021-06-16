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
    static let height:CGFloat = SystemEnvironment.isTablet ? 456 : 477
    static let uiRange:CGFloat = 320
    static let barWidth:CGFloat = Dimen.bar.medium
    static let imageHeight:CGFloat = SystemEnvironment.isTablet ? 500 : 720
    static let barHeight = Dimen.line.medium
    static let marginBottom = SystemEnvironment.isTablet ? Dimen.margin.regularExtra : Dimen.margin.medium
    static let marginBottomBar = SystemEnvironment.isTablet ? Dimen.margin.mediumExtra : Dimen.margin.heavy
    static let maginBottomLogo = (Self.imageHeight - Self.height) + (Self.marginBottom + Self.barHeight + Dimen.margin.medium)
}
struct TopBanner: PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var pageObservable:PageObservable 
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var datas: [BannerData]
     
    @State var pages: [PageViewProtocol] = []
    
   
    var action:((_ idx:Int) -> Void)? = nil
    var body: some View {
        LoopSwipperView(
            viewModel : self.viewModel,
            pages: self.pages
            )
        .modifier(MatchParent())
        .onReceive(self.pagePresenter.$currentTopPage){ page in
            self.isTop = self.pageObservable.pageObject?.id == page?.id
            self.isTop ? self.autoChange() : self.autoChangeCancel()
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
            
        }
        .onDisappear(){
            self.autoChangeCancel()
        }

    }
    
    @State var isInit = false
    @State var isTop = false
    @State var autoChangeSubscription:AnyCancellable?
    func autoChange(){
        ComponentLog.d("autoChange isTop " + self.isTop.description, tag:self.tag)
        ComponentLog.d("autoChange isInit " + self.isInit.description, tag:self.tag)
        self.autoChangeCancel()
        if !self.isTop { return }
        if !self.isInit { return }
        
        
        //ComponentLog.d("autoChange init " + self.pageID, tag:self.tag)
        self.autoChangeSubscription = Timer.publish(
            every: 5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.viewModel.request = .next
                ComponentLog.d("autoChange com " + self.pageID, tag:self.tag)
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
                }
            }
        //}
        //.modifier(MatchParent())
        
    }
}


