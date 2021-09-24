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
    var isRecovery:Bool
    var isPlay:Bool = false
    var isLoading:Bool = false
    var action:()->Void
    
    var body: some View {
        ZStack{
            if self.isSelected && !self.isRecovery{
                SimplePlayer(
                    pageObservable:self.pageObservable,
                    viewModel:self.playerModel
                )
                .modifier(MatchParent())
                
            }
            if !self.isPlay || !self.isSelected || self.isLoading || self.isRecovery {
                if self.data.image == nil {
                    Image(Asset.noImg16_9)
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                } else {
                    KFImage(URL(string: self.data.image!))
                        .resizable()
                        .placeholder {
                            Image(Asset.noImg16_9)
                                .resizable()
                        }
                        .cancelOnDisappear(true)
                        .aspectRatio(contentMode: .fill)
                        .modifier(MatchParent())
                }
                
                if (self.isLoading || self.isRecovery) && self.isSelected{
                    CircularSpinner(resorce: Asset.ani.loading)
                } else {
                    Button(action: {
                        self.data.reset()
                        self.action()
                    }) {
                        Image(Asset.icon.thumbPlay)
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.heavyExtra, height: Dimen.icon.heavyExtra)
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
                        .frame(width: Dimen.icon.tiny, height: Dimen.icon.tiny)
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
            Text(self.data.fullTitle)
                .modifier(BoldTextStyle(
                        size: Font.size.regular,
                            color: Color.app.white)
                )
                .lineLimit(2)
                .padding(.top, SystemEnvironment.isTablet ? Dimen.margin.tiny : Dimen.margin.light)
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
    var data:PlayData
    var isInit:Bool
    @Binding var isLike:LikeStatus?
    @Binding var isAlram:Bool?
  
    var body: some View {
        if self.data.srisId != nil && self.isInit {
            LikeButton(srisId: self.data.srisId!, isLike: self.$isLike, useText:false, isThin:true){ value in
                self.data.isLike = value
            }
            .buttonStyle(BorderlessButtonStyle())
            if self.data.notificationData != nil {
                AlramButton(data: self.data.notificationData!, isAlram: self.$isAlram){ value in
                    self.data.isAlram = value 
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
    }
}