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
    @State var isPairing:Bool? = nil
    @State var hasAuthority:Bool? = nil
    @State var synopsisData:SynopsisData? = nil
    @State var isFullScreen:Bool = false
    
    enum SingleRequestType:String {
        case preview, changeOption
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
                                viewModel:self.playerModel,
                                pageObservable:self.pageObservable,
                                title: self.title,
                                thumbImage: self.imgBg
                            )
                            
                            if self.playerData == nil {
                                PlayViewer(
                                    pageObservable:self.pageObservable,
                                    title: self.title,
                                    textInfo: self.textInfo,
                                    imgBg: self.imgBg)
                                
                            }
                        }
                        .modifier(Ratio16_9( geometry:geometry, isFullScreen: self.isFullScreen))
                        .padding(.top, self.sceneObserver.safeAreaTop)
                        
                        InfinityScrollView( viewModel: self.infinityScrollModel ){
                            VStack(alignment:.leading , spacing:0) {
                                if self.episodeViewerData != nil {
                                    EpisodeViewer(data:self.episodeViewerData!)
                                }
                                HStack(spacing:0){
                                    FunctionViewer(
                                        synopsisData :self.synopsisData,
                                        srisId: self.srisId,
                                        isHeart: self.$isBookmark
                                    )
                                    Spacer()
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
                            }
                        }
                        .modifier(MatchParent())
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 20, coordinateSpace: .local)
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
                    //PageLog.d("scrollPosition " + pos.description, tag: self.tag)
                    self.pageDragingModel.uiEvent = .dragCancel(geometry)
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
                        default : self.initPage()
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
    
    @State var title:String? = nil
    @State var imgBg:String? = nil
    @State var textInfo:String? = nil
    
    @State var synopsisPlayType:SynopsisPlayType = .unknown
    @State var srisId:String? = nil
    @State var srisCount:String? = nil
    @State var isBookmark:Bool? = nil
    @State var epsdRsluId:String = ""
    
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
        self.progressCompleted = false
        self.episodeViewerData = nil
        self.purchasViewerData = nil
        self.playerData = nil
        self.title = nil
        self.imgBg = nil
        self.textInfo = nil
        self.pageDataProviderModel.initate()
    }

    private func requestProgress(_ progress:Int){
        
        PageLog.d("requestProgress " + progress.description, tag: self.tag)
        if self.progressError {return}
        if self.progressCompleted{
            PageLog.d("requestProgress Completed", tag: self.tag)
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
            if self.isPairing == true {
                self.pageDataProviderModel.requestProgress(q: .init(type: .getDirectView(model)))
            }else{
                if model.hasExamPreview{
                    self.synopsisPlayType = .preplay
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
                    self.synopsisPlayType = .preplay
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
                    return
                }
                self.setupPreview(data)
            }
            if  res.id.hasPrefix( SingleRequestType.changeOption.rawValue ) {
                guard let data = res.data as? Play else {
                    PageLog.d("error changeOption", tag: self.tag)
                    return
                }
                self.setupPlay(data)
            }

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
                self.purchasViewerData = PurchaseViewerData().setData(
                        synopsisModel: self.synopsisModel,
                        isPairing: self.isPairing)
                self.hasAuthority = false
            }
            if let kidYn = self.synopsisModel?.kidsYn {self.synopsisData?.kidZone = kidYn }

            self.title = self.episodeViewerData?.episodeTitle
            self.textInfo = self.purchasViewerData?.serviceInfo
            self.imgBg = self.synopsisModel?.imgBg
            self.epsdRsluId = self.synopsisModel?.epsdRsluId ?? ""
            DataLog.d("PageSynopsis epsdRsluId  : " + (self.epsdRsluId ?? ""), tag: "상품정보 조회")
            
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
        self.purchasViewerData = PurchaseViewerData().setData(
                synopsisModel: self.synopsisModel,
                isPairing: self.isPairing)
        
        if let lastWatch = data.last_watch_info {
            if let t = lastWatch.watch_rt?.toInt() {
                switch self.synopsisPlayType {
                case .vod: self.synopsisPlayType = .vod(Double(t))
                case .vodChange: self.synopsisPlayType = .vodChange(Double(t))
                case .vodNext: self.synopsisPlayType = .vodNext(Double(t))
                default: do{}
                }
            }
        }
        if let curSynopsisItem = self.synopsisModel?.curSynopsisItem {
            self.hasAuthority = curSynopsisItem.hasAuthority
        }
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
    
    
    
    /*
     Player process
     */
    
    func playCompleted(){
        
        switch playerData?.type {
        case .preplay:
            self.preplayCompleted()
        case .preview(let count):
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
