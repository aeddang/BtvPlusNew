//
//  PosterBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI
import Combine


struct PosterBlockKids:PageComponent, BlockProtocol {
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
    @State var datas:[PosterData] = []
    @State var isUiActive:Bool = true
    @State var hasMore:Bool = true
    @State var list: PosterList?
    private func getList() -> some View {
        if let list = self.list { return list }
        let newList = PosterList(
            viewModel:self.viewModel,
            banners: self.data.leadingBanners,
            datas: self.datas,
            useTracking:self.useTracking,
            margin:max(self.sceneObserver.safeAreaStart,self.sceneObserver.safeAreaEnd) + DimenKids.margin.regular
            )
            
        DispatchQueue.main.async {
            self.list = newList
        }
        return newList
    }
    
    var body :some View {
        VStack(alignment: .leading , spacing: DimenKids.margin.thinExtra) {
            if self.isUiActive {
                HStack(alignment: .bottom, spacing:DimenKids.margin.thin){
                    VStack(alignment: .leading , spacing:DimenKids.margin.tiny){
                        Spacer().modifier(MatchHorizontal(height: 0))
                        HStack( spacing:DimenKids.margin.thin){
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
                            self.pagePresenter.openPopup(
                                PageKidsProvider.getPageObject(.kidsCategoryList)
                                    .addParam(key: .data, value: data)
                                    .addParam(key: .type, value: CateBlock.ListType.poster)
                                    .addParam(key: .subType, value:data.cardType)
                            )
                        }
                    }
                }
                .modifier(MatchHorizontal(height: DimenKids.tab.thin))
                .modifier(ContentHorizontalEdgesKids())
                
                if !self.datas.isEmpty {
                    self.getList()
                        
                        
                } else if self.useEmpty {
                    ErrorKidsData( text: self.data.cardType != .watchedVideo
                                ? String.pageText.myWatchedEmpty
                                : String.alert.dataError)
                        .modifier(MatchParent())
                } else {
                    SkeletonBlockKids(
                        len:7,
                        spacing: DimenKids.margin.thinUltra,
                        size:ListItemKids.poster.type01
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
            if let _ = data.posters {
                if data.allPosters?.isEmpty == true {
                    self.hasMore = false
                }
                ComponentLog.d("ExistData " + data.name, tag: "BlockProtocol")
                self.creatDataBinding()
                return
            }
            if let apiQ = self.getRequestApi(pairing:self.pairing.status) {
                ComponentLog.d("RequestData " + data.name, tag: "BlockProtocolA")
                dataProvider.requestData(q: apiQ)
            } else {
                ComponentLog.d("RequestData Fail" + data.name, tag: "BlockProtocolA")
                self.data.setRequestFail()
            }
            
        }
        .onDisappear{
            ComponentLog.d("onDisappear" + data.name, tag: "BlockProtocolA")
            self.clearDataBinding()
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
            case .cwGridKids:
                guard let resData = res?.data as? CWGridKids else {return onBlank()}
                guard let grid = resData.grid else {return onBlank()}
                grid.forEach{ g in
                    if let blocks = g.block {
                        let addDatas = blocks.map{ d in
                            PosterData(pageType: .kids).setData(data: d, cardType: data.cardType)
                        }
                        allDatas.append(contentsOf: addDatas)
                    }
                }
            default: do {}
            }
            
            if allDatas.isEmpty { return onBlank() }
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
            onDataBinding()
        }
        else { onBlank() }
    }
    
    @State var dataBindingSubscription:AnyCancellable?
    func creatDataBinding() {
    
        self.dataBindingSubscription?.cancel()
        self.dataBindingSubscription = Timer.publish(
            every: SkeletonBlockKids.dataBindingDelay , on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.clearDataBinding()
                if let datas = data.posters {
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
