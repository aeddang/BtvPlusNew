//
//  VideoBlock.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI
import Combine
extension ThemaBlock{
    static let skeletonNum:Int = SystemEnvironment.isTablet ? 8 : 4
}
struct ThemaBlock:BlockProtocol, PageComponent {
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    var pageObservable:PageObservable
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var data: BlockData
    var useTracking:Bool = false
    @State var datas:[ThemaData] = []
    @State var isUiActive:Bool = true
    @State var skeletonSize:CGSize = CGSize()
    
    @State var list: ThemaList?
    private func getList() -> some View {
        if let list = self.list {return list}
        let newList = ThemaList(
            viewModel:self.viewModel,
            banners: self.data.leadingBanners,
            datas: self.datas,
            useTracking:self.useTracking)
            
        DispatchQueue.main.async {
            self.list = newList
            
        }
        return newList
    }
    
    var body :some View {
        VStack(alignment: .leading , spacing: Dimen.margin.thinExtra) {
            if self.isUiActive {
                Text(data.name).modifier(BlockTitle())
                    .frame(height:Dimen.tab.thin)
                    .modifier(ContentHorizontalEdges())
                if !self.datas.isEmpty {
                    self.getList()
                } else {
                    SkeletonBlock(
                        len:Self.skeletonNum,
                        spacing:Dimen.margin.tiny,
                        size:self.skeletonSize
                    )
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
            if let datas = data.themas {
                if let size = datas.first?.type.size {
                    self.skeletonSize = size
                }
                ComponentLog.d("ExistData " + data.name, tag: "BlockProtocol")
                self.creatDataBinding()
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
        .onDisappear{
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
        if !self.datas.isEmpty {
            onDataBinding()
        }
        else { onBlank() }
    }
    
    @State var dataBindingSubscription:AnyCancellable?
    func creatDataBinding() {
    
        self.dataBindingSubscription?.cancel()
        self.dataBindingSubscription = Timer.publish(
            every: SkeletonBlock.dataBindingDelay, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.clearDataBinding()
                if let datas = data.themas {
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
