//
//  ImageViewPager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI

extension TopBanner{
    static let barWidth:CGFloat = 20
    static let imageHeight:CGFloat = 720
    static let height:CGFloat = 477
    
    static let barHeight = Dimen.line.medium
    static let marginBottom = Dimen.margin.medium
    static let maginBottomLogo = (Self.imageHeight - Self.height) + (Self.marginBottom + Self.barHeight + Dimen.margin.medium)
}


struct TopBanner: PageComponent {
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
            .onReceive( [self.index].publisher ){ idx in
                if self.viewModel.index == idx { return }
                self.viewModel.index = idx
                self.setBar()
            }
            .onReceive(self.viewModel.$event){ evt in
                guard let event = evt else { return }
                switch event {
                case .move(let idx) : withAnimation{ self.index = idx }
                }
            }
            .onAppear(){
                self.pages = datas.map{data in
                    TopBannerItem(data: data)
                }
                self.setBar()
            }
        }
    }
    
    func setBar(){
        let count = self.datas.count
        let size = Self.barWidth
        withAnimation{
            self.leading = size * CGFloat(self.index)
            self.tailing = size * CGFloat(max(0,(count - self.index - 1)))
        }
    }
    
}

struct TopBannerItem: PageComponent, Identifiable {
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
