//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine
extension PlayerTopBody{
    static let strokeButtonText = TextModifier(
        family: Font.family.bold,
        size: Font.size.tinyExtra,
        color: Color.app.greyLight,
        activeColor: Color.app.white
    )
    static let strokeButtonTextFull = TextModifier(
        family: Font.family.bold,
        size: Font.size.thinExtra,
        color: Color.app.greyLight,
        activeColor: Color.app.white
    )
    
    
}


struct PlayerTopBody: PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    var title:String? = nil
    
    var isFullScreen:Bool = false
    var isShowing:Bool = false
    var isMute:Bool = false
    var isLock:Bool = false
    var isPreroll:Bool = false
    var textQuality:String? = nil
    var textRate:String? = nil
    
    var body: some View {
        VStack(
            alignment :.trailing,
            spacing:Dimen.margin.thin){
            HStack(spacing: self.isFullScreen ? PlayerUI.fullScreenSpacing : PlayerUI.spacing){
                if !self.isLock {
                    Button(action: {
                        self.viewModel.btvPlayerEvent = .close
                        
                    }) {
                        Image(Asset.icon.back)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.regular,
                                   height: Dimen.icon.regular)
                    }
                    .accessibility(label: Text( String.app.back))
                    if self.isFullScreen && self.title != nil {
                        VStack(alignment: .leading){
                            Text(self.title!)
                                .modifier(MediumTextStyle(
                                        size: Font.size.mediumExtra,
                                        color: Color.app.white)
                                )
                                .lineLimit(1)
                            Spacer().modifier(MatchHorizontal(height: 0))
                        }
                        .modifier(MatchHorizontal(height: Font.size.mediumExtra))
                    } else{
                        Spacer().modifier(MatchHorizontal(height: 0))
                    }
                    ImageButton(
                        defaultImage: Asset.player.volumeOn,
                        activeImage: Asset.player.volumeOff,
                        isSelected: self.isMute,
                        size: CGSize(width:Dimen.icon.regular,height:Dimen.icon.regular)
                    ){ _ in
                        self.viewModel.event = .mute(!self.isMute, isUser: true)
                        self.viewModel.btvLogEvent = .clickConfigButton(.clickVodConfig, config: "mute")
                        
                        if self.isMute {
                            if self.viewModel.volume == 0 {
                                self.viewModel.event = .volume(0.5, isUser: true)
                            }else{
                                self.viewModel.event = .mute(false, isUser: true)
                            }
                        } else {
                            self.viewModel.event = .mute(true, isUser: true)
                        }
                    }
                    .accessibility(label: Text( self.isMute ? String.player.muteOff : String.player.muteOn))
                    .fixedSize()
                   
                    if self.textQuality != nil {
                        StrokeRectButton(
                            text: self.textQuality!,
                            isSelected: false,
                            textModifier: self.isFullScreen ? Self.strokeButtonTextFull :  Self.strokeButtonText,
                            size: self.isFullScreen ? Dimen.button.regularRect : Dimen.button.lightRect
                            ){ _ in
                            
                            self.viewModel.btvLogEvent = .clickConfigButton(.clickVodConfig, config: "resolution")
                            self.viewModel.selectFunctionType = .quality
                        }
                        .accessibility(label: Text(String.player.qulitySelect))
                    }
                    if self.textRate != nil {
                        StrokeRectButton(
                            text: self.textRate!,
                            isSelected: false,
                            textModifier: self.isFullScreen ? Self.strokeButtonTextFull :  Self.strokeButtonText,
                            size: self.isFullScreen ? Dimen.button.regularRect : Dimen.button.lightRect
                            ){ _ in
                            
                            self.viewModel.btvLogEvent = .clickConfigButton(.clickVodConfig, config: "speed")
                            self.viewModel.selectFunctionType = .rate
                            
                        }
                        .accessibility(label: Text(String.player.speedSelect))
                    }
                    
                } else {
                    Spacer().modifier(MatchHorizontal(height: 0))
                }
               
                ImageButton(
                    defaultImage: Asset.player.more,
                    activeImage: Asset.player.lock,
                    isSelected: self.isLock,
                    size: CGSize(width:Dimen.icon.light,height:Dimen.icon.light)
                ){ _ in
                    if self.isLock {
                        
                        self.viewModel.isLock = false
                    } else {
                        self.viewModel.btvLogEvent = .clickConfigButton(.clickVodConfig, config: "etc")
                        self.viewModel.btvUiEvent = .more
                    }
                }
                .accessibility(hidden: true)
            }
            PlayerMoreBox( viewModel: self.viewModel )
                    .accessibility(hidden: true)
            Spacer()
            
        }
    }//body
    
    
   
    
}


