//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI
import Combine

extension PlayerBottom{
    static let nextProgressTime:Double = 5
}
    
struct PlayerBottom: PageView{
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    @ObservedObject var insideModel: BtvInsideModel = BtvInsideModel()
    var type:PageType = .btv
    @State var isFullScreen:Bool = false
    @State var isUiShowing:Bool = false
    @State var isFixUiStatus:Bool = false
    @State var isPlaying:Bool = false
    @State var showDirectview = false
    @State var showPreplay = false
    
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
                    showCookie: self.showCookie,
                    showNext: self.showNext,
                    showNextCancel: self.showNextCancel,
                    nextProgress: self.nextProgress,
                    nextBtnTitle: self.nextBtnTitle,
                    isSeasonNext: self.isSeasonNext)
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
        .onReceive(self.viewModel.$event) { evt in
            withAnimation{
                switch evt {
                case .fixUiStatus(let isFix) :
                    self.isFixUiStatus = isFix
                    if isFix { self.isUiShowing = false }
                default : break
                }
            }
        }
        .onReceive(self.viewModel.$btvPlayerEvent) { evt in
            withAnimation{
                switch evt {
                case .nextViewCancel :
                    self.nextProgressCancel()
                case .cookieView :
                    if let cookie = self.currentCookie {
                        self.viewModel.event = .seekTime(cookie.startTime, true)
                    }
                default : break
                }
            }
        }
        .onReceive(self.viewModel.$playerUiStatus) { st in
            withAnimation{
                switch st {
                case .view :
                    if !self.isFixUiStatus || self.isFullScreen{
                        self.isUiShowing = true
                    }
                default :
                    self.isUiShowing = false
                }
            }
        }
        .onReceive(self.pagePresenter.$isFullScreen){fullScreen in
            self.isFullScreen = fullScreen
            if fullScreen {
                if self.viewModel.playerUiStatus == .view {
                    self.isUiShowing = true
                }
            } else {
                if self.isFixUiStatus  {
                    self.isUiShowing = false
                }
            }
            
        }
        .onReceive(self.insideModel.$isUpdate){ update in
            if !update {return}
            self.resetInside(insideSearchTime: self.insideModel.searchTime)
        }
        .onReceive(self.viewModel.$currentQuality){_ in
            self.durationTime = nil
            self.nextProgress = 0.0
            self.isTimeCheck = false
            guard let data = self.viewModel.synopsisPlayerData else {
                withAnimation {
                    self.showDirectview = false
                    self.showPreplay = false
                    self.showNext = false
                }
                return
            }
            withAnimation {
                self.showDirectview = false
                self.showPreplay = false
                self.showNext = false
                switch data.type {
                case .preview : break
                case .preplay :
                    self.showPreplay = true
                case .vod :
                    self.showDirectview = true
                    if !self.isTimeCheck {
                        self.isTimeCheck = self.viewModel.synopsisPlayerData?.hasNext ?? false
                    }
                    
                default : break
                }
            }
        }
        .onReceive(self.viewModel.$duration){ t in
            self.durationTime = t
            if self.viewModel.endingTime <= 0 {
                self.endingTime = t-Self.nextProgressTime
                self.showNextCancel = false
            } else {
                self.endingTime = self.viewModel.endingTime
                self.showNextCancel = true
            }
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
            if self.endingTime != -1 {
                self.checkNext(t: t, d:d)
            }
            if self.insideSearchTime != -1 {
                self.checkInside(t: t)
            }
            if !self.viewModel.isPlay80 {
                let rate = t/d
                if rate >= 0.8 {
                    self.viewModel.isPlay80 = true
                    self.viewModel.btvPlayerEvent = .play80
                }
            }
        }.onDisappear(){
            self.nextProgressCancel()
        }
    }//body
    
    @State var nextBtnTitle:String = ""
    @State var isSeasonNext:Bool = false
    @State var endingTime:Double = -1
    @State var showNext = false
    @State var showNextCancel = false
    @State var nextTimer:AnyCancellable?
    @State var nextProgress:Float = 0.0
    func checkNext(t:Double, d:Double){
        if t > self.endingTime {
            if !self.showNext {
                self.nextProgressStart(t: d-t)
            }
        } else {
            if self.showNext {
                self.nextProgressCancel()
            }
        }
    }
    func nextProgressStart(t:Double = 5){
        if !self.setup.nextPlay { return }
        self.nextBtnTitle = self.viewModel.synopsisPlayerData?.nextString ?? ""
        self.isSeasonNext = self.viewModel.synopsisPlayerData?.nextEpisode == nil
        ComponentLog.d("nextProgressStart", tag: self.tag)
        withAnimation { self.showNext = true }
        
        let times:Float = Float(Self.nextProgressTime * 10)
        var time:Float = Float(min(t, Self.nextProgressTime) * 10)
        self.nextTimer?.cancel()
        self.nextTimer = Timer.publish(
            every: 0.1, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                withAnimation{
                    time += 1
                    self.nextProgress = min(1,time/times)
                    if time == times {
                        ComponentLog.d("nextProgressComplete", tag: self.tag)
                        self.viewModel.btvPlayerEvent = .nextView(isAuto:true)
                        self.nextProgressCancel()
                    }
                }
            }
    }
    func nextProgressCancel(){
        withAnimation { self.showNext = false }
        self.endingTime = -1
        self.nextTimer?.cancel()
        self.nextTimer = nil
    }
    
    
    
    @State var insideSearchTime:Double = -1
    @State var cookies:[CookieInfo]? = nil
    @State var showCookie:String? = nil
    @State var currentCookie:CookieInfo? = nil
    func resetInside(insideSearchTime:Double){
        if !self.isTimeCheck {
            self.isTimeCheck = insideSearchTime != -1
        }
        self.insideSearchTime = insideSearchTime
        let cookies =  self.insideModel.cookies
        self.cookies = cookies
    }
    
    func checkInside(t:Double){
        guard let cookies = self.cookies else {return}
        if t < self.insideSearchTime {return}
        guard let find = cookies.first(where: {$0.startTime <= t && $0.endTime >= t}) else {
            if self.currentCookie != nil {
                self.showCookie = nil
                self.currentCookie = nil
            }
            return
        } 
        if find.id != self.currentCookie?.id{
            self.currentCookie = find
            self.showCookie = " " + find.index.description + "/" + cookies.count.description
        }
        
        
    }
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
