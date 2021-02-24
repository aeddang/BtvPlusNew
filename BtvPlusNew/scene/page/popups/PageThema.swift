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
                                    pageDragingModel: self.pageDragingModel,
                                    datas: self.blocks,
                                    useTracking:self.useTracking,
                                    marginVertical: Dimen.margin.lightExtra
                                    )
                                .onReceive(self.pageDragingModel.$nestedScrollEvent){evt in
                                    guard let evt = evt else {return}
                                    switch evt {
                                    case .pulled :
                                        self.pageDragingModel.uiEvent = .pulled(geometry)
                                    case .pull(let pos) :
                                        self.pageDragingModel.uiEvent = .pull(geometry, pos)
                                    case .scroll(_) :
                                        self.pageDragingModel.uiEvent = .dragCancel
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
                            self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ _ in
                            self.pageDragingModel.uiEvent = .draged(geometry)
                        })
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
                if pos < 30 && pos > 120{ return }
                if self.reloadDegree >= ReflashSpinner.DEGREE_MAX
                    && Double(pos) < self.reloadDegree
                {
                    return
                }
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
            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.title = obj.getParamValue(key: .title) as? String
                self.originDatas = obj.getParamValue(key: .data) as? [BlockItem] ?? []
            }
            .onDisappear{
                self.anyCancellable.forEach{$0.cancel()}
                self.anyCancellable.removeAll()
            }
        }//geo
    }//body
    
    private func reload(){
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
        self.useTracking = true
    }
    private func onBlock(stat:BlockStatus, block:BlockData){
        switch stat {
        case .passive: self.removeBlock(block)
        case .active: break
        default: return
        }
        self.completedNum += 1
        PageLog.d("completedNum " + completedNum.description, tag: "BlockProtocol")
        if self.completedNum == self.requestNum {
            self.completedNum = 0
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

