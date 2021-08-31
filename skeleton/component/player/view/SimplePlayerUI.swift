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



struct SimplePlayerUI: PageComponent {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel:PlayerModel
    @ObservedObject var pageObservable:PageObservable
    
    @State var progress: Float = 0
    @State var isPlaying = false
    @State var isLoading = false
    @State var isSeeking = false
    @State var isError = false
    @State var errorMessage = ""
    @State var useFullScreen:Bool = true
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
            .opacity(self.isShowing ? 1 : 0)
            
            if self.isLoading {
                CircularSpinner(resorce: Asset.ani.loading)
            }
            /*
            ActivityIndicator( isAnimating: self.$isLoading,
                               style: .large,
                               color: Color.app.white )
            */
            VStack(spacing:0){
                Spacer()
                HStack(alignment:.center, spacing:Dimen.margin.thin){
                    Spacer()
                    if self.useFullScreen {
                        ImageButton(
                            defaultImage: Asset.player.fullScreen,
                            activeImage: Asset.player.fullScreenOff,
                            isSelected: self.isFullScreen,
                            size: CGSize(width:Dimen.icon.regular,height:Dimen.icon.regular)
                        ){ _ in
                            if self.viewModel.useFullScreenAction {
                                let changeOrientation:UIInterfaceOrientationMask = SystemEnvironment.isTablet
                                ? (self.sceneObserver.sceneOrientation == .portrait ? .portrait :.landscape)
                                : (self.isFullScreen ? .portrait : .landscape)
                                
                                self.isFullScreen
                                    ? self.pagePresenter.fullScreenExit(changeOrientation: changeOrientation)
                                    : self.pagePresenter.fullScreenEnter()
                            } else{
                                self.viewModel.event = .fullScreen(!self.isFullScreen)
                            }
                        }
                    }
                }
                .padding(.all, self.isFullScreen ? PlayerUI.paddingFullScreen : PlayerUI.padding)
                .opacity(self.isShowing  ? 1 : 0)
                ProgressSlider(
                    progress: self.progress,
                    thumbSize: self.isFullScreen
                        ? Dimen.icon.thinExtra
                        : 0,
                        
                    onChange: { pct in
                        let willTime = self.viewModel.duration * Double(pct)
                        self.viewModel.event = .seeking(willTime)
                    },
                    onChanged:{ pct in
                        self.viewModel.event = .seekProgress(pct)
                    })
                    .frame(height: self.isFullScreen
                            ? PlayerUI.uiHeightFullScreen
                            : Dimen.stroke.regular )
                .padding(.all, self.isFullScreen
                         ? PlayerUI.paddingFullScreen
                         : 0)
            }
            
            
            if !self.isSeeking {
                VStack(spacing:Dimen.margin.regular){
                    ImageButton(
                        defaultImage: Asset.icon.thumbPlay,
                        activeImage: Asset.player.pause,
                        isSelected: self.isPlaying,
                        size: CGSize(width:Dimen.icon.heavyExtra,height:Dimen.icon.heavyExtra)
                    ){ _ in
                        self.viewModel.isUserPlay = self.isPlaying ? false  : true
                        self.viewModel.event = .togglePlay
                        ComponentLog.d("BtvPlayerModel isUserPlay set " + self.viewModel.isUserPlay.description  , tag: self.tag)
                    }
                    if self.isFullScreen && ( self.viewModel.playInfo != nil ) && !self.isPlaying {
                        Text(self.viewModel.playInfo!)
                            .modifier(BoldTextStyle(size: Font.size.lightExtra, color: Color.app.white))
                    }
                }
                .opacity( (self.isShowing && !self.isLoading  && !self.viewModel.isLock) ? 1 : 0 )
            }
        }
       //.toast(isShowing: self.$isError, text: self.errorMessage)
        .onReceive(self.viewModel.$time) { tm in
            if self.viewModel.duration <= 0 {return}
            if !self.isSeeking {
                self.progress = Float(self.viewModel.time / max(self.viewModel.duration,1))
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
                    if self.viewModel.streamStatus == .buffering(0) { withAnimation{self.isLoading = true} }
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
            default : do{}
            }
        }
        .onReceive(self.viewModel.$streamEvent) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .seeked: withAnimation{
                self.isSeeking = false
            }
            default : break
            }
        }
        .onReceive(self.viewModel.$playerStatus) { st in
            //guard let status = st else { return }
        }
        .onReceive(self.viewModel.$streamStatus) { st in
            guard let status = st else { return }
            switch status {
            case .buffering(_) :
                if self.viewModel.playerUiStatus == .hidden{ self.isLoading = true }
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
            case .drm(let e) : self.errorMessage = "drm " + e.getDescription()
            case .asset(let e) : self.errorMessage = "asset " + e.getDescription() 
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
            self.useFullScreen = self.viewModel.useFullScreenButton
        }
    }
    

}

