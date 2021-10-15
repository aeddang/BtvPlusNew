//
//  VideoBlock.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI
import Combine

struct BannerBlock:BlockProtocol, PageComponent {
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var naviLogManager:NaviLogManager
    var pageObservable:PageObservable
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var data: BlockData
    @State var bannerData:BannerData? = nil
    @State var isUiActive:Bool = true
   
    var body :some View {
        ZStack() {
            if self.isUiActive {
                if let banner = self.bannerData {
                    BannerItem(data: banner){
                        var actionBody = MenuNaviActionBodyItem()
                        actionBody.menu_id = banner.menuId
                        actionBody.menu_name = banner.menuNm
                        actionBody.position = banner.logPosition
                        actionBody.config = banner.logConfig
                        self.naviLogManager.actionLog(.clickBannerLineBanner, actionBody: actionBody)
                    }
                    .modifier(MatchParent())
                }
            }
        }
        .padding(.horizontal, Dimen.margin.thin)
        .modifier(MatchParent())
        .onAppear{
            if self.bannerData != nil { return }
            if let datas = data.banners {
                withAnimation{
                    self.bannerData = datas.first
                }
                ComponentLog.d("ExistData " + data.name, tag: "BlockProtocol")
                return
            }
            if let apiQ = self.getRequestApi(pairing:self.pairing.status) {
                ComponentLog.d("RequestData " + data.name, tag: "BlockProtocolA")
                dataProvider.requestData(q: apiQ)
            } else {
                ComponentLog.d("RequestDataFail " + data.name, tag: "BlockProtocolA")
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
            var allDatas:[BannerData] = []
            switch data.dataType {
            case .banner:
                guard let resData = res?.data as? EventBanner else {return onBlank()}
                guard let banners = resData.banners else {return onBlank()}
                if banners.isEmpty {return onBlank()}
                let addDatas = banners.map{ d in
                    BannerData().setData(data: d)
                }
                allDatas.append(contentsOf: addDatas)
            default: do {}
            }
            self.bannerData = allDatas.first
            self.updateListSize()
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
        if self.bannerData != nil {
            onDataBinding()
        }
        else { onBlank() }
    }
    
    
    
}
