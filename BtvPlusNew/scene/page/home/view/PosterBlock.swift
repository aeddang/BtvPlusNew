//
//  PosterBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI

struct PosterBlock:PageComponent, BlockProtocol {
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var viewModel: InfinityScrollModel = InfinityScrollModel()
    var data: Block
    @State var datas:[PosterData] = []
    @State var listHeight:CGFloat = 0
    var body :some View {
        VStack(alignment: .leading , spacing: Dimen.margin.thinExtra) {
            if !self.datas.isEmpty {
                Text(data.name).modifier(BlockTitle())
            }
            PosterList(viewModel:self.viewModel, datas: self.$datas)
                .modifier(MatchHorizontal(height: self.listHeight))
           
        }
        .onAppear{
            if let datas = data.posters {
                self.datas = datas
                self.updateListSize()
                ComponentLog.d("ExistData " + data.name, tag: "BlockProtocol")
                
            }
            if let apiQ = self.getRequestApi() {
                dataProvider.requestData(q: apiQ)
            }
        }
        .onDisappear{
            
        }
        
        .onReceive(dataProvider.$result) { res in
            if res?.id != data.id { return }
            var allDatas:[PosterData] = []
            switch data.dataType {
            case .cwGrid:
                guard let resData = res?.data as? CWGrid else {return onBlank()}
                guard let grid = resData.grid else {return onBlank()}
                grid.forEach{ g in
                    if let blocks = g.block {
                        let addDatas = blocks.map{ d in
                            PosterData().setData(data: d, cardType: data.cardType)
                        }
                        allDatas.append(contentsOf: addDatas)
                    }
                }
            case .grid:
                guard let resData = res?.data as? GridEvent else {return onBlank()}
                guard let blocks = resData.contents else {return onBlank()}
                let addDatas = blocks.map{ d in
                    PosterData().setData(data: d, cardType: data.cardType)
                }
                allDatas.append(contentsOf: addDatas)
                
            case .bookMark:
                guard let resData = res?.data as? BookMark else {return onBlank()}
                guard let blocks = resData.bookmarkList else {return onBlank()}
                let addDatas = blocks.map{ d in
                    PosterData().setData(data: d, cardType: data.cardType)
                }
                allDatas.append(contentsOf: addDatas)
                
            case .watched:
                guard let resData = res?.data as? Watch else {return onBlank()}
                guard let blocks = resData.watchList else {return onBlank()}
                let addDatas = blocks.map{ d in
                    PosterData().setData(data: d, cardType: data.cardType)
                }
                allDatas.append(contentsOf: addDatas)
                
            default: do {}
            }
            self.datas = allDatas
            self.updateListSize()
            self.data.posters = allDatas
            ComponentLog.d("Remote " + data.name, tag: "BlockProtocol")
        }
        .onReceive(dataProvider.$error) { err in
            if err?.id != data.id { return }
            onError(err)
            
        }
    }
    
    func updateListSize(){
        if !self.datas.isEmpty {
            self.listHeight = self.datas.first!.type.size.height
        }
        else { onBlank() }
    }
    
    
}
