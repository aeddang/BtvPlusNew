//
//  VideoBlock.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI
import Combine

struct VideoBlockKids:BlockProtocol, PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var naviLogManager:NaviLogManager
    
    var pageObservable:PageObservable
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var data: BlockData
    var useTracking:Bool = false
    var useEmpty:Bool = false
    @State var datas:[VideoData] = []
   
    @State var isUiActive:Bool = true
    @State var hasMore:Bool = true
    
    @State var list: VideoList?
    @State var listId:String = ""
    @State var kidName:String? = nil
    @State var isListUpdated:Bool = true
    @State var skeletonSize:CGSize = CGSize()
    private func getList() -> some View {
        let key = (self.datas.first?.epsdId ?? "") + self.datas.count.description
        if key == self.listId,  let list = self.list {
            //ComponentLog.d("Recycle List " + key , tag: self.tag + "List")
            return list
        }
        ComponentLog.d("New List " + key , tag: self.tag + "List")
    
        let newList = VideoList(
            viewModel:self.viewModel,
            banners: self.data.leadingBanners,
            datas: self.datas,
            margin:max(self.sceneObserver.safeAreaStart,self.sceneObserver.safeAreaEnd) + DimenKids.margin.regular,
            useTracking:self.useTracking
        )
        
        DispatchQueue.main.async {
            self.listId = key
            self.list = newList
            
        }
        return newList
    }
    
    var body :some View {
        VStack(alignment: .leading , spacing: DimenKids.margin.thinExtra) {
            if self.isUiActive {
                HStack(alignment: .center, spacing:DimenKids.margin.thin){
                    VStack(alignment: .leading , spacing:0){
                        Spacer().modifier(MatchHorizontal(height: 0))
                        HStack( spacing:DimenKids.margin.thin){
                            if let kidName = self.kidName {
                                Text(String.app.sir.replace(kidName)).modifier(BlockTitleKids())
                                    .lineLimit(1)
                            }
                            Text(data.name).modifier(BlockTitleKids())
                                .lineLimit(1)
                            Text(data.subName).modifier(BoldTextStyleKids(size: Font.sizeKids.tinyExtra, color:Color.app.brownDeep))
                                .lineLimit(1)
                        }
                    }
                    if self.hasMore {
                        TextButton(
                            defaultText: String.button.all,
                            textModifier: TextModifier (family:Font.familyKids.bold, size: Font.sizeKids.thinExtra, color: Color.app.brownExtra)
                        ){_ in
                            
                            self.sendLog(self.naviLogManager)
                            if data.cardType == .watchedVideo {
                                self.pagePresenter.openPopup(
                                    PageKidsProvider.getPageObject( .kidsMy)
                                        .addParam(key: .subId, value: PageKidsMy.recentlyWatchCode)
                                       
                                )
                            } else {
                                self.pagePresenter.openPopup(
                                    PageKidsProvider.getPageObject( .kidsCategoryList)
                                        .addParam(key: .data, value: data)
                                        .addParam(key: .type, value: CateBlock.ListType.video)
                                        .addParam(key: .subType, value:data.cardType)
                                )
                            }
                        }
                    }
                }
                .modifier(MatchHorizontal(height: DimenKids.tab.thin))
                .modifier(ContentHorizontalEdgesKids())
                
                
                if !self.datas.isEmpty && self.isListUpdated{
                    self.getList()
                       
                } else if self.useEmpty {
                    ErrorKidsData( text: self.data.cardType != .watchedVideo
                                   ? String.kidsText.kidsMyWatchedEmpty
                                   : String.alert.dataError)
                        .modifier(MatchParent())
                   
                }else {
                    SkeletonBlockKids(
                        len:4,
                        spacing: DimenKids.margin.thinUltra,
                        size:self.skeletonSize
                    )
                    .modifier(MatchParent())
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
            if data.cardType == .watchedVideo, let nick = data.kid?.nickName {
                self.kidName = nick
            }
            
            if let _ = self.data.videos {
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
            case .cwGridKids:
                guard let resData = res?.data as? CWGridKids else {return onBlank()}
                guard let grid = resData.grid else {return onBlank()}
                if grid.isEmpty {return onBlank()}
                grid.forEach{ g in
                    if let blocks = g.block {
                        let addDatas = blocks.map{ d in
                            VideoData(pageType: .kids).setData(data: d, cardType: data.cardType)
                        }
                        allDatas.append(contentsOf: addDatas)
                    }
                }
           
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
            every: SkeletonBlockKids.dataBindingDelay, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.clearDataBinding()
                if let datas = data.videos {
                    DispatchQueue.global(qos: .background).async {
                        withAnimation{ self.datas = datas }
                    }
                }
            }
    }
    func clearDataBinding() {
        self.dataBindingSubscription?.cancel()
        self.dataBindingSubscription = nil
       
    }
}
