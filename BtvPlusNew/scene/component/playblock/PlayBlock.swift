//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI
import Combine

class PlayBlockModel: PageDataProviderModel {
    private(set) var dataType:BlockData.DataType = .grid
    private(set) var key:String? = nil
    private(set) var menuId:String? = nil
    private(set) var isClip:Bool = false
    private(set) var initFocus:Int? = nil
    private(set) var initFocusID:String? = nil
    fileprivate(set) var continuousTime:Double? = nil
    fileprivate(set) var btvPlayType:BtvPlayType? = nil
    fileprivate(set) var finalPlayData:PlayData? = nil
    
    private(set) var data:BlockData? = nil
    
    @Published fileprivate(set) var fullPlayData:PlayInfo? = nil
    @Published fileprivate(set) var currentPlayData:PlayData? = nil
    @Published fileprivate(set) var isPlayStatusUpdate = false {
        didSet{ if self.isPlayStatusUpdate { self.isPlayStatusUpdate = false} }
    }
    
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }
    
    func resetInitFocus() {
        self.initFocus = nil
        self.initFocusID = nil
    }
    func update(menuId:String?, initFocus:Int? = nil, initFocusID:String? = nil, key:String? = nil) {
        self.menuId = menuId
        self.key = key
        self.initFocus = initFocus
        self.initFocusID = initFocusID
        self.isUpdate = true
    }
    
    func update(data:BlockData, initFocus:Int? = nil, initFocusID:String? = nil,  key:String? = nil) {
        self.isClip = true
        self.menuId = data.menuId
        
        self.data = data
        self.key = key
        self.initFocus = initFocus
        self.initFocusID = initFocusID
        self.isUpdate = true
    }
    
    enum LogEvent{
        case select, play, like(Bool?), alram(Bool)
    }
    
    fileprivate(set) var dataNum:Int = 0
    @Published var logEvent:LogEvent? = nil {didSet{ if logEvent != nil { logEvent = nil} }}
    @Published var naviLogPlayData:PlayData? = nil
}

struct PlayBlock: PageComponent{
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PlayBlockModel = PlayBlockModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var playerModel: BtvPlayerModel = BtvPlayerModel(useFullScreenAction:false)
    
    var key:String? = nil
    var marginTop : CGFloat = 0
    var marginBottom : CGFloat = 0
    var spacing: CGFloat = Dimen.margin.medium
    var headerSize:CGFloat = Dimen.tab.lightExtra 
    @State var sceneOrientation: SceneOrientation = .portrait
    var body: some View {
        GeometryReader { geometry in
            PageDataProviderContent(
                pageObservable:self.pageObservable,
                viewModel : self.viewModel
            ){
                if !self.isError {
                    ZStack(alignment: .topLeading){
                        ReflashSpinner(
                            progress: self.$reloadDegree)
                            .padding(.top, self.marginTop)
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            axes: .vertical,
                            scrollType : .reload(isDragEnd:false),
                            header:self.isClip ?
                                ClipHeader(
                                    totalCount: self.totalCount,
                                    isSortAble: self.isSortAble,
                                    marginTop: self.marginTop, 
                                    action: self.sortAction)
                                : nil,
                            headerSize: self.headerSize + self.spacing,
                            marginTop:self.marginTop,
                            marginBottom :self.marginBottom,
                            spacing: 0,
                            isRecycle: true,
                            useTracking: true){
                            if self.datas.isEmpty   {
                                Spacer().modifier(ListRowInset())
                            } else {
                                ForEach(self.datas) { data in
                                    PlayItem(
                                        pageObservable: self.pageObservable,
                                        playerModel: self.playerModel,
                                        viewModel: self.viewModel,
                                        data: data,
                                        range: self.getRange()
                                        ){ data in
                                        
                                            self.viewModel.logEvent = .play
                                            self.forcePlay(data: data)
                                    }
                                    .id(data.hashId)
                                    .modifier(
                                        ListRowInset(
                                            marginHorizontal: Dimen.margin.thin,
                                            spacing: self.spacing,
                                            marginTop: self.marginTop
                                        )
                                    )
                                    .onAppear{
                                        if data.index == self.datas.last?.index {
                                            self.load()
                                        }
                                        self.onAppear(idx:data.index)
                                    }
                                    .onDisappear{
                                        self.onDisappear(idx: data.index)
                                    }
                                    .onTapGesture {
                                        self.viewModel.logEvent = .select
                                        if self.focusIndex != data.index {
                                            self.onFocusChange(willFocus: data.index)
                                        }
                                        if !data.isClip {
                                            self.appSceneObserver.event = .toast((data.openDate ?? "") + " " + String.alert.updateAlramRecommand)
                                        }
                                    }
                                }
                                Spacer().modifier(MatchHorizontal(height: Dimen.margin.medium))
                                    .onAppear{
                                        self.onAppear(idx:self.maxCount)
                                    }
                                    .onDisappear{
                                        self.onDisappear(idx:self.maxCount)
                                    }
                            }
                        }
                        .modifier(MatchParent())

                    }
                   
                } else {
                    EmptyAlert()
                    .modifier(MatchParent())
                }
            }
            
            .onReceive(self.repository.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .updatedWatchLv :
                    self.viewModel.isPlayStatusUpdate = true
                default : break
                }
            }
            .onReceive(self.pagePresenter.$event){ evt in
                guard let evt = evt else {return}
                switch evt.type {
                case .timeChange :
                    if evt.id == "PageSynopsisPlayer", let continuousPlayTime = evt.data as? Double {
                        self.onPlaytimeChanged(t:continuousPlayTime)
                    }
                    
                case .completed :
                    guard let type = evt.data as? ScsNetwork.ConfirmType  else { return }
                    switch type {
                    case .adult:
                        self.viewModel.isPlayStatusUpdate = true
                    default : break
                    }
                default : break
                }
            }
            .onReceive(self.pagePresenter.$isFullScreen){ isFullScreen in
                if self.pagePresenter.currentTopPage?.id != self.pageObject?.id {return}
                if isFullScreen {
                    if self.isFullScreen {return}
                    self.openFullScreen()
                }
            }
            .onReceive(self.playerModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .fullScreen(let isFullScreen) :
                    if isFullScreen {
                        self.openFullScreen()
                    } else {
                        self.closeFullScreen()
                    }
                default : break
                }
            }
            
            .onReceive(self.infinityScrollModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pullCompleted :
                    if !self.infinityScrollModel.isLoading { self.reload() }
                    withAnimation{ self.reloadDegree = 0 }
                case .pullCancel :
                    withAnimation{ self.reloadDegree = 0 }
                default : break
                }
            }
            .onReceive(self.infinityScrollModel.$scrollPosition){_ in
                self.delayUpdate()
            }
            .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                if pos < InfinityScrollModel.PULL_RANGE { return }
                self.reloadDegree = Double(pos - InfinityScrollModel.PULL_RANGE)
            }
            .onReceive(self.viewModel.$isUpdate){ update in
                if update {
                    self.isClip = self.viewModel.isClip
                    self.reload()
                }
            }
            .onReceive(self.viewModel.$event){evt in
                guard let evt = evt else { return }
                switch evt {
                case .onResult(_, let res, _):
                    switch res.type {
                    case .getGridPreview , .getGridEvent, .getCWGrid: self.loaded(res)
                    case .getNotificationVod(_, _, _ , let returnDatas) : self.loadedNoti(res, returnDatas:returnDatas)
                    default : break
                    }
                case .onError(_,  let err, _):
                    switch err.type {
                    case .getGridPreview , .getGridEvent, .getCWGrid: self.onError() 
                    case .getNotificationVod(_, _, _ , let returnDatas) : self.errorNoti(returnDatas:returnDatas)
                    default : break
                    }
                    
                default : break
                }
            }
            .onReceive(self.pairing.$event){evt in
                guard let _ = evt else {return}
                switch evt {
                case .pairingCompleted : self.reload()
                case .disConnected : self.reload()
                case .pairingCheckCompleted(let isSuccess) :
                    if self.pagePresenter.currentTopPage?.id != self.pageObject?.id {return}
                    if isSuccess { self.reload() }
                    else { self.appSceneObserver.alert = .pairingCheckFail }
                default : break
                }
            }
            .onReceive(self.playerModel.$btvPlayerEvent){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .close :
                    if self.isFullScreen {
                        self.closeFullScreen()
                    }
                case .changeView(let epsdId) :
                    self.closeFullScreen(changeEpsdId:epsdId)
                case .fullVod (let synopsisData):
                    self.closeFullScreen(fullSynopsisData:synopsisData)
                    
                default : break
                }
            }
            .onReceive(self.playerModel.$streamEvent){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .completed :
                    self.selectedData?.completed()
                    if self.isFullScreen {
                        self.closeFullScreen()
                    }
                default : break
                }
            }
            .onReceive(self.sceneObserver.$isUpdated){ _ in
                if self.sceneOrientation == self.sceneObserver.sceneOrientation {return}
                self.sceneOrientation = self.sceneObserver.sceneOrientation
                self.sceneOrientationUpdate()
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                if self.pageObject == page , let pos = self.finalIndex{ 
                    self.onFocusChange(willFocus: pos)
                }
            }
            .onAppear(){
                self.sceneOrientation = self.sceneObserver.sceneOrientation
            }
            .onDisappear(){
                self.delayUpdateCancel()
            }
        }
    }//body
    
    private func forcePlay(data:PlayData? = nil){
        guard let current:PlayData = data ?? self.selectedData else {return}
        if self.focusIndex != current.index {
            self.onFocusChange(willFocus: current.index)
        } else {
            self.viewModel.isPlayStatusUpdate = true
        }
       
        if self.pairing.status != .pairing && self.isClip{
            self.appSceneObserver.alert = .needPairing()
            return
        }
        
        
        let watchLv = current.watchLv
        if watchLv >= 19 {
            if self.pairing.status != .pairing {
                self.appSceneObserver.alert = .needPairing()
                return
            }
            if !SystemEnvironment.isAdultAuth {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.adultCertification)
                )
                return
            }
        }
        if !SystemEnvironment.isAdultAuth ||
            ( !SystemEnvironment.isWatchAuth && SystemEnvironment.watchLv != 0 )
        {
            if SystemEnvironment.watchLv != 0 && SystemEnvironment.watchLv <= watchLv {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.confirmNumber)
                        .addParam(key: .type, value: ScsNetwork.ConfirmType.adult)
                )
                return
            }
        }
    }
    
   
    @State var finalIndex:Int? = nil
    @State var isFullScreen:Bool = false
    @State var isHold:Bool = false
    @State var initFocus:Int? = nil

    private func openFullScreen(){
        if self.focusIndex == -1 {return}
        if self.isHold {return}
        self.isHold = true
        self.isFullScreen = true
        self.finalIndex = self.focusIndex
        self.delayUpdateCancel()
        PageLog.d("onOpenFullScreen " + (self.finalIndex?.description ?? ""), tag:self.tag)
        self.playerModel.event = .pause()
        self.viewModel.currentPlayData = nil
        self.onPlaytimeChanged(t:self.playerModel.time)
        let playTime = self.selectedData?.playTime
        let playData = self.playerModel.playData
        let btvPlayType = self.playerModel.btvPlayType
        self.playerModel.reset()
        if self.viewModel.isClip {
            if let epsdId = self.selectedData?.epsdId , let cdata = self.selectedData?.synopsisData {
                let data = SynopsisData(
                        srisId: cdata.srisId, searchType: .prd,
                        epsdId: epsdId, epsdRsluId: "",
                        prdPrcId: cdata.prdPrcId, kidZone:cdata.kidZone,
                        progressTime: playTime,
                        synopType: cdata.synopType
                )
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.synopsisPlayer, animationType: Optional.none)
                        .addParam(key: .data, value: data)
                )
            }
        } else {
            self.viewModel.continuousTime =  playTime
            self.viewModel.fullPlayData = playData
            self.viewModel.btvPlayType = btvPlayType
            self.pagePresenter.fullScreenEnter(isLock: true, changeOrientation: .landscape)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isHold = false
            }
        }
        
    }
    
    private func closeFullScreen(fullSynopsisData:SynopsisData? = nil, changeEpsdId:String? = nil){
        if self.focusIndex == -1 {return}
        if self.finalIndex == nil {return}
        if self.isHold {return}
        self.isHold = true
        self.delayUpdateCancel()
        self.onPlaytimeChanged(t:self.playerModel.time)
        self.playerModel.event = .pause()
        self.playerModel.reset()
       // self.selectedData?.completed()
        PageLog.d("onCloseFullScreen " + (self.finalIndex?.description ?? "nil"), tag:self.tag)
        if changeEpsdId == nil {
            self.pagePresenter.fullScreenExit(changeOrientation: SystemEnvironment.isTablet ? nil : .portrait)
            self.viewModel.fullPlayData = nil
        } else {
            if let epsdId = changeEpsdId, let cdata = self.selectedData?.synopsisData {
                let data = SynopsisData(
                        srisId: cdata.srisId, searchType: .prd,
                        epsdId: epsdId, epsdRsluId: "",
                        prdPrcId: cdata.prdPrcId, kidZone:cdata.kidZone,
                        synopType: cdata.synopType
                    )
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.synopsisPlayer, animationType: Optional.none)
                        .addParam(key: .data, value: data)
                )
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isFullScreen = false
            if let posIdx = self.finalIndex {
                if posIdx >= 0 && posIdx < datas.count {
                    self.infinityScrollModel.uiEvent = .scrollTo(datas[posIdx].hashId)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if let full = fullSynopsisData {
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.synopsis)
                                    .addParam(key: .data, value: full)
                                    .addParam(key: .watchLv, value: self.selectedData?.synopsisModel?.watchLevel)
                            )
                        }else if self.viewModel.fullPlayData != nil {
                            self.viewModel.fullPlayData = nil
                        } else {
                            self.onFocusChange(willFocus: posIdx)
                            PageLog.d("onCloseFullScreenUpdate " + (posIdx.description), tag:self.tag)
                        }
                    }
                }
            }
        }
    }
    
    private func sceneOrientationUpdate(){
        if self.isFullScreen {return}
        if self.focusIndex == -1 {return}
        if !SystemEnvironment.isTablet {
            if self.sceneObserver.sceneOrientation == .landscape {
                self.openFullScreen()
            } else {
                self.closeFullScreen()
            }
            return
        }
        
        if self.isHold {return}
        self.isHold = true
        self.onPlaytimeChanged(t: self.playerModel.time)
        self.playerModel.event = .pause()
        self.finalIndex = self.focusIndex
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isFullScreen = false
            if let posIdx = self.finalIndex {
                if posIdx >= 0 && posIdx < self.datas.count {
                    self.infinityScrollModel.uiEvent = .scrollTo(self.datas[posIdx].hashId)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.onFocusChange(willFocus: posIdx)
                        PageLog.d("onSceneOrientationUpdate " + (posIdx.description), tag:self.tag)
                    }
                }
            }
           
        }
    }
    
    
    private func onPlaytimeChanged(t:Double){
        guard let data = self.selectedData else { return }
        data.playTime = t
        PageLog.d("onPlaytimeChanged playTime " + t.description, tag:self.tag)
    }

    @State var delayUpdateSubscription:AnyCancellable?
    func delayUpdate(){
        self.delayUpdateSubscription?.cancel()
        self.delayUpdateSubscription = Timer.publish(
            every: 0.3, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.delayUpdateCancel()
                self.onUpdate()
            }
    }
    
    func delayUpdateCancel(){
        self.delayUpdateSubscription?.cancel()
        self.delayUpdateSubscription = nil
    }
    
    @State var viewIdx:[Int] = []
    private func onAppear(idx:Int){
        if viewIdx.first(where:{$0 == idx}) == nil {
            viewIdx.append(idx)
        }
        viewIdx.sort()
    }
    private func onDisappear(idx:Int){
        if let find = viewIdx.firstIndex(of: idx) {
            viewIdx.remove(at: find)
        }
    }
   
    @State var prevHalf:Int = 0
    private func onUpdate(){
        if self.isHold { return }
        if self.maxCount < 1 {return}
        let cPos = self.infinityScrollModel.scrollPosition
        
        //PageLog.d("onUpdate origin " + cPos.description, tag: self.tag)
        if cPos >= 0 && self.focusIndex != 0{
            if let focus  = self.initFocus{
                if focus == 0 || focus == 1 {
                    self.onResetFocusChange(willFocus: focus)
                } else {
                    self.infinityScrollModel.uiEvent = .scrollMove(self.datas[focus].hashId)
                }
                self.initFocus = nil
               
            } else {
                self.onResetFocusChange(willFocus: 0)
            }
            
            return
        }
        if cPos < -100 && self.maxCount == 2 {
            self.onResetFocusChange(willFocus: 1)
            return
        }
        if self.focusPos == cPos {return}
        
        let full = viewIdx.reduce(0, {$0+$1})
        PageLog.d("onUpdate " + viewIdx.debugDescription, tag: self.tag)
        let half = Int(floor(Float(full)/Float(viewIdx.count)))
        PageLog.d("onUpdate half " + half.description, tag: self.tag)
        var willPos = self.focusIndex
        if half != self.focusIndex && half != self.prevHalf {
            willPos = half
            self.prevHalf = half
            
        } else if half == self.focusIndex {
            let diff = self.focusPos - cPos
            let range = self.getRange()
            if abs(diff) > range {
                if diff < 0 {
                    PageLog.d("onUpdate half move up " + half.description, tag: self.tag)
                    willPos = half - 1
                } else {
                    PageLog.d("onUpdate half move down " + half.description, tag: self.tag)
                    willPos = half + 1
                }
            }
        }
       
        willPos = min(willPos,  self.maxCount-1)
        willPos = max(willPos,  0)
        if willPos != self.focusIndex {
            self.onResetFocusChange(willFocus: willPos)
        }
    }
    
    private func getRange()-> CGFloat {
        return PlayItem.getListRange(
            width: self.sceneObserver.screenSize.width,
            sceneOrientation: self.sceneOrientation,
            isClip: self.isClip)
            + self.spacing
    }
    private func onResetFocusChange(willFocus:Int){
        PageLog.d("onUpdate willFocus  " + willFocus.description, tag: self.tag)
        //self.selectedData?.reset()
        self.onPlaytimeChanged(t:self.playerModel.time)
        self.playerModel.reset()
        self.onFocusChange(willFocus: willFocus)
    }
    @State var focusPos:CGFloat = -1
    private func onFocusChange(willFocus:Int){
        self.isHold = false
        if self.datas.isEmpty {return}
        self.finalIndex = nil
        self.selectedData = self.datas[willFocus]
        self.focusIndex = willFocus
        self.focusPos = self.infinityScrollModel.scrollPosition
        PageLog.d("onFocusChange " + (willFocus.description) + " " + self.focusPos.description, tag: self.tag)
        DispatchQueue.main.async {
            self.viewModel.finalPlayData = self.selectedData
            self.viewModel.currentPlayData = self.selectedData
        }
    }
    
    
    private func loadedNoti(_ res:ApiResultResponds, returnDatas:Any? = nil){
        guard let data = res.data as? NotificationVod else { return errorNoti(returnDatas:returnDatas)}
        guard let notiDatas = data.NotiVodList else { return emptyNoti(returnDatas:returnDatas)}
        guard let requestDatas = returnDatas as? [PlayData] else { return }
        requestDatas.forEach{ d in
            if let find = notiDatas.first(where: { noti in
                d.srisId == noti.sris_id && d.epsdId == noti.epsd_id}){
                d.setData(data: find)
            } else {
                d.setData(data: nil)
            }
        }
    }
    
    private func emptyNoti(returnDatas:Any? = nil){
        guard let requestDatas = returnDatas as? [PlayData] else { return }
        requestDatas.forEach{ $0.setData(data: nil) }
    }
    private func errorNoti(returnDatas:Any? = nil){
        guard let requestDatas = returnDatas as? [PlayData] else { return }
        requestDatas.forEach{ $0.setData(data: nil) }
    }
    
    //extention
    @State var isClip:Bool = false
    @State var isError:Bool = false
    @State var datas:[PlayData] = []
    @State var selectedData:PlayData? = nil
    @State var reloadDegree:Double = 0
    @State var appearList:[Int] = []
    @State var appearValue:Float = 0
    @State var focusIndex:Int = -1
    @State var maxCount:Int = 0
    @State var totalCount:Int = 0
    @State var isPaging:Bool = false
    @State var isInitSortAble:Bool = true
    @State var isSortAble:Bool = false
    @State var sortType:EuxpNetwork.SortType = SortTab.finalSortType
    
}



