//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI



struct PageSynopsisPackage: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @ObservedObject var pageDataProviderModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var synopsisListViewModel: InfinityScrollModel = InfinityScrollModel()
   
    @State var synopsisData:SynopsisData? = nil
    @State var isPairing:Bool? = nil
    @State var useTracking:Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            PageDataProviderContent(
                viewModel: self.pageDataProviderModel
            ){
                PageDragingBody(
                    viewModel:self.pageDragingModel,
                    axis:.horizontal
                ) {
                    ZStack{
                        if self.synopsisPackageModel != nil && self.isUIView {
                            PackageBody(
                                infinityScrollModel: self.infinityScrollModel,
                                synopsisListViewModel: self.synopsisListViewModel,
                                synopsisPackageModel: self.synopsisPackageModel!,
                                isPairing: self.isPairing,
                                contentID: self.synopsisModel?.epsdId,
                                currentPoster:self.currentPoster,
                                episodeViewerData: self.episodeViewerData,
                                summaryViewerData: self.summaryViewerData,
                                useTracking: self.useTracking){ posterData in
                             
                                self.updateSynopsis(posterData)
                            }
                            
                            .highPriorityGesture(
                                DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
                                    .onChanged({ value in
                                       self.pageDragingModel.uiEvent = .drag(geometry, value)
                                    })
                                    .onEnded({ value in
                                        self.pageDragingModel.uiEvent = .draged(geometry, value)
                                    })
                            )
                            .gesture(
                                self.pageDragingModel.cancelGesture
                                    .onChanged({_ in self.pageDragingModel.uiEvent = .dragCancel})
                                    .onEnded({_ in self.pageDragingModel.uiEvent = .dragCancel})
                            )
                        } else {
                            Spacer().modifier(MatchParent())
                        }
                    }
                    .modifier(PageFull(style:.dark))
                }//PageDragingBody
                .onReceive(self.synopsisListViewModel.$event){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .pullCompleted :
                        self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                    case .pullCancel :
                        self.pageDragingModel.uiEvent = .pullCancel(geometry)
                    default : do{}
                    }
                }
                .onReceive(self.synopsisListViewModel.$pullPosition){ pos in
                    self.pageDragingModel.uiEvent = .pull(geometry, pos)
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
                    case .purchase(_, _, _) :
                        self.resetPage()
                    default : break
                    }
                default : break
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
                if ani {
                    self.isPageUiReady = true
                    self.initPage()
                }
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                self.useTracking = page?.id == self.pageObject?.id
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
                }
                self.initPage()
            }
            
            
        }//geo
        
        
    }//body

    /*
     Data process
     */
   
    
    @State var isInitPage = false
    @State var progressError = false
    @State var progressCompleted = false
    
    @State var synopsisPackageModel:SynopsisPackageModel? = nil
    @State var synopsisModel:SynopsisModel? = nil
    @State var currentPoster:PosterData? = nil
    
    @State var episodeViewerData:EpisodeViewerData? = nil
    @State var summaryViewerData:SimpleSummaryViewerData? = nil

    @State var isPageUiReady = false
    @State var isPageDataReady = false
    @State var isUIView:Bool = false
    
    func initPage(){
        if !self.isPageDataReady || !self.isPageUiReady || self.synopsisData == nil { return }
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
            self.pageDataProviderModel.requestProgress( q:.init(type: .getGatewaySynopsis(data)))
        
        case 1 :
            guard let model = self.synopsisPackageModel else {return}
            if self.isPairing == true {
                self.pageDataProviderModel.requestProgress(q: .init(type: .getPackageDirectView(model, false)))
                self.progressCompleted = true
            } else {
                self.completedProgress()
            }
            
            
        default : do{}
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
        PageLog.d("onAllProgressCompleted(", tag: self.tag)
        if #available(iOS 14.0, *) {
            withAnimation{ self.isUIView = true }
        } else {
            self.isUIView = true
        }
    }
    
    private func setupGatewaySynopsis (_ data:GatewaySynopsis){
        self.synopsisPackageModel = SynopsisPackageModel().setData(data:data)
        
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
            self.episodeViewerData = EpisodeViewerData().setData(data: content)
            self.summaryViewerData = SimpleSummaryViewerData().setData(data: content)
            self.synopsisModel = SynopsisModel(type: .title).setData(data: data)
        } else {
            PageLog.d("setupSynopsis error", tag: self.tag)
        }
    }
    
    
    
   
}






