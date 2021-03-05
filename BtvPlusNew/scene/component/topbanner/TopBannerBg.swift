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

struct TopBannerBg: PageComponent {
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    var viewModel:ViewPagerModel = ViewPagerModel()
    var datas: [BannerData]
     
    @State var pages: [PageViewProtocol] = []
    @State var index: Int = 0
    
    var action:((_ idx:Int) -> Void)? = nil
    var body: some View {
        SwipperView(
            viewModel : self.viewModel,
            pages: self.pages,
            index: self.$index,
            useGesture : false
            )
            .modifier(MatchHorizontal(height: TopBanner.imageHeight))
            .onAppear(){
                self.pages = datas.map{data in
                    TopBannerBgItem(data: data)
                }
            }
    }
}

struct TopBannerBgItem: PageComponent, Identifiable {

    @EnvironmentObject var sceneObserver:SceneObserver
    let id = UUID().uuidString
    let data: BannerData
   
    var body: some View {
        ZStack{
            ImageView(url:data.image, contentMode: .fill, noImg: Asset.noImgBanner)
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
