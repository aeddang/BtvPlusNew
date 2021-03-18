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

struct FloatingBanner: PageComponent {
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
                    SwipperView(
                        viewModel : self.viewModel,
                        pages: self.pages,
                        index: self.$index
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
                            Text((self.index+1).description.toFixLength(2))
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
                            Text((self.pages.count).description.toFixLength(2))
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
                        self.close?(true)
                    }
                    Spacer()
                   
                    TextButton(defaultText: String.app.close,
                               textModifier:MediumTextStyle(
                                    size: Font.size.lightExtra, color: Color.app.black).textModifier ){ _ in
                        self.close?(false)
                    }
                }
                .padding(.horizontal, Dimen.margin.regularExtra)
                .frame( height:50)
                .background(Color.app.white)
            }
            .frame(width: 300, height: 430)
            .background(Color.brand.bg)
            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.medium))
        }
        .modifier(MatchParent())
        
        .onAppear(){
            self.pages = datas.map{data in
                FloatingBannerItem(data: data)
            }
            self.setBar(idx:self.index)
        }
        .onReceive( self.viewModel.$index ){ idx in
            self.setBar(idx:idx)
        }
    }
    
    private func setBar(idx:Int){
        let count = self.datas.count
        let minSize:CGFloat = 150.0 / CGFloat(count)
        let size = min(Dimen.bar.regular, minSize)
        withAnimation{
            self.leading = size * CGFloat(idx)
            self.trailing = size * CGFloat(max(0,(count - idx - 1)))
        }
    }
}

struct FloatingBannerItem: PageComponent, Identifiable {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    let id = UUID().uuidString
    let data: BannerData
   
    var body: some View {
        ImageView(url:data.image, contentMode: .fill, noImg: Asset.noImg9_16)
        .modifier(MatchParent())
        .clipped()
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
            }else if let link = data.outLink {
                AppUtil.openURL(link)
            }
            self.pageSceneObserver.event = .floatingBanner(nil)
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
