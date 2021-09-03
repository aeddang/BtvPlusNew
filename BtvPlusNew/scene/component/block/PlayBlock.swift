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
     
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }
    
    func update(menuId:String?, key:String? = nil) {
        self.menuId = menuId
        self.key = key
        self.isUpdate = true
    }
}

struct PlayBlock: PageComponent{
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:PlayBlockModel = PlayBlockModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var playerModel: BtvPlayerModel = BtvPlayerModel(useFullScreenAction:false)
    
    var key:String? = nil
    var marginTop : CGFloat = 0
    var marginBottom : CGFloat = 0
    var spacing: CGFloat = Dimen.margin.medium
   
    @State var sceneOrientation: SceneOrientation = .portrait
    var body: some View {
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
                        marginTop:self.marginTop,
                        marginBottom :self.marginBottom,
                        spacing: 0,
                        isRecycle: true,
                        useTracking: true){
                        if self.datas.isEmpty {
                            Spacer().modifier(ListRowInset())
                        } else {
                            ForEach(self.datas) { data in
                                PlayItem(
                                    pageObservable:self.pageObservable,
                                    playerModel:self.playerModel,
                                    data: data,
                                    isSelected: data.index == self.focusIndex) { playData in
                                        
                                        self.forcePlay(data: playData)
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
                                        //self.onAppear(idx:data.index)
                                    }
                                    .onDisappear{
                                        //self.onDisappear(idx: data.index)
                                    }
                                    .onTapGesture {
                                        if self.focusIndex != data.index {
                                            self.onFocusChange(willFocus: data.index)
                                        }
                                        self.appSceneObserver.event = .toast((data.openDate ?? "") + " " + String.alert.updateAlramRecommand)
                                    }
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
        .onReceive(self.playerModel.$event){evt in
            guard let evt = evt else {return}
            switch evt {
            case .fullScreen(let isFullScreen) :
                if !isFullScreen { return }
                self.openFullScreen()
                
            default : break
            }
        }
        .onReceive(self.repository.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .updatedWatchLv : self.playerModel.btvUiEvent = .prevPlay
            default : break
            }
        }
        .onReceive(self.pagePresenter.$event){ evt in
            guard let evt = evt else {return}
            switch evt.type {
            case .completed :
                guard let type = evt.data as? ScsNetwork.ConfirmType  else { return }
                switch type {
                case .adult: self.playerModel.btvUiEvent = .prevPlay
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
        .onReceive(self.pagePresenter.$currentTopPage){ page in
            if !self.isFullScreen {return}
            if self.pagePresenter.currentTopPage?.id != self.pageObject?.id {return}
            self.closeFullScreen()
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
            self.onUpdate()
        }
        .onReceive(self.infinityScrollModel.$pullPosition){ pos in
            if pos < InfinityScrollModel.PULL_RANGE { return }
            self.reloadDegree = Double(pos - InfinityScrollModel.PULL_RANGE)
        }
        .onReceive(self.viewModel.$isUpdate){ update in
            if update {
                self.reload()
            }
        }
        .onReceive(self.viewModel.$event){evt in
            guard let evt = evt else { return }
            switch evt {
            case .onResult(_, let res, _):
                switch res.type {
                case .getNotificationVod(_, _, _ , let returnDatas) : self.loadedNoti(res, returnDatas:returnDatas)
                case .getGridPreview : self.loaded(res)
                default : break
                }
            case .onError(_,  let err, _):
                switch err.type {
                case .getGridPreview : self.onError()
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
        .onReceive(self.pagePresenter.$event){ evt in
            guard let evt = evt else {return}
            switch evt.type {
            case .timeChange :
                guard let t = evt.data as? Double else { return }
                self.onPlaytimeChanged(t:t)
            default : break
            }
        }
        .onReceive(self.sceneObserver.$isUpdated){ _ in
            self.sceneOrientation = self.sceneObserver.sceneOrientation
            self.sceneOrientationUpdate()
        }
        .onAppear(){
            self.sceneOrientation = self.sceneObserver.sceneOrientation
            self.playerModel.isMute = true
        }
        .onDisappear(){
            self.delayUpdateCancel()
        }
        
    }//body
    
    private func forcePlay(data:PlayData? = nil){
        guard let current:PlayData = data ?? self.selectedData else {return}
        if self.focusIndex != current.index {
            self.onFocusChange(willFocus: current.index)
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
    private func openFullScreen(){
        if self.playerModel.playData == nil { return }
        self.isHold = true
        self.isFullScreen = true
        self.finalIndex = self.focusIndex
        PageLog.d("onOpenFullScreen" + (self.finalIndex?.description ?? ""), tag:self.tag)
        self.focusIndex = -1
        self.playerModel.event = .pause
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.fullPlayer)
                .addParam(key: .data, value: self.playerModel.playData)
                .addParam(key: .type, value: self.playerModel.btvPlayType)
                .addParam(key: .autoPlay, value: true)
                .addParam(key: .initTime, value: self.playerModel.time)
        )
    }
    
    private func closeFullScreen(){
        self.isHold = true
        PageLog.d("onCloseFullScreen" + (self.finalIndex?.description ?? ""), tag:self.tag)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isFullScreen = false
            self.pagePresenter.orientationLock(lockOrientation: .all)
            self.isHold = false
            if let posIdx = self.finalIndex {
                if posIdx > 0 && posIdx < datas.count {
                    self.infinityScrollModel.uiEvent = .scrollTo(datas[posIdx].hashId)
                    self.onFocusChange(willFocus: posIdx)
                    PageLog.d("onCloseFullScreen " + (self.selectedData?.title ?? "no"), tag:self.tag)
                }
            }
        }
    }
    
    private func sceneOrientationUpdate(){
        if !SystemEnvironment.isTablet {return}
        if self.focusIndex == -1 {return}
        self.isHold = true
        self.infinityScrollModel.uiEvent = .scrollTo(self.datas[0].hashId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isFullScreen = false
            self.isHold = false
            let posIdx = self.focusIndex
            if posIdx > 0 && posIdx < self.datas.count {
                self.infinityScrollModel.uiEvent = .scrollTo(self.datas[posIdx].hashId)
                self.onFocusChange(willFocus: posIdx)
                PageLog.d("onSceneOrientationUpdate " + (self.selectedData?.title ?? "no"), tag:self.tag)
            }
           
        }
    }
    
    private func onPlaytimeChanged(t:Double){
        guard let data = self.selectedData else { return }
        data.playTime = t
        PageLog.d("onPlaytimeChanged playTime " + t.description, tag:self.tag)
    }
    
    @State var isError:Bool = false
    @State var datas:[PlayData] = []
    @State var selectedData:PlayData? = nil
    @State var reloadDegree:Double = 0
    @State var appearList:[Int] = []
    @State var appearValue:Float = 0
    @State var focusIndex:Int = -1
    @State var maxCount:Int = 0
    func reload(){
        self.delayUpdateCancel()
        self.datas = []
        self.appearList = []
        self.infinityScrollModel.reload()
        self.load()
    }
    
    func load(){
        if  !self.infinityScrollModel.isLoadable { return }
        withAnimation{ self.isError = false }
        self.infinityScrollModel.onLoad()
        self.viewModel.request = .init(
            id: self.tag,
            type: .getGridPreview(
                self.viewModel.menuId,
                self.infinityScrollModel.page + 1)
        )
    }
    
    private func onError(){
        withAnimation{ self.isError = true }
    }
    
    private func loaded(_ res:ApiResultResponds){
        guard let data = res.data as? GridPreview else { return }
        setDatas(datas: data.contents)
       
    }
    
    private func emptyNoti(returnDatas:Any? = nil){
        guard let requestDatas = returnDatas as? [PlayData] else { return }
        requestDatas.forEach{ $0.setData(data: nil) }
    }
    private func errorNoti(returnDatas:Any? = nil){
        guard let requestDatas = returnDatas as? [PlayData] else { return }
        requestDatas.forEach{ $0.setData(data: nil) }
    }
    
    private func setDatas(datas:[PreviewContentsItem]?) {
        guard let datas = datas else {
            if self.datas.isEmpty { self.onError() }
            return
        }
        if !datas.isEmpty {
            let start = self.datas.count
            let end = start + datas.count
            let loadedDatas:[PlayData] = zip(start...end, datas).map { idx, d in
                return PlayData().setData(data: d, idx: idx)
            }
            self.datas.append(contentsOf: loadedDatas)
            if self.pairing.status == .pairing {
                self.viewModel.request = .init(
                    id: self.tag,
                    type: .getNotificationVod(
                        loadedDatas.filter{$0.srisId != nil}.map{$0.srisId!},
                        loadedDatas.filter{$0.epsdId != nil}.map{$0.epsdId!},
                        .movie,
                        returnDatas: loadedDatas
                        ),
                    isOptional:true
                )
            }
            self.maxCount = self.datas.count
            self.delayUpdate()
        }
        self.infinityScrollModel.onComplete(itemCount: datas.count)
        
        
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
    
    private func onAppear(idx:Int){
        if self.appearList.first(where: {$0 == idx}) == nil {
            self.appearList.append(idx)
        }
        self.delayUpdate()
    }
    private func onDisappear(idx:Int){
        if let find = self.appearList.firstIndex(where: {$0 == idx}) {
            self.appearList.remove(at: find)
        }
        self.delayUpdate()
    }
    
    @State var delayUpdateSubscription:AnyCancellable?
    func delayUpdate(){
        self.delayUpdateSubscription?.cancel()
        self.delayUpdateSubscription = Timer.publish(
            every: 0.2, on: .current, in: .common)
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
    
    @State var prevPos:CGFloat = -1
    private func onUpdate(){
        if self.isHold { return }
        //PageLog.d("onUpdate " + self.maxCount.description, tag: self.tag)
        if self.maxCount < 1 {return}
        let cPos = self.infinityScrollModel.scrollPosition
        if prevPos == -1 {
            self.onFocusChange(willFocus: 0)
            return
        }
        let range = self.getRange()
        let modifyPos = abs(cPos - (range*0.3))
        let willPos:Int = Int( round(modifyPos / range) )
        
        PageLog.d("onUpdate range " + range.description, tag: self.tag)
        PageLog.d("onUpdate willPos  " + willPos.description, tag: self.tag)
        if willPos != self.focusIndex && willPos < self.maxCount {
            self.onFocusChange(willFocus: willPos)
        }
    }
    
    private func getRange()-> CGFloat {
        return PlayItem.getListRange(
            width: self.sceneObserver.screenSize.width,
            sceneOrientation: self.sceneOrientation)
            + self.spacing
    }
    
    private func onFocusChange(willFocus:Int){
        
        PageLog.d("onFocusChange " + willFocus.description, tag: self.tag)
        self.prevPos = self.infinityScrollModel.scrollPosition
          
        self.onPlaytimeChanged(t:self.playerModel.time)
        self.finalIndex = nil
        self.playerModel.event = .pause
        self.playerModel.reset()
        self.playerModel.resetCurrentPlayer()
        self.pagePresenter.orientationLock(isLock: false)
        self.selectedData = self.datas[willFocus]
        withAnimation{ self.focusIndex = willFocus }
    }
    
}



