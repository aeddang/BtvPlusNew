//
//  PosterBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI

struct PosterBlock:PageComponent, BlockProtocol {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    var pageObservable:PageObservable
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var data: BlockData
    var useTracking:Bool = false
    @State var datas:[PosterData] = []
    @State var listHeight:CGFloat = ListItem.poster.type01.height
    @State var isUiActive:Bool = true
    @State var hasMore:Bool = true
    var body :some View {
        VStack(alignment: .leading , spacing: Dimen.margin.thinExtra) {
            if self.isUiActive {
                HStack(alignment: .bottom, spacing:Dimen.margin.thin){
                    VStack(alignment: .leading , spacing:Dimen.margin.tiny){
                        Spacer().modifier(MatchHorizontal(height: 0))
                        HStack( spacing:Dimen.margin.thin){
                            Text(data.name).modifier(BlockTitle())
                                .lineLimit(1)
                            Text(data.subName).modifier(BlockTitle(color:Color.app.grey))
                                .lineLimit(1)
                        }
                    }
                    if self.hasMore {
                        TextButton(
                            defaultText: String.button.all,
                            textModifier: MediumTextStyle(size: Font.size.thin, color: Color.app.white).textModifier
                        ){_ in
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.categoryList)
                                    .addParam(key: .data, value: data)
                                    .addParam(key: .type, value: CateBlock.ListType.poster)
                                    .addParam(key: .subType, value:data.cardType)
                            )
                        }
                    }
                }
                .modifier(MatchHorizontal(height: Dimen.tab.thin))
                .modifier(ContentHorizontalEdges())
                if !self.datas.isEmpty {
                    PosterList(
                        viewModel:self.viewModel,
                        banners: self.data.leadingBanners,
                        datas: self.datas,
                        useTracking:self.useTracking
                        )
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
                    
                } else if self.hasMore {
                    PosterList(
                        viewModel:self.viewModel,
                        datas: [PosterData(),PosterData(),PosterData(),PosterData(),PosterData()]
                        )
                        .modifier(MatchHorizontal(height: self.listHeight))
                    .opacity(0.5)
                } else {
                    EmptyAlert()
                }
            }
        }
        .frame( height:
                    (self.data.listHeight ?? self.listHeight)
                    + Dimen.tab.thin + Dimen.margin.thinExtra)
        .onAppear{
            
            if let datas = data.posters {
                if data.allPosters?.isEmpty == true {
                    self.hasMore = false
                }
                self.datas = datas
                self.updateListSize()
                ComponentLog.d("ExistData " + data.name, tag: "BlockProtocol")
                
            }
            if let apiQ = self.getRequestApi(pairing:self.pairing.status) {
                dataProvider.requestData(q: apiQ)
            } else {
                self.data.setRequestFail()
            }
        }
        .onDisappear{
            
        }
        .onReceive(self.pageObservable.$layer ){ layer  in
            switch layer {
            case .bottom : self.isUiActive = false
            case .top, .below : self.isUiActive = true
            }
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
            onDataBinding()
        }
        else { onBlank() }
    }
    
    
}
