//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
struct PageThema: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    @State var originDatas:Array<BlockItem> = []
    @State var originBlocks:Array<BlockData> = []
    @State var blocks:Array<BlockData> = []
    @State var anyCancellable = Set<AnyCancellable>()
    
    @State var reloadDegree:Double = 0
    @State var useTracking:Bool = false
    @State var title:String? = nil
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                PageDataProviderContent(
                    pageObservable:self.pageObservable,
                    viewModel : self.viewModel
                ){
                    VStack(spacing:0){
                        PageTab(
                            title: self.title,
                            isBack : true
                        )
                        .padding(.top, self.sceneObserver.safeAreaTop)
                        ZStack(alignment: .topLeading){
                            if self.blocks.isEmpty {
                                Spacer()
                            }else{
                                VStack{
                                    ReflashSpinner(
                                        progress: self.$reloadDegree
                                    )
                                    Spacer()
                                }
                                MultiBlock(
                                    viewModel: self.infinityScrollModel,
                                    pageObservable: self.pageObservable,
                                    pageDragingModel: self.pageDragingModel,
                                    datas: self.blocks,
                                    useTracking:self.useTracking,
                                    marginVertical: 0
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
                        }
                    }
                }
                .modifier(PageFull())
                .highPriorityGesture(
                    DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
                        .onChanged({ value in
                            if self.useTracking { self.useTracking = false }
                            self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ _ in
                            self.pageDragingModel.uiEvent = .draged(geometry)
                            self.useTracking = true
                        })
                )
                .gesture(
                    self.pageDragingModel.cancelGesture
                        .onChanged({_ in
                            self.useTracking = true
                            self.pageDragingModel.uiEvent = .dragCancel})
                        .onEnded({_ in
                            self.useTracking = true
                            self.pageDragingModel.uiEvent = .dragCancel})
                )
            }
            .onReceive(self.infinityScrollModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pullCancel :
                    if !self.infinityScrollModel.isLoading {
                        if self.reloadDegree >= ReflashSpinner.DEGREE_MAX { self.reload() }
                    }
                    withAnimation{
                        self.reloadDegree = 0
                    }
                default : do{}
                }
                
            }
            .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                if pos < InfinityScrollModel.PULL_RANGE { return }
                withAnimation{
                    self.reloadDegree = Double(pos)
                }
            }
            .onReceive(self.infinityScrollModel.$scrollPosition){pos in
                self.pageDragingModel.uiEvent = .dragCancel
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
                if ani {
                    self.reload()
                }
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                self.useTracking = page?.id == self.pageObject?.id
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.title = obj.getParamValue(key: .title) as? String
                self.originDatas = obj.getParamValue(key: .data) as? [BlockItem] ?? []
            }
            .onDisappear{
                self.delayRequestSubscription?.cancel()
                self.delayRequestSubscription = nil
                self.anyCancellable.forEach{$0.cancel()}
                self.anyCancellable.removeAll()
            }
        }//geo
    }//body
    
    private func reload(){
        self.delayRequestSubscription?.cancel()
        self.delayRequestSubscription = nil
        self.isDataCompleted = false
        self.useTracking = false
        self.originBlocks = []
        self.blocks = []
        self.setupBlocks()
    }
    
    private func setupBlocks(){
        let blocks = self.originDatas.map{ d in
            BlockData().setDate(d)
        }
        .filter{ block in
            switch block.dataType {
            case .cwGrid : return block.menuId != nil && block.cwCallId != nil
            case .grid : return block.menuId != nil
            default : return true
            }
        }
        
        self.originBlocks = blocks
        blocks.forEach{ block in
            block.$status.sink(receiveValue: { stat in
                self.onBlock(stat:stat, block:block)
            }).store(in: &anyCancellable)
        }
        self.addBlock()
    }
    
    private let setNum = 5
    @State var requestNum = 0
    @State var completedNum = 0
    @State var isDataCompleted = false
    
    private func requestBlockCompleted(){
        PageLog.d("addBlock completed", tag: "BlockProtocol")
        self.isDataCompleted = true
    }
    private func onBlock(stat:BlockStatus, block:BlockData){
        self.useTracking = true
        switch stat {
        case .passive: self.removeBlock(block)
        case .active: break
        default: return
        }
        self.completedNum += 1
        PageLog.d("completedNum " + completedNum.description, tag: "BlockProtocol")
        if self.completedNum == self.requestNum {
            self.completedNum = 0
            self.delayRequest()
        }
    }
    
    @State var delayRequestSubscription:AnyCancellable?
    func delayRequest(){
        self.delayRequestSubscription?.cancel()
        self.delayRequestSubscription = Timer.publish(
            every: 0.01, on: .current, in: .tracking)
            .autoconnect()
            .sink() {_ in
                self.delayRequestSubscription?.cancel()
                self.delayRequestSubscription = nil
                self.addBlock()
            }
    }
    
    private func addBlock(){
        let max = min(setNum, self.originBlocks.count)
        if max == 0 {
            self.requestBlockCompleted()
            return
        }
        let set = self.originBlocks[..<max]
        self.originBlocks.removeSubrange(..<max)
        PageLog.d("addBlock" + set.debugDescription, tag: "BlockProtocol")
        if set.isEmpty { return }
        self.requestNum = set.count
        DispatchQueue.main.async {
            withAnimation {
                self.blocks.append(contentsOf: set)
            }
        }
    }
    
    private func removeBlock(_ block:BlockData){
        DispatchQueue.main.async {
            guard let find = self.blocks.firstIndex(of: block) else { return }
            self.blocks.remove(at: find)
        }
    }
    
}


#if DEBUG
struct PageThema_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageThema().contentBody
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

