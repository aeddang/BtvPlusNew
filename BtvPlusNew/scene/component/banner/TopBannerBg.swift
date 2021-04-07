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
struct TopBannerBg: PageComponent {
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    var viewModel:ViewPagerModel = ViewPagerModel()
    var datas: [BannerData]
     
    @State var pages: [PageViewProtocol] = []
    @State var index: Int = 0
    @State var leading:CGFloat = 0
    @State var trailing:CGFloat = 0
    
    var action:((_ idx:Int) -> Void)? = nil
    var body: some View {
        ZStack(alignment: .bottom){
            LoopSwipperView(
                viewModel : self.viewModel,
                pages: self.pages,
                isForground : false
                )
                .modifier(MatchHorizontal(height: TopBanner.imageHeight))
            if self.pages.count > 1 {
                HStack(spacing: Dimen.margin.tiny) {
                    Spacer()
                        .modifier(MatchVertical(width:self.leading))
                        .background(Color.transparent.white20)
                        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                    Spacer()
                        .modifier(MatchVertical(width: TopBanner.barWidth))
                        .background(Color.app.white)
                        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                    Spacer()
                        .modifier(MatchVertical(width:self.trailing))
                        .background(Color.transparent.white20)
                        .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                }
                .frame( height:TopBanner.barHeight)
                .padding(.bottom, Dimen.margin.heavy + TopBanner.imageHeight - TopBanner.height)
            }
        }
        .onAppear(){
            self.pages = datas.map{data in
                TopBannerBgItem(data: data)
            }
            self.setBar(idx:self.viewModel.index)
        }
        .onReceive( self.viewModel.$index ){ idx in
            self.setBar(idx:idx)
        }
    }
    
    private func setBar(idx:Int){
        let count = self.datas.count
        let minSize:CGFloat = 240.0
        let size = min(TopBanner.barWidth, minSize/CGFloat(count))
    
        withAnimation{
            self.leading = size * CGFloat(idx)
            self.trailing = size * CGFloat(max(0,(count - idx - 1)))
        }
    }
}

struct TopBannerBgItem: PageComponent, Identifiable {

    @EnvironmentObject var sceneObserver:PageSceneObserver
    let id = UUID().uuidString
    let data: BannerData
   
    var body: some View {
        ZStack(){
            KFImage(URL(string: self.data.image))
                .resizable()
                .placeholder {
                    Image(Asset.noImg9_16)
                        .resizable()
                }
                .cancelOnDisappear(true)
                .loadImmediately()
                .aspectRatio(contentMode: .fill)
                .frame(height:TopBanner.imageHeight)
            
            VStack{
                Image(Asset.shape.bgGradientTop)
                .renderingMode(.original)
                .resizable()
                    .modifier(MatchHorizontal(height: 110 + self.sceneObserver.safeAreaTop))
                Spacer()
                Image(Asset.shape.bgGradientBottom)
                .renderingMode(.original)
                .resizable()
                    .modifier(MatchHorizontal(height:TopBanner.height))
            }
            VStack{
                Spacer()
                if let logo = data.logo {
                    KFImage(URL(string: logo))
                        .resizable()
                        .cancelOnDisappear(true)
                        .loadImmediately()
                        .aspectRatio(contentMode: .fit)
                        .frame(minWidth: 0, maxWidth: 280, minHeight: 0, maxHeight: 80, alignment:.bottom)
                        .padding(.horizontal, Dimen.margin.heavy)
                }
                else if data.title != nil {
                    Text(data.title!)
                        .modifier(BlackTextStyle(size: Font.size.black) )
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Dimen.margin.heavy)
                }
                if data.subTitle != nil {
                    Text(data.subTitle!)
                        .modifier(MediumTextStyle(size: Font.size.lightExtra, color:Color.app.grey))
                        .multilineTextAlignment(.center)
                        .padding(.top, Dimen.margin.lightExtra)
                        .padding(.horizontal, Dimen.margin.thin)
                }
            }
            .offset(y:TopBanner.height/2 - TopBanner.maginBottomLogo - (TopBanner.imageHeight-TopBanner.height)/2)
            .modifier(MatchHorizontal(height: TopBanner.height))
           
        }
        .modifier(MatchHorizontal(height: TopBanner.imageHeight))
        .clipped()
    }
}

#if DEBUG
struct TopBannerBg_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            TopBannerBg(
             datas: [BannerData(),BannerData(),BannerData(),BannerData()])
            .frame(width:375, height: 477, alignment: .center)
        }
    }
}
#endif
