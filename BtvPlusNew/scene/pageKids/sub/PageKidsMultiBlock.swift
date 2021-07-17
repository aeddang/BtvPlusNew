//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

extension PageKidsMultiBlock{
    static let tabWidth:CGFloat = SystemEnvironment.isTablet ? 186 : 123
    static let tabMargin:CGFloat = DimenKids.margin.regular
    static let tabLimitedTitleSize:Int  = 10
}

struct PageKidsMultiBlock: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var tabNavigationModel:NavigationModel = NavigationModel()
    @ObservedObject var multiBlockViewModel:MultiBlockModel = MultiBlockModel()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var scrollTabSize:Int = 3
    @State var isDivisionTab:Bool = true
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack(alignment: .top){
                    MultiBlockBody(
                        pageObservable: self.pageObservable,
                        viewModel: self.multiBlockViewModel,
                        infinityScrollModel: self.infinityScrollModel,
                        pageDragingModel: self.pageDragingModel,
                        useBodyTracking: self.themaType == .ticket ? false : self.useTracking,
                        useTracking:self.useTracking,
                        marginTop: DimenKids.app.pageTop + self.marginTop + DimenKids.margin.regular + self.sceneObserver.safeAreaTop,
                        marginBottom: self.sceneObserver.safeAreaIgnoreKeyboardBottom
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
                    
                    VStack(spacing: 0){
                        PageKidsTab(
                            title: self.title,
                            isBack : true,
                            style: .kidsWhite
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        if self.tabs.count > 1 {
                            ScrollMenuTab(
                                viewModel: self.tabNavigationModel,
                                tabIdx: self.selectedTabIdx,
                                tabs: self.tabs,
                                scrollTabSize:self.scrollTabSize,
                                tabWidth: Self.tabWidth,
                                tabColor: Color.app.ivoryLight,
                                bgColor: Color.app.white,
                                marginHorizontal: Self.tabMargin,
                                isDivision: self.isDivisionTab
                            )
                            .opacity(self.isTop ? 1 : 0)
                            .modifier(ContentHorizontalEdgesKids(margin:Self.tabMargin))
                            .frame( height: self.isTop ? MenuTab.height : 0)
                            .padding(.bottom, self.isTop ? DimenKids.margin.thin : 0)
                            .onReceive(self.tabNavigationModel.$index){ idx in
                                if !self.isUiInit { return }
                                self.setupOriginData(idx: idx)
                            }
                        }
                    }
                    .background(Color.app.white)
                }
                .onReceive(self.infinityScrollModel.$event){evt in
                    guard let evt = evt else {return}
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
                .modifier(PageFullScreen(style:.kids))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }

            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
                if ani {
                    self.isUiInit = true
                    self.setupOriginData()
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
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                if page?.id == self.pageObject?.id {
                    if self.useTracking {return}
                    self.useTracking = true
                    
                } else {
                    if !self.useTracking {return}
                    self.useTracking = false
                }
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
            .onAppear{
                let w = Float(geometry.size.width - (Self.tabMargin*2) - max(geometry.safeAreaInsets.leading,geometry.safeAreaInsets.trailing) )
                let limit = Int(floor(w / Float(Self.tabWidth)))
                self.scrollTabSize = limit
                guard let obj = self.pageObject  else { return }
                self.openId = obj.getParamValue(key: .subId) as? String
                self.title = obj.getParamValue(key: .title) as? String
                self.tabDatas = obj.getParamValue(key: .datas) as? [BlockItem] ?? []
                
                
                
                self.tabs = self.tabDatas.map{$0.menu_nm ?? ""}
                if self.tabDatas.count > 1 {
                    if self.tabs.first(where: {$0.count > Self.tabLimitedTitleSize}) != nil {
                        self.isDivisionTab = false
                    }
                    self.marginTop =  MenuTab.height + DimenKids.margin.thin
                }
                self.themaType = obj.getParamValue(key: .type) as? BlockData.ThemaType ?? .category
            }
            
        }//geo
    }//body
    @State var isUiInit:Bool = false
    @State var themaType:BlockData.ThemaType = .category
    @State var marginTop:CGFloat = 0
    @State var isTop:Bool = true
   
    @State var tabs:[String] = []
    @State var tabDatas:[BlockItem] = []
    @State var selectedTabIdx:Int = -1
    
    @State var originDatas:[BlockItem] = []
    @State var useTracking:Bool = false
    @State var title:String? = nil
    @State var finalSelectedIndex:Int? = nil
    @State var openId:String? = nil
    
    private func setupOriginData(idx:Int? = nil){
        var moveIdx:Int = idx ?? 0
        if idx == nil , let findIds = self.openId?.split(separator: "|") {
            let tab = zip(0...self.tabDatas.count, self.tabDatas).first(
                where: { idx, t in
                    guard let menuId = t.cw_call_id_val else {return false}
                    return findIds.first(where: {$0 == menuId}) != nil
                }
            )
            moveIdx = tab?.0 ?? 0
        }
        finalSelectedIndex = nil
        selectedTabIdx = moveIdx
        let cdata = self.tabDatas[moveIdx]
        originDatas = cdata.blocks ?? []
        var delay:Double = 0
        if originDatas.isEmpty {
            originDatas = [cdata]
            delay = 0.1
        }
        reload(delay: delay)
        self.openId = nil
    }
    
    private func reload(delay:Double = 0){
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) {
            DispatchQueue.main.async {
                self.multiBlockViewModel.updateKids(
                    datas: self.originDatas, openId: self.openId)
            }
        }
    }
}


#if DEBUG
struct PageKidsMultiBlock_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageKidsMultiBlock().contentBody
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

