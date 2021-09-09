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
    static let openProgressTime:Double = 10
    static let previewLimit:Double = 5 * 60
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
    @State var showFullVod = false
    @State var isLock:Bool = false
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
                    showFullVod: self.showFullVod,
                    showNextCancel: self.showNextCancel,
                    nextProgress: self.nextProgress,
                    nextBtnTitle: self.nextBtnTitle,
                    isSeasonNext: self.isSeasonNext,
                    isLock: self.isLock)
            } else {
                PlayerBottomBodyKids(
                    viewModel: self.viewModel,
                    isFullScreen: self.isFullScreen,
                    isUiShowing: self.isUiShowing,
                    isPlaying: self.isPlaying,
                    showPreplay: self.showPreplay,
                    isLock: self.isLock)
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
            withAnimation {
                self.resetShow()
            }
        }
        .onReceive(self.viewModel.$isLock) { isLock in
            withAnimation{
                self.isLock = isLock
            }
        }
        
        .onReceive(self.viewModel.$duration){ t in
            if t <= 0 {return}
            self.durationTime = t
            guard let data = self.viewModel.synopsisPlayerData else { return }
            
            ComponentLog.d("duration " + t.description, tag:self.tag)
            ComponentLog.d("originDuration " + self.viewModel.originDuration.description, tag:self.tag)
            ComponentLog.d("previewLimit " + Self.previewLimit.description, tag:self.tag)
            
            switch data.type {
            case .preview : break
            case .preplay :
                ComponentLog.d("preplay " + self.showPreplay.description, tag:self.tag)
                if self.viewModel.originDuration > Self.previewLimit || self.type == .btv {
                    withAnimation {self.showPreplay = true}
                } else {
                    withAnimation {
                        self.showPreplay = false
                        self.viewModel.btvPlayerEvent = .disablePreview
                    }
                    DispatchQueue.main.async {
                        self.viewModel.event = .pause
                        self.viewModel.event = .stop
                    }
                  
                }
            case .clip : break
            default :
                self.openingTime = min(self.viewModel.openingTime, Self.openProgressTime)
                ComponentLog.d("vod " + data.hasNext.description, tag:self.tag)
                if data.hasNext {
                    
                    let defaultEndingTime =  t-Self.nextProgressTime
                    if self.viewModel.endingTime <= 0 {
                        self.endingTime = defaultEndingTime
                        self.showNextCancel = false
                        ComponentLog.d("vod hasNext default " + self.endingTime.description, tag:self.tag)
                    } else {
                        self.endingTime = self.viewModel.endingTime
                        self.showNextCancel = self.endingTime < defaultEndingTime
                        ComponentLog.d("vod hasNext " + self.showNextCancel.description, tag:self.tag)
                        ComponentLog.d("vod hasNext endingTime " + self.endingTime.description, tag:self.tag)
                    }
                }
            }
            withAnimation {
                self.showFullVod = self.viewModel.fullVod != nil
            }
            
        }
        .onReceive(self.viewModel.$isPlay) { play in
            self.isPlaying = play
        }
        .onReceive(self.viewModel.$streamEvent) { evt in
            guard let evt = evt else { return }
            switch evt {
            case .seeked: self.moveNext()
            default : break
            }
        }
        .onReceive(self.viewModel.$time){ t in
            guard let d = self.durationTime else {return}
            if d <= 0 { return }
            if self.openingTime > 0 {
                self.checkOpening(t: t)
            }
            if self.endingTime > 0 {
                self.checkNext(t: t, d:d)
            }
            if self.insideSearchTime > 0 {
                self.checkInside(t: t)
            } else {
                self.removeInside()
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
    
    private func resetShow(){
        self.showDirectview = false
        self.showPreplay = false
        self.isShowNext = false
        self.showNext = false
        self.showFullVod = false
        self.isSeasonNext = false
        self.nextProgressCancel()
        self.removeInside()
        self.openingTime = -1
        self.nextBtnTitle = ""
        ComponentLog.d("resetShow", tag: self.tag)
    }
    
    @State var nextBtnTitle:String = ""
    @State var isSeasonNext:Bool = false
    @State var openingTime:Double = -1
    @State var endingTime:Double = -1
    @State var isShowNext = false
    @State var showNext = false
    @State var showNextCancel = false
    @State var nextTimer:AnyCancellable?
    @State var nextProgress:Float = 0.0
    
    func checkOpening(t:Double){
        if self.showDirectview {
            if t > self.openingTime {
                withAnimation { self.showDirectview = false }
            }
        } else {
            if t < self.openingTime {
                withAnimation { self.showDirectview = true }
            }
        }
    }
    
    func moveNext(){
        if !self.isShowNext {return}
        let t = self.viewModel.time
        let end = self.endingTime + Self.nextProgressTime
        if t > end {
            ComponentLog.d("nextProgress move", tag: self.tag)
            self.nextProgressCancel()
        }
    }
    
    func checkNext(t:Double, d:Double){
        if t > self.endingTime {
            if !self.isShowNext {
                self.isShowNext = true
                self.nextProgressStart(t:t, d:d)
            }
        } else {
            if self.isShowNext {
                self.isShowNext = false
                self.nextProgressCancel()
            }
        }
    }
    func nextProgressStart(t:Double, d:Double){
        if !self.setup.nextPlay { return }
        self.nextBtnTitle = self.viewModel.synopsisPlayerData?.nextString ?? ""
        self.isSeasonNext = self.viewModel.synopsisPlayerData?.nextEpisode == nil
        
        /*
        if self.isSeasonNext {
            withAnimation {
                self.showNext = true
                self.showNextCancel = false
                self.nextProgress = 1
            }
            return
        }*/
        let end = self.endingTime + Self.nextProgressTime
        if end > d {
            ComponentLog.d("nextProgress over", tag: self.tag)
            self.nextProgressCancel()
            return
        }
        ComponentLog.d("nextProgressStart", tag: self.tag)
        withAnimation { self.showNext = true }
        // let diff = Self.nextProgressTime - (Self.nextProgressTime - (t-self.endingTime))
        // var time:Float = Float(diff / tick)
        let tick:Double = 1/20
        let times:Float = Float(Self.nextProgressTime / tick)
        var time:Float = 0
        self.nextTimer?.cancel()
        self.nextTimer = Timer.publish(
            every: tick , on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                time += 1
                self.nextProgress = min(1,time/times)
                if self.nextProgress == 1 {
                    ComponentLog.d("nextProgressComplete", tag: self.tag)
                    self.viewModel.btvPlayerEvent = .nextView(isAuto:true)
                    self.nextProgressCancel()
                }
            }
    }
    
    func nextProgressCancel(){
        ComponentLog.d("nextProgressCancel", tag: self.tag)
        withAnimation { self.showNext = false }
        self.nextTimer?.cancel()
        self.nextTimer = nil
    }
    
    
    @State var insideSearchTime:Double = -1
    @State var cookies:[CookieInfo]? = nil
    @State var showCookie:String? = nil
    @State var currentCookie:CookieInfo? = nil
    func resetInside(insideSearchTime:Double){
        self.insideSearchTime = insideSearchTime
        let cookies =  self.insideModel.cookies
        self.cookies = cookies
    }
    func removeInside(){
        if self.currentCookie != nil {
            self.showCookie = nil
            self.currentCookie = nil
        }
    }
    func checkInside(t:Double){
        guard let cookies = self.cookies else {return}
        if t < self.insideSearchTime {
            self.removeInside()
            return
        }
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
