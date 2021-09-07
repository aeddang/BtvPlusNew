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
    
    static let uiHeight:CGFloat = SystemEnvironment.isTablet ? 64 : 40
    static let uiHeightFullScreen:CGFloat  = SystemEnvironment.isTablet ? 120 : 64
    
    static let uiRealHeight:CGFloat = SystemEnvironment.isTablet ? 65 : 45
    static let uiRealHeightFullScreen:CGFloat  = SystemEnvironment.isTablet ? 110 : 65
    
    static let spacing:CGFloat = DimenKids.margin.thin
    static let fullScreenSpacing:CGFloat = DimenKids.margin.light
    
    static let icon:CGSize = CGSize(width:DimenKids.icon.thinExtra,height:Dimen.icon.thinExtra)
    static let iconFullScreen:CGSize = CGSize(width:DimenKids.icon.regular,height:Dimen.icon.regular)
    
    static let timeText:CGFloat = Font.sizeKids.microUltra
    static let timeTextFullScreen:CGFloat = Font.sizeKids.thin
}

struct KidsPlayerUI: PageComponent {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel:PlayerModel
    @ObservedObject var pageObservable:PageObservable
    @State var time:String = "00:00:00"
    @State var duration:String = "00:00:00"
    @State var completeTime:String = "00:00:00"
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
                        
            if self.isLoading {
                CircularSpinner(resorce: Asset.ani.loading)
            }
            
            VStack(alignment:.leading, spacing:0){
                Spacer().modifier(MatchParent())
                if self.showReplay {
                    Text(String.player.replay)
                        .kerning(Font.kern.thin)
                        .modifier(BoldTextStyleKids(size: Font.sizeKids.thin, color: Color.app.white))
                        .padding(.vertical, DimenKids.margin.thinExtra)
                        .padding(.horizontal, DimenKids.margin.regular)
                        .background(Color.app.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.regularUltra))
                        .padding(.leading, self.isFullScreen ? Self.paddingFullScreen : Self.padding)
                }
                HStack(alignment:.center, spacing:0){
                    ImageButton(
                        defaultImage: AssetKids.player.replay,
                        size: self.isFullScreen ? Self.iconFullScreen : Self.icon,
                        padding: Self.spacing
                    ){ _ in
                        
                        self.viewModel.isReplay.toggle()
                        
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .padding(.leading, -Self.spacing/2)
                    .opacity(self.isReplay ? 1 : 0.6)
                    ZStack(alignment:.bottom){
                        HStack(alignment:.center, spacing:Dimen.margin.thin){
                            Text(self.time)
                                .kerning(Font.kern.thin)
                                .modifier(BoldTextStyleKids(size: self.isFullScreen ? Self.timeTextFullScreen : Self.timeText, color: Color.app.white))
                                .fixedSize(horizontal: true, vertical: false)
                            
                            Spacer()
                            Text(self.completeTime)
                                .modifier(BoldTextStyleKids(size: self.isFullScreen ? Self.timeTextFullScreen : Self.timeText, color: Color.app.greyLightExtra))
                                .fixedSize(horizontal: true, vertical: false)

                        }
                        ProgressSlider(
                            progress: self.progress,
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
                            .frame(height:self.isFullScreen ? Self.uiHeightFullScreen :  Self.uiHeight)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                   
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
                    .padding(.trailing, -Self.spacing/2)
                }
                .frame(height: self.isFullScreen ? Self.uiHeightFullScreen : Self.uiHeight)
                .padding(.bottom, self.isFullScreen ? Self.paddingFullScreen : Self.padding)
                .padding(.horizontal, self.isFullScreen ? Self.paddingFullScreen : Self.padding)
                .opacity(self.isShowing && !self.viewModel.isLock ? 1 : 0)
            }
            
            
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
                        self.viewModel.isUserPlay = self.isPlaying ? false  : true
                        self.viewModel.event = .togglePlay
                        ComponentLog.d("BtvPlayerModel isUserPlay set " + self.viewModel.isUserPlay.description  , tag: self.tag)
                    }
                    .opacity(self.isLoading ? 0 : 1)
                    if self.isFullScreen && ( self.viewModel.playInfo != nil ) && !self.isPlaying {
                        if let limited = self.viewModel.limitedDuration {
                            Text(limited.secToMin())
                                .font(.custom(
                                        Font.familyKids.bold,
                                        size: self.isFullScreen ? Font.sizeKids.medium : Font.sizeKids.tiny))
                                .foregroundColor(Color.app.white)
                                
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
        //.toast(isShowing: self.$isError, text: self.errorMessage)
        .onReceive(self.viewModel.$time) { tm in
            if self.viewModel.duration <= 0 {return}
            self.time = tm.secToHourString()
            self.completeTime = (self.viewModel.duration - tm).secToHourString()
            if !self.isSeeking {
                self.progress = Float(self.viewModel.time / max(self.viewModel.duration,1))
            }
        }
        .onReceive(self.viewModel.$duration) { tm in
            self.duration = tm.secToHourString()
        }
        .onReceive(self.viewModel.$isReplay) { isReplay in
            self.isReplay = isReplay
            if isReplay {
                self.showReplayStart()
            } else {
                self.showReplayCancel()
            }
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
                default :
                    self.isShowing = false
                    if self.viewModel.streamStatus == .buffering(0) { self.isLoading = true }
                }
            }
        }
        .onReceive(self.viewModel.$event) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .seeking(let willTime):
                self.progress = Float(willTime / max(self.viewModel.duration,1))
                if !self.isSeeking {
                    withAnimation{ self.isSeeking = true }
                }
            default : break
            }
        }
        .onReceive(self.viewModel.$streamEvent) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .seeked: withAnimation{self.isSeeking = false}
            default : break
            }
        }
        .onReceive(self.viewModel.$streamStatus) { st in
            guard let status = st else { return }
            switch status {
            case .buffering(_) : withAnimation{self.isLoading = true}
            default :  withAnimation{self.isLoading = false}
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
            case .drm(let e): self.errorMessage = "drm " + e.getDescription()
            case .asset(let e): self.errorMessage = "asset " + e.getDescription()
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
        .onDisappear(){
            self.showReplayCancel()
        }
    }
    @State private var isReplay:Bool = false
    @State private var showReplay:Bool = false
    @State private var showReplayTimer:AnyCancellable?
    private func showReplayStart(){
        withAnimation{
            self.showReplay = true
        }
        self.showReplayTimer?.cancel()
        self.showReplayTimer = Timer.publish(
            every: 2, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.showReplayCancel()
            }
    }
    private func showReplayCancel(){
        self.showReplayTimer?.cancel()
        self.showReplayTimer = nil
        withAnimation{
            self.showReplay = false
        }
    }

}

