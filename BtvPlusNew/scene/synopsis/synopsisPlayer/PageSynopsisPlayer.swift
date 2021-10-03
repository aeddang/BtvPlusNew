//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine


struct PageSynopsisPlayer: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var naviLogManager:NaviLogManager
    @EnvironmentObject var setup:Setup
    @ObservedObject var pageDataProviderModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var playerModel: BtvPlayerModel = BtvPlayerModel(useFullScreenAction:false, useFullScreenButton: false)
    @ObservedObject var prerollModel = PrerollModel()
    
    @State var synopsisData:SynopsisData? = nil
    @State var isPairing:Bool? = nil
    @State var isPlayBeforeDraging:Bool = false
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
                    SynopsisTop(
                        geometry: geometry,
                        pageObservable: self.pageObservable,
                        pageDragingModel: self.pageDragingModel,
                        playerModel: self.playerModel,
                        prerollModel: self.prerollModel,
                        title: self.title,
                        epsdId:self.epsdId,
                        imgBg: self.imgBg,
                        imgContentMode: self.imgContentMode,
                        textInfo: self.textInfo,
                        playListData: self.playListData,
                        isPlayAble: self.isPlayAble,
                        isPlayViewActive: self.isPlayViewActive
                    )
                    .modifier(PageFullScreen())
                }
            }
            .onReceive(self.prerollModel.$event){evt in
                guard let evt = evt else { return }
                self.onEventLog(prerollEvent: evt)
            }
            .onReceive(self.playerModel.$btvPlayerEvent){evt in
                guard let evt = evt else { return }
                self.onEventLog(btvPlayerEvent: evt)
                self.onEvent(btvPlayerEvent: evt)
            }
            .onReceive(self.playerModel.$btvUiEvent){evt in
                guard let evt = evt else { return }
                self.onEventLog(btvUiEvent: evt)
            }
            .onReceive(self.playerModel.$btvLogEvent){evt in
                guard let evt = evt else { return }
                self.onEventLog(btvLogEvent: evt)
            }
            .onReceive(self.playerModel.$streamEvent){evt in
                guard let evt = evt else { return }
                self.onEvent(streamEvent: evt)
            }
            .onReceive(self.playerModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .fullScreen(let isFullScreen) :
                    if isFullScreen { return }
                    self.pagePresenter.closePopup(self.pageObject?.id)
                case .recovery(let isUser) :
                    if isUser { self.initPage() }
                default : break
                }
                self.onEventLog(event: evt)
            }
            .onReceive(self.self.pageDragingModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .dragInit :
                    self.isPlayBeforeDraging = self.playerModel.isPlay
                    self.playerModel.event = .pause()
                case .draged: if self.isPlayBeforeDraging {
                    self.playerModel.event = .resume()
                }
                default : break
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
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    if self.isPageUiReady {return}
                    DispatchQueue.main.async {
                        self.pagePresenter.fullScreenEnter(isLock: true, changeOrientation: .landscape)
                        self.isPageUiReady = true
                        self.initPage()
                    }
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.pushId = obj.getParamValue(key: .pushId) as? String
                self.synopsisData = obj.getParamValue(key: .data) as? SynopsisData
                if self.synopsisData == nil {
                    if let json = obj.getParamValue(key: .data) as? SynopsisJson {
                        self.synopsisData = SynopsisData(
                            srisId: json.srisId, searchType:EuxpNetwork.SearchType.prd, epsdId: json.epsdId,
                            epsdRsluId: json.episodeResolutionId, prdPrcId: json.pid, kidZone: nil, synopType: SynopsisType.none)
                    }
                    if let qurry = obj.getParamValue(key: .data) as? SynopsisQurry {
                        self.synopsisData = SynopsisData(
                            srisId:  qurry.srisId, searchType:EuxpNetwork.SearchType.prd, epsdId:  qurry.epsdId,
                            epsdRsluId: nil, prdPrcId: nil, kidZone: nil, synopType: SynopsisType.none)
                    }
                }
            }
            .onDisappear{
                self.onDisappearLog()
                self.pagePresenter.fullScreenExit()
            }
        }//geo
    }//body
    
    
    @State var isInitPage = false
    @State var progressError = false
    @State var progressCompleted = false
    @State var isAllProgressCompleted = false
    @State var synopsisModel:SynopsisModel? = nil
    @State var episodeViewerData:EpisodeViewerData? = nil
    @State var playerData:SynopsisPlayerData? = nil
    @State var playListData:PlayListData = PlayListData()
    @State var title:String? = nil
    @State var imgBg:String? = nil
    @State var textInfo:String? = nil
    @State var imgContentMode:ContentMode = .fit
    @State var synopsisPlayType:SynopsisPlayType = .unknown
    
    @State var epsdId:String? = nil
    @State var epsdRsluId:String = ""
    @State var isPlayAble:Bool = false
    @State var isPlayViewActive = false
    @State var isPageUiReady = false
    @State var isPageDataReady = false
    @State var isContinuousPlay:Bool = false
    
    @State var pushId:String? = nil
    @State var pageLodId:NaviLog.PageId? = nil
    @State var insideChangeViewId:String? = nil
    @State var insideChangeViewRuntime:String? = nil
    
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
        self.progressError = false
        self.progressCompleted = false
        self.isAllProgressCompleted = false
        self.episodeViewerData = nil
        self.playerData = nil
        self.title = nil
        self.imgBg = nil
        self.textInfo = nil
        self.isContinuousPlay = false
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
        case 0 :
            guard let data = self.synopsisData else {
                PageLog.d("requestProgress synopsisData nil", tag: self.tag)
                self.errorProgress()
                return
            }
            self.pageDataProviderModel.requestProgress( q: .init(type: .getSynopsis(data)))
        
        case 1 :
            self.pageDataProviderModel.requestProgress(
                q: .init(type: .getPlay(self.epsdRsluId )))
            self.progressCompleted = true
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
            guard let data = res.data as? Play else {
                PageLog.d("error Play", tag: self.tag)
                self.progressError = true
                return
            }
            self.setupPlay(data)
        default : break
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
        withAnimation{
            self.isPlayAble = true
            self.isPlayViewActive = false
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
        if self.isAllProgressCompleted {return}
        self.isAllProgressCompleted = true
        PageLog.d("onAllProgressCompleted(", tag: self.tag)
        self.playerModel.btvUiEvent = .syncListScroll
        self.playStartLog()
    }
    

    private func setupSynopsis (_ data:Synopsis) {
        if self.synopsisData?.srisId?.isEmpty != false { self.synopsisData?.srisId = data.contents?.sris_id }
        if self.synopsisData?.epsdId?.isEmpty != false { self.synopsisData?.epsdId = data.contents?.epsd_id }
        PageLog.d("srisId " + (self.synopsisData?.srisId ?? "nil"), tag: self.tag)
        PageLog.d("epsdId " + (self.synopsisData?.epsdId ?? "nil"), tag: self.tag)
        if let content = data.contents {
            self.episodeViewerData = EpisodeViewerData(type: .btv).setData(data: content)
            self.synopsisModel = SynopsisModel(type: .seasonFirst).setData(data: data)
            self.epsdRsluId = self.synopsisModel?.epsdRsluId ?? self.epsdRsluId
            self.synopsisData?.epsdRsluId = self.epsdRsluId
            self.title = self.episodeViewerData?.episodeSubTitle
            self.epsdId = self.synopsisModel?.epsdId
            self.imgBg = self.synopsisModel?.imgBg
            self.imgContentMode = self.synopsisModel?.imgContentMode ?? .fit
            DataLog.d("PageSynopsis epsdRsluId  : " + self.epsdRsluId, tag: self.tag)
            withAnimation{self.isPlayAble = true}
            if let infoList = self.synopsisModel?.seriesInfoList {
                
                let playList = zip(infoList, 0...infoList.count).map{ data, idx in
                    PlayerListData().setData(data: data, isClip: true, idx: idx)}
                
                self.playListData = PlayListData(
                    listTitle: String.pageText.synopsisClipView,
                    title: content.title,
                    datas: playList)
            } else {
                self.playListData = PlayListData(
                    listTitle: String.pageText.synopsisClipView,
                    datas: [])
            }
            
        } else {
            self.progressError = true
            PageLog.d("setupSynopsis error", tag: self.tag)
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
            if synopsis.originEpsdId?.isEmpty == false, let fullVod = synopsis.originEpsdId {
                self.synopsisPlayType = .clip(nil, SynopsisData(
                    srisId: self.synopsisData?.srisId,
                    searchType: .prd,
                    epsdId: fullVod,
                    synopType: self.synopsisData?.synopType ?? .none
                ))
            } else {
                self.synopsisPlayType = .clip()
            }
            
            //let prerollData = SynopsisPrerollData().setData(data: synopsis, playType: self.synopsisPlayType, epsdRsluId: self.epsdRsluId)
            if let progress = self.synopsisData?.progressTime {
                self.playerModel.continuousProgressTime = progress
                self.isContinuousPlay = true
            }
            self.playerData = SynopsisPlayerData()
                .setData(type: self.synopsisPlayType, datas: self.playListData.datas, epsdId:self.epsdId ?? "")
            self.playerModel
                //.setData(synopsisPrerollData: prerollData)
                .setData(synopsisPlayData: self.playerData)
                .setData(data: dataInfo, type: .vod(self.epsdRsluId,self.title), autoPlay:true)
        }
    }
    
    func onContinuousPlay(){
        if !self.isContinuousPlay {return}
        self.pagePresenter.onPageEvent(self.pageObject,
                                       event: .init(id:self.tag,  type: .timeChange, data: self.playerModel.time))
    }
   
    /*
     Player process
     */
    func playCompleted(){
        self.onContinuousPlay()
        if self.playerModel.isReplay {return}
        if !self.nextVod(auto: true) {
            self.vodCompleted()
        }
    }
    @discardableResult
    func nextVod(auto:Bool = true, isUser:Bool? = nil)->Bool{
        if self.playerModel.isReplay && auto {return false}
        guard let playData = self.playerData else { return false}
        if !playData.hasNext { return false}
        if !self.setup.nextPlay && auto {
            self.appSceneObserver.alert = .confirm(
                String.pageText.synopsisNextPlay, String.pageText.synopsisNextClipPlayConfirm) { isOk in
                if isOk {
                    self.naviLog(pageID: .playInside, action: .clickContinuousPlayButton, result:"예")
                    nextVod(auto:false, isUser:false)
                } else {
                    self.naviLog(pageID: .playInside, action: .clickContinuousPlayButton, result:"아니오") 
                }
            }
            return true
        }
        if let find = playData.nextEpisode {
            self.changeVod(epsdId: find.epsdId)
            if !auto && isUser != false{
                self.playerModel.btvLogEvent =
                    .clickInsideButton(.clickInsideSkipIntro , .nextView(isAuto:false)
                                       , config:find.title, result:find.epsdId)
            }
            return true
        }
        return false
    }
    
    private func vodCompleted(){
        PageLog.d("vodCompleted", tag: self.tag)
        self.pagePresenter.closePopup(self.pageObject?.id)
    }
    
    func changeVod(epsdId:String?){
        self.onContinuousPlay()
        guard let epsdId = epsdId else { return }
        guard let cdata = self.synopsisData else { return }
        self.synopsisData = SynopsisData(
                srisId: cdata.srisId, searchType: .prd,
                epsdId: epsdId, epsdRsluId: "",
                prdPrcId: cdata.prdPrcId, kidZone:cdata.kidZone,
                synopType: cdata.synopType
            )
        self.resetPage()
    }
    
    
    func onEvent(btvPlayerEvent:BtvPlayerEvent){
        switch btvPlayerEvent {
        case .changeView(let epsdId) :
            self.changeVod(epsdId:epsdId)
            
        case .nextView(let isAuto) :
            self.nextVod(auto: isAuto)
        case .fullVod (let synopsisData):
            self.onContinuousPlay()
            self.pagePresenter.closePopup(self.pageObject?.id)
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.synopsis)
                    .addParam(key: .data, value: synopsisData)
                    .addParam(key: .watchLv, value: self.synopsisModel?.watchLevel)
            )
        case .close :
            self.onContinuousPlay()
            self.pagePresenter.closePopup(self.pageObject?.id)
        default: break
        }
    }
    
    
    
    func onEvent(streamEvent:PlayerStreamEvent){
        switch streamEvent {
        case .completed:
            self.playCompleted()
        default: break
        }
    }
    
}


