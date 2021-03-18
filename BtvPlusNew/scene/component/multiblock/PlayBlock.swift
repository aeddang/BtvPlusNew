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
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:PlayBlockModel = PlayBlockModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var playerModel: BtvPlayerModel = BtvPlayerModel(useFullScreenAction:false)
    
    var key:String? = nil
    var useTracking:Bool = false
    var marginTop : CGFloat = 0
    var marginBottom : CGFloat = 0
    var spacing: CGFloat = Dimen.margin.medium
   
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
                        useTracking: self.useTracking){
                        if self.datas.isEmpty {
                            Spacer().modifier(ListRowInset())
                        } else {
                            ForEach(self.datas) { data in
                                PlayItem(
                                    pageObservable:self.pageObservable,
                                    playerModel:self.playerModel,
                                    data: data,
                                    isSelected: data.index == self.focusIndex
                                    )
                                    .id(data.index)
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
                                        self.onAppear(idx:data.index)
                                    }
                                    .onDisappear{
                                        self.onDisappear(idx: data.index)
                                    }
                                    .onTapGesture {
                                        if self.focusIndex != data.index {
                                            self.onFocusChange(willFocus: data.index)
                                        }
                                        self.pageSceneObserver.event = .toast((data.openDate ?? "") + " " + String.alert.updateAlramRecommand)
                                    }
                            }
                        }
                    }
                    .modifier(MatchParent())

                }
                .background(Color.brand.bg)
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
        .onReceive(self.sceneObserver.$isUpdated){ update in
            if !update {return}
            if self.pagePresenter.currentTopPage?.id != self.pageObject?.id {return}
            if self.playerModel.playData == nil { return }
            switch self.sceneObserver.sceneOrientation {
            case .landscape :
                self.pagePresenter.fullScreenEnter()
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
            default : do{}
            }
            
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
                if isSuccess { self.reload() }
                else { self.pageSceneObserver.alert = .pairingCheckFail }
            default : do{}
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
        .onAppear(){
            self.playerModel.isMute = true
        }
        .onDisappear(){
            self.delayUpdateCancel()
        }
        
    }//body
   
    @State var finalIndex:Int? = nil
    @State var isFullScreen:Bool = false
    private func openFullScreen(){
        if self.playerModel.playData == nil { return }
        self.isFullScreen = true
        self.finalIndex = self.playerModel.currentIdx
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isFullScreen = false
            if let posIdx = self.finalIndex {
                self.infinityScrollModel.uiEvent = .scrollTo(posIdx)
                self.pagePresenter.orientationLock(lockOrientation: .all)
            }
        }
    }
    
    private func onPlaytimeChanged(t:Double){
        guard let data = self.selectedData else { return }
        data.playTime = t
    }
    
    
    @State var isError:Bool = false
    @State var datas:[PlayData] = []
    @State var selectedData:PlayData? = nil
    @State var reloadDegree:Double = 0
    @State var appearList:[Int] = []
    @State var appearValue:Float = 0
    @State var focusIndex:Int = -1
     
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
        let start = self.datas.count
        let end = datas.count
        let loadedDatas:[PlayData] = zip(start...end, datas).map { idx, d in
            return PlayData().setData(data: d, idx: idx)
        }
        self.datas.append(contentsOf: loadedDatas)
        
        if self.pairing.status != .pairing { return }
        self.infinityScrollModel.onComplete(itemCount: loadedDatas.count)
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
            every: 0.4, on: .current, in: .common)
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
    
    private func onUpdate(){
        if self.pagePresenter.isFullScreen { return }
        if self.appearList.isEmpty {
            return
        }
        self.appearList.sort()
        let value = Float(self.appearList.reduce(0, {$0 + $1}) / self.appearList.count)
        let diff = self.appearValue - value
        self.appearValue = value
        let willIdx = Int(round(Double(self.appearList.count/2)))
        var willFocus = self.appearList[willIdx]
        if diff > 0 {
            if self.appearList.first == 0 && willFocus == self.focusIndex {
                willFocus = self.appearList.first ?? 0
            }
        } else {
            if self.appearList.last == (self.datas.count-1) && willFocus == self.focusIndex{
                willFocus = self.appearList.last ?? self.datas.count-1
            }
        }
        if self.selectedData == nil { willFocus = 0 }
        if self.focusIndex != willFocus  {
            self.onFocusChange(willFocus: willFocus)
        }
        
    }
    
    private func onFocusChange(willFocus:Int){
        PageLog.d("onFocusChange " + willFocus .description, tag: self.tag)
        if self.pagePresenter.isFullScreen { return }
        if self.isFullScreen { return }
        self.onPlaytimeChanged(t:self.playerModel.time)
        self.finalIndex = nil
        self.playerModel.reset()
        self.playerModel.resetCurrentPlayer()
        self.pagePresenter.orientationLock(isLock: false)
        self.selectedData = self.datas[willFocus]
        PageLog.d("onFocusChange completed " + willFocus .description, tag: self.tag)
        withAnimation{ self.focusIndex = willFocus }
    }

}



