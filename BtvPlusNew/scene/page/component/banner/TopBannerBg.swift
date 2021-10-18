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
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @ObservedObject var pageObservable:PageObservable
   
    var viewModel:ViewPagerModel = ViewPagerModel()
    var datas: [BannerData]
    var ratio:CGFloat = 1.0
    var useQuickMenu:Bool = false
    @State var pages: [PageViewProtocol] = []
    @State var index: Int = 0
    @State var leading:CGFloat = 0
    @State var trailing:CGFloat = 0
    @State var isHorizontal:Bool = false
    var action:((_ idx:Int) -> Void)? = nil
    var body: some View {
        ZStack(alignment: .bottom){
            LoopSwipperView(
                pageObservable: self.pageObservable,
                viewModel : self.viewModel,
                pages: self.pages,
                isForground : false,
                ratio: self.ratio
                )
            .modifier(MatchParent())
                
            if self.pages.count > 1 {
                VStack(alignment: SystemEnvironment.isTablet ? .leading : /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 0){
                    Spacer().modifier(MatchHorizontal(height: 0))
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
                    .modifier(MatchHorizontal( height:TopBanner.barHeight))
                    
                }
                .padding(.horizontal, SystemEnvironment.isTablet ? Dimen.margin.thin : 0)
                .padding(.bottom, isHorizontal
                            ? TopBanner.marginBottomBarHorizontal
                            : TopBanner.marginBottomBarVertical
                )
            }
        }
        .modifier(MatchHorizontal(height: isHorizontal ?  TopBanner.imageHeightHorizontal : TopBanner.imageHeight))
        .onReceive( self.viewModel.$index ){ idx in
            self.setBar(idx:idx)
        }
        .onReceive(self.sceneObserver.$isUpdated) { update in
            if !update {return}
            if !SystemEnvironment.isTablet {return}
            self.isHorizontal = self.sceneObserver.sceneOrientation == .landscape
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                self.pages = datas.map{data in
                    TopBannerBgItem(data: data)
                }
                self.setBar(idx:self.viewModel.index)
            }
        }
        .onAppear(){
            if SystemEnvironment.isTablet {
                self.isHorizontal = self.sceneObserver.sceneOrientation == .landscape
            }
        }
        
    }
    
    private func setBar(idx:Int){
        if self.pages.isEmpty {return}
        let count = self.datas.count
        let realPos = idx == -1
            ? 0
            : idx == count
                ? (count-1)
                : idx
        let minSize:CGFloat = 240.0
        let size = min(TopBanner.barWidth, minSize/CGFloat(count))
    
        withAnimation{
            
            self.leading = size * CGFloat(realPos)
            self.trailing = size * CGFloat(max(0,(count - realPos - 1)))
        }
    }
}

struct TopBannerBgItem: PageComponent, Identifiable {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    let id = UUID().uuidString
    let data: BannerData
    
    @State var isHorizontal:Bool = false
    var body: some View {
        ZStack(){
            KFImage(URL(string: self.data.image))
                .resizable()
                .placeholder {
                    Image(SystemEnvironment.isTablet ? Asset.noImg16_9 : Asset.noImg9_16)
                        .resizable()
                }
                .cancelOnDisappear(true)
                .aspectRatio(contentMode:  .fill)
                .modifier(MatchHorizontal(height:isHorizontal ? TopBanner.imageHeightHorizontal : TopBanner.imageHeight))
              
            if !SystemEnvironment.isTablet {
                VStack{
                    Image(Asset.shape.bgGradientTop)
                    .renderingMode(.original)
                    .resizable()
                    .modifier(MatchHorizontal(height: 110 + self.sceneObserver.safeAreaTop))
                    Spacer()
                    Image(Asset.shape.bgGradientBottom)
                    .renderingMode(.original)
                    .resizable()
                        .modifier(MatchHorizontal(height:isHorizontal ? TopBanner.heightHorizontal :TopBanner.height))
                }
            }
            if SystemEnvironment.isTablet {
                VStack(alignment:.leading, spacing:0){
                    Spacer().modifier(MatchParent())
                    if let logo = data.logo {
                        KFImage(URL(string: logo))
                            .resizable()
                            .cancelOnDisappear(true)
                            .aspectRatio(contentMode: .fit)
                            .frame(
                                minWidth: 0,
                                idealWidth: 300,
                                maxWidth: 400,
                                minHeight: 0,
                                idealHeight : 80,
                                maxHeight: 120, alignment:.bottomLeading)
                            
                    }
                    else if data.title != nil {
                        Text(data.title!)
                            .modifier(BlackTextStyle(size: Font.size.black) )
                            .multilineTextAlignment(.leading)
                    }
                    if let subTitle = data.subTitle1 {
                        Text(subTitle)
                            .modifier(MediumTextStyle(size: Font.size.thinExtra, color:data.subTitleColor1))
                            .multilineTextAlignment(.leading)
                            .padding(.top, Dimen.margin.lightExtra)
                    }
                    if let subTitle = data.subTitle2 {
                        Text(subTitle)
                            .modifier(MediumTextStyle(size: Font.size.thinExtra, color:data.subTitleColor2))
                            .multilineTextAlignment(.leading)
                            .padding(.top, Dimen.margin.micro)
                    }
                    if let subTitle = data.subTitle3 {
                        Text(subTitle)
                            .modifier(MediumTextStyle(size: Font.size.thinExtra, color:data.subTitleColor3))
                            .multilineTextAlignment(.leading)
                            .padding(.top, Dimen.margin.micro)
                    }
                    
                }
                .padding(.horizontal, Dimen.margin.thin)
                .padding(.bottom, isHorizontal ? TopBanner.maginBottomLogoHorizontal : TopBanner.maginBottomLogo)
            } else {
                VStack(spacing:0){
                    Spacer()
                    if let logo = data.logo {
                        KFImage(URL(string: logo))
                            .resizable()
                            .cancelOnDisappear(true)
                            .aspectRatio(contentMode: .fit)
                            .frame(
                                minWidth: 0,
                                idealWidth: 150,
                                maxWidth: 280,
                                minHeight: 0,
                                idealHeight: 60,
                                maxHeight: 80, alignment:.bottom)
                            
                            .padding(.horizontal, Dimen.margin.heavy)
                    } else if data.title != nil {
                        Text(data.title!)
                            .modifier(BlackTextStyle(size: Font.size.black) )
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Dimen.margin.heavy)
                    }
                    if let subTitle = data.subTitle1 {
                        Text(subTitle)
                            .kerning(Font.kern.thin)
                            .modifier(MediumTextStyle(size: Font.size.light, color:data.subTitleColor1))
                            .multilineTextAlignment(.center)
                            .padding(.top, Dimen.margin.regular)
                            .padding(.horizontal, Dimen.margin.thin)
                    }
                    if let subTitle = data.subTitle2 {
                        Text(subTitle)
                            .kerning(Font.kern.thin)
                            .modifier(MediumTextStyle(size: Font.size.light, color:data.subTitleColor2))
                            .multilineTextAlignment(.center)
                            .padding(.top, Dimen.margin.tinyExtra)
                            .padding(.horizontal, Dimen.margin.thin)
                    }
                    if let subTitle = data.subTitle3 {
                        Text(subTitle)
                            .kerning(Font.kern.thin)
                            .modifier(MediumTextStyle(size: Font.size.light, color:data.subTitleColor3))
                            .multilineTextAlignment(.center)
                            .padding(.top, Dimen.margin.tinyExtra)
                            .padding(.horizontal, Dimen.margin.thin)
                    }
                }
                .padding(.bottom,  TopBanner.maginBottomLogo)
                .modifier(MatchParent())
            }
            
           
        }
        .modifier(MatchHorizontal(height: isHorizontal ? TopBanner.imageHeightHorizontal : TopBanner.imageHeight))
        .onReceive(self.sceneObserver.$isUpdated) { update in
            if !update {return}
            if !SystemEnvironment.isTablet {return}
            self.isHorizontal = self.sceneObserver.sceneOrientation == .landscape
        }
        .onAppear(){
            if SystemEnvironment.isTablet {
                self.isHorizontal = self.sceneObserver.sceneOrientation == .landscape
            }
        }
    }
}


