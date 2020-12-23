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
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PageDataProviderModel = PageDataProviderModel()
   
    @State var originBlocks:Array<Block> = []
    @State var blocks:Array<Block> = []
    @State var menuId:String = ""
    @State var anyCancellable = Set<AnyCancellable>()
    
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            if self.blocks.isEmpty {
                Spacer()
            }else{
                MultiBlock(datas: self.$blocks)
            }
        }
        .modifier(PageFull())
        .onAppear{
            guard let obj = self.pageObject  else { return }
            self.menuId = (obj.getParamValue(key: .id) as? String) ?? self.menuId
            self.setupBlocks()
        }
        .onReceive(self.dataProvider.bands.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .updated: self.setupBlocks()
            default: do{}
            }
        }
        
    }//body
    
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
    @State var completedNum = 0
    private func onBlock(stat:BlockStatus, block:Block){
        switch stat {
        case .passive: self.removeBlock(block)
        case .active: break
        default: return
        }
        completedNum += 1
        ComponentLog.d("completedNum " + completedNum.description, tag: "BlockProtocol")
        if completedNum == setNum {
            completedNum = 0
            addBlock()
        }
        
    }
    
    private func addBlock(){
        let max = min(setNum, self.originBlocks.count)
        if max == 0 {return}
        let set = self.originBlocks[..<max]
        self.originBlocks.removeSubrange(..<max)
        ComponentLog.d("addBlock" + set.debugDescription, tag: "BlockProtocol")
        if set.isEmpty { return }
        withAnimation {
            self.blocks.append(contentsOf: set)
        }
    }
    
    private func removeBlock(_ block:Block){
        guard let find = self.blocks.firstIndex(of: block) else { return }
        self.blocks.remove(at: find)
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
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

