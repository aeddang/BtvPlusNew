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
    static let barWidth:CGFloat = 120
    static let imageHeight:CGFloat = 667
    static let height:CGFloat = 477
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
                        Spacer()
                            .modifier(MatchParent())
                            .background(Color.app.white)
                        Spacer()
                            .modifier(MatchVertical(width:self.tailing))
                            .background(Color.transparent.white20)
                    }
                    .frame(width:Self.barWidth, height:Dimen.line.medium)
                    .modifier(
                        LayoutBotttom(
                            geometry: geometry,
                            height:Dimen.line.medium,
                            margin: Dimen.margin.medium )
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
                    TopBannerItem(imagePath: data.image)
                }
                self.setBar()
            }
        }
    }
    
    func setBar(){
        let count = self.datas.count
        let size = Self.barWidth / CGFloat(count)
        withAnimation{
            self.leading = size * CGFloat(self.index)
            self.tailing = size * CGFloat(max(0,(count - self.index - 1)))
        }
    }
    
}

struct TopBannerItem: PageComponent, Identifiable {
    let id = UUID().uuidString
    let imagePath: String
    var body: some View {
        ZStack{
            ImageView(url:imagePath, contentMode: .fill, noImg: Asset.source.pairingTutorial)
            VStack{
                Image(Asset.shape.bgGradientTop)
                .renderingMode(.original)
                .resizable()
                .modifier(MatchHorizontal(height: 110))
                Spacer()
                Image(Asset.shape.bgGradientBottom)
                .renderingMode(.original)
                .resizable()
                .modifier(MatchHorizontal(height: 463))
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
