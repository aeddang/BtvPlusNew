//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
struct PageMultiBlock: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var multiBlockViewModel:MultiBlockModel = MultiBlockModel(logType: .list)
    @ObservedObject var cateBlockViewModel:CateBlockModel = CateBlockModel()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var cateInfinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var tabInfinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    @State var marginBottom:CGFloat = 0
    @State var isInit:Bool = false
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack(alignment: .topLeading){
                    if self.cateData != nil {
                        CateBlock(
                            pageObservable: self.pageObservable,
                            infinityScrollModel:self.cateInfinityScrollModel,
                            viewModel:self.cateBlockViewModel,
                            useTracking:true,
                            marginTop: self.marginTop + self.sceneObserver.safeAreaTop + Dimen.app.top,
                            marginBottom: self.marginBottom
                        )
                        
                    } else {
                        MultiBlockBody(
                            pageObservable: self.pageObservable,
                            viewModel: self.multiBlockViewModel,
                            infinityScrollModel: self.infinityScrollModel,
                            pageDragingModel: self.pageDragingModel,
                            useBodyTracking: self.themaType == .ticket ? false : true,
                            useTracking:true,
                            marginTop: self.marginTop  + Dimen.margin.thin + self.sceneObserver.safeAreaTop + Dimen.app.top,
                            marginBottom: self.marginBottom,
                            isRecycle : self.themaType == .ticket ? false : true
                        )
                        .onReceive(self.pageDragingModel.$nestedScrollEvent){evt in
                            guard let evt = evt else {return}
                            switch evt {
                            case .pullCompleted :
                                self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                            case .pullCancel :
                                self.pageDragingModel.uiEvent = .pullCancel(geometry)
                            case .pull(let pos) :
                                self.pageDragingModel.uiEvent = .pull(geometry, pos)
                            default: break
                            }
                        }
                    }
                    ZStack(alignment: .topLeading){
                        if self.tabDatas != nil && self.isTop != nil {
                            TextTabList(
                                viewModel:self.tabInfinityScrollModel,
                                datas: self.tabDatas!,
                                selectedIdx:self.selectedTabIdx,
                                useTracking:false) { data in
                                self.setupOriginData(idx: data.index)
                            }
                            .modifier(MatchHorizontal(height: TextTabList.height))
                            .padding(.top, (self.isTop == true ? Dimen.app.pageTop  : 0) + self.sceneObserver.safeAreaTop )
                        }
                        PageTab(
                            title: self.title,
                            isBack : true,
                            style: .dark
                        )
                        .padding(.top, self.sceneObserver.safeAreaTop)
                    }
                    .modifier(MatchHorizontal(height: (self.isTop == true ? self.marginTop  : 0) + Dimen.app.pageTop  + self.sceneObserver.safeAreaTop))
                    .background(Color.app.blueDeep)
                }
                .onReceive(self.infinityScrollModel.$event){evt in
                    guard let evt = evt else {return}
                    if self.isTop == nil {return}
                    switch evt {
                    case .top :
                        if self.isTop == true {return}
                        withAnimation{self.isTop = true}
                    case .down :
                        if self.isTop == false {return}
                        withAnimation{self.isTop = false}
                    default : do{}
                    }
                    
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }

            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    if self.isInit {return}
                    DispatchQueue.main.async {
                        self.appSceneObserver.useTop = false
                        self.isInit = true
                        self.setupOriginData()
                    }
                    if self.themaType == .ticket {
                        self.pairing.authority.requestAuth(.updateTicket)
                    }
                }
            }
            .onReceive(self.pairing.$event){ evt in
                guard let evt = evt else {return}
                guard let idx = self.finalSelectedIndex else {return}
                switch evt {
                case .pairingCompleted : self.setupOriginData(idx: idx )
                default : break
                }
            }
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                withAnimation{ self.marginBottom = bottom }
            }
            .onReceive(self.appSceneObserver.$event){ evt in
                guard let evt = evt else { return }
                switch evt {
                case .update(let type):
                    switch type {
                    case .purchase :
                        if self.themaType == .ticket {
                            self.pairing.authority.requestAuth(.updateTicket)
                        }
                    default : break
                    }
                default : break
                }
            }
            .onReceive(self.pagePresenter.$event){ evt in
                guard let evt = evt else {return}
                self.onEventWatchLv(evt: evt)
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.openId = obj.getParamValue(key: .subId) as? String
                self.isFree = obj.getParamValue(key: .isFree) as? Bool ?? false
                if let data = obj.getParamValue(key: .data) as? CateData {
                    self.title = data.title
                    if let blocks = data.blocks?.filter({ $0.menu_id != nil }) {
                        let tabs = zip(0...blocks.count, blocks).map { idx, d in
                            TextTabData().setData(data: d, idx: idx)
                        }
                        .filter({$0.useAble})
                        self.tabDatas = tabs
                        if (self.tabDatas?.count ?? 0) > 0 {
                            self.marginTop =  TextTabList.height
                            self.isTop = true
                        }
                    }
                    
                    
                }else{
                    self.title = obj.getParamValue(key: .title) as? String
                    self.titleId = obj.getParamValue(key: .id) as? String
                    self.originDatas = obj.getParamValue(key: .data) as? [BlockItem] ?? []
                }
                
                self.themaType = obj.getParamValue(key: .type) as? BlockData.ThemaType ?? .category
            }
            
        }//geo
    }//body
    
    @State var themaType:BlockData.ThemaType = .category
    @State var marginTop:CGFloat = 0
    @State var isTop:Bool? = nil
    @State var cateData:TextTabData? = nil
    @State var tabDatas:[TextTabData]? = nil
    @State var selectedTabIdx:Int = -1
    @State var originDatas:[BlockItem] = []
   
    @State var title:String? = nil
    @State var titleId:String? = nil
    @State var finalSelectedIndex:Int? = nil
    @State var openId:String? = nil
    @State var isFree:Bool = false
    
    
    func onEventWatchLv(evt :PageEvent){
        if evt.id != self.tag { return }
        switch evt.type {
        case .completed :
            setupOriginData(idx:finalSelectedIndex)
        case .cancel :
           break
            
        default : break
        }
    }
    
    private func setupOriginData(idx:Int? = nil){
        var moveIdx:Int = idx ?? 0
        
        if idx == nil ,
           let findIds = openId?.contains("/") == true ? openId?.split(separator: "/") :  openId?.split(separator: "|")
        {
            let tab = self.tabDatas?.first(
                where: { t in
                    guard let menuId = t.menuId else {return false}
                    return findIds.first(where: {$0 == menuId}) != nil
                }
            )
            moveIdx = tab?.index ?? 0
        }
        
        let isAdult = self.tabDatas?[moveIdx].isAdult ?? false
        if self.pairing.status != .pairing && isAdult {
            finalSelectedIndex = idx
            self.appSceneObserver.alert = .needPairing()
            return
        }
        if !SystemEnvironment.isWatchAuth && SystemEnvironment.watchLv != 0 && isAdult {
            finalSelectedIndex = idx
            if SystemEnvironment.currentPageType == .btv {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.confirmNumber)
                        .addParam(key: .id, value: self.tag)
                        .addParam(key: .type, value: ScsNetwork.ConfirmType.adult)
                )
            }
            return
        }
        finalSelectedIndex = nil
        
        
        guard let datas = self.tabDatas else { return reload() }
        let data = datas[moveIdx]
        selectedTabIdx = moveIdx
        originDatas = data.blocks ?? []
        var delay:Double = 0
        if originDatas.isEmpty || data.isDropBox {
            if self.cateData == nil {delay = 0.1}
            self.cateData = data
        } else {
            if self.cateData != nil {delay = 0.1}
            self.cateData =  nil
        }
        reload(delay:delay, openId: self.openId)
        self.openId = nil
    }
    
    private func reload(delay:Double = 0, openId:String? = nil){
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) {
            DispatchQueue.main.async {
                var title = self.title
                var menuId = self.titleId
                
                if let data = self.cateData {
                    if data.isDropBox {
                        let dropMenus:[BlockData] = self.originDatas.map{ BlockData().setData($0) }
                        self.cateBlockViewModel.setupDropDown(datas: dropMenus)
                        if let first = dropMenus.first {
                            self.cateBlockViewModel
                                .update(data:first, listType: first.uiType.listType ?? .poster,
                                        idx: 0, isFree: self.isFree)
                        }
                    } else {
                        self.cateBlockViewModel.update(menuId:data.menuId,
                                                       listType:data.listType ?? .poster,
                                                       isAdult:data.isAdult, isFree: self.isFree)
                        
                    }
                    title = data.title
                    menuId = data.menuId ?? menuId
                } else {
                    if (self.tabDatas?.count ?? 0) > 1, let tabDatas = self.tabDatas {
                        title = tabDatas[self.selectedTabIdx].title
                        menuId = tabDatas[self.selectedTabIdx].menuId ?? menuId
                    }
                    let isAdult = self.tabDatas?[selectedTabIdx].isAdult ?? false
                    self.multiBlockViewModel.update(
                        datas: self.originDatas,
                        openId: openId,
                        kid: self.pairing.kid,
                        themaType: self.themaType, isAdult:isAdult, title: title, isFree: self.isFree)
                }
                if let tabs = self.tabDatas {
                    if self.selectedTabIdx > 0 && tabs.count > self.selectedTabIdx {
                        self.tabInfinityScrollModel.uiEvent = .scrollTo(tabs[self.selectedTabIdx].hashId)
                    }
                }
                self.naviLogManager.actionLog(
                    .pageShow,
                    actionBody: .init(menu_id: menuId, menu_name: title))
            }
        }
    }
}


#if DEBUG
struct PageThema_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMultiBlock().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

