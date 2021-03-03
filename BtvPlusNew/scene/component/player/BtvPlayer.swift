//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI

enum BtvPlayType {
    case preview(String), ad, vod(String, String?)
    var type: String {
        switch self {
        default: return "V"
        }
    }
    var title: String {
        switch self {
        case .preview: return "예고편"
        case .vod( _ , let title): return title ?? ""
        default: return ""
        }
    }
    var cid: String {
        switch self {
        case .preview(let epsdRsluId): return epsdRsluId
        case .vod(let epsdRsluId , _): return epsdRsluId
        default: return ""
        }
    }
}

struct Quality {
    let name:String
    let path:String
}

enum DragGestureType:String {
    case progress, volume, brightness, playList
}

enum SelectOptionType:String {
    case quality, rate, ratio
}
enum BtvUiEvent {
    case more, guide, initate, closeList
}

enum BtvPlayerEvent {
    case nextView, continueView, changeView(String)
}

class BtvPlayerModel:PlayerModel{
    @Published fileprivate(set) var brightness:CGFloat = UIScreen.main.brightness
    @Published fileprivate(set) var seeking:Double = 0
    @Published private(set) var message:String? = nil
    
    @Published var currentQuality:Quality? = nil
    @Published var selectFunctionType:SelectOptionType? = nil
    @Published var btvUiEvent:BtvUiEvent? = nil {didSet{ if btvUiEvent != nil { btvUiEvent = nil} }}
    @Published var btvPlayerEvent:BtvPlayerEvent? = nil {didSet{ if btvPlayerEvent != nil { btvPlayerEvent = nil} }}
    
    private(set) var synopsisPlayerData:SynopsisPlayerData? = nil
    private(set) var synopsisPrerollData:SynopsisPrerollData? = nil
    private(set) var openingTime:Double = 0
    fileprivate(set) var continuousTime:Double = 0
    fileprivate(set) var checkPreroll = true
    fileprivate(set) var isPrerollPlay = false
    private(set) var qualitys:[Quality] = []
    private(set) var header:[String:String]? = nil
    var initPlay:Bool? = nil
    var isFirstPlay:Bool = true
    
    private func appendQuality(name:String, path:String){
        let quality = Quality(name: name, path: path)
        qualitys.append(quality)
    }
    
    override func reset() {
        self.currentQuality = nil
        self.limitedDuration = nil
        self.continuousTime = 0
        self.openingTime = 0
        self.seeking = 0
        self.qualitys = []
        self.header = nil
        self.initPlay = nil
        super.reset()
    }
    
    @discardableResult
    func setData(synopsisPrerollData:SynopsisPrerollData?) -> BtvPlayerModel {
        self.synopsisPrerollData = synopsisPrerollData
        self.checkPreroll = true
        return self
    }
    
    @discardableResult
    func setData(synopsisPlayData:SynopsisPlayerData?) -> BtvPlayerModel {
        self.synopsisPlayerData = synopsisPlayData
        return self
    }
    
    @discardableResult
    func setData(data:PlayInfo, type:BtvPlayType) -> BtvPlayerModel {
        let isPrevPlay = self.isPlay
        self.reset()
        var header = [String:String]()
        header["x-ids-cinfo"] = type.type + "," + type.cid + "," + type.title
        self.header = header
        if let playData = self.synopsisPlayerData {
            self.playInfo = playData.type.name
            switch playData.type {
            case .preplay(let autoPlay):
                if let prevTime = data.PREVIEW_TIME {
                    self.limitedDuration = Double(prevTime.toInt())
                }
                self.initPlay = autoPlay
            case .preview(_, let autoPlay):
                self.initPlay = autoPlay
            case .vodNext(let t, let autoPlay), .vodChange(let t, let autoPlay):
                self.openingTime = playData.openingTime ?? 0
                self.continuousTime = t
                self.initPlay = autoPlay
            case .vod(let t, let autoPlay):
                self.openingTime = playData.openingTime ?? 0
                self.continuousTime = t
                self.initPlay = autoPlay
            default: do{}
            }
        }
        if self.isFirstPlay {
            self.isFirstPlay = false
            ComponentLog.d("first setup initPlay " + self.initPlay.debugDescription , tag: "BtvPlayer")
        }else if self.initPlay == nil{
            self.initPlay = isPrevPlay
            ComponentLog.d("auto setup initPlay " + self.initPlay.debugDescription , tag: "BtvPlayer")
        } else {
            ComponentLog.d("setup initPlay " + self.initPlay.debugDescription , tag: "BtvPlayer")
        }
        
        if let auto = data.CNT_URL_NS_AUTO { self.appendQuality(name: "AUTO", path: auto) }
        if let fhd = data.CNT_URL_NS_FHD { self.appendQuality(name: "FHD", path: fhd) }
        if let hd = data.CNT_URL_NS_HD  { self.appendQuality(name: "HD", path: hd) }
        if let sd = data.CNT_URL_NS_SD  { self.appendQuality(name: "SD", path: sd) }
        if !qualitys.isEmpty {
            currentQuality = qualitys.first{$0.name == "HD"}
        }
        return self
    }
}
struct PlayListData{
    var listTitle:String? = nil
    var title:String? = nil
    var datas:[VideoData] = []
}



struct BtvPlayer: PageComponent{
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel: BtvPlayerModel = BtvPlayerModel()
    @ObservedObject var prerollModel: PrerollModel = PrerollModel()
    @ObservedObject var listViewModel: InfinityScrollModel = InfinityScrollModel()
    var title:String? = nil
    var thumbImage:String? = nil
    var thumbContentMode:ContentMode = .fit
    var contentID:String? = nil
    var listData:PlayListData = PlayListData()
     
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                ZStack(alignment:.bottom){
                    CPPlayer( viewModel : self.viewModel)
                    PlayerEffect(viewModel: self.viewModel)
                    PlayerTop(viewModel: self.viewModel, title: self.title)
                    PlayerBottom(viewModel: self.viewModel)
                    PlayerListTab( viewModel: self.viewModel, listTitle:self.listData.listTitle, title: self.listData.title,
                                  listOffset:self.playListOffset + ListItem.video.size.height)
                        .opacity( self.playListTapOpacity )
                        
                    VideoList(viewModel:self.listViewModel,
                              datas: self.listData.datas,
                              contentID: self.contentID,
                              useTracking : false,
                              margin:PlayerUI.paddingFullScreen + PlayerListTab.padding ){ data in
                        
                        guard let epsdId = data.epsdId else { return }
                        self.viewModel.btvPlayerEvent = .changeView(epsdId)
                        }
                        .modifier(MatchHorizontal(height: ListItem.video.size.height))
                        .opacity( self.isFullScreen && (self.isUiShowing || self.isPlayListShowing) ? 1.0 : 0)
                        .padding(.bottom, self.playListOffset)
                    
                    PlayerOptionSelectBox(viewModel: self.viewModel)
                    PlayerGuide(viewModel: self.viewModel)
                }
                .opacity(self.isWaiting == false ? 1.0 : 0)
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
                
                if self.isPreroll {
                    Preroll(viewModel: self.prerollModel)
                }
                PlayerWaiting(
                    pageObservable:self.pageObservable,
                    viewModel: self.viewModel, imgBg: self.thumbImage, contentMode: self.thumbContentMode)
                    .opacity(self.isWaiting == true ? 1.0 : 0)
                
            }
            .modifier(MatchParent())
            .background(Color.app.black)
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if !update {return}
                if self.viewModel.isLock { return }
                switch self.sceneObserver.sceneOrientation {
                case .landscape : self.pagePresenter.fullScreenEnter()
                case .portrait : self.pagePresenter.fullScreenExit()
                }
            }
            
            .onReceive(self.viewModel.$event) { evt in
                guard let evt = evt else { return }
                switch evt {
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
                        withAnimation{ self.isWaiting = true }
                    }else{
                        self.recoveryTime = self.viewModel.time
                    }
                default : do{}
                }
            }
            .onReceive(self.viewModel.$currentQuality){ quality in
                self.viewModel.event = .stop
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
                ComponentLog.d("autoPlay " + autoPlay.description, tag: self.tag)
                if autoPlay {
                    self.initPlayer()
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
                    self.listViewModel.uiEvent = .scrollTo(find.index, UnitPoint.center)
                }
                self.updatePlayListOffset()
            }
            .onReceive(self.prerollModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .finish :
                    self.initPlay()
                default : do{}
                }
            }
            .onAppear(){
                if !Preroll.isInit { Preroll.initate() }
            }
            .onDisappear(){
                self.pagePresenter.fullScreenExit()
            }
        }//geo
    }//body
    
    func initPlayer(){
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
            "device_id" + SystemEnvironment.getGuestDeviceId() +
            "&token=" + (repository.getDrmId() ?? "")
       // ComponentLog.d("path : " + path, tag: self.tag)
        let t = self.viewModel.continuousTime > 0 ? self.viewModel.continuousTime : self.viewModel.time
        self.viewModel.continuousTime = 0
        self.viewModel.event = .load(path, true , t, self.viewModel.header)
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
    @State var playListOffset:CGFloat = -ListItem.video.size.height
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
            willPos = -ListItem.video.size.height
        }else{
            willPos = self.isPlayListShowing
                ? PlayerUI.paddingFullScreen
                : -ListItem.video.size.height + PlayerUI.paddingFullScreen
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
        let top = ListItem.video.size.height
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
        if self.playListOffset >= -ListItem.video.size.height/2 {
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
        targetRatio = min(3.0, targetRatio)
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
struct BtvPlayer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            BtvPlayer()
                .environmentObject(Repository())
                .environmentObject(Setup())
                .environmentObject(SceneObserver())
                .environmentObject(PagePresenter())
                .environmentObject(Pairing())
                .modifier(MatchParent())
        }
    }
}
#endif

