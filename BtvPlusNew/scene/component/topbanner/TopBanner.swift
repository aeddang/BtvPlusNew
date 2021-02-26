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
    static let barWidth:CGFloat = 20
    static let imageHeight:CGFloat = 720
    static let height:CGFloat = 477
    
    static let barHeight = Dimen.line.medium
    static let marginBottom = Dimen.margin.medium
    static let maginBottomLogo = (Self.imageHeight - Self.height) + (Self.marginBottom + Self.barHeight + Dimen.margin.medium)
}
struct TopBanner: PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    var datas: [BannerData]
     
    @State var pages: [PageViewProtocol] = []
    @State var index: Int = 0
    @State var leading:CGFloat = 0
    @State var tailing:CGFloat = 0
    
    var action:((_ idx:Int) -> Void)? = nil
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack(alignment: .top) {
                    SwipperView(
                        viewModel : self.viewModel,
                        pages: self.pages,
                        index: self.$index)
                    
                }
                .modifier(
                    LayoutTop(
                        geometry: geometry,
                        height:Self.imageHeight)
                )
                if self.pages.count > 1 {
                    HStack(spacing: Dimen.margin.tiny) {
                        Spacer()
                            .modifier(MatchVertical(width:self.leading))
                            .background(Color.transparent.white20)
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                        Spacer()
                            .modifier(MatchVertical(width: Self.barWidth))
                            .background(Color.app.white)
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                        Spacer()
                            .modifier(MatchVertical(width:self.tailing))
                            .background(Color.transparent.white20)
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                    }
                    .frame( height:Self.barHeight)
                    .modifier(
                        LayoutBotttom(
                            geometry: geometry,
                            height:Self.barHeight,
                            margin: Self.marginBottom )
                    )
                }
            }
            .modifier(MatchHorizontal(height: Self.height))
            
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                self.isTop = self.pageObservable.pageObject?.pageID == page?.pageID
                self.isTop ? self.autoChange() : self.autoChangeCancel()
            }
            .onReceive( [self.index].publisher ){ idx in
                if self.viewModel.index == idx { return }
                self.viewModel.index = idx
                self.setBar()
            }
            .onReceive(self.viewModel.$status){ status in
                switch status {
                case .stop : self.autoChange()
                case .move : self.autoChangeCancel()
                }
            }
            .onReceive(self.viewModel.$request){ evt in
                guard let event = evt else { return }
                switch event {
                case .move(let idx) : withAnimation{ self.index = idx }
                case .jump(let idx) : self.index = idx
                }
            }
            .onReceive(self.pageObservable.$status){status in
                switch status {
                //case .enterBackground : self.autoChangeCancel()
                //case .enterForeground : self.autoChange()
                case .becomeActive : self.autoChange()
                case .resignActive : self.autoChangeCancel()
                case .disconnect : self.autoChangeCancel()
                default : return
                }
            }
            .onAppear(){
                self.pages = datas.map{data in
                    TopBannerItem(data: data)
                }
                self.setBar()
            }
            .onDisappear(){
                self.autoChangeCancel()
            }
        }
    }
    
    private func setBar(){
        let count = self.datas.count
        let size = Self.barWidth
        withAnimation{
            self.leading = size * CGFloat(self.index)
            self.tailing = size * CGFloat(max(0,(count - self.index - 1)))
        }
    }
    
    @State var isTop = false
    @State var autoChangeSubscription:AnyCancellable?
    func autoChange(){
        if !self.isTop { return }
        ComponentLog.d("autoChange", tag:self.tag)
        self.autoChangeSubscription?.cancel()
        self.autoChangeSubscription = Timer.publish(
            every: 5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                var idx  = self.index + 1
                if idx >= self.datas.count {
                    idx = 0
                    self.viewModel.request = .jump(idx)
                } else {
                    self.viewModel.request = .move(idx)
                }
                ComponentLog.d("autoChange com " + idx.description, tag:self.tag)
                
            }
    }
    
    func autoChangeCancel(){
        ComponentLog.d("autoChangeCancel", tag:self.tag)
        self.autoChangeSubscription?.cancel()
        self.autoChangeSubscription = nil
    }
    
}

struct TopBannerItem: PageComponent, Identifiable {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var sceneObserver:SceneObserver
    let id = UUID().uuidString
    let data: BannerData
   
    var body: some View {
        ZStack{
            ImageView(url:data.image, contentMode: .fill, noImg: Asset.noImgBanner)
            
            VStack{
                Image(Asset.shape.bgGradientTop)
                .renderingMode(.original)
                .resizable()
                    .modifier(MatchHorizontal(height: 110 + self.sceneObserver.safeAreaTop))
                Spacer()
                Image(Asset.shape.bgGradientBottom)
                .renderingMode(.original)
                .resizable()
                .modifier(MatchHorizontal(height: 463))
            }
           
            VStack{
                Spacer()
                if data.logo != nil {
                    ImageView(url:data.logo!, contentMode: .fit, noImg: Asset.noImg1_1)
                        .frame(minWidth: 0, maxWidth: 280, minHeight: 0, maxHeight: 80, alignment:.bottom)
                    
                }
                else if data.title != nil {
                    Text(data.title!)
                        .modifier(BlackTextStyle(size: Font.size.black) )
                        .multilineTextAlignment(.center)
                }
                if data.subTitle != nil {
                    Text(data.subTitle!)
                        .modifier(MediumTextStyle(size: Font.size.lightExtra, color:Color.app.grey))
                        .multilineTextAlignment(.center)
                        .padding(.top, Dimen.margin.lightExtra)
                }
            }
            .padding(.horizontal, Dimen.margin.heavy)
            .padding(.bottom, TopBanner.maginBottomLogo)
            
            VStack{
                Spacer()
                    .modifier(MatchHorizontal(height: TopBanner.height - Dimen.app.top - self.sceneObserver.safeAreaTop))
                    .background(Color.transparent.clearUi)
                    .padding(.top, Dimen.app.pageTop + self.sceneObserver.safeAreaTop)
                    .onTapGesture {
                        if let move = data.move {
                            switch move {
                            case .home :
                                if let gnbTypCd = data.moveData?[PageParam.id] as? String {
                                    if let band = dataProvider.bands.getData(gnbTypCd: gnbTypCd) {
                                        self.pagePresenter.changePage(
                                            PageProvider
                                                .getPageObject(move)
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
                        }else if let link = data.link {
                            AppUtil.openURL(link)
                        }
                    }
                Spacer()
            }
        }
        .clipped()
    }
}

#if DEBUG
struct TopBanner_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            TopBanner(
             datas: [BannerData(),BannerData(),BannerData(),BannerData()])
            .frame(width:375, height: 477, alignment: .center)
        }
    }
}
#endif
