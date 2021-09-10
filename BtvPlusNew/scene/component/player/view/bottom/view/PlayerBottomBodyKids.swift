//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine



struct PlayerBottomBodyKids: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    var viewModel: BtvPlayerModel = BtvPlayerModel()
    var isFullScreen:Bool = false
    var isUiShowing:Bool = false
    var isPlaying:Bool = false
    var showPreplay = false
    var isLock:Bool = false
    var body: some View {
        
        VStack(alignment :.trailing, spacing:0){
            Spacer()
            HStack(spacing:self.isFullScreen ? KidsPlayerUI.fullScreenSpacing : KidsPlayerUI.spacing){
                Spacer()
                
                if self.showPreplay {
                    if self.isFullScreen {
                        if self.isPlaying {
                            if let limited = self.viewModel.limitedDuration {
                                Text(limited.secToMin())
                                    .font(.custom(
                                            Font.familyKids.bold,
                                            size:  Font.sizeKids.lightExtra ))
                                    .foregroundColor(Color.app.white)
                                    
                                + Text(String.app.min + " " + String.player.preplay)
                                    .font(.custom(
                                            Font.familyKids.bold,
                                            size:  Font.sizeKids.lightExtra ))
                                        .foregroundColor(Color.app.white)
                            } else if let info = self.viewModel.playInfo{
                                Text(info)
                                    .modifier(BoldTextStyleKids(
                                                size:  Font.sizeKids.lightExtra ,
                                                color: Color.app.white))
                            }
                        }
                        RectButtonKids(
                            text: String.player.continueView,
                            trailIcon: AssetKids.icon.play,
                            size : DimenKids.button.mediumRectExtra,
                            trailIconSize: DimenKids.icon.microUltra
                            ){_ in
                            self.viewModel.btvUiEvent = .clickInsideButton(.clickInsideSkipIntro , String.player.continueView)
                            self.viewModel.btvPlayerEvent = .continueView
                        }
                    }else {
                        if let limited = self.viewModel.limitedDuration {
                            Text(limited.secToMin())
                                .font(.custom(
                                        Font.familyKids.bold,
                                        size:  Font.sizeKids.tiny ))
                                .foregroundColor(Color.app.white)
                                
                            + Text(String.app.min + " " + String.player.preplay)
                                .font(.custom(
                                        Font.familyKids.bold,
                                        size:  Font.sizeKids.tiny ))
                                    .foregroundColor(Color.app.white)
                        } else if let info = self.viewModel.playInfo{
                            Text(info)
                                .modifier(BoldTextStyleKids(
                                            size:  Font.sizeKids.tiny,
                                            color: Color.app.white))
                        }
                    }
                }
            }
        }
        .padding(.bottom,
                 self.isUiShowing && !self.isLock
                    ? self.isFullScreen
                        ? KidsPlayerUI.uiHeightFullScreen : KidsPlayerUI.uiHeight
                    : 0
                 )
        .opacity(self.isUiShowing ? 1.0 : 0)
        
        
    }//body
}


