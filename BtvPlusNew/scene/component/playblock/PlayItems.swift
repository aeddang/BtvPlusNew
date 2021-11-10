//
//  PlayItem.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/20.
//

import Foundation
import SwiftUI
import Combine
import struct Kingfisher.KFImage

struct PlayItemScreen: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var setup:Setup
    @ObservedObject var pageObservable:PageObservable
    @ObservedObject var playerModel: BtvPlayerModel
    var data:PlayData
    var isSelected:Bool
    var isPlay:Bool = false
    var isLoading:Bool = false
    var action:()->Void
    
    var body: some View {
        ZStack{
            if self.isSelected {
                SimplePlayer(
                    pageObservable:self.pageObservable,
                    viewModel:self.playerModel
                )
                .modifier(MatchParent())
                
            }
            if !self.isPlay || !self.isSelected || self.isLoading  {
                if self.data.image == nil {
                    Image(Asset.noImg16_9)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .modifier(MatchParent())
                } else {
                    KFImage(URL(string: self.data.image!))
                        .resizable()
                        .placeholder {
                            Image(Asset.noImg16_9)
                                .resizable()
                        }
                        .cancelOnDisappear(true)
                        .modifier(MatchParent())
                }
                
                if let time = self.data.durationTime {
                    ZStack(alignment:.bottomTrailing){
                        Spacer().modifier(MatchParent())
                        Text(time)
                            .modifier(BoldTextStyle(size: Font.size.tiny))
                            .lineLimit(1)
                            .padding(.horizontal, Dimen.margin.micro)
                            .padding(.top, Dimen.margin.micro)
                            .padding(.bottom, Dimen.margin.microExtra)
                            .background(Color.transparent.black70)
                            .clipShape(RoundedRectangle(cornerRadius: Dimen.radius.thin))
                            .padding(.all, Dimen.margin.microUltra)
                    }
                    .modifier(MatchParent())
                }
                
                if self.isLoading && self.isSelected{
                    CircularSpinner(resorce: Asset.ani.loading)
                } else {
                    Button(action: {
                        self.data.reset()
                        self.action()
                    }) {
                        Image(Asset.player.releasePlay)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(
                                width:Dimen.icon.medium,
                                height:Dimen.icon.medium)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            
        }
    }
}




struct PlayItemInfo: PageView {
    var data:PlayData
    var body: some View {
        if !data.isClip {
            HStack(spacing: SystemEnvironment.isTablet ? Dimen.margin.tiny : Dimen.margin.thin){
                if self.data.date != nil {
                    Text(self.data.date!)
                        .modifier(MediumTextStyle(
                                size: Font.size.lightExtra,
                                color: Color.brand.primary)
                        )
                        .lineLimit(1)
                }
                if let icon = data.ppmIcon {
                    KFImage(URL(string: icon))
                        .resizable()
                        .cancelOnDisappear(true)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: Dimen.icon.tinyUltra)
                    
                }else if self.data.provider != nil {
                    Text(self.data.provider!)
                        .modifier(BoldTextStyle(
                                size: Font.size.lightExtra,
                                    color: Color.app.white)
                        )
                        .lineLimit(1)
                }
                if self.data.restrictAgeIcon != nil {
                    Image( self.data.restrictAgeIcon! )
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.thinExtra, height: Dimen.icon.thinExtra)
                        .padding(.top, -Dimen.margin.microExtra)
                        .padding(.leading, -Dimen.margin.microUltra)
                }
                
            }
            .padding(.top, SystemEnvironment.isTablet ? Dimen.margin.tiny : Dimen.margin.light)
            if let summary = self.data.summary {
                Text(summary)
                    .modifier(MediumTextStyle(size: Font.size.thin, color: Color.app.greyMedium))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .padding(.top, Dimen.margin.thin)
            }
        } else {
            Spacer().modifier(MatchHorizontal(height: 0))
            Text(self.data.fullTitle)
                .modifier(BoldTextStyle(
                        size: Font.size.regular,
                            color: Color.app.white)
                )
                .lineLimit(2)
               
            if let subTitle = self.data.subTitle {
                Text(subTitle)
                    .modifier(MediumTextStyle(
                            size: Font.size.lightExtra,
                            color: Color.brand.primary)
                    )
                    .lineLimit(1)
                    .padding(.top, SystemEnvironment.isTablet ? Dimen.margin.tinyExtra : Dimen.margin.thinExtra)
            }
        }
        
    }
}

struct PlayItemFunction: PageView {
    var viewModel:PlayBlockModel
    var data:PlayData
    var isInit:Bool
    @Binding var isLike:LikeStatus?
    @Binding var isAlram:Bool?
  
    var body: some View {
        if self.data.srisId != nil && self.isInit {
            LikeButton(
                playBlockModel:self.viewModel,
                playData: data,
                srisId: self.data.srisId!, isLike: self.$isLike, useText:false, isThin:true, isPreview: true){ value in
                self.data.isLike = value
            }
            .buttonStyle(BorderlessButtonStyle())
            if self.data.notificationData != nil {
                AlramButton(
                    playBlockModel:self.viewModel,
                    playData: data,
                    data: self.data.notificationData!, isAlram: self.$isAlram){ value in
                    self.data.isAlram = value 
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
    }
}
