//
//  VideoBlock.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI

struct VideoBlock:BlockProtocol, PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var viewModel: InfinityScrollModel = InfinityScrollModel()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var data: BlockData
    var useTracking:Bool = false
    @State var datas:[VideoData] = []
    @State var listHeight:CGFloat = 0
    var body :some View {
        VStack(alignment: .leading , spacing: Dimen.margin.thinExtra) {
            if !self.datas.isEmpty {
                HStack( spacing:Dimen.margin.thin){
                    VStack(alignment: .leading, spacing:0){
                        Text(data.name).modifier(BlockTitle())
                            .lineLimit(1)
                        Spacer().modifier(MatchHorizontal(height: 0))
                    }
                    TextButton(
                        defaultText: String.button.all,
                        textModifier: MediumTextStyle(size: Font.size.thin, color: Color.app.white).textModifier
                    ){_ in
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.cate)
                                .addParam(key: .data, value: data)
                                .addParam(key: .type, value: CateBlock.ListType.video)
                        )
                    }
                }
                .modifier(ContentHorizontalEdges())
            } else{
                ActivityIndicator(isAnimating: .constant(true), style: .medium).padding(.all, Dimen.margin.light)
            }
            
            VideoList(
                viewModel:self.viewModel,
                datas: self.datas,
                useTracking:self.useTracking
                )
                .modifier(MatchHorizontal(height: self.listHeight))
                .onReceive(self.viewModel.$event){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .pullCancel : self.pageDragingModel.updateNestedScroll(evt: .pulled)
                    default : do{}
                    }
                }
                .onReceive(self.viewModel.$pullPosition){ pos in
                    self.pageDragingModel.updateNestedScroll(evt: .pull(pos))
                }
        }
        .onAppear{
            if let datas = data.videos {
                self.datas = datas
                self.updateListSize()
            }
            if let apiQ = self.getRequestApi() {
                dataProvider.requestData(q: apiQ)
            }
        }
        .onReceive(dataProvider.$result) { res in
            if res?.id != data.id { return }
            var allDatas:[VideoData] = []
            switch data.dataType {
            case .cwGrid:
                guard let resData = res?.data as? CWGrid else {return onBlank()}
                guard let grid = resData.grid else {return onBlank()}
                if grid.isEmpty {return onBlank()}
                grid.forEach{ g in
                    if let blocks = g.block {
                        let addDatas = blocks.map{ d in
                            VideoData().setData(data: d, cardType: data.cardType)
                        }
                        allDatas.append(contentsOf: addDatas)
                    }
                }
            case .grid:
                guard let resData = res?.data as? GridEvent else {return onBlank()}
                guard let blocks = resData.contents else {return onBlank()}
                let addDatas = blocks.map{ d in
                    VideoData().setData(data: d, cardType: data.cardType)
                }
                allDatas.append(contentsOf: addDatas)
                
            case .bookMark:
                guard let resData = res?.data as? BookMark else {return onBlank()}
                guard let blocks = resData.bookmarkList else {return onBlank()}
                let addDatas = blocks.map{ d in
                    VideoData().setData(data: d, cardType: data.cardType)
                }
                allDatas.append(contentsOf: addDatas)
                
            case .watched:
                guard let resData = res?.data as? Watch else {return onBlank()}
                guard let blocks = resData.watchList else {return onBlank()}
                let addDatas = blocks.map{ d in
                    VideoData().setData(data: d, cardType: data.cardType)
                }
                allDatas.append(contentsOf: addDatas)
                
            default: do {}
            }
            self.datas = allDatas
            self.updateListSize()
            self.data.videos = allDatas
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
            self.listHeight = ListItem.video.height
            onDataBinding()
        }
        else { onBlank() }
    }
}
