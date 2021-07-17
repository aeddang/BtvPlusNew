//
//  VideoBlock.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI

struct TicketBlock:BlockProtocol, PageComponent {
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    var pageObservable:PageObservable
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var data: BlockData
    var useTracking:Bool = false
    @State var datas:[TicketData]? = nil
  
    @State var isUiActive:Bool = true
    var body :some View {
        VStack(alignment: .leading , spacing: Dimen.margin.thinExtra) {
            if self.isUiActive {
                if self.datas?.isEmpty == false {
                    Text(data.name).modifier(BlockTitle())
                        .frame(height:Dimen.tab.thin)
                        .modifier(ContentHorizontalEdges())
                }
                if let datas = self.datas {
                    TicketList(
                        viewModel:self.viewModel,
                        data:self.data,
                        datas: datas,
                        useTracking:self.useTracking)
                }
            }
        }
        .modifier(
            ContentScrollPull(
                infinityScrollModel: self.viewModel,
                pageDragingModel: self.pageDragingModel)
        )
        .onAppear{
            if self.datas?.isEmpty == false {
                ComponentLog.d("RecycleData " + data.name, tag: "BlockProtocol")
                return
            }
            if let datas = data.tickets {
                self.datas = datas
                return
            }
            
            if data.dataType == .theme , let blocks = data.blocks {
                self.datas = blocks.map{ d in
                    TicketData().setData(data: d, cardType: data.cardType, posters: self.data.posters)
                }
                self.updateListSize()
                ComponentLog.d("ExistData " + data.name, tag: "BlockProtocol")
                return
            }
            if let apiQ = self.getRequestApi(pairing:pairing.status) {
                ComponentLog.d("RequestData " + data.name, tag: "BlockProtocolA")
                dataProvider.requestData(q: apiQ)
            } else {
                ComponentLog.d("RequestData Fail" + data.name, tag: "BlockProtocolA")
                self.data.setRequestFail()
            }
        }
        .onReceive(self.pageObservable.$layer ){ layer  in
            switch layer {
            case .bottom : self.isUiActive = false
            case .top, .below : self.isUiActive = true
            }
        }
        .onReceive(dataProvider.$result) { res in
            if res?.id != data.id { return }
            var allDatas:[TicketData] = []
            switch data.dataType {
            case .cwGrid:
                guard let resData = res?.data as? CWGrid else {return onBlank()}
                guard let grid = resData.grid else {return onBlank()}
                grid.forEach{ g in
                    if let blocks = g.block {
                        let addDatas = blocks.map{ d in
                            TicketData().setData(data: d, cardType: data.cardType)
                        }
                        allDatas.append(contentsOf: addDatas)
                    }
                }
            case .grid:
                guard let resData = res?.data as? GridEvent else {return onBlank()}
                guard let blocks = resData.contents else {return onBlank()}
                let addDatas = blocks.map{ d in
                    TicketData().setData(data: d, cardType: data.cardType)
                }
                allDatas.append(contentsOf: addDatas)
            default: do {}
            }
            self.datas = allDatas
            self.updateListSize()
            self.data.tickets = allDatas
            ComponentLog.d(allDatas.count.description, tag: self.tag)
            
        }
        .onReceive(dataProvider.$error) { err in
            if err?.id != data.id { return }
            onError(err)
            ComponentLog.d(err.debugDescription, tag: self.tag)
        }
    }
    func updateListSize(){
        if self.datas?.isEmpty == false {
            onDataBinding()
        }
        else { onBlank() }
    }
    
}
