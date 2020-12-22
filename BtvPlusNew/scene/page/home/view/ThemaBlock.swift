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
    @ObservedObject var viewModel: InfinityScrollModel = InfinityScrollModel()
    var data: Block
    @State var datas:[ThemaData] = []
    @State var listHeight:CGFloat = 0
    var body :some View {
        VStack(alignment: .leading , spacing: Dimen.margin.thinExtra) {
            if !self.datas.isEmpty {
                Text(data.name).modifier(BlockTitle())
            }
            ThemaList(viewModel:self.viewModel, datas: self.$datas)
                .modifier(MatchHorizontal(height: self.listHeight))
            
        }
        .onAppear{
            self.datas = []
            if let datas = data.themas {
                self.datas = datas
                self.updateListSize()
            }
            if let apiQ = self.getRequestApi() {
                dataProvider.requestData(q: apiQ)
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
        if !self.datas.isEmpty { self.listHeight = self.datas.first!.type.size.height }
        else { onBlank() }
    }
    
}
