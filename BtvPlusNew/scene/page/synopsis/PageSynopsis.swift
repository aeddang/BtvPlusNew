//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PageSynopsis: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var pageDataProviderModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    @State var isPairing:Bool? = nil
    @State var hasAuthority:Bool? = nil
    @State var synopsisData:SynopsisData? = nil

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
                        Image(Asset.noImg16_9)
                            .modifier(Ratio16_9(geometry:geometry))
                        InfinityScrollView( viewModel: self.infinityScrollModel ){
                            VStack(alignment:.leading , spacing:0) {
                                if self.episodeViewerData != nil {
                                    EpisodeViewer(data:self.episodeViewerData!)
                                }
                                FunctionViewer(
                                    synopsisData :self.synopsisData,
                                    srisId: self.srisId,
                                    isHeart: self.$isBookmark
                                )
                                if self.hasAuthority != nil && self.purchasViewerData != nil {
                                    PurchasViewer( data:self.purchasViewerData! )
                                }
                                if self.hasAuthority == false && self.isPairing == false {
                                    FillButton(
                                        text: String.button.connectBtv
                                    ){_ in
                                        self.pagePresenter.openPopup(
                                            PageProvider.getPageObject(.pairing)
                                        )
                                    }
                                }
                                
                                
                            }
                        }
                        .modifier(MatchParent())
                    }
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 20, coordinateSpace: .local)
                            .onChanged({ value in
                                self.pageDragingModel.uiEvent = .drag(geometry, value)
                            })
                            .onEnded({ _ in
                                self.pageDragingModel.uiEvent = .draged(geometry)
                            })
                    )
                    .modifier(PageFull())
                }//PageDragingBody
                .onReceive(self.infinityScrollModel.$event){evt in
                    guard let _ = evt else {return}
                    self.pageDragingModel.uiEvent = .draged(geometry)
                    
                }
            }//PageDataProviderContent
            .onReceive(self.pairing.$event){evt in
                guard let _ = evt else {return}
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
            .onReceive(self.pageObservable.$status){status in
                switch status {
                case .appear:
                    DispatchQueue.main.async {
                        switch self.pairing.status {
                        case .pairing : self.pairing.requestPairing(.check)
                        case .unstablePairing : self.pageSceneObserver.alert = .pairingRecovery
                        default : self.initPage()
                        }
                    }
                default : do{}
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.synopsisData = obj.getParamValue(key: .data) as? SynopsisData
            }
            
        }//geo
    }//body
    
    
    @State var isInitPage = false
    @State var progressError = false
    @State var synopsisModel:SynopsisModel? = nil
    @State var episodeViewerData:EpisodeViewerData? = nil
    @State var purchasViewerData:PurchasViewerData? = nil
    @State var srisId:String? = nil
    @State var srisCount:String? = nil
    @State var isBookmark:Bool? = nil
    
    func initPage(){
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
        self.episodeViewerData = nil
        self.purchasViewerData = nil
        self.pageDataProviderModel.initate()
    }

    private func requestProgress(_ progress:Int){
        PageLog.d("requestProgress " + progress.description, tag: self.tag)
        if self.progressError {return}
        guard let data = self.synopsisData else {return}
        switch progress {
        case 0 : self.pageDataProviderModel.requestProgress(
            qs: [
                .init(type: .getGatewaySynopsis(data)),
                .init(type: .getSynopsis(data))
            ])
        case 1 :
            if self.isPairing == true {
                if let model = self.synopsisModel {
                    self.pageDataProviderModel.requestProgress(q: .init(type: .getDirectView(model)))
                }
            }
        //case 2 : self.pageDataProviderModel.requestProgress(q: .init(type: .getGnb))
        //case 3 : self.pageDataProviderModel.requestProgress(q: .init(type: .getGnb))
        default : do{}
        }
    }
    
    private func respondProgress(progress:Int, res:ApiResultResponds, count:Int){
        PageLog.d("respondProgress " + progress.description + " " + count.description, tag: self.tag)
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
            guard let data = res.data as? DirectView else {
                self.progressError = true
                return
            }
            self.setupDirectView(data)
        default : do{}
        }
    }
    
    private func errorProgress(progress:Int, err:ApiResultError, count:Int){
        switch progress {
        case 0 : self.progressError = true
        case 1 : self.progressError = true
        default : do{}
        }
    }
    
    private func setupSynopsis (_ data:Synopsis){
        PageLog.d("setupSynopsis", tag: self.tag)
        if let content = data.contents {
            self.episodeViewerData = EpisodeViewerData().setData(data: content)
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
                self.purchasViewerData = PurchasViewerData().setData(
                        synopsisModel: self.synopsisModel,
                        isPairing: self.isPairing)
                self.hasAuthority = false
            }
            
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
        self.synopsisModel?.setData(directViewdata: data)
        self.isBookmark = self.synopsisModel?.isBookmark
        self.purchasViewerData = PurchasViewerData().setData(
                synopsisModel: self.synopsisModel,
                isPairing: self.isPairing)
        
        if let curSynopsisItem = self.synopsisModel?.curSynopsisItem {
            self.hasAuthority = curSynopsisItem.hasAuthority
        }
    }

}

#if DEBUG
struct PageSynopsis_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageSynopsis().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(SceneObserver())
                .environmentObject(PageSceneObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
