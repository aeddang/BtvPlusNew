//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine


struct PlayerBottomBody: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: BtvPlayerModel = BtvPlayerModel()
    
    var isFullScreen:Bool = false
    var isUiShowing:Bool = false
    var isPlaying:Bool = false
    var showDirectview = false
    var showPreplay = false
    var showPreview = false
    
    var showNext = false
    var nextProgress:Float = 0.0
    var nextBtnTitle:String = ""
    var nextBtnSize:CGFloat = 0
     
    var body: some View {
        
        VStack(alignment :.trailing, spacing:0){
            Spacer()
            HStack(spacing:self.isFullScreen ? PlayerUI.fullScreenSpacing : PlayerUI.spacing){
                Spacer()
                if self.showDirectview {
                    RectButton(
                        text: String.player.directPlay
                        ){_ in
                        self.viewModel.btvUiEvent = .clickInsideButton(.clickInsideSkipIntro , String.player.directPlay)
                        self.viewModel.event = .seekTime(self.viewModel.openingTime, true)
                    }
                }
                if self.showPreplay {
                    if self.isFullScreen {
                        if self.isPlaying {
                            if let limited = self.viewModel.limitedDuration {
                                Text(limited.secToMin())
                                    .font(.custom(
                                            Font.family.bold,
                                            size: Font.size.thin ))
                                    .foregroundColor(Color.app.white)
                                    
                                + Text(String.app.min + " " + String.player.preplay)
                                    .font(.custom(
                                            Font.family.bold,
                                            size:  Font.size.thin))
                                        .foregroundColor(Color.app.white)
                            } else if let info = self.viewModel.playInfo{
                                Text(info)
                                    .modifier(BoldTextStyle(
                                                size:  Font.size.thin,
                                                color: Color.app.white))
                            }
                        }
                        RectButton(
                            text: String.player.continueView,
                            icon: Asset.icon.play
                            ){_ in
                            self.viewModel.btvUiEvent = .clickInsideButton(.clickInsideSkipIntro , String.player.continueView)
                            self.viewModel.btvPlayerEvent = .continueView
                        }
                    }else{
                        if let limited = self.viewModel.limitedDuration {
                            Text(limited.secToMin())
                                .font(.custom(
                                        Font.family.bold,
                                        size: Font.size.thin ))
                                .foregroundColor(Color.app.white)
                                
                            + Text(String.app.min + " " + String.player.preplay)
                                .font(.custom(
                                        Font.family.bold,
                                        size:  Font.size.thin))
                                .foregroundColor(Color.app.white)
                        } else if let info = self.viewModel.playInfo{
                            Text(info)
                                .modifier(BoldTextStyle(
                                            size:  Font.size.thin,
                                            color: Color.app.white))
                        }
                    }
                }
                if self.showPreview {
                    RectButton(
                        text: String.player.cookie,
                        textTrailing: self.viewModel.synopsisPlayerData?.previewCount ?? ""
                        ){_ in
                        
                        self.viewModel.btvUiEvent = .clickInsideButton(.clickInsideSkipIntro , String.player.cookie)
                    }
                }
                
                if self.showNext{
                    RectButton(
                        text: self.nextBtnTitle,
                        fixSize: self.nextBtnSize,
                        progress: self.nextProgress,
                        padding: 0,
                        icon: Asset.icon.play
                        ){_ in
                        
                        self.viewModel.btvUiEvent = .clickInsideButton(.clickInsideSkipIntro , self.nextBtnTitle)
                        self.viewModel.btvPlayerEvent = .nextView
                    }
                }
            }
        }
        .padding(.bottom,
                 self.isUiShowing
                    ? self.isFullScreen
                        ? PlayerUI.uiRealHeightFullScreen : PlayerUI.uiRealHeight
                    : 0
                 )
        
        .opacity(self.isUiShowing ? 1.0 : 0.0)
    }//body
}


