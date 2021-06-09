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
    var type:PageType = .btv
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
            if self.type == .btv {
                PlayerBottomBody(
                    viewModel: self.viewModel,
                    isFullScreen: self.isFullScreen,
                    isUiShowing: self.isUiShowing,
                    isPlaying: self.isPlaying,
                    showDirectview: self.showDirectview,
                    showPreplay: self.showPreplay,
                    showPreview: self.showPreview,
                    showNext: self.showNext,
                    nextProgress: self.nextProgress,
                    nextBtnTitle: self.nextBtnTitle,
                    nextBtnSize: self.nextBtnSize)
            } else {
                PlayerBottomBodyKids(
                    viewModel: self.viewModel,
                    isFullScreen: self.isFullScreen,
                    isUiShowing: self.isUiShowing,
                    isPlaying: self.isPlaying,
                    showPreplay: self.showPreplay)
            }
        }
        .modifier(MatchParent())
        .padding(.all,
                 self.type == .btv
                    ? self.isFullScreen ? PlayerUI.paddingFullScreen : PlayerUI.padding
                    : self.isFullScreen ? KidsPlayerUI.paddingFullScreen : KidsPlayerUI.padding
        )
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
