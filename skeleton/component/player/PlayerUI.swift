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
    static let padding = Dimen.margin.thin
    static let paddingFullScreen = Dimen.margin.regular
    
    static let uiHeight:CGFloat = 44
    static let uiHeightFullScreen:CGFloat  = 64
}

struct PlayerUI: PageComponent {
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
                HStack(alignment:.center, spacing:Dimen.margin.thin){
                    Text(self.time)
                        .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                        .frame(width:53)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    ProgressSlider(
                        progress: min(self.progress, 1.0),
                        thumbSize: self.isFullScreen ? Dimen.icon.thinExtra : Dimen.icon.tiny,
                        onChange: { pct in
                            let willTime = self.viewModel.duration * Double(pct)
                            self.viewModel.event = .seeking(willTime)
                        },
                        onChanged:{ pct in
                            self.viewModel.event = .seekProgress(pct)
                        })
                        .frame(height: self.isFullScreen ? Self.uiHeightFullScreen : Self.uiHeight)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(self.duration)
                        .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.greyLightExtra))
                        .frame(width:53)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    ImageButton(
                        defaultImage: Asset.player.fullScreen,
                        activeImage: Asset.player.fullScreenOff,
                        isSelected: self.isFullScreen,
                        size: CGSize(width:Dimen.icon.regular,height:Dimen.icon.regular)
                    ){ _ in
                        self.isFullScreen
                            ? self.pagePresenter.fullScreenExit()
                            : self.pagePresenter.fullScreenEnter()
                    }
                }
                .padding(.all, self.isFullScreen ? Self.paddingFullScreen : Self.padding)
            }
            .opacity(self.isShowing && !self.viewModel.isLock ? 1 : 0)
            
            if !self.isSeeking {
                VStack(spacing:Dimen.margin.regular){
                    ImageButton(
                        defaultImage: Asset.player.resume,
                        activeImage: Asset.player.pause,
                        isSelected: self.isPlaying,
                        size: CGSize(width:Dimen.icon.heavyExtra,height:Dimen.icon.heavyExtra)
                    ){ _ in
                        self.viewModel.event = .togglePlay
                    }
                    if self.isFullScreen && ( self.viewModel.playInfo != nil ) && !self.isPlaying {
                        Text(self.viewModel.playInfo!)
                            .modifier(BoldTextStyle(size: Font.size.lightExtra, color: Color.app.white))
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
        .onReceive(self.viewModel.$playerStatus) { st in
            //guard let status = st else { return }
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
    }
    

}

