//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
extension PageSynopsisPackage{
    static let listWidth:CGFloat = 420
}
struct PageSynopsisPackage: PageView {
    var type:PageType = .btv
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var componentViewModel:SynopsisViewModel = SynopsisViewModel()
    @ObservedObject var pageDataProviderModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var synopsisListViewModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var peopleScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var synopsisData:SynopsisData? = nil
    @State var isPairing:Bool? = nil
    @State var marginBottom:CGFloat = 0
    @State var sceneOrientation: SceneOrientation = .portrait
    var body: some View {
        GeometryReader { geometry in
            PageDataProviderContent(
                viewModel: self.pageDataProviderModel
            ){
                PageDragingBody(
                    pageObservable: self.pageObservable, 
                    viewModel:self.pageDragingModel,
                    axis:.horizontal
                ) {
                    if self.type == .btv {
                        ZStack{
                            if self.isUIView && !self.progressError, let synopsisPackageModel = self.synopsisPackageModel {
                                if self.sceneOrientation == .portrait {
                                    PackageBody(
                                        componentViewModel: self.componentViewModel,
                                        infinityScrollModel: self.infinityScrollModel,
                                        synopsisListViewModel: self.synopsisListViewModel,
                                        peopleScrollModel: self.peopleScrollModel,
                                        synopsisPackageModel: synopsisPackageModel,
                                        isPairing: self.isPairing,
                                        isPosson: self.isPosson,
                                        contentID: self.synopsisModel?.epsdId,
                                        episodeViewerData: self.episodeViewerData,
                                        summaryViewerData: self.summaryViewerData,
                                        useTracking: true,
                                        marginBottom: self.marginBottom)
                                    { posterData in
                                        self.previewLog(data: posterData)
                                        self.updateSynopsis(posterData)
                                    }
                                    .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                                } else {
                                    HStack(alignment: .center, spacing: 0){
                                        TopViewer( data:self.synopsisPackageModel!)
                                            .modifier(MatchParent())
                                            .padding(.bottom, self.marginBottom - Dimen.margin.regular)
                                           
                                        PackageBody(
                                            componentViewModel: self.componentViewModel,
                                            infinityScrollModel: self.infinityScrollModel,
                                            synopsisListViewModel: self.synopsisListViewModel,
                                            peopleScrollModel: self.peopleScrollModel,
                                            synopsisPackageModel: synopsisPackageModel,
                                            isPairing: self.isPairing,
                                            isPosson: self.isPosson,
                                            contentID: self.synopsisModel?.epsdId,
                                            episodeViewerData: self.episodeViewerData,
                                            summaryViewerData: self.summaryViewerData,
                                            useTop: false,
                                            useTracking: true,
                                            marginBottom: self.marginBottom
                                        ){ posterData in
                                            self.previewLog(data: posterData)
                                            self.updateSynopsis(posterData)
                                        }
                                        .modifier(MatchVertical(width: Self.listWidth))
                                    }
                                    .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
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
                        .modifier(PageFull(style:.dark))
                    } else {
                        ZStack{
                            if self.synopsisPackageModel != nil && self.isUIView && !self.progressError {
                                PackageBodyKids(
                                    synopsisListViewModel: self.synopsisListViewModel,
                                    synopsisPackageModel: self.synopsisPackageModel!,
                                    isPairing: self.isPairing,
                                    contentID: self.synopsisModel?.epsdId,
                                    episodeViewerData: self.episodeViewerData,
                                    useTracking: true){ posterData in
                                        
                                    self.previewLog(data: posterData)
                                    self.updateSynopsis(posterData)
                                }
                                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                               
                            } else {
                                ZStack{
                                    if self.progressError {
                                        EmptyAlert(text: self.synopsisData == nil ? String.alert.dataError : String.alert.apiErrorServer)
                                            
                                    } else {
                                        Spacer().modifier(MatchParent())
                                    }
                                }
                                .modifier(MatchParent())
                                .background(Color.kids.bg)
                                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                            }
                        }
                        .modifier(PageFullScreen(style:.kidsLight))
                    }
                }//PageDragingBody
                .onReceive(self.synopsisListViewModel.$event){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .pullCompleted :
                        self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                    case .pullCancel :
                        self.pageDragingModel.uiEvent = .pullCancel(geometry)
                    default : break
                    }
                }
                .onReceive(self.componentViewModel.$uiEvent){evt in
                    guard let evt = evt else { return }
                    self.onEventLog(componentEvent: evt) 
                }
                .onReceive(self.infinityScrollModel.$scrollPosition){ pos in
                    self.pageDragingModel.uiEvent = .dragCancel
                }
                .onReceive(self.synopsisListViewModel.$pullPosition){ pos in
                    self.pageDragingModel.uiEvent = .pull(geometry, pos)
                }
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
                
            }//PageDataProviderContent
            .onReceive(self.pairing.$event){evt in
                guard let _ = evt else {return}
                self.isPageDataReady = true
                switch evt {
                case .pairingCompleted : self.initPage()
                case .disConnected : self.initPage()
                case .pairingCheckCompleted(let isSuccess, _) :
                    
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
                        case .pairing : self.pairing.requestPairing(.check(id:self.tag))
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
                    case .purchase(_, _, _) :
                        self.resetPage()
                    default : break
                    }
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
            }
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                withAnimation{ self.marginBottom = bottom }
            }
            .onAppear{
                self.sceneOrientation = self.sceneObserver.sceneOrientation
                guard let obj = self.pageObject  else { return }
                self.pushId = obj.getParamValue(key: .pushId) as? String
                self.synopsisData = obj.getParamValue(key: .data) as? SynopsisData
                if self.synopsisData == nil {
                    if let json = obj.getParamValue(key: .data) as? SynopsisJson {
                        self.synopsisData = SynopsisData(
                            srisId: json.srisId, searchType:EuxpNetwork.SearchType.sris, epsdId: json.epsdId,
                            epsdRsluId: json.episodeResolutionId, prdPrcId: json.pid, kidZone: nil, synopType: .package)
                    }
                    if let qurry = obj.getParamValue(key: .data) as? SynopsisQurry {
                        self.synopsisData = SynopsisData(
                            srisId:  qurry.srisId, searchType:EuxpNetwork.SearchType.sris, epsdId: qurry.epsdId,
                            epsdRsluId: nil, prdPrcId: nil, kidZone: nil, synopType: .package)
                    }
                }
                self.initPage()
            }
            .onDisappear(){
                self.onDisappearLog()
            }
            
            
        }//geo
        
        
    }//body
   
    /*
     Data process
     */
   
    @State var isCheckdPairing:Bool? = nil
    @State var isInitPage = false
    @State var progressError = false
    @State var progressCompleted = false
    @State var isAllProgressCompleted = false
    @State var synopsisPackageModel:SynopsisPackageModel? = nil
    @State var synopsisModel:SynopsisModel? = nil
    @State var currentPoster:PosterData? = nil
    
    @State var episodeViewerData:EpisodeViewerData? = nil
    @State var summaryViewerData:SummaryViewerData? = nil

    @State var isPageUiReady = false
    @State var isPageDataReady = false
    
    @State var isPosson:Bool = false
    @State var anotherStb:String? = nil
    @State var isUIView:Bool = false
    @State var pushId:String? = nil
    @State var pageLogId:NaviLog.PageId? = nil
    
    func initPage(){
        if self.synopsisData == nil {
            self.progressError = true
            return
        }
        self.isPosson = self.synopsisData?.isPosson ?? false
        self.anotherStb = self.isPosson ? self.synopsisData?.anotherStbId : nil
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
        self.progressError = false
        self.progressCompleted = false
        self.isAllProgressCompleted = false
        self.synopsisPackageModel = nil
        self.episodeViewerData = nil
        self.summaryViewerData = nil
        self.currentPoster = nil
        self.pageDataProviderModel.initate()
        
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
            self.pageDataProviderModel.requestProgress(
                q:.init(type: .getGatewaySynopsis(data ,anotherStbId:self.anotherStb)))
        
        case 1 :
            guard let model = self.synopsisPackageModel else {return}
            if self.isPairing == true || self.isPosson {
                self.pageDataProviderModel.requestProgress(
                    q: .init(type: .getPackageDirectView(model, isPpm: false, anotherStbId: self.anotherStb)))
                self.progressCompleted = true
            } else {
                self.completedProgress()
            }
        default : break
        }
    }
    
    private func respondProgress(progress:Int, res:ApiResultResponds, count:Int){
        PageLog.d("respondProgress " + progress.description + " " + count.description, tag: self.tag)
        self.progressError = false
        switch progress {
        case 0 :
            guard let data = res.data as? GatewaySynopsis else {
                self.progressError = true
                return
            }
            self.setupGatewaySynopsis(data)
            
        case 1 :
            guard let data = res.data as? DirectPackageView else {
                PageLog.d("DirectPackageView", tag: self.tag)
                self.progressError = true
                return
            }
            self.setupDirectPackageView(data)
        
    
        default :
            switch res.type {
            case .getSynopsis :
                guard let data = res.data as? Synopsis else {
                    PageLog.d("getSynopsis error", tag: self.tag)
                    return
                }
                self.setupSynopsis(data)
            default: break
            }
            
        }
    }
    
    private func errorProgress(progress:Int, err:ApiResultError, count:Int){
        switch progress {
        case 0 : self.progressError = true
        case 1 : self.progressError = true
        default : break
        }
    }
    
    private func completedProgress(){
        PageLog.d("completedProgress", tag: self.tag)
        
        self.onAllProgressCompleted()
        guard let poster = self.synopsisPackageModel?.posters.first else {
            PageLog.d("completedProgress no content", tag: self.tag)
            return
        }
        self.updateSynopsis(poster)
    }
    
    private func errorProgress(){
        PageLog.d("errorProgress", tag: self.tag)
        
        self.onAllProgressCompleted()
    }
    
    private func onAllProgressCompleted(){
        if self.isAllProgressCompleted {return}
        PageLog.d("onAllProgressCompleted(", tag: self.tag)
        self.isAllProgressCompleted = true
        if self.isUIView { return }
        withAnimation{ self.isUIView = true }
        
        self.pageStartLog()
    }
    
    private func setupGatewaySynopsis (_ data:GatewaySynopsis){
        self.synopsisPackageModel = SynopsisPackageModel(type:self.type)
            .setData(data:data, isPosson:self.isPosson, anotherStb:self.anotherStb)
    }
    
    private func setupDirectPackageView (_ data:DirectPackageView){
        PageLog.d("setupDirectPackageView", tag: self.tag)
        self.synopsisPackageModel?.setData(data: data)
    }
    
    private func updateSynopsis (_ data:PosterData){
        guard let synopsisData = data.synopsisData else {
            return
        }
        self.currentPoster = data
        self.pageDataProviderModel.request = .init(type: .getSynopsis(synopsisData))
    }
    
    
    private func setupSynopsis (_ data:Synopsis) {
        if let content = data.contents {
            self.episodeViewerData = EpisodeViewerData(type: self.type).setData(data: content)
            self.summaryViewerData = SummaryViewerData().setData(data: content)
            self.synopsisModel = SynopsisModel(type: .title).setData(data: data)
        } else {
            PageLog.d("setupSynopsis error", tag: self.tag)
        }
    }
    
    
    
    
   
}






