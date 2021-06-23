//
//  PlayerUI.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/29.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

extension KidsPlayerUI {
    static let padding = SystemEnvironment.isTablet ? DimenKids.margin.regularExtra : DimenKids.margin.lightExtra
    static let paddingFullScreen = DimenKids.margin.regular
    
    static let uiHeight:CGFloat = SystemEnvironment.isTablet ? 74 : 54
    static let uiHeightFullScreen:CGFloat  = SystemEnvironment.isTablet ? 120 : 74
    
    static let spacing:CGFloat = DimenKids.margin.thin
    static let fullScreenSpacing:CGFloat = DimenKids.margin.light
    
    static let icon:CGSize = CGSize(width:DimenKids.icon.tiny,height:Dimen.icon.tiny)
    static let iconFullScreen:CGSize = CGSize(width:DimenKids.icon.regular,height:Dimen.icon.regular)
    
    static let timeText:CGFloat = Font.sizeKids.micro
    static let timeTextFullScreen:CGFloat = Font.sizeKids.thin
}

struct KidsPlayerUI: PageComponent {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel:PlayerModel
    @ObservedObject var pageObservable:PageObservable
    @State var time:String = ""
    @State var duration:String = ""
    @State var progress: Float = 0
    @State var isPlaying = false
    @State var isLoading = false
    @State var isSeeking = false
    @State var isError = false
    @State var errorMessage = ""
    
    @State var isFullScreen:Bool = false
    @State var isShowing: Bool = false
    var body: some View {
        ZStack{
            HStack(spacing:0){
                Spacer().modifier(MatchParent())
                    .background(Color.transparent.clearUi)
                    .onTapGesture(count: 2, perform: {
                        if self.viewModel.isLock { return }
                        self.viewModel.event = .seekBackword(self.viewModel.getSeekBackwordAmount(), false)
                    })
                    .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                        self.viewModel.playerUiStatus = .hidden
                    })
                    
                Spacer().modifier(MatchParent())
                    .background(Color.transparent.clearUi)
                    .onTapGesture(count: 2, perform: {
                        if self.viewModel.isLock { return }
                        self.viewModel.event = .seekForward(self.viewModel.getSeekForwardAmount(), false)
                    })
                    .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                        self.viewModel.playerUiStatus = .hidden
                    })
            }
            .background(Color.transparent.black45)
            .opacity(self.isShowing  ? 1 : 0)
                        
            ActivityIndicator( isAnimating: self.$isLoading,
                               style: .large,
                               color: Color.app.white )
            
            VStack{
                Spacer()
                
                HStack(alignment:.center, spacing:0){
                    ImageButton(
                        defaultImage: AssetKids.player.replay,
                        size: self.isFullScreen ? Self.iconFullScreen : Self.icon,
                        padding: Self.spacing
                        
                    ){ _ in
                        self.viewModel.event = .seekTime(0,true)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    VStack(spacing:DimenKids.margin.micro){
                        ProgressSlider(
                            progress: min(self.progress, 1.0),
                            progressHeight: self.isFullScreen ? DimenKids.stroke.heavy: DimenKids.stroke.medium,
                            thumbSize: self.isFullScreen ? DimenKids.icon.tinyExtra : DimenKids.icon.microExtra,
                            color:Color.kids.primary,
                            radius: self.isFullScreen ? DimenKids.radius.tiny :  DimenKids.radius.micro,
                            onChange: { pct in
                                let willTime = self.viewModel.duration * Double(pct)
                                self.viewModel.event = .seeking(willTime)
                            },
                            onChanged:{ pct in
                                self.viewModel.event = .seekProgress(pct)
                            })
                            .fixedSize(horizontal: false, vertical: true)
                        HStack(alignment:.center, spacing:Dimen.margin.thin){
                            Text(self.time)
                                .kerning(Font.kern.thin)
                                .modifier(BoldTextStyleKids(size: self.isFullScreen ? Self.timeTextFullScreen : Self.timeText, color: Color.app.white))
                                .fixedSize(horizontal: true, vertical: false)
                            
                            Spacer()
                            Text(self.duration)
                                .modifier(BoldTextStyleKids(size: self.isFullScreen ? Self.timeTextFullScreen : Self.timeText, color: Color.app.greyLightExtra))
                                .fixedSize(horizontal: true, vertical: false)

                        }
                    }
                    .padding(.top, self.isFullScreen ? Self.timeTextFullScreen : Self.timeText )
                    ImageButton(
                        defaultImage: AssetKids.player.fullScreen,
                        activeImage: AssetKids.player.fullScreenOff,
                        isSelected: self.isFullScreen,
                        size: self.isFullScreen ? Self.iconFullScreen : Self.icon,
                        padding: Self.spacing
                    ){ _ in
                        if self.viewModel.useFullScreenAction {
                            self.isFullScreen
                                ? self.pagePresenter.fullScreenExit(changeOrientation: nil)
                                : self.pagePresenter.fullScreenEnter(changeOrientation: nil)
                        } else{
                            self.viewModel.event = .fullScreen(!self.isFullScreen)
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .frame(height: self.isFullScreen ? Self.uiHeightFullScreen : Self.uiHeight)
                .padding(.all, self.isFullScreen ? Self.paddingFullScreen : Self.padding)
            }
            .opacity(self.isShowing && !self.viewModel.isLock ? 1 : 0)
            
            if !self.isSeeking {
                VStack(spacing:DimenKids.margin.regular){
                    ImageButton(
                        defaultImage: AssetKids.player.resume,
                        activeImage: AssetKids.player.pause,
                        isSelected: self.isPlaying,
                        size: self.isFullScreen
                        ? CGSize(width:DimenKids.icon.heavy,height:DimenKids.icon.heavy)
                        : CGSize(width:DimenKids.icon.medium,height:DimenKids.icon.medium)
                    ){ _ in
                        self.viewModel.event = .togglePlay
                    }
                    if self.isFullScreen && ( self.viewModel.playInfo != nil ) && !self.isPlaying {
                        if let limited = self.viewModel.limitedDuration {
                            Text(limited.secToMin())
                                .font(.custom(
                                        Font.familyKids.bold,
                                        size: self.isFullScreen ? Font.sizeKids.medium : Font.sizeKids.tiny))
                                .foregroundColor(Color.kids.primary)
                                
                            + Text( String.app.min + " " + String.player.preplaying)
                                .font(.custom(
                                        Font.familyKids.bold,
                                        size: self.isFullScreen ? Font.sizeKids.medium : Font.sizeKids.tiny))
                                    .foregroundColor(Color.app.white)
                        } else if let info = self.viewModel.playInfo {
                            Text(info)
                                .modifier(BoldTextStyleKids(
                                            size: self.isFullScreen ? Font.sizeKids.medium : Font.sizeKids.tiny,
                                            color: Color.app.white))
                        }
                    }
                }
                .opacity( (self.isShowing && !self.isLoading  && !self.viewModel.isLock) ? 1 : 0 )
            }
        }
        .toast(isShowing: self.$isError, text: self.errorMessage)
        .onReceive(self.viewModel.$time) { tm in
            self.time = tm.secToHourString()
            if self.viewModel.duration <= 0.0 {return}
            if !self.isSeeking {
                self.progress = Float(self.viewModel.time / self.viewModel.duration)
            }
        }
        .onReceive(self.viewModel.$duration) { tm in
            self.duration = tm.secToHourString()
        }
        .onReceive(self.viewModel.$isPlay) { play in
            self.isPlaying = play
            if self.isPlaying {
                self.viewModel.playerUiStatus = .hidden
            }else {
                self.viewModel.playerUiStatus = .view
            }
        }
        .onReceive(self.viewModel.$playerUiStatus) { st in
            withAnimation{
                switch st {
                case .view :
                    self.isShowing = true
                default : self.isShowing = false
                }
            }
        }
        .onReceive(self.viewModel.$event) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .seeking(let willTime):
                self.progress = Float(willTime / self.viewModel.duration)
                if !self.isSeeking {
                    withAnimation{ self.isSeeking = true }
                }
            default : do{}
            }
        }
        .onReceive(self.viewModel.$streamEvent) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .seeked: withAnimation{
                self.isSeeking = false
            }
            default : do{}
            }
        }
        .onReceive(self.viewModel.$streamStatus) { st in
            guard let status = st else { return }
            switch status {
            case .buffering(_) : self.isLoading = true
            default : self.isLoading = false
            }
        }
        .onReceive(self.viewModel.$error) { err in
            guard let error = err else { return }
            ComponentLog.d("error " + err.debugDescription, tag: self.tag)
            self.isError = true
            self.viewModel.playerUiStatus = .view
            switch error{
            case .connect(_) : self.errorMessage = "connect error"
            case .illegalState(_) : self.errorMessage = "illegalState"
            case .stream(let e) :
                switch e {
                case .pip(let msg): self.errorMessage = msg
                case .playback(let msg): self.errorMessage = msg
                case .unknown(let msg): self.errorMessage = msg
                case .certification(let msg): self.errorMessage = msg
                }
            }
        }
        .onReceive(self.pagePresenter.$isFullScreen){fullScreen in
            self.isFullScreen = fullScreen
        }
        .onAppear{
            self.isFullScreen = self.pagePresenter.isFullScreen
        }
    }
    

}

