//
//  VideoBlock.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI

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
    @State var listHeight:CGFloat = ListItem.banner.type04.height
    @State var isUiActive:Bool = true
    var body :some View {
        ZStack() {
            if self.isUiActive {
                if !self.datas.isEmpty {
                    BannerList(
                        viewModel:self.viewModel,
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
                
                }
            }
        }
        .frame( height: self.listHeight)
        .onAppear{
            if let datas = data.banners {
                self.datas = datas
                self.updateListSize()
                ComponentLog.d("ExistData " + data.name, tag: "BlockProtocol")
                return
            }
            if let apiQ = self.getRequestApi(pairing:self.pairing.status) {
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
            self.listHeight = self.datas.first!.type.size.height
            onDataBinding()
        }
        else { onBlank() }
    }
    
}
