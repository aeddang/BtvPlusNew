//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine

extension PlayerBottomBody {
    static let nextBtnSize:CGFloat = SystemEnvironment.isTablet ? 136 : 80
    static let nextBtnSizeFullScreen:CGFloat = SystemEnvironment.isTablet ? 142 : 91
    
    static let seasonBtnSize:CGFloat = SystemEnvironment.isTablet ? 161 : 96
    static let seasonBtnSizeFullScreen:CGFloat = SystemEnvironment.isTablet ? 172 : 105
}
struct PlayerBottomBody: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: BtvPlayerModel = BtvPlayerModel()
    
    var isFullScreen:Bool = false
    var isUiShowing:Bool = false
    var isPlaying:Bool = false
    var showDirectview = false
    var showPreplay = false
    var showCookie:String? = nil
    var showNext = false
    var showNextCancel = false
    var nextProgress:Float = 0.0
    var nextBtnTitle:String = ""
    var isSeasonNext:Bool = false
     
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
                            //self.viewModel.btvUiEvent = .clickInsideButton(.clickInsideSkipIntro , String.player.continueView)
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
                if let cookie = self.showCookie {
                    RectButton(
                        text: String.player.cookie,
                        textTrailing: cookie
                        ){_ in
                        
                        self.viewModel.btvPlayerEvent = .cookieView
                        //self.viewModel.btvUiEvent = .clickInsideButton(.clickInsideSkipIntro , String.player.cookie)
                    }
                }
                
                if self.showNext{
                    if self.showNextCancel {
                        RectButton(
                            text: String.player.continuePlay
                            ){_ in
                            //self.viewModel.btvUiEvent = .clickInsideButton(.clickInsideSkipIntro , String.player.directPlay)
                            self.viewModel.btvPlayerEvent = .nextViewCancel
                        }
                    }
                    RectButton(
                        text: self.nextBtnTitle,
                        fixSize: self.isSeasonNext
                        ? (self.isFullScreen ? Self.seasonBtnSizeFullScreen : Self.seasonBtnSize)
                        : (self.isFullScreen ? Self.nextBtnSizeFullScreen : Self.nextBtnSize),
                        progress: self.nextProgress,
                        padding: 0,
                        icon: Asset.icon.play
                        ){_ in
                        
                        self.viewModel.btvUiEvent = .clickInsideButton(.clickInsideSkipIntro , self.nextBtnTitle)
                        self.viewModel.btvPlayerEvent = .nextView(isAuto:false)
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
        
        .opacity(!self.isUiShowing && self.showPreplay ? 0.0 : 1.0)
    }//body
}


