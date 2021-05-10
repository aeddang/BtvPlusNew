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
    @EnvironmentObject var pairing:Pairing
    var pageObservable:PageObservable
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var data: BlockData
    var margin:CGFloat = Dimen.margin.thin
    var useTracking:Bool = false
    var useEmpty:Bool = false
    @State var datas:[VideoData] = []
    @State var listHeight:CGFloat = ListItem.video.size.height + ListItem.video.type01
    @State var isUiActive:Bool = true
    @State var hasMore:Bool = true
    var body :some View {
        VStack(alignment: .leading , spacing: Dimen.margin.thinExtra) {
            if self.isUiActive {
                if !self.datas.isEmpty || self.useEmpty {
                    HStack(alignment: .bottom, spacing:Dimen.margin.thin){
                        VStack(alignment: .leading, spacing:0){
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
                                    PageProvider.getPageObject(data.dataType == .watched ? .watchedList : .categoryList)
                                        .addParam(key: .data, value: data)
                                        .addParam(key: .type, value: CateBlock.ListType.video)
                                        .addParam(key: .subType, value:data.cardType)
                                )
                            }
                        }
                    }
                    .modifier(MatchHorizontal(height: Dimen.tab.thin))
                    .padding( .horizontal , self.margin)
                }
                if !self.datas.isEmpty {
                    VideoList(
                        viewModel:self.viewModel,
                        banners: self.data.leadingBanners,
                        datas: self.datas,
                        margin:self.margin,
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
                        
                } else if self.useEmpty {
                    EmptyAlert( text: self.data.dataType != .watched
                                ? String.pageText.myWatchedEmpty
                                : String.alert.dataError)
                        .modifier(MatchParent())
                }
            }
        }
        .frame( height:
                    (self.data.listHeight ?? self.listHeight)
                    + Dimen.tab.thin + Dimen.margin.thinExtra)
        .onAppear{
            if let datas = data.videos {
                if data.allVideos?.isEmpty == true {
                    self.hasMore = false
                }
                self.datas = datas
                self.updateListSize()
                ComponentLog.d("ExistData " + data.name, tag: "BlockProtocol")
                return
            }
            if let apiQ = self.getRequestApi(pairing: self.pairing.status) {
                dataProvider.requestData(q: apiQ)
            } else {
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
            self.checkModifyWatchedItem(res)
    
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
            if allDatas.isEmpty { return onBlank() }
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
            self.listHeight = ListItem.video.size.height + self.datas.first!.bottomHeight
            onDataBinding()
        }
        else { onBlank() }
    }
    
    func checkModifyWatchedItem(_ res:ApiResultResponds?) {
        guard let res = res else { return }
        
        switch res.type {
        case .deleteWatch(let list, let isAll):
            if self.data.dataType != .watched {return}
            if isAll {
                self.hasMore = false
                self.datas.removeAll()
                
            } else {
                list?.forEach{ del in
                    if let f = self.datas.firstIndex(where: {$0.srisId == del }) {
                        self.datas.remove(at: f)
                    }
                }
            }
        default: break
        }
        
    }
}
