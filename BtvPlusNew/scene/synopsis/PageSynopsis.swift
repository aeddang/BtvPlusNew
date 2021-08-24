//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
extension PageSynopsis {
    enum ComponentEvent {
        case changeVod(String?), changeSynopsis(SynopsisData?), changeOption(PurchaseModel?), purchase, watchBtv
    }
    class ComponentViewModel:ComponentObservable{
        @Published var uiEvent:ComponentEvent? = nil {didSet{ if uiEvent != nil { uiEvent = nil} }}
    }
    
    static let useLayer:Bool = false
    static let getSynopData:Int = 0
    static let getAuth:Int = 1
    static let getPlay:Int = 2
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
                            topIdx: self.topIdx,
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
                        .modifier(PageFull(style:.kidsLight))
                    }
                }//PageDragingBody
                .onReceive(self.playerModel.$btvPlayerEvent){evt in
                    guard let evt = evt else { return }
                    self.onEvent(btvPlayerEvent: evt)
                    switch evt {
                    case .close : self.historyBack()
                    case .nextView : self.nextVod(auto: false)
                    case .continueView: self.continueVod()
                    case .changeView(let epsdId) : self.changeVod(epsdId:epsdId)
                    default : break
                    }
                }
                .onReceive(self.prerollModel.$event){evt in
                    guard let evt = evt else { return }
                    self.onEvent(prerollEvent: evt)
                }
                .onReceive(self.playerModel.$btvUiEvent){evt in
                    guard let evt = evt else { return }
                    self.onEvent(btvUiEvent: evt)
                }
                .onReceive(self.playerModel.$event){evt in
                    guard let evt = evt else { return }
                    switch evt {
                    case .fullScreen(_) :
                        self.onFullScreenControl()
                    default : break
                    }
                    self.onEvent(event: evt)
                }
                .onReceive(self.playerModel.$streamEvent){evt in
                    guard let evt = evt else { return }
                    self.onEvent(streamEvent: evt)
                }
                .onReceive(self.playerModel.$playerStatus){status in
                    guard let status = status else { return }
                    self.onStatus(playerStatus: status)
                }
                .onReceive(self.playerModel.$streamStatus){status in
                    guard let status = status else { return }
                    self.onStatus(streamStatus: status)
                }
                .onReceive(self.tabNavigationModel.$index ){ idx in
                    if idx == self.selectedRelationTabIdx { return }
                    self.selectedRelationContent(idx:idx)
                }
                .onReceive(self.componentViewModel.$uiEvent){evt in
                    guard let evt = evt else { return }
                    switch evt {
                    case .changeVod(let epsdId) : self.changeVod(epsdId:epsdId)
                    case .changeSynopsis(let data): self.changeVod(synopsisData: data)
                    case .changeOption(let option) : self.changeOption(option)
                    case .purchase : self.purchase()
                    case .watchBtv : self.watchBtv()
                    }
                }
            }//PageDataProviderContent
            
            .onReceive(self.pageObservable.$layer ){ layer  in
                switch layer {
                case .bottom : self.isUiActive = false
                case .top, .below : self.isUiActive = true
                }
            }
            .onReceive(self.pairing.$event){evt in
                guard let _ = evt else {return}
                self.isPageDataReady = true
                switch evt {
                case .pairingCompleted : self.initPage()
                case .disConnected : self.initPage()
                case .pairingCheckCompleted(let isSuccess) :
                    if isSuccess { self.initPage() }
                    else { self.appSceneObserver.alert = .pairingCheckFail }
                default : do{}
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
                default : do{}
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
                    case .purchase(let pid, _, _) :
                        self.purchasedPid = pid
                        self.resetPage()
                    default : break
                    }
                default : break
                }
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
                }
            }
            .onReceive(self.pagePresenter.$isFullScreen){fullScreen in
                self.isFullScreen = fullScreen
                if self.type == .btv {
                    self.appSceneObserver.useBottom = !fullScreen
                }
            }
            .onReceive(self.playerModel.$streamEvent){evt in
                guard let _ = evt else {return}
                switch evt {
                case .completed : self.playCompleted()
                default : do{}
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.isPageUiReady = true
                    self.initPage()
                }
            }
            .onReceive(self.sceneObserver.$isUpdated){ _ in
                self.sceneOrientation = self.sceneObserver.sceneOrientation
                
                if self.relationDatas.isEmpty == false {
                    let relationDatas = self.relationContentsModel.getRelationContentSets(idx: self.selectedRelationTabIdx, row: self.relationRow)
                    self.relationDatas = relationDatas
                }
                
            }
            .onReceive(self.appSceneObserver.$safeBottomHeight) { _ in
                self.updateBottomPos(geometry: geometry)
            }
            .onReceive(self.self.pageDragingModel.$event){ evt in
                guard let evt = evt else {return}
                guard let page  = self.pageObject  else { return }
                switch evt {
                case .dragInit :
                    self.isPlayBeforeDraging = self.playerModel.isPlay
                    self.playerModel.event = .pause
                    self.pagePresenter.setLayerPopup(pageObject: page, isLayer: false)
                    withAnimation{
                        self.dragOffset = 0
                    }
                case .drag(_, let dragOpacity) :
                    self.dragOpacity = dragOpacity
                case .draged: if self.isPlayBeforeDraging {
                    self.playerModel.event = .resume
                    }
                }
                
            }
            .onAppear{
                self.sceneOrientation = self.sceneObserver.sceneOrientation
                self.onLayerPlayerAppear() 
                guard let obj = self.pageObject  else { return }
                self.setupHistory(synopsisData:self.getSynopData(obj: obj))
                self.initPage()
            }
            .onDisappear(){
                self.onLayerPlayerDisappear()
                if self.isPlayAble {
                    self.log(type: .playBase) 
                }
            }
        }//geo
    }//body
    /*
    Data process
    */
    enum SingleRequestType:String {
        case preview, changeOption, relationContents, prohibitionSimultaneous
    }
    enum UiType{
        case simple, normal
    }
    @State var historys:[SynopsisData] = []
    @State var isInitPage = false
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
    @State var isPlayAble:Bool = false
    @State var isPlayViewActive = false
    @State var isPageUiReady = false
    @State var isPageDataReady = false
    @State var topIdx:Int = 0
    @State var isUIView:Bool = false
    
    /*동기화 value*/
    @State var epsdId:String? = nil
    @State var epsdRsluId:String = ""
    @State var purchasedPid:String? = nil
    @State var playStartTime:Int? = nil
    
    /*Layer*/
    @State var isBottom:Bool = false
    @State var uiType:UiType = .normal
    @State var dragOffset:CGFloat = 0
    @State var dragOpacity:Double = 1
    
    func getSynopData(obj:PageObject)->SynopsisData {
        if let synopsisData = obj.getParamValue(key: .data) as? SynopsisData {
            return synopsisData
        } else {
            if let json = obj.getParamValue(key: .data) as? SynopsisJson {
                return SynopsisData(
                    srisId: json.srisId, searchType:EuxpNetwork.SearchType.sris.rawValue, epsdId: json.epsdId,
                    epsdRsluId: json.episodeResolutionId, prdPrcId: json.pid, kidZone: nil,
                    synopType: SynopsisType(value: json.synopType)
                )
            }
            if let qurry = obj.getParamValue(key: .data) as? SynopsisQurry {
                return SynopsisData(
                    srisId:  qurry.srisId, searchType:EuxpNetwork.SearchType.sris.rawValue, epsdId:  qurry.epsdId,
                    epsdRsluId: nil, prdPrcId: nil, kidZone: nil,
                    synopType: SynopsisType.none
                )
            }
        }
        return SynopsisData()
    }
    
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
    func setupHistory(synopsisData:SynopsisData){
        if let currentSynop = self.synopsisData {
            if self.historys.last?.epsdId != currentSynop.epsdId {
                self.historys.append(currentSynop)
            }
        }
        self.synopsisData = synopsisData
    }
    func historyBack(){
        if !self.historys.isEmpty {
            let history = self.historys.removeLast()
            self.synopsisData = history
            self.resetPage(isAllReset: true)
        } else {
            self.pagePresenter.closePopup(self.pageObject?.id)
        }
    }
    private func resetPage(isAllReset:Bool = false){
        PageLog.d("resetPage", tag: self.tag)
        self.playerModel.event = .stop
        self.isUIView = false
        self.hasAuthority = nil
        self.progressError = false
        self.progressCompleted = false
        self.episodeViewerData = nil
        self.purchasViewerData = nil
        self.summaryViewerData = nil
        self.purchaseWebviewModel = nil
        self.playerData = nil
        self.title = nil
        self.imgBg = nil
        self.textInfo = nil
        if isAllReset {
            self.resetRelationVod()
        } else if self.type == .btv && self.sceneOrientation == .portrait {
            //self.resetRelationVod()
        }
        self.pageDataProviderModel.initate()
        self.topIdx = UUID.init().hashValue
        withAnimation{
            self.isPlayViewActive = false
        }
    }
    
    private func resetRelationVod(){
        self.relationTab = []
        self.seris = []
        self.relationDatas = []
        self.hasRelationVod = nil
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
            self.pageDataProviderModel.requestProgress( q: .init(type: .getSynopsis(data)))
        
        case Self.getAuth :
            guard let model = self.synopsisModel else {return}
          
            if self.isPairing == true {
                if self.episodeViewerData?.isAdult == true && !SystemEnvironment.isAdultAuth{
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.adultCertification)
                            .addParam(key: .data, value:self.pageObject)
                    )
                    self.pagePresenter.closePopup(self.pageObject?.id)
                    return
                }
                if model.synopsisType == .seriesChange , let prevDirectView = self.prevDirectView {
                    self.setupDirectView(prevDirectView, isSeasonWatchAll:true) // 권한 대이타 재사용
                    self.pageDataProviderModel.requestProgressSkip()
                } else {
                    self.pageDataProviderModel.requestProgress(q: .init(type: .getDirectView(model)))
                }
            }else{
                if self.episodeViewerData?.isAdult == true {
                    self.appSceneObserver.alert = .needPairing()
                    self.pagePresenter.closePopup(self.pageObject?.id)
                    return
                }
                self.pageDataProviderModel.requestProgressSkip()
                /*
                if model.hasExamPreview{
                    self.synopsisPlayType = .preplay()
                    self.pageDataProviderModel.requestProgress(q: .init(type: .getPreplay(self.epsdRsluId,  true )))
                }
                else if model.hasPreview{
                    self.synopsisPlayType = .preview(0)
                    let item = model.previews[0]
                    self.pageDataProviderModel.requestProgress(q: .init(type: .getPreplay(item.epsd_rslu_id,  false )))
                } else {
                    PageLog.d("no preview", tag: self.tag)
                    self.errorProgress()
                }
                self.progressCompleted = true
                */
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
                self.synopsisPlayType = .vod()
                self.pageDataProviderModel.requestProgress(q: .init(type: .getPlay(self.epsdRsluId,  self.pairing.hostDevice )))
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
            if self.isPairing == true {
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
            }
            if res.id.hasPrefix( SingleRequestType.changeOption.rawValue ) {
                guard let data = res.data as? Play else {
                    PageLog.d("error changeOption", tag: self.tag)
                    self.errorProgress()
                    return
                }
                self.setupPlay(data)
            }
            if res.id.hasPrefix( SingleRequestType.relationContents.rawValue ) {
                guard let data = res.data as? RelationContents else {
                    PageLog.d("error relationContents", tag: self.tag)
                    self.setupRelationContent(nil)
                    return
                }
                self.setupRelationContent(data)
            }
            if res.id.hasPrefix( SingleRequestType.prohibitionSimultaneous.rawValue ) {
                guard let data = res.data as? ProhibitionSimultaneous else { return }
                self.setupProhibitionSimultaneous(data)
            }
        }
    }
    
    private func errorProgress(progress:Int, err:ApiResultError, count:Int){
        switch progress {
        case 0 : self.progressError = true
        case 1 : self.progressError = true
        default :
            if  err.id.hasPrefix( SingleRequestType.relationContents.rawValue ) {
                PageLog.d("error relationContents", tag: self.tag)
                self.setupRelationContent(nil)
            }
            if  err.id.hasPrefix( SingleRequestType.preview.rawValue ) {
                PageLog.d("error preview", tag: self.tag)
                self.errorProgress()
            }
            if  err.id.hasPrefix( SingleRequestType.changeOption.rawValue ) {
                PageLog.d("error changeOption", tag: self.tag)
                self.errorProgress()
            }
        }
    }
    
    private func completedProgress(){
        PageLog.d("completedProgress", tag: self.tag)
        withAnimation{
            self.isPlayAble = self.purchasViewerData?.isPlayAble ?? true
            self.isPlayViewActive = true
        }
        
        guard let synopsisModel = self.synopsisModel else { return }
        if self.relationContentsModel.isReady {
            PageLog.d("already synopsisRelationData", tag: self.tag)
            self.setupRelationContentCompleted ()
            self.onAllProgressCompleted()
            return
        }
        
        self.relationContentsModel.setData(synopsis: synopsisModel)
        self.playListData = PlayListData(
            listTitle: String.pageText.synopsisSirisView,
            title: self.relationContentsModel.serisTitle,
            datas: self.relationContentsModel.playList
            )
         
        PageLog.d("request synopsisRelationData", tag: self.tag)
        if let synopsisRelationData = self.relationContentsModel.synopsisRelationData {
            self.pageDataProviderModel.request = .init(
                id: SingleRequestType.relationContents.rawValue,
                type: .getRelationContents(synopsisRelationData), isOptional:true
            )
        } else {
            self.setupRelationContentCompleted ()
        }
        
    }
    private func errorProgress(){
        PageLog.d("errorProgress", tag: self.tag)
        withAnimation{
            self.isPlayAble = false
            self.isPlayViewActive = true
        }
        self.playerModel.event = .stop
        self.onAllProgressCompleted()
    }
    
    private func onAllProgressCompleted(){
        PageLog.d("onAllProgressCompleted", tag: self.tag)
        if #available(iOS 14.0, *) {
            withAnimation{ self.isUIView = true }
        } else {
            self.isUIView = true
        }
        self.playStartLog()
        if self.pairing.status == .pairing && self.hasAuthority == true , let synopsisData = self.synopsisData {
            //동시시청체크
            self.pageDataProviderModel.request = .init(
                id: SingleRequestType.prohibitionSimultaneous.rawValue,
                type: .checkProhibitionSimultaneous(
                    synopsisData ,
                    self.pairing,
                    pcId: self.repository.storage.getPcid()), isOptional:true
            )
        }
    }
    
    private func setupProhibitionSimultaneous(_ data:ProhibitionSimultaneous){
        if data.has_authority?.toBool() == false {
            let reason = VlsNetwork.ProhibitionReason.getType(data.has_authority_reason)
            self.playerModel.event = .stop
            self.appSceneObserver.alert = .alert(String.alert.playProhibitionSimultaneous, reason.reason){
                self.pagePresenter.closePopup(self.pageObject?.id)
            }
            self.prohibitionSimultaneousLog(reason: reason) 
        }
    }
        
    @State var prevSrisId:String? = nil
    @State var prevDirectView:DirectView? = nil
    private func setupSynopsis (_ data:Synopsis) {
        if self.synopsisData?.srisId?.isEmpty != false { self.synopsisData?.srisId = data.contents?.sris_id }
        if self.synopsisData?.epsdId?.isEmpty != false { self.synopsisData?.epsdId = data.contents?.epsd_id }
        PageLog.d("srisId " + (self.synopsisData?.srisId ?? "nil"), tag: self.tag)
        PageLog.d("epsdId " + (self.synopsisData?.epsdId ?? "nil"), tag: self.tag)
        
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
           
            if self.isPairing == false {
                self.synopsisModel?.setData(directViewData: nil)
                self.purchasViewerData = PurchaseViewerData(type: self.type).setData(
                        synopsisModel: self.synopsisModel,
                        isPairing: self.isPairing)
                self.hasAuthority = false
            }
            
            if let kidYn = self.synopsisModel?.kidsYn {self.synopsisData?.kidZone = kidYn }
            self.epsdId = self.synopsisModel?.epsdId
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
        self.isBookmark = self.synopsisModel?.isBookmark
        PageLog.d("self.isBookmark " + (self.isBookmark?.description ?? "nil"), tag: self.tag)
        self.purchasViewerData = PurchaseViewerData(type: self.type).setData(
                synopsisModel: self.synopsisModel,
                isPairing: self.isPairing)
        
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
        if self.purchasViewerData?.isPlayAble == true, let curSynopsisItem = self.synopsisModel?.curSynopsisItem {
            self.hasAuthority = curSynopsisItem.hasAuthority
        } else{
            self.hasAuthority = false
        }
        ComponentLog.d("hasAuthority " + (hasAuthority?.description ?? "nil"), tag: self.tag)
        //self.infinityScrollModel.uiEvent = .scrollTo(self.infinityScrollModel.topIdx)
    }
    
    private func setupPreview (_ data:Preview){
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
            self.playerData = SynopsisPlayerData().setData(type: self.synopsisPlayType, synopsis: synopsis)
            self.playerModel
                .setData(synopsisPrerollData: prerollData)
                .setData(synopsisPlayData: self.playerData)
                .setData(data: dataInfo, type: .preview(self.epsdRsluId))
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
                .setData(type: self.synopsisPlayType, synopsis: synopsis)
            self.playerModel
                .setData(synopsisPrerollData: prerollData)
                .setData(synopsisPlayData: self.playerData)
                .setData(data: dataInfo, type: .vod(self.epsdRsluId,self.title))
        }
    }
    
    private func setupRelationContent (_ data:RelationContents?){
        self.relationContentsModel.setData(data: data)
        if self.relationContentsModel.unavailableSeris,
           let epsdId = self.relationContentsModel.getAvailableSeris()?.epsdId {
            self.changeVod( epsdId: epsdId)
            return
        }
        self.setupRelationContentCompleted ()
    }
    
    private func setupRelationContentCompleted (){
        self.updateRelationTabButtons(idx: self.tabNavigationModel.index)
            
        if self.relationTab.isEmpty {
            self.hasRelationVod = false
        }else{
            self.hasRelationVod = true
            self.selectedRelationContent(idx:0)
        }
        self.onAllProgressCompleted()
    }
    
    
    private var relationRow:Int {
       get {
           return
            self.type == .kids 
            ? 1
            :  self.sceneOrientation == .landscape ? 2
               : SystemEnvironment.isTablet ? 4 : 3
       }
   }
    private func selectedRelationContent (idx:Int){
        self.updateRelationTabButtons(idx: idx)
        self.tabNavigationModel.index = idx
        self.selectedRelationTabIdx = idx
       
        PageLog.d("selectedRelationContent", tag: self.tag)
        self.seris = []
        self.relationDatas = []
        var relationContentsIdx = self.selectedRelationTabIdx
        if !self.relationContentsModel.seris.isEmpty {
            if self.selectedRelationTabIdx == 0 {
                let sorted = self.relationContentsModel.getSerisDatas()
                self.seris = sorted
                return
            }else{
                relationContentsIdx = self.selectedRelationTabIdx-1
            }
        } 
        if self.relationContentsModel.relationContents.isEmpty { return }
        if relationContentsIdx >= self.relationContentsModel.relationContents.count  { return }
        
        let relationDatas = self.relationContentsModel.getRelationContentSets(idx: relationContentsIdx, row: self.relationRow)
        self.relationDatas = relationDatas
    }
    
    private func updateRelationTabButtons(idx:Int){
        self.relationTab = NavigationBuilder(
            index:idx,
            marginH:Dimen.margin.regular)
            .getNavigationButtons(texts:self.relationContentsModel.relationTabs)
    }
    
    /*
     Player process
     */
    private func playCompleted(){
        switch playerData?.type {
        case .preplay:
            self.preplayCompleted()
        case .preview(let count, _):
            if !self.nextPreview(count: count) {
                self.previewCompleted()
            }
        case .vod:
            if !self.nextVod() {
                self.vodCompleted()
            }
        default:do{}
        }
    }
    
    private func nextPreview(count:Int)->Bool{
        guard let playData = self.playerData else { return false}
        guard let previews = playData.previews else { return false}
        if !self.setup.nextPlay { return false}
        let next = count + 1
        if previews.count <= next { return false}
        self.synopsisPlayType = .preview(next)
        if self.isPairing == true {
            let item = previews[next]
            self.epsdRsluId = item.epsd_rslu_id ?? ""
            self.pageDataProviderModel.request = .init(
                id: SingleRequestType.preview.rawValue,
                type: .getPreview(item.epsd_rslu_id,  self.pairing.hostDevice))
           
        }else{
            let item = previews[next]
            self.epsdRsluId = item.epsd_rslu_id ?? ""
            self.pageDataProviderModel.request = .init(
                id: SingleRequestType.preview.rawValue,
                type: .getPreplay(item.epsd_rslu_id,  false))
        }
        return true
    }
    
    @discardableResult
    private func nextVod(auto:Bool = true)->Bool{
        guard let prevData = self.synopsisData else { return false}
        guard let playData = self.playerData else { return false}
        if !self.setup.nextPlay && auto { return false}
        if !playData.hasNext { return false}
        
        self.epsdRsluId = ""
        self.synopsisPlayType = .vodNext()
        let nextSynopsisData = SynopsisData(
            srisId: playData.nextSeason ?? prevData.srisId,
            searchType: prevData.searchType,
            epsdId: playData.nextEpisode,
            epsdRsluId: nil,
            prdPrcId: prevData.prdPrcId,
            kidZone: prevData.kidZone,
            synopType: prevData.synopType
        )
        
        self.setupHistory(synopsisData:nextSynopsisData)
        self.resetPage()
        return true
    }
    
    private func preplayCompleted(){
        PageLog.d("prevplayCompleted", tag: self.tag)
        self.continueVod()
    }
    
    private func previewCompleted(){
        PageLog.d("previewCompleted", tag: self.tag)
    }
    
    private func vodCompleted(){
        PageLog.d("vodCompleted", tag: self.tag)
    }
    
    private func continueVod(){
        if self.pairing.status != .pairing {
            self.appSceneObserver.alert = .needPairing(String.alert.needConnectForView)
            return
        }
        if self.hasAuthority == false {
            guard  let model = self.purchaseWebviewModel else { return }
            self.appSceneObserver.alert = .needPurchase(model)
        }
    }
    
    func changeOption(_ option:PurchaseModel?){
        guard let option = option else { return }
        self.epsdRsluId = option.epsd_rslu_id
        self.synopsisPlayType = .vodChange()
        self.pageDataProviderModel.request = .init(
            id: SingleRequestType.changeOption.rawValue,
            type: .getPlay(self.epsdRsluId,  self.pairing.hostDevice ))
    }
    
    func changeVod(synopsisData:SynopsisData?, isHistoryBack:Bool=false){
        guard let synopsisData = synopsisData else { return }
        self.setupHistory(synopsisData:synopsisData)
        self.resetPage(isAllReset: true)
    }
    
    func changeVod(epsdId:String?){
        guard let epsdId = epsdId else { return }
        guard let cdata = self.synopsisData else { return }
        self.setupHistory(synopsisData:
            SynopsisData(
                srisId: cdata.srisId, searchType: cdata.searchType,
                epsdId: epsdId, epsdRsluId: "",
                prdPrcId: cdata.prdPrcId, kidZone:cdata.kidZone,
                synopType: cdata.synopType
            )
        )
        self.resetPage()
    }
    
    func purchase(){
        guard  let model = self.purchaseWebviewModel else { return }
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.purchase)
                .addParam(key: .data, value: model)
        )
    }
    
    func watchBtv(){
        guard let isPurchased = self.synopsisModel?.isPurchased else { return }
        if !isPurchased {
            guard  let model = self.purchaseWebviewModel else { return }
            self.appSceneObserver.alert = .needPurchase(model, String.alert.purchaseContinueBtv)
            
        } else {
            let msg:NpsMessage = NpsMessage().setPlayVodMessage(
                contentId: self.epsdRsluId ,
                playTime: self.playerModel.time)
            
            self.pageDataProviderModel.request = .init(type: .sendMessage( msg))
            
            if self.setup.autoRemocon {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.remotecon)
                )
            }
            self.playerModel.event = .pause
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





