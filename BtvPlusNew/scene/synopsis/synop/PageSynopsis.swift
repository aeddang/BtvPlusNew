//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
import Intents

extension PageSynopsis {
    enum ComponentEvent {
        case changeVod(String?), changeSynopsis(SynopsisData?, isSrisChange:Bool = false), changeOption(PurchaseModel?), purchase, watchBtv
    }
    class ComponentViewModel:ComponentObservable{
        @Published var uiEvent:ComponentEvent? = nil {didSet{ if uiEvent != nil { uiEvent = nil} }}
    }
    
    static let useLayer:Bool = false
    static let getSynopData:Int = 0
    static let getAuth:Int = 1
    static let getPlay:Int = 2
    static let shortcutType = "com.skb.episode-search"
}

struct PageSynopsis: PageView {
    var type:PageType = .btv
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var naviLogManager:NaviLogManager
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var componentViewModel:ComponentViewModel = ComponentViewModel()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var pageDataProviderModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var playerModel: BtvPlayerModel = BtvPlayerModel()
    @ObservedObject var peopleScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var prerollModel = PrerollModel()
    @ObservedObject var playerListViewModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var relationBodyModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var tabNavigationModel:NavigationModel = NavigationModel()
    let universalSearchManager:UniversalSearchManager = UniversalSearchManager()
    
    @State var synopsisData:SynopsisData? = nil
    @State var isPairing:Bool? = nil
    @State var isFullScreen:Bool = false
    
    @State var isUiActive:Bool = true
    @State var sceneOrientation: SceneOrientation = .portrait
    @State var playerWidth: CGFloat  = 0
    @State var isPlayBeforeDraging:Bool = false
    
    
    var body: some View {
        GeometryReader { geometry in
            PageDataProviderContent(
                viewModel: self.pageDataProviderModel
            ){
                PageDragingBody(
                    pageObservable: self.pageObservable, 
                    viewModel:self.pageDragingModel,
                    axis:(self.type == .btv  && Self.useLayer) ? .vertical : .horizontal,
                    dragingEndAction: (self.type == .btv  && Self.useLayer)
                        ? { isBottom in self.onDragEndAction(isBottom: isBottom, geometry:geometry)}
                        : nil
                ) {
                    
                    if self.type == .btv {
                        BtvSynopsis(
                            geometry:geometry,
                            pageObservable:self.pageObservable,
                            pageDragingModel: self.pageDragingModel,
                            
                            synopsisData: self.synopsisData,
                            synopsisModel:self.synopsisModel,
                            componentViewModel: self.componentViewModel,
                            playerModel: self.playerModel,
                            playerListViewModel: self.playerListViewModel,
                            prerollModel: self.prerollModel,
                            playListData: self.playListData,
                            
                            peopleScrollModel: self.peopleScrollModel,
                            episodeViewerData: self.episodeViewerData,
                            purchasViewerData: self.purchasViewerData,
                            summaryViewerData: self.summaryViewerData,
                            
                            tabNavigationModel: self.tabNavigationModel,
                            relationBodyModel: self.relationBodyModel,
                            relationContentsModel: self.relationContentsModel,
                            relationTab: self.relationTab,
                            relationDatas: self.relationDatas,
                            hasRelationVod: self.hasRelationVod,
                        
                            title: self.title,
                            epsdId: self.epsdId,
                            imgBg: self.imgBg,
                            imgContentMode: self.imgContentMode,
                            textInfo: self.textInfo,
                            hasAuthority: self.hasAuthority,
                            isPlayAble: self.isPlayAble,
                            isPosson:self.isPosson,
                            progressError: self.progressError,
                            
                            isPairing: self.isPairing,
                            isPlayViewActive: self.isPlayViewActive,
                            isFullScreen: self.isFullScreen,
                            isUiActive: self.isUiActive,
                            isUIView: self.isUIView,
                            sceneOrientation: self.sceneOrientation,
                            isBookmark: self.$isBookmark,
                            isLike: self.$isLike,
                            isRecommand : self.isRecommand,
                            seris: self.$seris,
                            
                            infinityScrollModel: self.infinityScrollModel,
                            useTracking:true,
                            uiType:self.uiType,
                            dragOpacity:self.dragOpacity
                        )
                        .onReceive(self.peopleScrollModel.$event){evt in
                            if Self.useLayer {return}
                            guard let evt = evt else {return}
                            switch evt {
                            case .pullCompleted :
                                self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                            case .pullCancel :
                                self.pageDragingModel.uiEvent = .pullCancel(geometry)
                            default : do{}
                            }
                        }
                        .onReceive(self.peopleScrollModel.$pullPosition){ pos in
                            if Self.useLayer {return}
                            self.pageDragingModel.uiEvent = .pull(geometry, pos)
                        }
                        .modifier(PageFull(style:.dark))
                    } else {
                        KidsSynopsis(
                            geometry:geometry,
                            pageObservable:self.pageObservable,
                            pageDragingModel: self.pageDragingModel,
                            
                            synopsisData: self.synopsisData,
                            synopsisModel:self.synopsisModel,
                            componentViewModel: self.componentViewModel,
                            playerModel: self.playerModel,
                            playerListViewModel: self.playerListViewModel,
                            prerollModel: self.prerollModel,
                            playListData: self.playListData,
                            
                            peopleScrollModel: self.peopleScrollModel,
                            episodeViewerData: self.episodeViewerData,
                            purchasViewerData: self.purchasViewerData,
                            summaryViewerData: self.summaryViewerData,
                            
                            tabNavigationModel: self.tabNavigationModel,
                            relationBodyModel: self.relationBodyModel,
                            relationContentsModel: self.relationContentsModel,
                            relationTab: self.relationTab,
                            relationDatas: self.relationDatas,
                            hasRelationVod: self.hasRelationVod,
                        
                            title: self.title,
                            epsdId: self.epsdId,
                            imgBg: self.imgBg,
                            imgContentMode: self.imgContentMode,
                            textInfo: self.textInfo,
                            hasAuthority: self.hasAuthority,
                            isPlayAble: self.isPlayAble,
                            isPosson:self.isPosson,
                            progressError: self.progressError,
                            
                            isPairing: self.isPairing,
                            isPlayViewActive: self.isPlayViewActive,
                            isFullScreen: self.isFullScreen,
                            isUiActive: self.isUiActive,
                            isUIView: self.isUIView,
                            sceneOrientation: self.sceneOrientation,
                            isBookmark: self.$isBookmark,
                            seris: self.$seris
                        )
                        .modifier(PageFullScreen(style:.kidsLight))
                    }
                }//PageDragingBody
                .onReceive(self.playerModel.$btvPlayerEvent){evt in
                    guard let evt = evt else { return }
                    self.onEventLog(btvPlayerEvent: evt)
                    self.onEventInside(btvPlayerEvent: evt) 
                    switch evt {
                    case .close : self.historyBack()
                    case .changeView(let epsdId) : self.changeVod(epsdId:epsdId)
                   
                    default : break
                    }
                }
                .onReceive(self.prerollModel.$event){evt in
                    guard let evt = evt else { return }
                    self.onEventLog(prerollEvent: evt)
                }
                .onReceive(self.playerModel.$btvUiEvent){evt in
                    guard let evt = evt else { return }
                    switch evt {
                    case .watchBtv : self.watchBtv()
                    default : break
                    }
                    
                    self.onEventLog(btvUiEvent: evt)
                }
                .onReceive(self.playerModel.$duration){duration in
                    self.onDurationSiri(duration: duration)
                }
                .onReceive(self.playerModel.$event){evt in
                    guard let evt = evt else { return }
                    switch evt {
                    case .fullScreen(_) :
                        self.onFullScreenControl()
                    default : break
                    }
                    self.onEventLog(event: evt)
                    self.onEventProhibition(event: evt)
                    
                }
                .onReceive(self.playerModel.$streamEvent){evt in
                    guard let evt = evt else { return }
                    self.onEventLog(streamEvent: evt)
                    self.onEventProhibition(streamEvent: evt)
                    self.onEventSiri(streamEvent: evt)
                }
                .onReceive(self.playerModel.$playerStatus){status in
                    guard let status = status else { return }
                    self.onStatusLog(playerStatus: status)
                }
                .onReceive(self.playerModel.$streamStatus){status in
                    guard let status = status else { return }
                    self.onStatusLog(streamStatus: status)
                }
                .onReceive(self.tabNavigationModel.$index ){ idx in
                    if idx == self.selectedRelationTabIdx { return }
                    self.relationContentsModel.serisSortType = nil
                    self.selectedRelationContent(idx:idx)
                }
                .onReceive(self.pairing.$event){evt in
                    guard let evt = evt else { return }
                    self.onEvent(pairingEvent: evt)
                }
                .onReceive(self.componentViewModel.$uiEvent){evt in
                    guard let evt = evt else { return }
                    switch evt {
                    case .changeVod(let epsdId) : self.changeVod(epsdId:epsdId)
                    case .changeSynopsis(let data, let isSrisChange): self.changeVod(synopsisData: data, isRedirectPage: isSrisChange)
                    case .changeOption(let option) : self.changeOption(option)
                    case .purchase : self.purchase()
                    case .watchBtv : self.watchBtv()
                    }
                    self.onEventLog(componentEvent: evt)
                }
            }//PageDataProviderContent
            /*
            .userActivity(Self.shortcutType) { userActivity in
                self.onSiri(userActivity:userActivity)
            }*/
           
            .onReceive(self.pageObservable.$layer ){ layer  in
                switch layer {
                case .bottom : self.isUiActive = false
                case .top, .below : self.isUiActive = true
                }
            }
            .onReceive(self.infinityScrollModel.$scrollPosition){ pos in 
                self.pageDragingModel.uiEvent = .dragCancel
                
            }
            .onReceive(self.pageDragingModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .dragInit :
                    if !self.playerModel.isPrerollPlay {
                        self.isPlayBeforeDraging = self.playerModel.isPlay
                        self.playerModel.event = .pause
                    }
                case .draged:
                    if self.isPlayBeforeDraging {
                        self.playerModel.event = .resume
                    }
                default: break
                }
                self.onDrag(evt: evt)
                
            }
            .onReceive(self.pairing.$event){evt in
                guard let _ = evt else {return}
                self.isPageDataReady = true
                switch evt {
                case .pairingCompleted : self.initPage()
                case .disConnected : self.initPage()
                case .pairingCheckCompleted(let isSuccess) :
                    if isSuccess {
                        let isPairing = self.pairing.status == .pairing
                        if isPairing == self.isCheckdPairing {return}
                        self.isCheckdPairing = isPairing
                        self.initPage()
                    }
                    else { self.appSceneObserver.alert = .pairingCheckFail }
                default : break
                }
            }
            .onReceive(self.pageDataProviderModel.$event){evt in
                guard let evt = evt else { return }
                switch evt {
                case .willRequest(let progress): self.requestProgress(progress)
                case .onResult(let progress, let res, let count):
                    self.respondProgress(progress: progress, res: res, count: count)
                case .onError(let progress,  let err, let count):
                    self.errorProgress(progress: progress, err: err, count: count)
                }
            }
            .onReceive(self.pageObservable.$status){status in
                switch status {
                case .appear:
                    DispatchQueue.main.async {
                        switch self.pairing.status {
                        case .pairing : self.pairing.requestPairing(.check)
                        case .unstablePairing : self.appSceneObserver.alert = .pairingRecovery
                        default :
                            self.isPageDataReady = true
                            self.initPage()
                        }
                    }
                default : break
                }
            }
            .onReceive(self.appSceneObserver.$alertResult){ result in
                guard let result = result else { return }
                switch result {
                case .retry(let alert) :
                    if alert == nil {
                        self.resetPage()
                    }
                default : break
                }
            }
            .onReceive(self.appSceneObserver.$event){ evt in
                guard let evt = evt else { return }
                switch evt {
                case .update(let type):
                    switch type {
                    case .purchaseCompleted(let pid) :
                        self.purchasedPid = pid
                        self.isAfterPurchase = true
                        self.resetPage()
                    default : break
                    }
                default : break
                }
            }
            .onReceive(self.pagePresenter.$event){ evt in
                guard let evt = evt else {return}
                self.onEventWatchLv(evt: evt)
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                if !self.isPageUiReady {return}
                if Self.useLayer {return}
                if page != self.pageObject {
                    self.isFinalPlaying = self.playerModel.isPrerollPlay ? true : self.playerModel.isPlay
                    self.playerModel.event = .pause
                    //ComponentLog.d("isFinalPlaying pause" , tag: "PageSynopsis BtvPlayer")
                } else {
                    if self.isFinalPlaying == true {
                        self.playerModel.event = .resume
                        self.isFinalPlaying = false
                        //ComponentLog.d("isFinalPlaying resume" , tag: "PageSynopsis BtvPlayer")
                    }
                    self.setupBottom()
                }
            }
            .onReceive(self.pagePresenter.$isFullScreen){fullScreen in
                self.isFullScreen = fullScreen
                self.setupBottom()
            }
            .onReceive(self.playerModel.$streamEvent){evt in
                guard let evt = evt else {return}
                self.onEventInside(streamEvent:evt)
                switch evt {
                case .completed : break
                default : break
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    if self.isPageUiReady {return}
                    DispatchQueue.main.async {
                        self.isPageUiReady = true
                        self.initPage()
                    }
                }
            }
            .onReceive(self.sceneObserver.$isUpdated){ _ in
                self.sceneOrientation = self.sceneObserver.sceneOrientation
                if self.relationDatas.isEmpty == false {
                    let relationDatas = self.relationContentsModel.getRelationContentSets(idx: self.selectedRelationTabIdx, row: self.relationRow)
                    self.relationDatas = relationDatas
                }
                if !self.isPageUiReady {return}
                
                if SystemEnvironment.isTablet{
                    if self.pagePresenter.currentTopPage != self.pageObject {return}
                    self.setupBottom()
                } else {
                    if self.sceneOrientation == .landscape && !self.isFullScreen {
                        self.pagePresenter.fullScreenEnter()
                    }
                }
            }
            .onReceive(self.pageObservable.$status) { status in
                if !self.isPageUiReady {return}
                self.onEventProhibition(pageStatus: status)
            }
            .onReceive(self.appSceneObserver.$safeBottomHeight) { _ in
                self.updateBottomPos(geometry: geometry)
            }
            .onAppear{
                self.playerModel.pageType = .kids
                self.sceneOrientation = self.sceneObserver.sceneOrientation
                self.onLayerPlayerAppear() 
                guard let obj = self.pageObject  else { return }
                self.setupHistory(synopsisData:self.getSynopData(obj: obj))
                self.initPage()
            }
            .onDisappear(){
                self.onLayerPlayerDisappear()
                self.onDisappearLog()
                self.onDisappearProhibition()
            }
        }//geo
    }//body
    
    private func setupBottom(){
        if self.isFullScreen {
            self.appSceneObserver.useBottomImmediately = false
            return
        }
        if self.type == .btv {
            if SystemEnvironment.isTablet {
                self.appSceneObserver.useBottomImmediately = self.sceneOrientation == .portrait
            } else {
                self.appSceneObserver.useBottomImmediately = true
            }
        }
    }


    /*
    Data process
    */
    enum SingleRequestType:String {
        case preview, changeOption, changeSeasonFirst,  relationContents, prohibitionSimultaneous, watchBtv
    }
    enum UiType{
        case simple, normal
    }
    @State var originHistorys:[SynopsisData] = []
    @State var historys:[SynopsisData] = []
    @State var isInitPage = false
    @State var isAutoPlay:Bool? = nil
    @State var isCheckdPairing:Bool? = nil
    @State var progressError = false
    @State var progressCompleted = false
    @State var synopsisModel:SynopsisModel? = nil
    @State var episodeViewerData:EpisodeViewerData? = nil
    @State var purchasViewerData:PurchaseViewerData? = nil
    @State var playerData:SynopsisPlayerData? = nil
    @State var summaryViewerData:SummaryViewerData? = nil
    @State var purchaseWebviewModel:PurchaseWebviewModel? = nil
    @State var relationContentsModel:RelationContentsModel = RelationContentsModel()
    @State var title:String? = nil
    @State var imgBg:String? = nil
    @State var imgContentMode:ContentMode = .fit
    @State var textInfo:String? = nil
    @State var playListData:PlayListData = PlayListData()
    @State var synopsisPlayType:SynopsisPlayType = .unknown
    @State var isBookmark:Bool? = nil
    @State var isRecommand:Bool? = nil
    @State var isLike:LikeStatus? = nil
    @State var hasAuthority:Bool? = nil
    @State var relationTab:[NavigationButton] = []
    @State var selectedRelationTabIdx:Int = 0
    @State var seris:[SerisData] = []
    @State var relationDatas:[PosterDataSet] = []
    @State var hasRelationVod:Bool? = nil
    @State var isFinalPlaying:Bool = false
    @State var isRedirectPage:Bool = false // 방영종료 시리즈진입시 시청가능한 페이지로 자동이동 여부
    @State var isPlayAble:Bool = false
    @State var isPlayViewActive = false
    @State var isPageUiReady = false
    @State var isPosson:Bool = false
    @State var anotherStb:String? = nil
    @State var isPageDataReady = false
    @State var isUIView:Bool = false

    
    /*동기화 value*/
    @State var epsdId:String? = nil
    @State var epsdRsluId:String = ""
    @State var purchasedPid:String? = nil
    @State var isAfterPurchase:Bool = false
    @State var playStartTime:Int? = nil
    
    /*Layer*/
    @State var isBottom:Bool = false
    @State var uiType:UiType = .normal
    @State var dragOffset:CGFloat = 0
    @State var dragOpacity:Double = 1
    
    /*extention params*/
    @State var firstPurchase:Bool = false
    @State var currentRedirectSris:String? = nil
    @State var isProhibitionCheckComplete:Bool = false
    
    
    
    private func initPage(){
        if self.synopsisData == nil {
            self.progressError = true
            return
        }
        if !self.isPageDataReady || !self.isPageUiReady { return }
        if self.pageObservable.status == .initate { return }
        self.isPairing = self.pairing.status == .pairing
        if self.isInitPage {
            self.resetPage(isAllReset: true)
            return
        }
        PageLog.d("initPage", tag: self.tag)
        self.isInitPage = true
        self.pageDataProviderModel.initate()
    }
    
    
    
    func resetPage(isAllReset:Bool = false, isRedirectPage:Bool = false){
        PageLog.d("resetPage", tag: self.tag)
        self.playerModel.event = .pause
        self.isUIView = false
        self.hasAuthority = nil
        self.progressError = false
        self.progressCompleted = false
        self.episodeViewerData = nil
        self.purchasViewerData = nil
        self.summaryViewerData = nil
        self.purchaseWebviewModel = nil
        self.isRedirectPage = isRedirectPage
        
        self.playerData = nil
        self.title = nil
        self.imgBg = nil
        self.textInfo = nil
        self.onResetPageWatchLv()
        self.onResetPageInside()
        self.onResetPageCorner()
        self.onResetPageRelationContent()
        self.onResetPageProhibitionSimultaneous()
        self.pageDataProviderModel.initate()
        withAnimation{
            self.isPlayViewActive = false
        }
    }
    
    

    private func requestProgress(_ progress:Int){
        PageLog.d("requestProgress " + progress.description, tag: self.tag)
        if self.progressError {
            self.errorProgress()
            return
        }
        if self.progressCompleted{
            self.completedProgress()
            return
        }
        switch progress {
        case Self.getSynopData :
            guard let data = self.synopsisData else {
                PageLog.d("requestProgress synopsisData nil", tag: self.tag)
                self.errorProgress()
                return
            }
            self.pageDataProviderModel.requestProgress( q: .init(type: .getSynopsis(data,anotherStbId:self.anotherStb)))
        
        case Self.getAuth :
            guard let model = self.synopsisModel else {return}
            
            let isWatchAble = self.checkWatchLvAuth()
            if !isWatchAble {
                self.fullScreenCancel()
                return
            }
            if self.isPairing == true || self.isPosson {
                if model.synopsisType == .seriesChange && model.isSeasonWatchAll && !self.isPosson,
                   let prevDirectView = self.prevDirectView {
                    self.setupDirectView(prevDirectView, isSeasonWatchAll:true) // 권한 대이타 재사용
                    self.pageDataProviderModel.requestProgressSkip()
                } else {
                    self.pageDataProviderModel.requestProgress(
                        q: .init(type: .getDirectView(model, anotherStbId:self.anotherStb )))
                }
            }else{
                self.pageDataProviderModel.requestProgressSkip()
                
            }
            
        case Self.getPlay :
            guard let model = self.synopsisModel else {return}
            if self.hasAuthority == false{
                if self.purchasViewerData?.isPlayAble == false {
                    PageLog.d("play unAble ", tag: self.tag)
                    self.completedProgress()
                    return
                }
                if model.hasExamPreview{
                    self.synopsisPlayType = .preplay()
                    self.pageDataProviderModel.requestProgress(q: .init(type: .getPreplay(self.epsdRsluId,  true )))
                }
                else if model.hasPreview{
                    self.synopsisPlayType = .preview(0)
                    let item = model.previews[0]
                    self.pageDataProviderModel.requestProgress(q: .init(type: .getPreview(item.epsd_rslu_id,  self.pairing.hostDevice )))
                } else {
                    PageLog.d("no preview", tag: self.tag)
                    self.errorProgress()
                }
            }
            else {
                switch self.synopsisPlayType {
                case .unknown, .preview, .preplay:
                    self.synopsisPlayType = .vod()
                default:
                    break
                }
                self.pageDataProviderModel.requestProgress( 
                    q: .init(type: .getPlay(self.epsdRsluId, anotherStbId: self.anotherStb )))
            }
            self.progressCompleted = true
        //case 3 : self.pageDataProviderModel.requestProgress(q: .init(type: .getGnb))
        default : break
        }
    }
    
    private func respondProgress(progress:Int, res:ApiResultResponds, count:Int){
        PageLog.d("respondProgress " + progress.description + " " + count.description, tag: self.tag)
        self.progressError = false
        switch progress {
        case Self.getSynopData :
            guard let data = res.data as? Synopsis else {
                PageLog.d("error Synopsis", tag: self.tag)
                self.progressError = true
                return
            }
            self.setupSynopsis(data)
            
        case Self.getAuth :
            if self.isPairing == true || self.isPosson {
                guard let data = res.data as? DirectView else {
                    PageLog.d("error DirectView", tag: self.tag)
                    self.progressError = true
                    return
                }
                self.setupDirectView(data)
                
            } else {
                guard let data = res.data as? Preview else {
                    PageLog.d("error Preview", tag: self.tag)
                    self.progressError = true
                    return
                }
                self.setupPreview(data)
            }
        
        case Self.getPlay :
            if self.hasAuthority == false{
                guard let data = res.data as? Preview else {
                    PageLog.d("error Preview", tag: self.tag)
                    self.progressError = true
                    return
                }
                self.setupPreview(data)
            }else{
                guard let data = res.data as? Play else {
                    PageLog.d("error Play", tag: self.tag)
                    self.progressError = true
                    return
                }
                self.setupPlay(data)
            }
            
        default :
            if res.id.hasPrefix( SingleRequestType.preview.rawValue ) {
                guard let data = res.data as? Preview else {
                    PageLog.d("error next Preview", tag: self.tag)
                    self.errorProgress()
                    return
                }
                self.setupPreview(data)
            }else if res.id.hasPrefix( SingleRequestType.changeOption.rawValue ) {
                guard let data = res.data as? Play else {
                    PageLog.d("error changeOption", tag: self.tag)
                    self.errorProgress()
                    return
                }
                self.setupPlay(data)
            }else if res.id.hasPrefix( SingleRequestType.relationContents.rawValue ) {
                guard let data = res.data as? RelationContents else {
                    PageLog.d("error relationContents", tag: self.tag)
                    self.setupRelationContent(nil)
                    return
                }
                self.setupRelationContent(data)
            }else if res.id.hasPrefix( SingleRequestType.prohibitionSimultaneous.rawValue ) {
                guard let data = res.data as? ProhibitionSimultaneous else { return }
                self.onProhibitionSimultaneous(data)
            }else if res.id.hasPrefix( SingleRequestType.watchBtv.rawValue ) {
                guard let data = res.data as? ResultMessage else { return }
                self.watchBtvCompleted(isSuccess: data.header?.result == ApiCode.success)
            } else {
                self.onInsideRespond(res: res)
            }
        }
    }
    
    private func errorProgress(progress:Int, err:ApiResultError, count:Int){
        switch progress {
        case 0 : self.progressError = true
        case 1 : self.progressError = true
        default :
            if  err.id.hasPrefix( SingleRequestType.relationContents.rawValue ) {
                PageLog.e("error relationContents", tag: self.tag)
                self.setupRelationContent(nil)
            }else if  err.id.hasPrefix( SingleRequestType.preview.rawValue ) {
                PageLog.e("error preview", tag: self.tag)
                self.errorProgress()
            }else if  err.id.hasPrefix( SingleRequestType.changeOption.rawValue ) {
                PageLog.e("error changeOption", tag: self.tag)
                self.errorProgress()
            }else if err.id.hasPrefix( SingleRequestType.watchBtv.rawValue ) {
                self.watchBtvCompleted(isSuccess: false)
            } else {
                self.onInsideRespondError(err: err)
            }
        }
    }
    
    private func completedProgress(){
        PageLog.d("completedProgress", tag: self.tag)
        withAnimation{
            self.isPlayAble = self.purchasViewerData?.isPlayAble ?? true
            self.isPlayViewActive = true
        }
        self.checkCornerPlay()
        //guard let synopsisModel = self.synopsisModel else { return }
        if self.relationContentsModel.isReady {
            PageLog.d("already synopsisRelationData", tag: self.tag)
            self.setupRelationContentCompleted ()
            self.onAllProgressCompleted()
            return
        }
    
        self.playListData = PlayListData(
            listTitle: String.pageText.synopsisSirisView,
            title: self.relationContentsModel.serisTitle,
            datas: self.relationContentsModel.playList
            )
         
        PageLog.d("request synopsisRelationData", tag: self.tag)
        if let synopsisRelationData = self.relationContentsModel.synopsisRelationData {
            self.pageDataProviderModel.request = .init(
                id: SingleRequestType.relationContents.rawValue,
                type: .getRelationContents(synopsisRelationData,anotherStbId:self.anotherStb), isOptional:true
            )
        } else {
            self.setupRelationContentCompleted ()
        }
        
    }
    func errorProgress(){
        PageLog.d("errorProgress", tag: self.tag)
        withAnimation{
            self.isPlayAble = false
            self.isPlayViewActive = true
        }
        self.playerModel.event = .pause
        self.onAllProgressCompleted()
    }
    
    func onAllProgressCompleted(){
        PageLog.d("onAllProgressCompleted", tag: self.tag)
        self.onAllProgressCompletedSiri()
         
        if #available(iOS 14.0, *) {
            withAnimation{ self.isUIView = true }
        } else {
            self.isUIView = true
        }
        self.playStartLog()
        if self.isAfterPurchase {
            self.isAfterPurchase = false
            if self.hasAuthority == true {
                self.onFullScreenViewMode()
            }
        }
        
    }
    
    
    @State var prevSrisId:String? = nil
    @State var prevDirectView:DirectView? = nil
    private func setupSynopsis (_ data:Synopsis) {
        if self.synopsisData?.srisId?.isEmpty != false { self.synopsisData?.srisId = data.contents?.sris_id }
        if self.synopsisData?.epsdId?.isEmpty != false { self.synopsisData?.epsdId = data.contents?.epsd_id }
         
        self.purchaseWebviewModel = PurchaseWebviewModel().setParam(synopsisData: data)
        if let content = data.contents {
            self.episodeViewerData = EpisodeViewerData().setData(data: content)
            self.summaryViewerData = SummaryViewerData().setData(data: content)
            if let prev = self.synopsisModel { //페이지 변경
                if self.synopsisData?.srisId != self.prevSrisId { // 시리즈변경
                    self.prevSrisId = self.synopsisData?.srisId
                    self.prevDirectView = nil
                    self.synopsisModel = SynopsisModel(type: .seasonFirst).setData(data: data)
                    
                } else { //회차변경    // if self.episodeViewerData?.count != self.srisCount
                    if prev.metvSeasonWatchAll {
                        self.prevDirectView = prev.directViewData
                        self.synopsisModel = SynopsisModel(type: .seriesChange).setData(data: data)
                    }else{
                        self.prevDirectView = nil
                        self.synopsisModel = SynopsisModel(type: .seriesChange).setData(data: data)
                    }
                }
            } else { //최초진입
                self.prevSrisId = self.synopsisData?.srisId
                self.prevDirectView = nil
                self.synopsisModel = SynopsisModel(type: .seasonFirst).setData(data: data)
            }
            if self.checkeRedirect() { return }
            self.epsdId = self.synopsisModel?.epsdId
            if self.isPairing == false && !self.isPosson {
                self.synopsisModel?.setData(directViewData: nil)
                self.purchasViewerData = PurchaseViewerData(type: self.type).setData(
                        synopsisModel: self.synopsisModel,
                    isPairing: self.isPairing, isPosson: self.isPosson)
                self.hasAuthority = false
            }
            
            if let kidYn = self.synopsisModel?.kidsYn {self.synopsisData?.kidZone = kidYn }
            self.isRecommand = self.synopsisModel?.isRecommandAble
            self.epsdRsluId = self.synopsisModel?.epsdRsluId ?? self.epsdRsluId
            self.synopsisData?.epsdRsluId = self.epsdRsluId
            self.synopsisModel?.purchasedPid = self.purchasedPid
            self.title = self.episodeViewerData?.episodeTitle
            self.imgBg = self.synopsisModel?.imgBg
            self.imgContentMode = self.synopsisModel?.imgContentMode ?? .fit
            self.relationContentsModel.reset(synopsisType: self.synopsisModel?.synopsisType, pageType: self.type)
            self.relationContentsModel.selectedEpsdId = self.epsdId
            DataLog.d("PageSynopsis epsdId  : " + (self.epsdId ?? "nil"), tag: self.tag)
            DataLog.d("PageSynopsis epsdRsluId  : " + self.epsdRsluId, tag: self.tag)
            DataLog.d("PageSynopsis isRecommand  : " + (self.isRecommand.debugDescription), tag: self.tag)
        } else {
            self.progressError = true
            PageLog.d("setupSynopsis error", tag: self.tag)
        }
    }
        
    private func setupDirectView (_ data:DirectView, isSeasonWatchAll:Bool = false){
        PageLog.d("setupDirectView", tag: self.tag)
        self.purchaseWebviewModel?.setParam(directView: data, monthlyPid: nil)
        self.synopsisModel?.setData(directViewData: data, isSeasonWatchAll: isSeasonWatchAll)
        self.relationContentsModel.setData(synopsis: self.synopsisModel)
        self.isBookmark = self.synopsisModel?.isBookmark
        PageLog.d("self.isBookmark " + (self.isBookmark?.description ?? "nil"), tag: self.tag)
        self.purchasViewerData = PurchaseViewerData(type: self.type).setData(
                synopsisModel: self.synopsisModel,
                isPairing: self.isPairing,
                isPosson:self.isPosson)
        
        if !isSeasonWatchAll, let lastWatch = data.last_watch_info {
            if let t = lastWatch.watch_rt?.toInt() {
                switch self.synopsisPlayType {
                case .vod(_, let autoPlay): self.synopsisPlayType = .vod(Double(t), autoPlay)
                case .vodChange(_, let autoPlay): self.synopsisPlayType = .vodChange(Double(t), autoPlay)
                case .vodNext(_, let autoPlay): self.synopsisPlayType = .vodNext(Double(t), autoPlay)
                default: break
                }
            }
        }
        self.textInfo = self.purchasViewerData?.serviceInfo
        self.epsdRsluId = self.synopsisModel?.curSynopsisItem?.epsd_rslu_id ?? self.synopsisModel?.epsdRsluId ?? ""
        if self.purchasViewerData?.isPlayAble == true {
            self.hasAuthority = self.purchasViewerData?.hasAuthority
        } else{
            self.hasAuthority = false
        }
        ComponentLog.d("hasAuthority " + (hasAuthority?.description ?? "nil"), tag: self.tag)
        //self.infinityScrollModel.uiEvent = .scrollTo(self.infinityScrollModel.topIdx)
    }
    
    private func setupPreview (_ data:Preview){
        self.relationContentsModel.setData(synopsis: self.synopsisModel)
        if data.result != ApiCode.success {
            PageLog.d("fail PreviewInfo", tag: self.tag)
            self.errorProgress()
            return
        }
        guard let dataInfo = data.CTS_INFO else {
            PageLog.d("error PreviewInfo", tag: self.tag)
            self.errorProgress()
            return
        }
        PageLog.d("setupPreview", tag: self.tag)
        if let synopsis = self.synopsisModel {
            let prerollData = SynopsisPrerollData()
                .setData(data: synopsis, playType: self.synopsisPlayType, epsdRsluId: self.epsdRsluId)
            self.playerData = SynopsisPlayerData()
                .setData(type: self.synopsisPlayType,
                         synopsis: synopsis, relationContentsModel: self.relationContentsModel)
            self.playerModel
                .setData(synopsisPrerollData: prerollData)
                .setData(synopsisPlayData: self.playerData)
                .setData(data: dataInfo,
                         type: .preview(self.epsdRsluId),
                         autoPlay: self.isAutoPlay)
            withAnimation{self.isPlayAble = true}

        }
    }
    
    private func setupPlay (_ data:Play){
        if data.result != ApiCode.success {
            PageLog.d("fail Play", tag: self.tag)
            self.errorProgress()
            return
        }
        guard let dataInfo = data.CTS_INFO else {
            PageLog.d("error PlayInfo", tag: self.tag)
            self.errorProgress()
            return
        }
        if let synopsis = self.synopsisModel {
            self.bindWatchingData()
            let prerollData = SynopsisPrerollData()
                .setData(data: synopsis, playType: self.synopsisPlayType, epsdRsluId: self.epsdRsluId)
            
            self.playerData = SynopsisPlayerData()
                .setData(type: self.synopsisPlayType, synopsis: synopsis, relationContentsModel:self.relationContentsModel)
            
            self.playerModel
                .setData(synopsisPrerollData: prerollData)
                .setData(synopsisPlayData: self.playerData)
                .setData(data: dataInfo, type: .vod(self.epsdRsluId,self.title),
                         autoPlay: self.isAutoPlay)
            
            if self.hasAuthority == true {
                self.playerModel.continuousProgress = self.synopsisData?.progress
                self.playerModel.continuousProgressTime = self.synopsisData?.progressTime
            }
        }
       
    }
    
    /*
     Player process
     */
    
    func watchBtv(){
        if self.isPairing != true {
            self.appSceneObserver.alert = .needPairing()
            return
        }
        self.onDefaultViewMode()
        let msg:NpsMessage = NpsMessage().setPlayVodMessage(
            contentId: self.epsdRsluId ,
            playTime: self.playerModel.time)
        
        self.pageDataProviderModel.request = .init(id : SingleRequestType.watchBtv.rawValue, type: .sendMessage( msg))
        self.playerModel.event = .pause
    }
    
    func watchBtvCompleted(isSuccess:Bool){
        if isSuccess {
            if self.setup.autoRemocon {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.remotecon)
                )
            }
            self.appSceneObserver.event = .toast(String.alert.btvplaySuccess)
        } else {
            self.appSceneObserver.event = .toast(String.alert.btvplayFail)
        }
    }
    
    
   
    
}

#if DEBUG
struct PageSynopsis_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageSynopsis().contentBody
                .environmentObject(Repository())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .environmentObject(Setup())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif





