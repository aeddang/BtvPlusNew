//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI



struct PageSynopsis: PageView {
    class ComponentViewModel:ComponentObservable{
        @Published var selectedOption:PurchaseModel? = nil
    }
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var setup:Setup
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var componentViewModel:ComponentViewModel = ComponentViewModel()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var pageDataProviderModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var playerModel: BtvPlayerModel = BtvPlayerModel()
    @ObservedObject var peopleScrollModel: InfinityScrollModel = InfinityScrollModel(axis: .horizontal)
    @ObservedObject var prerollModel = PrerollModel()
    @ObservedObject var playerListViewModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var relationContentsModel:RelationContentsModel = RelationContentsModel()
    
    
    @State var isPairing:Bool? = nil
    @State var hasAuthority:Bool? = nil
    @State var synopsisData:SynopsisData? = nil
    @State var isFullScreen:Bool = false
    @State var relationTabIdx:Int = 0
    @State var safeAreaBottom:CGFloat = 0
    
    enum SingleRequestType:String {
        case preview, changeOption, relationContents
    }
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
                        ZStack {
                            BtvPlayer(
                                pageObservable:self.pageObservable,
                                viewModel:self.playerModel,
                                prerollModel:self.prerollModel,
                                listViewModel: self.playerListViewModel,
                                title: self.title,
                                thumbImage: self.imgBg,
                                thumbContentMode: self.imgContentMode,
                                contentID:self.epsdId,
                                listData: self.playListData
                            )
                            .onReceive(self.playerModel.$btvPlayerEvent){evt in
                                guard let evt = evt else { return }
                                switch evt {
                                case .nextView : self.nextVod()
                                case .continueView: self.continueVod()
                                case .changeView(let epsdId) : self.changeVod(epsdId:epsdId)
                                }
                            }
                            if !self.isPlayAble {
                                PlayViewer(
                                    pageObservable:self.pageObservable,
                                    title: self.title,
                                    textInfo: self.textInfo,
                                    imgBg: self.isPlayViewActive ? self.imgBg : nil,
                                    contentMode: self.imgContentMode,
                                    isActive: self.isPlayViewActive
                                )
                            }
                        }
                        .modifier(Ratio16_9( geometry:geometry, isFullScreen: self.isFullScreen))
                        .padding(.top, self.sceneObserver.safeAreaTop)
                        
                        InfinityScrollView( viewModel: self.infinityScrollModel ){
                            VStack(alignment:.leading , spacing:Dimen.margin.regular) {
                                if self.episodeViewerData != nil {
                                    EpisodeViewer(data:self.episodeViewerData!)
                                        .padding(.top, Dimen.margin.regularExtra)
                                    
                                    HStack(spacing:0){
                                        FunctionViewer(
                                            synopsisData :self.synopsisData,
                                            srisId: self.srisId,
                                            isHeart: self.$isBookmark
                                        )
                                        Spacer()
                                    }
                                }
                                
                                if self.hasAuthority != nil && self.purchasViewerData != nil {
                                    PurchaseViewer(
                                        componentViewModel: self.componentViewModel,
                                        data:self.purchasViewerData! )
                                }
                                if self.hasAuthority == false && self.isPairing == false {
                                    FillButton(
                                        text: String.button.connectBtv
                                    ){_ in
                                        self.pagePresenter.openPopup(
                                            PageProvider.getPageObject(.pairing)
                                        )
                                    }
                                    .padding(.horizontal, Dimen.margin.thin)
                                }
                                if self.summaryViewerData != nil {
                                    SummaryViewer(
                                        peopleScrollModel:self.peopleScrollModel,
                                        data: self.summaryViewerData!)
                                        
                                        .onReceive(self.peopleScrollModel.$scrollPosition){pos in
                                            self.pageDragingModel.uiEvent = .dragCancel(geometry)
                                        }
                                        .onReceive(self.peopleScrollModel.$event){evt in
                                            guard let evt = evt else {return}
                                            switch evt {
                                            case .pullCancel : self.pageDragingModel.uiEvent = .pulled(geometry)
                                            default : do{}
                                            }
                                        }
                                        .onReceive(self.peopleScrollModel.$pullPosition){ pos in
                                            self.pageDragingModel.uiEvent = .pull(geometry, pos)
                                        }
                                }
                                if !self.relationTab.isEmpty {
                                    if self.relationTab.count == 1 {
                                        Text(self.relationTab.first!)
                                            .modifier(BoldTextStyle( size: Font.size.regular, color:Color.app.white ))
                                            .padding(.horizontal, Dimen.margin.thin)
                                    }else{
                                        CPTabDivisionNavigation(
                                            buttons: NavigationBuilder(
                                                index:self.relationTabIdx,
                                                marginH:Dimen.margin.regular)
                                                .getNavigationButtons(texts:self.relationTab),
                                            index: self.$relationTabIdx
                                        )
                                        .frame(height:Dimen.tab.regular)
                                        .padding(.horizontal, Dimen.margin.thin)
                                        .onReceive( [self.relationTabIdx].publisher ){ idx in
                                            if idx == self.selectedRelationTabIdx { return }
                                            self.selectedRelationContent(idx:idx)
                                        }
                                    }
                                    
                                }
                                if !self.seris.isEmpty {
                                    SerisTab(
                                        data:self.relationContentsModel,
                                        seris: self.$seris
                                    ){ season in
                                        guard let data = season.synopsisData else {return}
                                        self.synopsisData = data
                                        self.resetPage()
                                    }
                                    .padding(.horizontal, Dimen.margin.thin)
                                }
                                ForEach(self.seris) { data in
                                    SerisItem( data:data, isSelected: self.synopsisData?.epsdId == data.contentID )
                                        .padding(.horizontal, Dimen.margin.thin)
                                    .onTapGesture {
                                        self.changeVod(epsdId:data.epsdId)
                                    }
                                }
                                
                                VStack(spacing:Dimen.margin.thin){
                                    ForEach(self.relationDatas) { data in
                                        PosterSet( data:data )
                                    }
                                }
                                Spacer().frame(height: self.safeAreaBottom)
                            }
                        }
                        .modifier(MatchParent())
                        .highPriorityGesture(
                            DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
                                .onChanged({ value in
                                    self.pageDragingModel.uiEvent = .drag(geometry, value)
                                })
                                .onEnded({ _ in
                                    self.pageDragingModel.uiEvent = .draged(geometry)
                                })
                        )
                    }
                    
                    .modifier(PageFull())
                }//PageDragingBody
                .onReceive(self.infinityScrollModel.$scrollPosition){pos in
                   self.pageDragingModel.uiEvent = .dragCancel(geometry)
                }
            }//PageDataProviderContent
            .onReceive(self.pairing.$event){evt in
                guard let _ = evt else {return}
                self.isPageDataReady = true
                switch evt {
                case .pairingCompleted : self.initPage()
                case .disConnected : self.initPage()
                case .pairingCheckCompleted(let isSuccess) :
                    if isSuccess { self.initPage() }
                    else { self.pageSceneObserver.alert = .pairingCheckFail }
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
            
            .onReceive(self.componentViewModel.$selectedOption ){option in
                guard let option = option else { return }
                self.changeOption(option)
            }
            .onReceive(self.pageObservable.$status){status in
                switch status {
                case .appear:
                    DispatchQueue.main.async {
                        switch self.pairing.status {
                        case .pairing : self.pairing.requestPairing(.check)
                        case .unstablePairing : self.pageSceneObserver.alert = .pairingRecovery
                        default :
                            self.isPageDataReady = true
                            self.initPage()
                        }
                    }
                default : do{}
                }
            }
            .onReceive(self.pageSceneObserver.$alertResult){ result in
                guard let result = result else { return }
                switch result {
                case .retry(let alert) :
                    if alert == nil {
                        self.resetPage()
                    }
                default : do{}
                }
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
            .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
                self.safeAreaBottom = pos
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.isPageUiReady = true
                    self.initPage()
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.synopsisData = obj.getParamValue(key: .data) as? SynopsisData
            }
            
            
        }//geo
    }//body
    

    /*
     Data process
     */
    
    @State var isInitPage = false
    @State var progressError = false
    @State var progressCompleted = false
    @State var synopsisModel:SynopsisModel? = nil
    @State var episodeViewerData:EpisodeViewerData? = nil
    @State var purchasViewerData:PurchaseViewerData? = nil
    @State var playerData:SynopsisPlayerData? = nil
    @State var summaryViewerData:SummaryViewerData? = nil
    @State var purchaseWebviewModel:PurchaseWebviewModel? = nil
    
    @State var title:String? = nil
    @State var imgBg:String? = nil
    @State var imgContentMode:ContentMode = .fit
    @State var textInfo:String? = nil
    
    @State var playListData:PlayListData = PlayListData()
    
    @State var synopsisPlayType:SynopsisPlayType = .unknown
    @State var srisId:String? = nil
    @State var srisCount:String? = nil
    @State var isBookmark:Bool? = nil
    @State var epsdId:String? = nil
    @State var epsdRsluId:String = ""

    @State var relationTab:[String] = []
    @State var selectedRelationTabIdx:Int = 0
    @State var seris:[SerisData] = []
    @State var relationDatas:[PosterDataSet] = []

    @State var isPlayAble:Bool = false
    @State var isPageUiReady = false
    @State var isPageDataReady = false
    @State var isPlayViewActive = false
    
    func initPage(){
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
        self.pageDataProviderModel.initate()
        withAnimation{ self.isPlayViewActive = false }
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
            guard let data = self.synopsisData else {return}
            self.pageDataProviderModel.requestProgress( qs: [
                .init(type: .getGatewaySynopsis(data)),
                .init(type: .getSynopsis(data))
            ])
        
        case 1 :
            guard let model = self.synopsisModel else {return}
            if self.purchasViewerData?.isPlayAble == false {
                withAnimation{ self.isPlayViewActive = true }
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
            switch count {
            case 0 :
                guard let data = res.data as? GatewaySynopsis else {
                    self.progressError = true
                    return
                }
                self.setupGatewaySynopsis(data)
                
            case 1 :
                guard let data = res.data as? Synopsis else {
                    PageLog.d("error Synopsis", tag: self.tag)
                    self.progressError = true
                    return
                }
                self.setupSynopsis(data)
                
            default : do{}
            }
            
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
    }
    

    private func setupSynopsis (_ data:Synopsis) {
        PageLog.d("setupSynopsis prev " + (self.srisId ?? "nil"), tag: self.tag)
        PageLog.d("setupSynopsis new " + (self.synopsisData?.srisId ?? "nil"), tag: self.tag)
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
            self.synopsisData?.epsdRsluId = self.synopsisModel?.epsdRsluId
            if self.isPairing == false {
                self.synopsisModel?.setData(directViewdata: nil)
                self.purchasViewerData = PurchaseViewerData().setData(
                        synopsisModel: self.synopsisModel,
                        isPairing: self.isPairing)
                self.hasAuthority = false
            }
            
            if let kidYn = self.synopsisModel?.kidsYn {self.synopsisData?.kidZone = kidYn }

            self.title = self.episodeViewerData?.episodeTitle
            self.textInfo = self.purchasViewerData?.serviceInfo
            self.epsdRsluId = self.synopsisModel?.epsdRsluId ?? ""
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
        self.purchaseWebviewModel?.setParam(me061Info: data, monthlyPid: nil)
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
        if let curSynopsisItem = self.synopsisModel?.curSynopsisItem {
            self.hasAuthority = curSynopsisItem.hasAuthority
        }
        withAnimation{self.isPlayAble = true}
    }
    
    private func setupPreview (_ data:Preview){
        if data.result != ApiCode.success {
            PageLog.d("fail PreviewInfo", tag: self.tag)
            return
        }
        guard let dataInfo = data.CTS_INFO else {
            PageLog.d("error PreviewInfo", tag: self.tag)
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
            return
        }
        guard let dataInfo = data.CTS_INFO else {
            PageLog.d("error PlayInfo", tag: self.tag)
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
        self.selectedRelationContent(idx:0)
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
                self.seris = self.relationContentsModel.getSerisDatas()
                return
            }else{
                relationContentsIdx = self.selectedRelationTabIdx-1
            }
        } 
        if self.relationContentsModel.relationContents.isEmpty { return }
        if relationContentsIdx >= self.relationContentsModel.relationContents.count  { return }
        self.relationDatas =  self.relationContentsModel.getRelationContentSets(idx: relationContentsIdx)
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
    func nextVod()->Bool{
        guard let prevData = self.synopsisData else { return false}
        guard let playData = self.playerData else { return false}
        if !self.setup.nextPlay { return false}
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
    
    func changeOption(_ option:PurchaseModel){
        self.epsdRsluId = option.epsd_rslu_id
        self.synopsisPlayType = .vodChange()
        self.pageDataProviderModel.request = .init(
            id: SingleRequestType.changeOption.rawValue,
            type: .getPlay(self.epsdRsluId,  self.pairing.hostDevice ))
    }
    
    
    func preplayCompleted(){
        PageLog.d("prevplayCompleted", tag: self.tag)
    }
    
    
    func previewCompleted(){
        PageLog.d("previewCompleted", tag: self.tag)
    }
    
    func vodCompleted(){
        PageLog.d("vodCompleted", tag: self.tag)
    }
    
    func continueVod(){
        if self.pairing.status != .pairing {
            self.pageSceneObserver.alert = .needPairing
            return
        }
        if self.hasAuthority == false {
            guard  let model = self.purchaseWebviewModel else { return }
            self.pageSceneObserver.alert = .needPurchase(model)
        }
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

}

#if DEBUG
struct PageSynopsis_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageSynopsis().contentBody
                .environmentObject(Repository())
                .environmentObject(PagePresenter())
                .environmentObject(SceneObserver())
                .environmentObject(PageSceneObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .environmentObject(Setup())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
