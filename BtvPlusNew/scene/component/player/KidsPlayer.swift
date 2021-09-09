//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

struct KidsPlayer: PageComponent{
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var networkObserver:NetworkObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    @ObservedObject var prerollModel: PrerollModel = PrerollModel()
    @ObservedObject var listViewModel: InfinityScrollModel = InfinityScrollModel()
    var playGradeData: PlayGradeData? = nil
    var title:String? = nil
    var thumbImage:String? = nil
    var thumbContentMode:ContentMode = .fit
    var contentID:String? = nil
    var listData:PlayListData = PlayListData()
    var type:BtvPlayerType = .normal
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                ZStack(alignment:.bottom){
                    CPPlayer(
                        viewModel : self.viewModel,
                        pageObservable : self.pageObservable,
                        type: .kids)
                    if let grade = self.playGradeData {
                        PlayerGrade(
                            viewModel: self.viewModel,
                            pageType: .kids,
                            data:grade
                        )
                    }
                    PlayerEffect(viewModel: self.viewModel, type: .kids)
                    PlayerBottom(viewModel: self.viewModel, type: .kids)
                    PlayerTop(viewModel: self.viewModel, title: self.title, type: .kids)
                    PlayerListTabKids( viewModel: self.viewModel, listTitle:self.listData.listTitle, title: self.listData.title,
                                  listOffset:self.playListOffset + ListItemKids.video.size.height)
                        .opacity( self.playListTapOpacity )
                        
                    PlayerListKids(
                        viewModel:self.listViewModel,
                        datas: self.listData.datas,
                        contentID: self.contentID,
                        margin:KidsPlayerUI.paddingFullScreen + PlayerListTabKids.padding
                        ){ data in
                            guard let epsdId = data.epsdId else { return }
                            self.viewModel.btvPlayerEvent = .changeView(epsdId)
                            self.listViewModel.itemEvent = .select(data)
                        }
                        .modifier(MatchHorizontal(height: ListItemKids.video.size.height))
                        .opacity( self.isFullScreen && (self.isUiShowing || self.isPlayListShowing) ? 1.0 : 0)
                        .padding(.bottom, self.playListOffset)
                    
                    PlayerOptionSelectBox(viewModel: self.viewModel, type: .kids)
                }
                .opacity(self.isWaiting == false ? 1.0 : 0)
                /*
                .gesture(
                    DragGesture(minimumDistance: 5, coordinateSpace: .local)
                        .onChanged({ value in
                            if self.viewModel.isLock { return }
                            if self.isFullScreen
                                && (self.isUiShowing || self.isPlayListShowing)
                                && !self.listData.datas.isEmpty {
                                
                                let range = geometry.size.height/2
                                if value.startLocation.y > range {
                                    self.dragGestureType = .playList
                                }
                            }
                            
                            if let type = dragGestureType {
                                switch type {
                                case .brightness: self.onBrightnessChange(value: value)
                                case .volume: self.onVolumeChange(value: value)
                                case .progress: self.onProgressChange(value: value)
                                case .playList: self.onPlaylistChange(value: value)
                                }
                            }else {
                                let diffX = value.translation.width
                                let diffY = value.translation.height
                                if abs(diffX) > abs(diffY) {
                                    self.dragGestureType = .progress
                                }else{
                                    if self.isPlayListShowing {
                                        self.dragGestureType = .playList
                                    }else{
                                        let half = geometry.size.width/2
                                        let posX = value.startLocation.x
                                        if posX > half {self.dragGestureType = .volume}
                                        else {self.dragGestureType = .brightness}
                                    }
                                }
                                self.viewModel.playerUiStatus = .hidden
                            }
                        })
                        .onEnded({ value in
                            switch self.dragGestureType {
                            case .progress:
                                self.viewModel.event = .seekMove(self.viewModel.seeking, false)
                                self.viewModel.seeking = 0
                            case .playList:
                                self.onPlaylistChangeCompleted()
                            default:break
                            }
                            self.resetDragGesture()
                        })
                )
                
                .gesture(
                    MagnificationGesture(minimumScaleDelta: 0).onChanged { val in
                        if self.viewModel.isLock { return }
                        self.onRatioChange(value: val)
                    }.onEnded { val in
                        self.resetDragGesture()
                        self.isChangeRatioCancel = false
                    }
                )
                */
                if self.isPreroll {
                    PrerollUi(
                        viewModel: self.viewModel,
                        prerollModel: self.prerollModel,
                        type: .kids
                    )
                }
                PlayerDisable(
                    pageObservable:self.pageObservable,
                    viewModel: self.viewModel
                )
                PlayerWaitingKids(
                    pageObservable:self.pageObservable,
                    viewModel: self.viewModel, imgBg: self.thumbImage, contentMode: self.thumbContentMode)
                    .opacity(self.isWaiting == true ? 1.0 : 0)
                
            }
            .modifier(MatchParent())
            .background(Color.app.black)
            .onReceive(self.viewModel.$streamEvent) { evt in
                guard let evt = evt else { return }
                switch evt {
                case .seeked : self.viewModel.seeking = 0
                default : break
                }
            }
            .onReceive(self.viewModel.$event) { evt in
                guard let evt = evt else { return }
                switch evt {
                case .mute(let isMute) : BtvPlayerModel.isInitMute = isMute
                case .volume : BtvPlayerModel.isInitMute = false
                case .seeking(let willTime):
                    let diff =  willTime - self.viewModel.time
                    self.viewModel.seeking = diff
                    
                case .resume :
                    if self.isPrerollPause {
                        ComponentLog.d("isPrerollPause retry" , tag: self.tag)
                        self.isPrerollPause = false
                        self.initPlayer()
                    }
                    if self.isWaiting != false {
                        self.continuousPlay()
                    }
                    
                case .pause :
                    if self.isPreroll {
                        ComponentLog.d("isPrerollPause" , tag: self.tag)
                        self.isPrerollPause = true
                        self.isPreroll = false
                        self.viewModel.isPrerollPlay = false
                        self.viewModel.btvPlayerEvent = .stopAd
                        withAnimation{ self.isWaiting = true }
                        
                    }else{
                        self.recoveryTime = self.viewModel.time
                    }
                default :  break
                }
            }
            .onReceive(self.viewModel.$selectQuality){ quality in
                self.setup.selectedQuality = quality?.name
                self.viewModel.selectedQuality = quality?.name
                self.viewModel.currentQuality = quality
            }
            .onReceive(self.viewModel.$duration){ d in
                if d < 10 { return }
                if (self.viewModel.continuousProgress ?? 1) < MetvNetwork.maxWatchedProgress,
                   let progress = self.viewModel.continuousProgress{
                    let t = round(d * Double(progress))
                    self.viewModel.event = .seekTime(t)
                    self.viewModel.continuousProgress = nil
                    ComponentLog.d("continuousProgress play" , tag: self.tag)
                }
                if let progressTime = self.viewModel.continuousProgressTime {
                    self.viewModel.event = .seekTime(progressTime)
                    self.viewModel.continuousProgressTime = nil
                    ComponentLog.d("continuousProgressTime play" , tag: self.tag)
                }
            }
            .onReceive(self.viewModel.$currentQuality){ quality in
                if self.isPreroll {
                    self.isPreroll = false
                    self.viewModel.isPrerollPlay = false
                    if self.viewModel.initPlay == nil {
                        ComponentLog.d("auto setup initPlay preroll" , tag: self.tag)
                        self.viewModel.initPlay = true
                    }
                }
                if quality == nil { return }
                let autoPlay = self.viewModel.initPlay ?? self.setup.autoPlay
                self.viewModel.continuousTime = self.viewModel.time
                ComponentLog.d("autoPlay " + autoPlay.description, tag: self.tag)
                if autoPlay {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.05){
                        self.initPlayer()
                    }
                } else  {
                    withAnimation{ self.isWaiting = true }
                }
                
            }
            
            .onReceive(self.viewModel.$btvUiEvent) { evt in
                guard let evt = evt else { return }
                    switch evt {
                    case .initate :
                        self.initPlayer()
                    case .closeList :
                        self.isPlayListShowing = false
                        self.updatePlayListOffset()
                    default : break
                }
            }
            .onReceive(self.viewModel.$playerUiStatus) { st in
                withAnimation{
                    switch st {
                    case .view :
                        self.isUiShowing = true
                    default : self.isUiShowing = false
                    }
                }
                if !self.isPlayListShowing {
                    self.updatePlayListOffset()
                }
        
            }
            .onReceive(self.pagePresenter.$isFullScreen){fullScreen in
                self.isFullScreen = fullScreen
                if let find = self.listData.datas.first(where: {self.contentID == $0.epsdId}) {
                    self.listViewModel.uiEvent = .scrollTo(find.hashId, UnitPoint.center)
                }
                self.updatePlayListOffset()
            }
            .onReceive(self.prerollModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                //case .start : self.viewModel.event = .pause
                case .finish, .skipAd : self.initPlay()
                default : do{}
                }
            }
            .onAppear(){
                if !Preroll.isInit { Preroll.initate() }
                self.viewModel.isUserPlay = self.setup.autoPlay
                self.viewModel.selectedQuality = self.setup.selectedQuality
                if BtvPlayerModel.isInitMute {
                    self.viewModel.isMute = true
                }
            }
            .onDisappear(){
                self.pagePresenter.fullScreenExit()
                self.viewModel.event = .stop
            }
        }//geo
    }//body
    
    func initPlayer(){
        if self.setup.dataAlram && self.networkObserver.status == .cellular {
            self.appSceneObserver.event = .toast(String.alert.dataNetwork)
        }
        ComponentLog.d("initPlayer", tag: self.tag)
        withAnimation{ self.isWaiting = false }
        if self.viewModel.checkPreroll {
            self.viewModel.checkPreroll = false
            if let data = self.viewModel.synopsisPrerollData {
                if !self.isPreroll {
                    self.isPreroll = true
                    self.viewModel.isPrerollPlay = true
                }
                ComponentLog.d("initPreroll", tag: self.tag)
                self.prerollModel.request = .load(data)
                return
            }
        }
        self.initPlay()
    }
    
    func continuousPlay(){
        withAnimation{ self.isWaiting = false }
        self.viewModel.continuousTime = self.recoveryTime
        self.initPlay()
    }
    
    func initPlay(){
        ComponentLog.d("initPlay", tag: self.tag)
        if self.isPreroll {
            self.isPreroll = false
            self.viewModel.isPrerollPlay = false
        }
        guard let quality = self.viewModel.currentQuality else {
            self.viewModel.event = .stop
            return
        }
        let find = quality.path.contains("?")
        let leading = find ? "&" : "?"
        let path = quality.path + leading +
            "device_id" + SystemEnvironment.deviceId +
            "&token=" + (repository.getDrmId() ?? "")
        ComponentLog.d("path : " + path, tag: self.tag + " " + self.viewModel.id)
        let t = self.viewModel.continuousTime
        ComponentLog.d("continuousTime " + t.description, tag: self.tag)
        self.viewModel.continuousTime = 0
        DispatchQueue.main.async {
            self.viewModel.event = .load(path, true , t, self.viewModel.header)
        }
        
    }
    
    @State var isWaiting:Bool? = nil
    @State var isPrerollPause:Bool = false
    @State var recoveryTime:Double = 0
    @State var isPreroll:Bool = false
    @State var dragGestureType:DragGestureType? = nil
    @State var startSeeking:Double = -1
    @State var startVolume:Float = -1
    @State var startBrightness:CGFloat = -1
    @State var startRatio:CGFloat = -1
    @State var isChangeRatioCancel = false
    @State var isFullScreen:Bool = false
    @State var isUiShowing:Bool = false
    @State var isPlayListShowing:Bool = false
    @State var startPlayListOffset:CGFloat = -1
    @State var playListOffset:CGFloat = -ListItemKids.video.size.height
    @State var playListTapOpacity:Double = 0
    
    func resetDragGesture(){
        self.startSeeking = -1
        self.startVolume = -1
        self.startBrightness = -1
        self.startRatio = -1
        self.startPlayListOffset = -1
        self.dragGestureType = nil
    }
    
    func updatePlayListOffset(){
        if self.listData.datas.isEmpty { return }
        var willPos = self.playListOffset
        if !self.isFullScreen {
            willPos = -ListItemKids.video.size.height
        }else{
            willPos = self.isPlayListShowing
                ? PlayerUI.paddingFullScreen
                : -ListItemKids.video.size.height + PlayerUI.paddingFullScreen
        }
        withAnimation{
            self.playListOffset = willPos
            self.updateListTapOpacity()
        }
    }
    
    func updateListTapOpacity(){
        if !self.isPlayListShowing {
            self.playListTapOpacity = 0
            return
        }
        let top = ListItemKids.video.size.height
        let pos = top + self.playListOffset
        self.playListTapOpacity = Double( pos / top )
    }
    func onPlaylistChange(value:DragGesture.Value){
        if !self.isPlayListShowing { self.isPlayListShowing = true }
        if self.startPlayListOffset == -1 {self.startPlayListOffset = self.playListOffset }
        self.playListOffset  = self.startPlayListOffset - value.translation.height
        self.updateListTapOpacity()
    }
    func onPlaylistChangeCompleted(){
        if self.playListOffset >= -ListItemKids.video.size.height/2 {
            self.isPlayListShowing = true
        }else{
            self.isPlayListShowing = false
        }
        self.updatePlayListOffset()
    }
    
    
    func onRatioChange(value:CGFloat){
        if self.isChangeRatioCancel { return }
        if self.startRatio == -1 {self.startRatio = self.viewModel.screenRatio }
        let diff = value - 2
        var targetRatio = self.startRatio + diff
        //ComponentLog.d("onRatioChange " + targetRatio.description, tag: self.tag)
        if self.viewModel.screenGravity == .resizeAspect {
            if targetRatio > 1.0 {
                self.viewModel.event = .screenRatio(1)
                self.viewModel.event = .screenGravity(.resizeAspectFill)
                self.isChangeRatioCancel = true
                //ComponentLog.d("onRatioChange resizeAspectFil", tag: self.tag)
                return
            }
        }else {
            if targetRatio < 0.0 {
                self.viewModel.event = .screenRatio(1)
                self.viewModel.event = .screenGravity(.resizeAspect)
                self.isChangeRatioCancel = true
                //ComponentLog.d("onRatioChange resizeAspect", tag: self.tag)
                return
            }
        }
        targetRatio = min(4.0, targetRatio)
        targetRatio = max(1.0, targetRatio)
        
        self.viewModel.event = .screenRatio(targetRatio)
    }
    
    func onProgressChange(value:DragGesture.Value){
        if self.startSeeking == -1 {self.startSeeking = self.viewModel.seeking }
        let diff = Double(value.translation.width/1)
        self.viewModel.seeking = self.startSeeking + Double(diff)
    }
    
    func onVolumeChange(value:DragGesture.Value){
        if self.startVolume  == -1 {self.startVolume  = self.viewModel.volume }
        let diff = Float(value.translation.height/200)
        var targetVolume = self.startVolume - diff
        targetVolume = max(0, targetVolume)
        targetVolume = min(1, targetVolume)
        self.viewModel.event = .volume(targetVolume)
    }
    
    func onBrightnessChange(value:DragGesture.Value){
        if self.startBrightness  == -1 {self.startBrightness  = UIScreen.main.brightness }
        let diff = CGFloat(value.translation.height/200)
        var targetBrightness  = self.startBrightness - diff
        targetBrightness = max(0, targetBrightness)
        targetBrightness = min(1, targetBrightness)
        UIScreen.main.brightness = targetBrightness
        self.viewModel.brightness = targetBrightness
    }
}


#if DEBUG
struct KidsPlayer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            KidsPlayer()
                .environmentObject(Repository())
                .environmentObject(Setup())
                .environmentObject(PageSceneObserver())
                .environmentObject(PagePresenter())
                .environmentObject(Pairing())
                .modifier(MatchParent())
        }
    }
}
#endif

