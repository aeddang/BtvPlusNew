//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine

extension PlayerBottom {
    static let nextProgressTime:Double = 30
    
}

struct PlayerBottom: PageView{
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    
    @State var isFullScreen:Bool = false
    @State var isUiShowing:Bool = false
    @State var isPlaying:Bool = false
    @State var showDirectview = false
    @State var showPreplay = false
    @State var showPreview = false
    
    @State var showNext = false
    @State var nextProgress:Float = 0.0
    @State var nextBtnTitle:String = ""
    @State var nextBtnSize:CGFloat = 0
    @State var isTimeCheck = false
    @State var durationTime:Double? = nil
    
    var body: some View {
        ZStack(alignment: .topLeading){
            VStack(alignment :.trailing, spacing:Dimen.margin.thinExtra){
                Spacer()
                HStack(spacing:self.isFullScreen ? Dimen.margin.regular : Dimen.margin.light){
                    Spacer()
                    if self.showDirectview {
                        RectButton(
                            text: String.player.directPlay
                            ){_ in
                            
                            self.viewModel.event = .seekTime(self.viewModel.openingTime, true)
                        }
                    }
                    if self.showPreplay {
                        if self.isFullScreen {
                            if self.isPlaying {
                                Text(String.player.preplaying)
                                    .modifier(BoldTextStyle(size: Font.size.thin, color: Color.app.white))
                            }
                            RectButton(
                                text: String.player.continueView,
                                icon: Asset.icon.play
                                ){_ in
                                
                                self.viewModel.btvPlayerEvent = .continueView
                            }
                        }else{
                            RectButton(
                                text: String.player.preplay
                                ){_ in
                                
                            }
                        }
                    }
                    
                    if self.showPreview {
                        RectButton(
                            text: String.player.cookie,
                            textTailing: self.viewModel.synopsisPlayerData?.previewCount ?? ""
                            ){_ in
                            
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
                            
                            self.viewModel.btvPlayerEvent = .nextView
                        }
                    }
                }
            }
            .padding(.bottom,
                     self.isUiShowing
                        ? self.isFullScreen
                            ? PlayerUI.uiHeightFullScreen : PlayerUI.uiHeight
                        : 0
                     )
        }
        .modifier(MatchParent())
        .padding(.all, self.isFullScreen ? PlayerUI.paddingFullScreen : PlayerUI.padding)
        .onReceive(self.viewModel.$playerUiStatus) { st in
            withAnimation{
                switch st {
                case .view :
                    self.isUiShowing = true
                default : self.isUiShowing = false
                }
            }
        }
        .onReceive(self.pagePresenter.$isFullScreen){fullScreen in
            self.isFullScreen = fullScreen
        }
        
        .onReceive(self.viewModel.$currentQuality){_ in
            self.durationTime = nil
            self.nextProgress = 0.0
            self.isTimeCheck = false
            guard let data = self.viewModel.synopsisPlayerData else {
                withAnimation {
                    self.showDirectview = false
                    self.showPreplay = false
                    self.showPreview = false
                    self.showNext = false
                }
                return
            }
            withAnimation {
                self.showDirectview = false
                self.showPreplay = false
                self.showPreview = false
                self.showNext = false
                switch data.type {
                case .preview :
                    self.showPreview = true
                case .preplay :
                    self.showPreplay = true
                case .vod :
                    self.showDirectview = true
                    self.isTimeCheck = self.viewModel.synopsisPlayerData?.hasNext ?? false
                    
                default : do{}
                }
            }
        }
        .onReceive(self.viewModel.$duration){ t in
            self.durationTime = t
        }
        .onReceive(self.viewModel.$isPlay) { play in
            self.isPlaying = play
        }
        .onReceive(self.viewModel.$time){ t in
            if self.showDirectview {
                if t >= self.viewModel.openingTime {
                    withAnimation { self.showDirectview = false }
                }
            } else {
                if t < self.viewModel.openingTime {
                    withAnimation { self.showDirectview = true }
                }
            }
            if !self.isTimeCheck { return }
            guard let d = self.durationTime else {return}
            if d <= 0 { return }
            let r = d - t
            if r > Self.nextProgressTime {
                if self.showNext {
                    withAnimation { self.showNext = false }
                }
            } else {
                self.nextProgress = Float((Self.nextProgressTime - r) / Self.nextProgressTime)
                if !self.showNext {
                    self.nextBtnTitle = self.viewModel.synopsisPlayerData?.nextString ?? ""
                    self.nextBtnSize = self.viewModel.synopsisPlayerData?.nextEpisode == nil ? 96 : 80
                    withAnimation { self.showNext = true }
                }
            }
        }
    }//body
}


#if DEBUG
struct PlayerBottom_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            PlayerBottom(
            )
            .environmentObject(PagePresenter())
            .modifier(MatchParent())
        }
        .background(Color.brand.bg)
    }
}
#endif
