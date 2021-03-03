//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

class MultiBlockModel: PageDataProviderModel {
  
    private(set) var datas:[BlockData]? = nil
    private(set) var headerSize:Int = 0
    private(set) var requestSize:Int = 5
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }
    
    init(headerSize:Int = 0, requestSize:Int = 5) {
        self.headerSize = headerSize
        self.requestSize = requestSize
    }
    
    
    func update(datas:[BlockItem]) {
        self.datas = datas.map{ block in
            BlockData().setDate(block)
        }
        .filter{ block in
            switch block.dataType {
            case .cwGrid : return block.menuId != nil && block.cwCallId != nil
            case .grid : return block.menuId != nil
            default : return true
            }
        }
        self.isUpdate = true
    }
    
}


struct MultiBlockBody: PageComponent {
   
    var viewModel:MultiBlockModel = MultiBlockModel()
    var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var pageObservable:PageObservable = PageObservable()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var useBodyTracking:Bool = false
    var useTracking:Bool = false
    var marginTop : CGFloat = 0
    var marginBottom : CGFloat = 0
    var topDatas:[BannerData]? = nil
    var monthlyViewModel: InfinityScrollModel? = nil
    var monthlyDatas:[MonthlyData]? = nil
    var isRecycle = true
    var action: ((_ data:MonthlyData) -> Void)? = nil
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            MultiBlock(
                viewModel: self.infinityScrollModel,
                pageObservable: self.pageObservable,
                pageDragingModel: self.pageDragingModel,
                topDatas: self.topDatas,
                datas: self.blocks,
                headerSize: self.viewModel.headerSize,
                useBodyTracking:self.useBodyTracking,
                useTracking:self.useTracking,
                marginTop:self.marginTop,
                marginBottom: self.marginBottom,
                monthlyViewModel : self.monthlyViewModel,
                monthlyDatas: self.monthlyDatas,
                isRecycle:self.isRecycle,
                action:self.action
                )
        }
        .onReceive(self.viewModel.$isUpdate){ update in
            if update {
                self.reload()
            }
        }
        .onDisappear{
            self.anyCancellable.forEach{$0.cancel()}
            self.anyCancellable.removeAll()
        }
        
    }//body
    
    @State var originBlocks:Array<BlockData> = []
    @State var blocks:[BlockData] = []
    @State var anyCancellable = Set<AnyCancellable>()
    
    func reload(){
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
        self.blocks = []
        self.infinityScrollModel.reload()
        self.originBlocks = viewModel.datas ?? []
        self.setupBlocks()
    }

    private func setupBlocks(){
        self.originBlocks.forEach{ block in
            block.$status.sink(receiveValue: { stat in
                self.onBlock(stat:stat, block:block)
            }).store(in: &anyCancellable)
        }
        self.addBlock()
    }
    
   
    @State var requestNum = 0
    @State var completedNum = 0
    
    private func requestBlockCompleted(){
        PageLog.d("addBlock completed", tag: "BlockProtocol")
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
        var max = 0
        if  #available(iOS 14.0, *) {
            max = self.originBlocks.count
        } else {
            max = min(self.viewModel.requestSize, self.originBlocks.count)
        }
        if max == 0 {
            self.requestBlockCompleted()
            return
        }
        let set = self.originBlocks[..<max]
        self.originBlocks.removeSubrange(..<max)
        PageLog.d("addBlock" + set.debugDescription, tag: "BlockProtocol")
        if set.isEmpty { return }
        self.requestNum = set.count
        self.blocks.append(contentsOf: set)
    }
    
    private func removeBlock(_ block:BlockData){
        if let find = self.blocks.firstIndex(of: block) {
            self.blocks.remove(at: find)
            return
        }
    }
    
}

