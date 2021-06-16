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
    var pageObservable:PageObservable
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var data: BlockData
    var margin:CGFloat = Dimen.margin.thin
    var useTracking:Bool = false
    var useEmpty:Bool = false
    @State var datas:[VideoData] = []
   
    @State var isUiActive:Bool = true
    @State var hasMore:Bool = true
    @State var skeletonSize:CGSize = CGSize()

    @State var list: VideoList?
    @State var listId:String = ""
    @State var isListUpdated:Bool = true
    private func getList() -> some View {
        let key = (self.datas.first?.epsdId ?? "") + self.datas.count.description
        let type = self.datas.first?.type
        if key == self.listId,  let list = self.list {
            switch type {
            case .watching: ComponentLog.d("Recycle List " + key , tag: self.tag + "List")
            default : break
            }
            return list
        }
        switch type {
        case .watching:  ComponentLog.d("New List " + key , tag: self.tag + "List")
        default : break
        }
        
        let newList = VideoList(
            viewModel:self.viewModel,
            banners: self.data.leadingBanners,
            datas: self.datas,
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
                
                if !self.datas.isEmpty  && self.isListUpdated{
                    self.getList()
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
                }else {
                    SkeletonBlock(
                        len:Self.skeletonNum,
                        spacing:VideoList.spacing,
                        size:self.skeletonSize
                    )
                    Spacer()
                    
                }
            }
        }
        .modifier(MatchParent())
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
                    self.skeletonSize = size
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
            //self.datas.removeAll()
            self.clearDataBinding()
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
                    withAnimation{ self.datas = datas }
                }
            }
    }
    func clearDataBinding() {
        self.dataBindingSubscription?.cancel()
        self.dataBindingSubscription = nil
       
    }
}
