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

extension PlayerUI {
    static let padding = SystemEnvironment.isTablet ? Dimen.margin.thinExtra : Dimen.margin.thin
    static let paddingFullScreen = SystemEnvironment.isTablet ? Dimen.margin.lightExtra : Dimen.margin.regular
    
    static let uiHeight:CGFloat = SystemEnvironment.isTablet ? 62 : 48
    static let uiHeightFullScreen:CGFloat  = SystemEnvironment.isTablet ? 110 : 80
    
    static let uiRealHeight:CGFloat = SystemEnvironment.isTablet ? 52 : 34
    static let uiRealHeightFullScreen:CGFloat  = SystemEnvironment.isTablet ? 80 : 56
    
    static let timeTextWidth:CGFloat  = SystemEnvironment.isTablet ? 87 : 55
    
    static let spacing:CGFloat = SystemEnvironment.isTablet ? Dimen.margin.lightExtra : Dimen.margin.light
    static let fullScreenSpacing:CGFloat = SystemEnvironment.isTablet ? Dimen.margin.light : Dimen.margin.regular
}

struct PlayerUI: PageComponent {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel:PlayerModel
    @ObservedObject var pageObservable:PageObservable
    @State var time:String = "00:00:00"
    @State var completeTime:String = "00:00:00"
    @State var duration:String = "00:00:00"
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
                        self.viewModel.event = .seekBackword(self.viewModel.getSeekBackwordAmount(), isUser: true)
                    })
                    .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                        self.viewModel.playerUiStatus = .hidden
                    })
                    
                Spacer().modifier(MatchParent())
                    .background(Color.transparent.clearUi)
                    .onTapGesture(count: 2, perform: {
                        if self.viewModel.isLock { return }
                        self.viewModel.event = .seekForward(self.viewModel.getSeekForwardAmount(), isUser: true)
                    })
                    .onTapGesture(count: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/, perform: {
                        self.viewModel.playerUiStatus = .hidden
                    })
            }
            .background(Color.transparent.black45)
            .opacity(self.isShowing  ? 1 : 0)
            .accessibility(hidden: true)
            if self.isLoading {
                CircularSpinner(resorce: Asset.ani.loading)
            }
            
            VStack{
                Spacer()
                HStack(alignment:.center, spacing:Dimen.margin.thin){
                    Text(self.time)
                        .kerning(Font.kern.thin)
                        .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                        .frame(width:Self.timeTextWidth)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    ProgressSlider(
                        pageObservable: self.pageObservable, 
                        progress: self.progress,
                        thumbSize: self.isFullScreen ? Dimen.icon.thinExtra : Dimen.icon.tiny,
                        onChange: { pct in
                            let willTime = self.viewModel.duration * Double(pct)
                            self.viewModel.event = .seeking(willTime, isUser: true)
                        },
                        onChanged:{ pct in
                            self.viewModel.event = .seekProgress(pct, isUser: true)
                            self.viewModel.seeking = 0
                        
                        })
                        .accessibility(hidden: true)
                        .frame(height: self.isFullScreen ? Self.uiHeightFullScreen : Self.uiHeight)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(self.completeTime)
                        .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.greyLightExtra))
                        .frame(width:Self.timeTextWidth)
                        .fixedSize(horizontal: true, vertical: false)
                    if self.useFullScreen {
                        ImageButton(
                            defaultImage: Asset.player.fullScreen,
                            activeImage: Asset.player.fullScreenOff,
                            isSelected: self.isFullScreen,
                            size: CGSize(width:Dimen.icon.regular,height:Dimen.icon.regular)
                        ){ _ in
                            if let model =  self.viewModel as? BtvPlayerModel {
                                model.btvLogEvent = .clickFullScreen(!self.isFullScreen)
                            }
                            
                            if self.viewModel.useFullScreenAction {
                                let changeOrientation:UIInterfaceOrientationMask = self.isFullScreen ? .portrait : .landscape
                                self.isFullScreen
                                    ? self.pagePresenter.fullScreenExit(changeOrientation: changeOrientation)
                                    : self.pagePresenter.fullScreenEnter(
                                        isLock: SystemEnvironment.isTablet ,
                                        changeOrientation: changeOrientation)
                            } else{
                                self.viewModel.event = .fullScreen(!self.isFullScreen, isUser:true)
                            }
                        }
                        .accessibility(label: Text(
                            self.isFullScreen ? String.player.fullscreenExit :  String.player.fullscreen))
                    }
                }
                .padding(.horizontal, self.isFullScreen ? Self.paddingFullScreen : Self.padding)
            }
            .opacity(self.isShowing && !self.viewModel.isLock ? 1 : 0)
            
            if !self.isSeeking {
                VStack(spacing:Dimen.margin.regular){
                    ImageButton(
                        defaultImage: Asset.player.resume,
                        activeImage: Asset.player.pause,
                        isSelected: self.isPlaying,
                        size: (SystemEnvironment.isTablet && self.isFullScreen)
                        ? CGSize(width:Dimen.icon.heavy,height:Dimen.icon.heavy)
                        : CGSize(width:Dimen.icon.heavyExtra,height:Dimen.icon.heavyExtra)
                    ){ _ in
                        self.viewModel.isUserPlay = self.isPlaying ? false  : true
                        self.viewModel.event = .togglePlay(isUser: true)
                        ComponentLog.d("BtvPlayerModel isUserPlay set " + self.viewModel.isUserPlay.description  , tag: self.tag)
                       
                    }
                    .accessibility(label: Text(
                        self.isPlaying ? String.player.pause :  String.player.resume))
                    .opacity(self.isLoading ? 0 : 1)
                    if self.isFullScreen && ( self.viewModel.playInfo != nil ) && !self.isPlaying {
                        if let info = self.viewModel.playInfo{
                           Text(info)
                               .modifier(BoldTextStyle(
                                           size:  Font.size.lightExtra,
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
            if tm < 0 {return}
            self.time = tm.secToHourString()
            self.completeTime = max(0,self.viewModel.duration - tm).secToHourString()
            if !self.isSeeking {
                self.progress = Float(tm / max(self.viewModel.duration,1))
            }
        }
        .onReceive(self.viewModel.$duration) { tm in
            self.duration = tm.secToHourString()
        }
        
        .onReceive(self.viewModel.$isPlay) { play in
            self.isPlaying = play
            /*
            if self.isPlaying {
                self.viewModel.playerUiStatus = .hidden
            }else {
                self.viewModel.playerUiStatus = .view
            }*/
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
            case .seeking(let willTime, _):
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
            case .seeked: withAnimation{
                self.isSeeking = false
            }
            default : break
            }
        }
        .onReceive(self.viewModel.$streamStatus) { st in
            guard let status = st else { return }
            switch status {
            case .buffering(_) : withAnimation{ self.isLoading = true }
            default : withAnimation{ self.isLoading = false }
            }
        }
        .onReceive(self.viewModel.$error) { err in
            guard let error = err else { return }
            ComponentLog.d("error " + err.debugDescription, tag: self.tag)
           
            self.viewModel.playerUiStatus = .view
            switch error{
            case .connect(_) : self.errorMessage = "connect error"

            case .illegalState(_) :
                self.errorMessage = "illegalState"
                return
            case .drm(_) : self.errorMessage = "drm"
                return
            case .asset(_) : self.errorMessage = "asset"
                return
            case .stream(let e) :
                switch e {
                case .pip(let msg): self.errorMessage = msg
                case .playback(let msg): self.errorMessage = msg
                case .unknown(let msg): self.errorMessage = msg
                case .certification(let msg): self.errorMessage = msg
                }
            }
            self.isError = true
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

