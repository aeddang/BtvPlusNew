//
//  VideoBlock.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI
import Combine
extension VideoBlock{
    static let skeletonNum:Int = SystemEnvironment.isTablet ? 6 : 3
}
struct VideoBlock:BlockProtocol, PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var naviLogManager:NaviLogManager
    var pageObservable:PageObservable
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var data: BlockData
    var margin:CGFloat = Dimen.margin.thin
    var useTracking:Bool = false
    var useEmpty:Bool = false
    var isMyWatch:Bool = false
    @State var datas:[VideoData] = []
    @State var isUiActive:Bool = true
    @State var hasMore:Bool = true
    @State var skeletonSize:CGSize = CGSize()
    @State var list: VideoList?
    @State var listId:String = ""
    @State var isListUpdated:Bool = true
    @State var isWatchedBlock:Bool = false
    @State var watchedCount:String? = nil
    private func getList() -> some View {
        let key = (self.datas.first?.epsdId ?? "") + self.datas.count.description
        if key == self.listId,  let list = self.list {
            return list
        }
        let newList = VideoList(
            viewModel:self.viewModel,
            banners: self.data.leadingBanners,
            datas: self.datas,
            parentData: self.data,
            useTracking:self.useTracking)
        DispatchQueue.main.async {
            self.listId = key
            self.list = newList
        }
        return newList
    }
    
    var body :some View {
        VStack(alignment: .leading , spacing: Dimen.margin.thinExtra) {
            if self.isUiActive {
                HStack(alignment: .center, spacing:Dimen.margin.thin){
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
                            self.sendLog(self.naviLogManager)
                            let firstData = data.videos?.first
                            
                            if (data.cardType == .clip || firstData?.isClip == true) && firstData?.isSearch == false {
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.clipPreviewList)
                                        .addParam(key: .data, value: data)
                                )
                            } else {
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(
                                        self.isMyWatch
                                        ? .myWatchedList
                                        : data.dataType == .watched ? .myWatchedList : .categoryList)
                                        .addParam(key: .data, value: data)
                                        .addParam(key: .type, value: CateBlock.ListType.video)
                                        .addParam(key: .subType, value:data.cardType)
                                        .addParam(key: .isFree, value:!data.usePrice)
                                )
                            }
                        }
                    }
                }
                .modifier(MatchHorizontal(height: Dimen.tab.thin))
                .padding( .horizontal , self.margin)
                
                if !self.datas.isEmpty  && self.isListUpdated{
                    self.getList()
                        .fixedSize(horizontal: false, vertical: true)
                       
                } else if self.useEmpty || self.isWatchedBlock{
                    EmptyAlert( text: self.data.dataType == .watched
                                ? String.pageText.myWatchedEmpty
                                : String.alert.dataError)
                        .modifier(MatchParent())
                }else {
                    SkeletonBlock(
                        len:Self.skeletonNum,
                        spacing:Dimen.margin.tiny,
                        size:self.skeletonSize
                    )
                    .modifier(MatchParent())
                    //Spacer()
                }
            }
        }
        .modifier(MatchParent())
        .modifier(
            ContentScrollPull(
                infinityScrollModel: self.viewModel,
                pageDragingModel: self.pageDragingModel)
        )
        .onAppear{
            if !self.datas.isEmpty {
                ComponentLog.d("RecycleData " + data.name, tag: "BlockProtocol")
                return
            }
            if let datas = self.data.videos {
                if data.allVideos?.isEmpty == true {
                    self.hasMore = false
                }
                if let size = datas.first?.type.size {
                    self.skeletonSize = CGSize(width: size.width, height: size.height + ListItem.video.type01)
                }
                ComponentLog.d("ExistData " + data.name, tag: "BlockProtocol")
                self.creatDataBinding()
                return
            }
            if let apiQ = self.getRequestApi(pairing: self.pairing.status) {
                ComponentLog.d("RequestData " + data.name, tag: "BlockProtocolA")
                dataProvider.requestData(q: apiQ)
            } else {
                ComponentLog.d("RequestData Fail " + data.name, tag: "BlockProtocolA")
                self.data.setRequestFail()
            }
        }
        .onDisappear{
            self.clearDataBinding()
        }
        .onReceive(self.pageObservable.$layer ){ layer  in
            switch layer {
            case .bottom : self.isUiActive = false
            case .below : self.isUiActive = true
            case .top : self.isUiActive = true
                if !self.isWatchedBlock {return}
                if self.pairing.status != .pairing {return}
                if let apiQ = self.getRequestApi(pairing: self.pairing.status, isReset: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        self.dataProvider.requestData(q: apiQ)
                    }
                }
            }
        }
        .onReceive(dataProvider.$result) { res in
            //self.checkModifyWatchedItem(res)
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
                }.filter{$0.isContinueWatch}.filter{$0.progress != 1}
                self.watchedCount = addDatas.count.description
                allDatas.append(contentsOf: addDatas)
            default: break
            }
            if allDatas.isEmpty && !self.isWatchedBlock { return onBlank() }
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
            onDataBinding()
        }
        else { onBlank() }
    }
    
    func checkModifyWatchedItem(_ res:ApiResultResponds?) {
        guard let res = res else { return }
        
        switch res.type {
        case .deleteWatch(let list, let isAll):
            if self.data.dataType != .watched {return}
            self.isListUpdated = false
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isListUpdated = true
            }
        default: break
        }
        
    }
    
    @State var dataBindingSubscription:AnyCancellable?
    func creatDataBinding() {
       
        self.dataBindingSubscription?.cancel()
        self.dataBindingSubscription = Timer.publish(
            every: SkeletonBlock.dataBindingDelay, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.clearDataBinding()
                if let datas = data.videos {
                    self.isWatchedBlock = datas.first?.isWatched ?? false
                    withAnimation{ self.datas = datas }
                }
            }
    }
    func clearDataBinding() {
        self.dataBindingSubscription?.cancel()
        self.dataBindingSubscription = nil
       
    }
}
