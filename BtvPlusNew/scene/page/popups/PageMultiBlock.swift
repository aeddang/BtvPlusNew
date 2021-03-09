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
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var multiBlockViewModel:MultiBlockModel = MultiBlockModel()
    @ObservedObject var cateBlockViewModel:CateBlockModel = CateBlockModel()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var cateInfinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                
                ZStack(alignment: .topLeading){
                    if self.cateData != nil {
                        CateBlock(
                            infinityScrollModel:self.cateInfinityScrollModel,
                            viewModel:self.cateBlockViewModel,
                            useTracking:self.useTracking,
                            marginTop: self.marginTop + self.sceneObserver.safeAreaTop + Dimen.app.top,
                            marginBottom: Dimen.app.bottom + self.sceneObserver.safeAreaBottom
                        )
                        .background(Color.brand.bg)
                    } else {
                        MultiBlockBody(
                            viewModel: self.multiBlockViewModel,
                            infinityScrollModel: self.infinityScrollModel,
                            pageObservable: self.pageObservable,
                            pageDragingModel: self.pageDragingModel,
                            useBodyTracking: self.useTracking,
                            useTracking:self.useTracking,
                            marginTop: self.marginTop  + Dimen.margin.thin + self.sceneObserver.safeAreaTop + Dimen.app.top,
                            marginBottom: Dimen.app.bottom + self.sceneObserver.safeAreaBottom
                        )
                        .onReceive(self.pageDragingModel.$nestedScrollEvent){evt in
                            guard let evt = evt else {return}
                            switch evt {
                            case .pulled :
                                self.pageDragingModel.uiEvent = .pulled(geometry)
                            case .pull(let pos) :
                                self.pageDragingModel.uiEvent = .pull(geometry, pos)
                            default: break
                            }
                        }
                        
                    }
                    ZStack(alignment: .topLeading){
                        if self.tabDatas != nil && self.isTop != nil {
                            TextTabList(
                                datas: self.tabDatas!,
                                selectedIdx:self.selectedTabIdx,
                                useTracking:self.useTracking) { data in
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
                    case .top : withAnimation{self.isTop = true}
                    case .down : withAnimation{self.isTop = false}
                    default : do{}
                    }
                }
                
                .modifier(PageFull())
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
                        .onChanged({_ in
                            //self.useTracking = true
                            self.pageDragingModel.uiEvent = .dragCancel})
                        .onEnded({_ in
                            //self.useTracking = true
                            self.pageDragingModel.uiEvent = .dragCancel})
                )
            }
            
            .onReceive(self.infinityScrollModel.$scrollPosition){pos in
                
                self.pageDragingModel.uiEvent = .dragCancel
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
                if ani { self.setupOriginData(idx:0) }
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                self.useTracking = page?.id == self.pageObject?.id
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let data = obj.getParamValue(key: .data) as? CateData {
                    self.title = data.title
                    if let blocks = data.blocks?.filter({ $0.menu_id != nil }) {
                        self.tabDatas = zip(0...blocks.count, blocks).map { idx, d in
                            TextTabData().setData(data: d, idx: idx)
                        }
                        .filter({$0.useAble})
                        
                        if (self.tabDatas?.count ?? 0) > 1 {
                            self.marginTop =  TextTabList.height
                            self.isTop = true
                        }
                    }
                    
                }else{
                    self.title = obj.getParamValue(key: .title) as? String
                    self.originDatas = obj.getParamValue(key: .data) as? [BlockItem] ?? []
                }
            }
            
        }//geo
    }//body
    
    
    @State var marginTop:CGFloat = 0
    @State var isTop:Bool? = nil
    @State var cateData:TextTabData? = nil
    @State var tabDatas:[TextTabData]? = nil
    @State var selectedTabIdx:Int = -1
    @State var originDatas:Array<BlockItem> = []
    @State var useTracking:Bool = false
    @State var title:String? = nil
    
    private func setupOriginData(idx:Int){
        
        guard let datas = self.tabDatas else { return reload() }
        selectedTabIdx = idx
        originDatas = datas[idx].blocks ?? []
        var delay:Double = 0
        if originDatas.isEmpty {
            if self.cateData == nil {delay = 0.1}
            self.cateData = self.tabDatas?[idx]
        } else {
            if self.cateData != nil {delay = 0.1}
            self.cateData =  nil
        }
        reload(delay:delay)
    }
    
    private func reload(delay:Double = 0){
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            DispatchQueue.main.async {
                if let data = self.cateData {
                    self.cateBlockViewModel.update(menuId:data.menuId, listType:data.listType ?? .poster, key:nil)
                } else {
                    self.multiBlockViewModel.update(datas: self.originDatas)
                }
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
                .environmentObject(SceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(PageSceneObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

