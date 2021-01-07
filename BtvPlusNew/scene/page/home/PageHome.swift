//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
struct PageHome: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @State var originBlocks:Array<Block> = []
    @State var blocks:Array<Block> = []
    @State var menuId:String = ""
    @State var anyCancellable = Set<AnyCancellable>()
    
    @State var reloadDegree:Double = 0
    @State var useTracking:Bool = false
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            if self.blocks.isEmpty {
                Spacer()
            }else{
                VStack{
                    ReflashSpinner(
                        progress: self.$reloadDegree
                    )
                    .padding(.top, Dimen.app.pageTop)
                    Spacer()
                }
                MultiBlock(viewModel: self.infinityScrollModel, datas: self.$blocks, useTracking:self.useTracking)
            }
        }
        .modifier(PageFull())
        .onAppear{
            guard let obj = self.pageObject  else { return }
            DispatchQueue.main.async {
                self.menuId = (obj.getParamValue(key: .id) as? String) ?? self.menuId
                self.setupBlocks()
            }
            
        }
        .onReceive(self.dataProvider.bands.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .updated: self.setupBlocks()
            default: do{}
            }
        }
        .onReceive(self.infinityScrollModel.$event){evt in
            guard let evt = evt else {return}
            if self.pagePresenter.currentTopPage?.pageID == .home {
                switch evt {
                case .top : self.pageSceneObserver.useTop = true
                case .down :
                    if !self.isDataCompleted { return }
                    self.pageSceneObserver.useTop = false
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
        }
        .onReceive(self.infinityScrollModel.$pullPosition){ pos in
            PageLog.d("infinityScrollModel " + pos.description, tag: self.tag)
            if pos < 30 && pos > 120{ return }
            if self.reloadDegree >= ReflashSpinner.DEGREE_MAX
                && Double(pos) < self.reloadDegree
            {
                return
            }
            withAnimation{
                self.reloadDegree = Double(pos)
                PageLog.d("self.reloadDegree " + self.reloadDegree.description, tag: self.tag)
            }
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            self.useTracking = ani
        }
        .onDisappear{
            self.anyCancellable.forEach{$0.cancel()}
            self.anyCancellable.removeAll()
        }
        
    }//body
    
    private func reload(){
        self.isDataCompleted = false
        self.originBlocks = []
        self.blocks = []
        self.setupBlocks()
    }
    
    private func setupBlocks(){
        guard let blocksData = self.dataProvider.bands.getData(menuId: self.menuId)?.blocks else {return}
        let blocks = blocksData.map{ data in
            Block().setDate(data)
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
    private func onBlock(stat:BlockStatus, block:Block){
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
    
    private func removeBlock(_ block:Block){
        DispatchQueue.main.async {
            guard let find = self.blocks.firstIndex(of: block) else { return }
            self.blocks.remove(at: find)
        }
    }
    
}


#if DEBUG
struct PageHome_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageHome().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(PageSceneObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

