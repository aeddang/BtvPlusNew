//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine
extension PlayerTopBodyKids{
    static let lockTextSize:CGSize = SystemEnvironment.isTablet
        ? CGSize(width:198,height:48)
        : CGSize(width:103,height:25)
    static let lockTextSizeFull:CGSize = SystemEnvironment.isTablet
        ? CGSize(width:202,height:46)
        : CGSize(width:129,height:32)
}

struct PlayerTopBodyKids: PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    var title:String? = nil
    
    var isFullScreen:Bool = false
    var isShowing:Bool = false
    var isMute:Bool = false
    var isLock:Bool = false
    
    var body: some View {
        HStack(alignment: .top,  spacing: self.isFullScreen ? KidsPlayerUI.fullScreenSpacing : KidsPlayerUI.spacing){
            if !self.isLock {
                if self.isFullScreen {
                    Button(action: {
                        self.viewModel.btvPlayerEvent = .close
                        
                    }) {
                        Image(AssetKids.player.back)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: self.isFullScreen
                                    ? KidsPlayerUI.iconFullScreen.width : KidsPlayerUI.icon.width,
                                height: self.isFullScreen
                                    ? KidsPlayerUI.iconFullScreen.height : KidsPlayerUI.icon.height)
                    }
                }
                if self.isFullScreen, let title = self.title {
                    VStack(alignment: .leading){
                        Text(title)
                            .modifier(BoldTextStyleKids(
                                    size: Font.sizeKids.regular,
                                    color: Color.app.white)
                            )
                            .lineLimit(1)
                        Spacer().modifier(MatchHorizontal(height: 0))
                    }
                    .modifier(MatchHorizontal(height: Font.sizeKids.regular))
                    .padding(.top, SystemEnvironment.isTablet ? 0 : DimenKids.margin.thin)
                } else{
                    Spacer().modifier(MatchHorizontal(height: 0))
                }
            } else {
                Spacer().modifier(MatchHorizontal(height: 0))
            }
            PlayerMoreBoxKids( viewModel: self.viewModel, isLock:self.isLock )
                .offset(x: SystemEnvironment.isTablet ? DimenKids.margin.light : DimenKids.margin.thin)
            if self.showLockText {
                Image(AssetKids.player.lockText)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: self.isFullScreen
                            ? Self.lockTextSizeFull.width : Self.lockTextSize.width,
                        height: self.isFullScreen
                            ? Self.lockTextSizeFull.height : Self.lockTextSize.height)
                    .offset(x: DimenKids.margin.light)
            }
            VStack( spacing:0){
               
                ImageButton(
                    defaultImage: AssetKids.player.more,
                    activeImage: AssetKids.player.lock,
                    isSelected: self.isLock,
                    size: self.isFullScreen ? KidsPlayerUI.iconFullScreen : KidsPlayerUI.icon,
                    padding: self.isFullScreen ? KidsPlayerUI.fullScreenSpacing : KidsPlayerUI.spacing
                ){ _ in
                    if self.isLock {
                        self.viewModel.isLock = false
            
                    } else {
                        self.viewModel.btvUiEvent = .more
                    }
                }
                
                if !self.isLock {
                    ImageButton(
                        defaultImage: AssetKids.player.volumeOn,
                        activeImage: AssetKids.player.volumeOff,
                        isSelected: self.isMute,
                        size: self.isFullScreen ? KidsPlayerUI.iconFullScreen : KidsPlayerUI.icon,
                        padding: self.isFullScreen ? KidsPlayerUI.fullScreenSpacing : KidsPlayerUI.spacing
                    ){ _ in
                        
                        self.viewModel.event = .mute(!self.isMute)
                        
                        if self.isMute {
                            if self.viewModel.volume == 0 {
                                self.viewModel.event = .volume(0.5)
                            }else{
                                self.viewModel.event = .mute(false)
                            }
                        } else {
                            self.viewModel.event = .mute(true)
                        }
                    }
                    ImageButton(
                        defaultImage: AssetKids.player.lockOn,
                        size: self.isFullScreen ? KidsPlayerUI.iconFullScreen : KidsPlayerUI.icon,
                        padding: self.isFullScreen ? KidsPlayerUI.fullScreenSpacing : KidsPlayerUI.spacing
                    ){ _ in
                        self.viewModel.isLock = true
                    }
                }
                Spacer()
            }
        }
        .onReceive(self.viewModel.$isLock) { isLock in
            if isLock {
                self.showLockTextStart()
            } else {
                self.showLockTextCancel()
            }
        }
        .onDisappear{
            self.showLockTextCancel()
        }
    }//body

    @State private var showLockText:Bool = false
    @State private var showLockTextTimer:AnyCancellable?
    private func showLockTextStart(){
        withAnimation{
            self.showLockText = true
        }
        self.showLockTextTimer?.cancel()
        self.showLockTextTimer = Timer.publish(
            every: 5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.showLockTextCancel()
            }
    }
    private func showLockTextCancel(){
        self.showLockTextTimer?.cancel()
        self.showLockTextTimer = nil
        withAnimation{
            self.showLockText = false
        }
    }
}


