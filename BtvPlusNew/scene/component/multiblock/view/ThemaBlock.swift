//
//  VideoBlock.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI

struct ThemaBlock:BlockProtocol, PageComponent {
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var viewModel: InfinityScrollModel = InfinityScrollModel()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var data: BlockData
    var useTracking:Bool = false
    @State var datas:[ThemaData] = []
    @State var listHeight:CGFloat = 0
    var body :some View {
        VStack(alignment: .leading , spacing: Dimen.margin.thinExtra) {
            if !self.datas.isEmpty {
                Text(data.name).modifier(BlockTitle())
                    .modifier(ContentHorizontalEdges())
            }
            ThemaList(
                viewModel:self.viewModel,
                datas: self.datas,
                useTracking:self.useTracking)
                
                .modifier(MatchHorizontal(height: self.listHeight))
                .onReceive(self.viewModel.$event){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .pullCompleted : self.pageDragingModel.updateNestedScroll(evt: .pullCompleted)
                    case .pullCancel : self.pageDragingModel.updateNestedScroll(evt: .pullCancel)
                    default : do{}
                    }
                }
                .onReceive(self.viewModel.$pullPosition){ pos in
                    self.pageDragingModel.updateNestedScroll(evt: .pull(pos))
                }
            
        }
        .frame( height: self.listHeight + Font.size.regular + Dimen.margin.thinExtra)
        .onAppear{
            self.datas = []
            if data.dataType == .theme , let blocks = data.blocks {
                self.datas = blocks.map{ d in
                    ThemaData().setData(data: d, cardType: data.cardType)
                }
                self.updateListSize()
                return
            }
            if let apiQ = self.getRequestApi(pairing:pairing.status) {
                dataProvider.requestData(q: apiQ)
            } else {
                self.data.setRequestFail()
            }
        }
        .onReceive(dataProvider.$result) { res in
            if res?.id != data.id { return }
            var allDatas:[ThemaData] = []
            switch data.dataType {
            case .cwGrid:
                guard let resData = res?.data as? CWGrid else {return onBlank()}
                guard let grid = resData.grid else {return onBlank()}
                grid.forEach{ g in
                    if let blocks = g.block {
                        let addDatas = blocks.map{ d in
                            ThemaData().setData(data: d, cardType: data.cardType)
                        }
                        allDatas.append(contentsOf: addDatas)
                    }
                }
            case .grid:
                guard let resData = res?.data as? GridEvent else {return onBlank()}
                guard let blocks = resData.contents else {return onBlank()}
                let addDatas = blocks.map{ d in
                    ThemaData().setData(data: d, cardType: data.cardType)
                }
                allDatas.append(contentsOf: addDatas)
            default: do {}
            }
            self.datas = allDatas
            self.updateListSize()
            self.data.themas = allDatas
            ComponentLog.d(allDatas.count.description, tag: self.tag)
            
        }
        .onReceive(dataProvider.$error) { err in
            if err?.id != data.id { return }
            onError(err)
            ComponentLog.d(err.debugDescription, tag: self.tag)
        }
    }
    func updateListSize(){
        if !self.datas.isEmpty {
            self.listHeight = self.datas.first!.type.size.height
            onDataBinding()
        }
        else { onBlank() }
    }
    
}
