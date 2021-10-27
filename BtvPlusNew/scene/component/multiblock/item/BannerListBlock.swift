//
//  VideoBlock.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI
import Combine
extension BannerListBlock{
    static let skeletonNum:Int = SystemEnvironment.isTablet ? 6 : 3
}
struct BannerListBlock:BlockProtocol, PageComponent {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    
    var pageObservable:PageObservable
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var data: BlockData
    var useTracking:Bool = false
    
    @State var datas:[BannerData] = []
    @State var isUiActive:Bool = true
    @State var skeletonSize:CGSize = CGSize()
    
    @State var list: BannerList?
    private func getList() -> some View {
        if let list = self.list {return list}
        let newList = BannerList(
            viewModel:self.viewModel,
            blockData:self.data,
            datas: self.datas,
            useTracking:true)
            
        DispatchQueue.main.async {
            self.list = newList
            
        }
        return newList
    }
    var body :some View {
        ZStack() {
            //if self.isUiActive {
                if !self.datas.isEmpty {
                    self.getList()

                
                } else {
                    SkeletonBlock(
                        len:Self.skeletonNum,
                        spacing:Dimen.margin.tiny,
                        size:self.skeletonSize
                    )
                    .modifier(MatchParent())
                }
            //}
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
            if let datas = data.banners {
                ComponentLog.d("ExistData " + data.name, tag: "BlockProtocol")
                if let size = datas.first?.type.size {
                    self.skeletonSize = size
                }
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
            var allDatas:[BannerData] = []
            switch data.dataType {
            case .banner:
                guard let resData = res?.data as? EventBanner else {return onBlank()}
                guard let banners = resData.banners else {return onBlank()}
                if banners.isEmpty {return onBlank()}
                let addDatas = banners.map{ d in
                    BannerData().setData(data: d, cardType: data.cardType)
                }
                allDatas.append(contentsOf: addDatas)
            default: break
            }
            if allDatas.isEmpty { return onBlank() }
            self.datas = allDatas
            self.data.banners = allDatas
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
                if let datas = data.banners {
                    withAnimation{ self.datas = datas }
                }
            }
    }
    func clearDataBinding() {
        self.dataBindingSubscription?.cancel()
        self.dataBindingSubscription = nil
       
    }
    
}
