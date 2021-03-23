//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PageSynopsis: PageView {
    enum ComponentEvent {
        case changeVod(String?), changeSynopsis(SynopsisData?), changeOption(PurchaseModel?), purchase
    }
    class ComponentViewModel:ComponentObservable{
        @Published var uiEvent:ComponentEvent? = nil {didSet{ if uiEvent != nil { uiEvent = nil} }}
    }
    
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var setup:Setup
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var componentViewModel:ComponentViewModel = ComponentViewModel()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var pageDataProviderModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var playerModel: BtvPlayerModel = BtvPlayerModel()
    @ObservedObject var peopleScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var prerollModel = PrerollModel()
    @ObservedObject var playerListViewModel: InfinityScrollModel = InfinityScrollModel()
    
    @State var synopsisData:SynopsisData? = nil
    @State var isPairing:Bool? = nil
    @State var isFullScreen:Bool = false
    @State var useTracking:Bool = false
    @State var isUiActive:Bool = true
    var body: some View {
        GeometryReader { geometry in
            PageDataProviderContent(
                viewModel: self.pageDataProviderModel
            ){
                PageDragingBody(
                    viewModel:self.pageDragingModel,
                    axis:.horizontal
                ) {
                    VStack(spacing:0){
                        SynopsisTop(
                            pageObservable: self.pageObservable,
                            playerModel: self.playerModel,
                            playerListViewModel: self.playerListViewModel,
                            prerollModel: self.prerollModel,
                            title: self.title,
                            imgBg: self.imgBg,
                            imgContentMode: self.imgContentMode,
                            textInfo: self.textInfo,
                            epsdId: self.epsdId,
                            playListData: self.playListData,
                            isPlayAble: self.isPlayAble,
                            isPlayViewActive: self.isPlayViewActive)
                        .modifier(Ratio16_9( geometry:geometry, isFullScreen: self.isFullScreen))
                        .padding(.top, self.sceneObserver.safeAreaTop)
                        .onReceive(self.playerModel.$btvPlayerEvent){evt in
                            guard let evt = evt else { return }
                            switch evt {
                            case .nextView : self.nextVod(auto: false)
                            case .continueView: self.continueVod()
                            case .changeView(let epsdId) : self.changeVod(epsdId:epsdId)
                            }
                        }
                        
                        if !self.isFullScreen {
                            if self.isUIView && self.isUiActive && !self.progressError {
                                SynopsisBody(
                                    componentViewModel: self.componentViewModel,
                                    infinityScrollModel: self.infinityScrollModel,
                                    relationContentsModel: self.relationContentsModel,
                                    peopleScrollModel: self.peopleScrollModel,
                                    pageDragingModel: self.pageDragingModel,
                                    isBookmark: self.$isBookmark,
                                    isLike: self.$isLike,
                                    relationTabIdx: self.$relationTabIdx,
                                    seris: self.$seris,
                                    topIdx : self.topIdx,
                                    synopsisData: self.synopsisData,
                                    isPairing: self.isPairing,
                                    episodeViewerData: self.episodeViewerData,
                                    purchasViewerData: self.purchasViewerData,
                                    summaryViewerData: self.summaryViewerData,
                                    srisId: self.srisId, epsdId: self.epsdId,
                                    hasAuthority: self.hasAuthority,
                                    relationTab: self.relationTab,
                                    relationDatas: self.relationDatas,
                                    hasRelationVod: self.hasRelationVod,
                                    useTracking:self.useTracking)
                                   
                                    .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                                    .onReceive(self.peopleScrollModel.$event){evt in
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
                                        self.pageDragingModel.uiEvent = .pull(geometry, pos)
                                    }
                                
                            } else {
                                ZStack{
                                    if self.progressError {
                                        EmptyAlert(text: self.synopsisData == nil ? String.alert.dataError : String.alert.apiErrorServer)
                                            
                                    } else {
                                        Spacer().modifier(MatchParent())
                                    }
                                }
                                .modifier(MatchParent())
                                .background(Color.brand.bg)
                                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                            }
                        }
                    }
                    .onReceive( [self.relationTabIdx].publisher ){ idx in
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
                        }
                    }
                    .modifier(PageFull())
                }//PageDragingBody
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
                if page != self.pageObject {
                    self.isFinalPlaying = self.playerModel.isPrerollPlay ? true : self.playerModel.isPlay
                    self.playerModel.event = .pause
                    ComponentLog.d("isFinalPlaying pause" , tag: "BtvPlayer")
                } else {
                    if self.isFinalPlaying == true {
                        self.playerModel.event = .resume
                        self.isFinalPlaying = false
                        ComponentLog.d("isFinalPlaying resume" , tag: "BtvPlayer")
                    }
                }
                self.useTracking = page?.id == self.pageObject?.id
            }
            .onReceive(self.pagePresenter.$isFullScreen){fullScreen in
                self.isFullScreen = fullScreen
            }
            .onReceive(self.playerModel.$streamEvent){evt in
                guard let _ = evt else {return}
                switch evt {
                case .completed : self.playCompleted()
                default : do{}
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
                if ani {
                    self.isPageUiReady = true
                    self.initPage()
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.synopsisData = obj.getParamValue(key: .data) as? SynopsisData
                if self.synopsisData == nil {
                    if let json = obj.getParamValue(key: .data) as? SynopsisJson {
                        self.synopsisData = SynopsisData(
                            srisId: json.srisId, searchType:EuxpNetwork.SearchType.sris.rawValue, epsdId: json.epsdId,
                            epsdRsluId: json.episodeResolutionId, prdPrcId: json.pid, kidZone: nil)
                    }
                    if let qurry = obj.getParamValue(key: .data) as? SynopsisQurry {
                        self.synopsisData = SynopsisData(
                            srisId:  qurry.srisId, searchType:EuxpNetwork.SearchType.sris.rawValue, epsdId:  qurry.epsdId,
                            epsdRsluId: nil, prdPrcId: nil, kidZone: nil)
                    }
                }
                self.initPage()
            }
        }//geo
        
        
    }//body

    /*
     Data process
     */
    enum SingleRequestType:String {
        case preview, changeOption, relationContents
    }
    
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
    @State var srisId:String? = nil
    @State var srisCount:String? = nil
    @State var isBookmark:Bool? = nil
    @State var isLike:LikeStatus? = nil
    @State var epsdId:String? = nil
    @State var epsdRsluId:String = ""
    @State var purchasedPid:String? = nil
    @State var hasAuthority:Bool? = nil
    @State var relationTab:[String] = []
    @State var selectedRelationTabIdx:Int = 0
    @State var seris:[SerisData] = []
    @State var relationDatas:[PosterDataSet] = []
    @State var hasRelationVod:Bool? = nil
    @State var relationTabIdx:Int = 0
    @State var isFinalPlaying:Bool = false
    @State var isPlayAble:Bool = false
    @State var isPlayViewActive = false
    @State var isPageUiReady = false
    @State var isPageDataReady = false
    @State var topIdx:Int = 0
    @State var isUIView:Bool = false
    
    func initPage(){
        if self.synopsisData == nil {
            self.progressError = true
            return
        }
        if !self.isPageDataReady || !self.isPageUiReady { return }
        if self.pageObservable.status == .initate { return }
        self.isPairing = self.pairing.status == .pairing
        if self.isInitPage {
            self.resetPage()
            return
        }
        PageLog.d("initPage", tag: self.tag)
        self.isInitPage = true
        self.pageDataProviderModel.initate()
    }
    
    func resetPage(){
        PageLog.d("resetPage", tag: self.tag)
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
        self.relationTab = []
        self.seris = []
        self.relationDatas = []
        self.hasRelationVod = nil
        self.pageDataProviderModel.initate()
        self.topIdx = UUID.init().hashValue
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
        case 0 :
            guard let data = self.synopsisData else {
                PageLog.d("requestProgress synopsisData nil", tag: self.tag)
                self.errorProgress()
                return
            }
            self.pageDataProviderModel.requestProgress( q: .init(type: .getSynopsis(data)))
        
        case 1 :
            guard let model = self.synopsisModel else {return}
            if self.purchasViewerData?.isPlayAble == false {
                self.errorProgress()
                self.progressCompleted = true
                return
            }
            if self.isPairing == true {
                self.pageDataProviderModel.requestProgress(q: .init(type: .getDirectView(model)))
            }else{
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
            }
            
        case 2 :
            guard let model = self.synopsisModel else {return}
            if self.hasAuthority == false{
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
        default : do{}
        }
    }
    
    private func respondProgress(progress:Int, res:ApiResultResponds, count:Int){
        PageLog.d("respondProgress " + progress.description + " " + count.description, tag: self.tag)
        self.progressError = false
        switch progress {
        case 0 :
            guard let data = res.data as? Synopsis else {
                PageLog.d("error Synopsis", tag: self.tag)
                self.progressError = true
                return
            }
            self.setupSynopsis(data)
            
        case 1 :
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
        
        case 2 :
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
            if  res.id.hasPrefix( SingleRequestType.preview.rawValue ) {
                guard let data = res.data as? Preview else {
                    PageLog.d("error next Preview", tag: self.tag)
                    self.errorProgress()
                    return
                }
                self.setupPreview(data)
            }
            if  res.id.hasPrefix( SingleRequestType.changeOption.rawValue ) {
                guard let data = res.data as? Play else {
                    PageLog.d("error changeOption", tag: self.tag)
                    self.errorProgress()
                    return
                }
                self.setupPlay(data)
            }
            
            if  res.id.hasPrefix( SingleRequestType.relationContents.rawValue ) {
                guard let data = res.data as? RelationContents else {
                    PageLog.d("error relationContents", tag: self.tag)
                    self.setupRelationContent(nil)
                    return
                }
                self.setupRelationContent(data)
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
        self.onAllProgressCompleted()
    }
    private func errorProgress(){
        PageLog.d("errorProgress", tag: self.tag)
        withAnimation{
            self.isPlayAble = false
            self.isPlayViewActive = true
        }
        self.onAllProgressCompleted()
    }
    
    private func onAllProgressCompleted(){
        PageLog.d("onAllProgressCompleted(", tag: self.tag)
        if #available(iOS 14.0, *) {
            withAnimation{ self.isUIView = true }
        } else {
            self.isUIView = true
        }
    }
    

    private func setupSynopsis (_ data:Synopsis) {
        
        if self.synopsisData?.srisId?.isEmpty != false { self.synopsisData?.srisId = data.contents?.sris_id }
        if self.synopsisData?.epsdId?.isEmpty != false { self.synopsisData?.epsdId = data.contents?.epsd_id }
        PageLog.d("srisId " + (self.synopsisData?.srisId ?? "nil"), tag: self.tag)
        PageLog.d("epsdId " + (self.synopsisData?.epsdId ?? "nil"), tag: self.tag)
        self.purchaseWebviewModel = PurchaseWebviewModel().setParam(synopsisData: data)
        if let content = data.contents {
            self.episodeViewerData = EpisodeViewerData().setData(data: content)
            self.summaryViewerData = SummaryViewerData().setData(data: content)
            if self.synopsisData?.srisId != self.srisId {
                self.srisId = self.synopsisData?.srisId
                if self.synopsisModel == nil {
                    self.synopsisModel = SynopsisModel(type: .seasonFirst).setData(data: data)
                }else {
                    self.synopsisModel = SynopsisModel(type: .seriesChange).setData(data: data)
                }
            } else if self.episodeViewerData?.count != self.srisCount {
                self.synopsisModel = SynopsisModel(type: .title).setData(data: data)
            }
           
            if self.isPairing == false {
                self.synopsisModel?.setData(directViewdata: nil)
                self.purchasViewerData = PurchaseViewerData().setData(
                        synopsisModel: self.synopsisModel,
                        isPairing: self.isPairing)
                self.hasAuthority = false
            }
            
            if let kidYn = self.synopsisModel?.kidsYn {self.synopsisData?.kidZone = kidYn }

            self.epsdRsluId = self.synopsisModel?.epsdRsluId ?? self.epsdRsluId
            self.synopsisData?.epsdRsluId = self.epsdRsluId
            self.synopsisModel?.purchasedPid = self.purchasedPid
            self.title = self.episodeViewerData?.episodeTitle
            self.epsdId = self.synopsisModel?.epsdId
            self.imgBg = self.synopsisModel?.imgBg
            self.imgContentMode = self.synopsisModel?.imgContentMode ?? .fit
            self.relationContentsModel.reset(synopsisType: self.synopsisModel?.synopsisType)
            DataLog.d("PageSynopsis epsdRsluId  : " + self.epsdRsluId, tag: self.tag)
            
        } else {
            self.progressError = true
            PageLog.d("setupSynopsis error", tag: self.tag)
        }
        
    }
    
    private func setupGatewaySynopsis (_ data:GatewaySynopsis){
        PageLog.d("setupGatewaySynopsis", tag: self.tag)
    }
    
    private func setupDirectView (_ data:DirectView){
        PageLog.d("setupDirectView", tag: self.tag)
        self.purchaseWebviewModel?.setParam(directView: data, monthlyPid: nil)
        self.synopsisModel?.setData(directViewdata: data)
        self.isBookmark = self.synopsisModel?.isBookmark
        self.purchasViewerData = PurchaseViewerData().setData(
                synopsisModel: self.synopsisModel,
                isPairing: self.isPairing)
        
        if let lastWatch = data.last_watch_info {
            if let t = lastWatch.watch_rt?.toInt() {
                switch self.synopsisPlayType {
                case .vod(_, let autoPlay): self.synopsisPlayType = .vod(Double(t), autoPlay)
                case .vodChange(_, let autoPlay): self.synopsisPlayType = .vodChange(Double(t), autoPlay)
                case .vodNext(_, let autoPlay): self.synopsisPlayType = .vodNext(Double(t), autoPlay)
                default: do{}
                }
            }
        }
        self.textInfo = self.purchasViewerData?.serviceInfo
        self.epsdRsluId = self.synopsisModel?.curSynopsisItem?.epsd_rslu_id ?? self.synopsisModel?.epsdRsluId ?? ""
        if let curSynopsisItem = self.synopsisModel?.curSynopsisItem {
            self.hasAuthority = curSynopsisItem.hasAuthority
        }
        withAnimation{self.isPlayAble = true}
        self.infinityScrollModel.uiEvent = .scrollTo(self.topIdx)
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
            let prerollData = SynopsisPrerollData()
                .setData(data: synopsis, playType: self.synopsisPlayType, epsdRsluId: self.epsdRsluId)
            self.playerData = SynopsisPlayerData().setData(type: self.synopsisPlayType, synopsis: synopsis)
            self.playerModel
                .setData(synopsisPrerollData: prerollData)
                .setData(synopsisPlayData: self.playerData)
                .setData(data: dataInfo, type: .vod(self.epsdRsluId,self.title))
        }
    }
    
    private func setupRelationContent (_ data:RelationContents?){
        self.relationContentsModel.setData(data: data)
        self.setupRelationContentCompleted ()
    }
    
    private func setupRelationContentCompleted (){
        self.relationTab = self.relationContentsModel.relationTabs
        if self.relationTab.isEmpty {
            self.hasRelationVod = false
        }else{
            self.hasRelationVod = true
            self.selectedRelationContent(idx:0)
        }
    }
    
    private func selectedRelationContent (idx:Int){
        self.selectedRelationTabIdx = idx
        self.relationTabIdx = idx
        PageLog.d("selectedRelationContent", tag: self.tag)
        self.seris = []
        self.relationDatas = []
        var relationContentsIdx = self.selectedRelationTabIdx
        if !self.relationContentsModel.seris.isEmpty {
            if self.selectedRelationTabIdx == 0 {
                let sorted = self.relationContentsModel.getSerisDatas()
                DispatchQueue.main.async {//IOS13
                    self.seris = sorted
                }
                return
            }else{
                relationContentsIdx = self.selectedRelationTabIdx-1
            }
        } 
        if self.relationContentsModel.relationContents.isEmpty { return }
        if relationContentsIdx >= self.relationContentsModel.relationContents.count  { return }
        let relationDatas = self.relationContentsModel.getRelationContentSets(idx: relationContentsIdx)
        DispatchQueue.main.async {//IOS13
            self.relationDatas = relationDatas
        }
    }
    
    /*
     Player process
     */
    func playCompleted(){
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
    
    func nextPreview(count:Int)->Bool{
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
    func nextVod(auto:Bool = true)->Bool{
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
            kidZone: prevData.kidZone)
        
        self.synopsisData = nextSynopsisData
        self.resetPage()
        return true
    }
    
    func preplayCompleted(){
        PageLog.d("prevplayCompleted", tag: self.tag)
        self.continueVod()
    }
    
    func previewCompleted(){
        PageLog.d("previewCompleted", tag: self.tag)
    }
    
    func vodCompleted(){
        PageLog.d("vodCompleted", tag: self.tag)
    }
    
    func continueVod(){
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
    
    func changeVod(synopsisData:SynopsisData?){
        guard let synopsisData = synopsisData else { return }
        self.synopsisData = synopsisData
        self.resetPage()
    }
    
    func changeVod(epsdId:String?){
        guard let epsdId = epsdId else { return }
        guard let cdata = self.synopsisData else { return }
        self.synopsisData = SynopsisData(
            srisId: cdata.srisId, searchType: cdata.searchType,
            epsdId: epsdId, epsdRsluId: "", prdPrcId: cdata.prdPrcId, kidZone:cdata.kidZone
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





