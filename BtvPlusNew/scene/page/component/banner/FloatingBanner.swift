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
import struct Kingfisher.KFImage

struct FloatingBanner: PageComponent {
    @EnvironmentObject var naviLogManager:NaviLogManager
    @ObservedObject var viewModel:ViewPagerModel = ViewPagerModel()
    var datas: [BannerData]
    @State var pages: [PageViewProtocol] = []
    @State var index: Int = 0
    @State var leading:CGFloat = 0
    @State var trailing:CGFloat = 0
    
    var close:((_ today:Bool) -> Void)? = nil
    var body: some View {
        ZStack{
            Spacer().modifier(MatchParent()).background(Color.transparent.black70)
                .onTapGesture {
                    self.close?(false)
                }
            VStack(spacing: 0){
                ZStack(alignment: .bottom) {
                    
                    LoopSwipperView(
                        viewModel : self.viewModel,
                        pages: self.pages
                        )
                    
                    if self.pages.count > 1 {
                        HStack(spacing: 0) {
                            ImageButton(
                                defaultImage: Asset.icon.directLeft,
                                size: CGSize(width:Dimen.icon.light,height:Dimen.icon.light)
                            ){ _ in
                                self.viewModel.request = .prev
                            }
                            Spacer()
                            Text(min(self.pages.count, max(1,self.index+1)).description.toFixLength(2))
                                .modifier(NumberMediumTextStyle(size: Font.size.lightExtra, color: Color.app.white))
                                .fixedSize(horizontal: true, vertical: true)
                            HStack(spacing: 0) {
                                Spacer()
                                    .modifier(MatchVertical(width:self.leading))
                                    .background(Color.transparent.white20)
                                Spacer()
                                    .modifier(MatchVertical(width: Dimen.bar.regular))
                                    .background(Color.app.white)
                                Spacer()
                                    .modifier(MatchVertical(width:self.trailing))
                                    .background(Color.transparent.white20)
                            }
                            .frame( height: Dimen.line.regular)
                            .padding(.horizontal, Dimen.margin.tiny)
                            Text(self.pages.count.description.toFixLength(2))
                                .modifier(NumberMediumTextStyle(size: Font.size.lightExtra, color: Color.app.greyLight))
                            Spacer()
                            ImageButton(
                                defaultImage: Asset.icon.directRight,
                                size: CGSize(width:Dimen.icon.light,height:Dimen.icon.light)
                            ){ _ in
                                self.viewModel.request = .next
                            }
                        }
                        .padding(.horizontal, Dimen.margin.lightExtra)
                        .frame( height:39)
                        .background(Color.transparent.black45)
                    }
                }
                HStack(spacing: 0) {
                    TextButton(defaultText: String.app.todayUnvisible,
                               textModifier:MediumTextStyle(
                                    size: Font.size.lightExtra, color: Color.app.grey).textModifier ){ _ in
                        
                        self.sendLog(action: .clickPopupButton, category: "오늘하루보지않기")
                        self.close?(true)
                    }
                    Spacer()
                   
                    TextButton(defaultText: String.app.close,
                               textModifier:MediumTextStyle(
                                    size: Font.size.lightExtra, color: Color.app.black).textModifier ){ _ in
                        
                        self.sendLog(action: .clickPopupButton, category: "닫기")
                        self.close?(false)
                    }
                }
                .padding(.horizontal, Dimen.margin.regularExtra)
                .frame( height:SystemEnvironment.isTablet ? 70 :  50)
                .background(Color.app.white)
            }
            .frame(width: SystemEnvironment.isTablet ? 420 : 300,
                   height: SystemEnvironment.isTablet ? 602 :430)
            .background(Color.brand.bg)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.medium))
        }
        .modifier(MatchParent())
        
        .onAppear(){
            self.pages = datas.map{data in
                FloatingBannerItem(data: data)
            }
            self.setBar(idx:self.viewModel.index)
        }
        .onReceive( self.viewModel.$index ){ idx in
            self.setBar(idx:idx)
            
        }
    }
    
    private func setBar(idx:Int){
        let count = self.datas.count
        let realPos = idx == -1
            ? 0
            : idx == count
                ? (count-1)
                : idx
        let minSize:CGFloat = 150.0 / CGFloat(count)
        let size = min(Dimen.bar.regular, minSize)
        withAnimation{
            self.leading = size * CGFloat(realPos)
            self.trailing = size * CGFloat(max(0,(count - realPos - 1)))
        }
        self.sendLog(action: .pageShow)
    }
    private func sendLog(action:NaviLog.Action, category:String? = "etc"){
        if self.viewModel.index < 0 {return}
        if self.viewModel.index >= self.datas.count {return}
        let data = self.datas[self.viewModel.index]
        var actionBody = MenuNaviActionBodyItem()
        actionBody.menu_id = data.menuId
        actionBody.menu_name = data.menuNm
        actionBody.category = category
        self.naviLogManager.actionLog( action, pageId: .popup, actionBody: actionBody)
    }
}

struct FloatingBannerItem: PageComponent, Identifiable {
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    let id = UUID().uuidString
    let data: BannerData
   
    var body: some View {
        ImageView(url: self.data.image,contentMode: .fill, noImg: Asset.noImg9_16)
            .modifier(MatchParent())
            .clipped()
        /*
        KFImage(URL(string: self.data.image))
            .resizable()
            .placeholder {
                Image(Asset.noImg9_16)
                    .resizable()
            }
            .cancelOnDisappear(true)
            .aspectRatio(contentMode: .fill)
            .modifier(MatchParent())
        .clipped()
        */
         .onTapGesture {
            
            var actionBody = MenuNaviActionBodyItem()
            actionBody.menu_id = data.menuId
            actionBody.menu_name = data.menuNm
            self.naviLogManager.actionLog(.clickPopupContents, pageId: .popup, actionBody: actionBody)
            
            BannerData.move(
                pagePresenter: self.pagePresenter,
                dataProvider: self.dataProvider,
                data: self.data)
            self.appSceneObserver.event = .floatingBanner(nil)
        }
    }
}

#if DEBUG
struct FloatingBanner_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            FloatingBanner(
             datas: [BannerData(),BannerData(),BannerData(),BannerData(),BannerData(),BannerData(),BannerData(),BannerData(),BannerData(),BannerData(),BannerData(),BannerData(),BannerData(),BannerData(),BannerData(),BannerData()])
                .environmentObject(PagePresenter())
                .frame(width:370
                       , height: 477, alignment: .center)
        }
    }
}
#endif
