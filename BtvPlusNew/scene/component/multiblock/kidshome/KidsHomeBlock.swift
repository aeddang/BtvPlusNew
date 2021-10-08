//
//  PosterBox.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//
import Foundation
import SwiftUI
import Combine

struct KidsHomeBlock:PageComponent, BlockProtocol {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    var pageObservable:PageObservable
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var pageDragingModel:PageDragingModel
    var data: BlockData
    var useTracking:Bool = false
   
    @State var homeBlockData:KidsHomeBlockData? = nil
    @State var isUiView:Bool = false
    @State var isUiActive:Bool = true
    @State var kid:Kid? = nil
    @State var useCreateHeader:Bool = true
    var body :some View {
        VStack(alignment: .leading , spacing: DimenKids.margin.thinExtra) {
            InfinityScrollView(
                viewModel: self.viewModel,
                axes: .horizontal,
                marginVertical: 0,
                marginHorizontal: max(self.sceneObserver.safeAreaStart,self.sceneObserver.safeAreaEnd) + DimenKids.margin.regular ,
                spacing: 0,
                isRecycle: true,
                useTracking: self.useTracking
                ){
                    HStack(alignment: .top, spacing:Dimen.margin.regular){
                        if self.isUiView, let homeBlockData = self.homeBlockData {
                            ForEach(homeBlockData.datas) { data in
                                switch data.type {
                                case .myHeader :
                                    if let myData = data as? KidsMyItemData {
                                        KidsMyItem(data:myData)
                                    }
                                case .playList:
                                    if let playData = data as? KidsPlayListData {
                                        KidsPlayList(data:playData)
                                    }
                                case .cateHeader:
                                    if let cateData = data as? KidsCategoryItemData {
                                        if !(cateData.playType == .create && !self.useCreateHeader){
                                            KidsCategoryItem(data:cateData)
                                                .padding(.top, DimenKids.margin.medium)
                                        }
                                    }
                                case .cateList:
                                    if let listData = data as? KidsCategoryListData {
                                        KidsCategoryList(data: listData)
                                    }
                                case .banner:
                                    if let bannerData = data as? KidsBannerData {
                                        KidsBanner(data: bannerData)
                                            .padding(.top, DimenKids.margin.medium)
                                    }
                                case .none: Spacer()
                                }
                            }
                        } else {
                            Spacer()
                        }
                    }
                }
        }
        .modifier(MatchParent())
        .modifier(
            ContentScrollPull(
                infinityScrollModel: self.viewModel,
                pageDragingModel: self.pageDragingModel)
        )
        .onReceive(self.pageObservable.$layer ){ layer  in
            switch layer {
            case .bottom :
                self.isUiActive = false
            case .top, .below :
                self.isUiActive = true
                
            }
        }
        .onReceive(self.pairing.$kid){ kid in
            self.kid = kid
            self.useCreateHeader = (kid?.ageMonth ?? 0) <= KidsPlayType.limitedLv2
        }
        .onReceive(self.pairing.authority.$purchaseLowLevelTicketList){ list in
            if let list = list {
                self.updatedMonthly(purchases: list, lowLevelPpm: true)
            }
            
        }
        .onReceive(self.pairing.authority.$purchaseTicketList){ list in
            if let list = list {
                self.updatedMonthly(purchases: list, lowLevelPpm: false)
            } else if self.pairing.status == .pairing {
                self.pairing.authority.requestAuth(.updateTicket)
            }
        }
        .onAppear{
            if let prevData =  self.data.kidsHomeBlockData {
                self.homeBlockData = prevData
                withAnimation{
                    self.isUiView = true
                }
                
                
            } else {
                let homeData = KidsHomeBlockData().setData(data: self.data)
                self.homeBlockData = homeData
                self.data.kidsHomeBlockData = homeData
                withAnimation{
                    self.isUiView = true
                }
                DispatchQueue.main.async{
                    if self.data.uiType == .kidsTicket && self.pairing.status == .pairing {
                        if let list = self.pairing.authority.purchaseTicketList {
                            self.updatedMonthly(purchases: list, lowLevelPpm: false)
                        }
                        if let list = self.pairing.authority.purchaseLowLevelTicketList {
                            self.updatedMonthly(purchases: list, lowLevelPpm: true)
                        }
                    }
                    self.openPage()
                }
            }
            
        }
        .onDisappear{}
    }
    
    private func updatedMonthly( purchases:[MonthlyInfoItem], lowLevelPpm:Bool){
        guard let homeBlockData = self.homeBlockData   else { return }
        let finds = homeBlockData.datas.filter{$0.type == .cateList}
        purchases.forEach{ purchase in
            
            finds.forEach{ find in
                if let find = find as? KidsCategoryListData {
                    if let item = find.datas.first(where: {$0.prdPrcId == purchase.prod_id}){
                        item.setData(data: purchase, lowLevelPpm: lowLevelPpm)
                    }
                }
            }
        }
    }
    private func openPage(){
        guard let homeBlockData = self.homeBlockData else { return }
        guard let openId = self.data.openId else { return }
        var find:BlockItem? = nil
        let _ = homeBlockData.blocks?.first(where: { data in
            if let blocks = data.blocks {
                return blocks
                    .filter({$0.menu_id != nil})
                    .first(where: { depth1 in
                        DataLog.d(( depth1.menu_nm ?? "") + " - " + depth1.menu_id!, tag:"openPageID")
                        var search = openId.contains( depth1.menu_id!)
                        if search { find =  depth1 }
                        else {
                            search = depth1.blocks?.filter({$0.menu_id != nil})
                                .first(where: { depth2 in
                                    DataLog.d(( depth2.menu_nm ?? "") + " - " + depth2.menu_id!, tag:"openPageID")
                                    let search2 = openId.contains( depth2.menu_id!)
                                    if search2 { find = depth1}
                                    return search2
                                }) != nil
                        }
                        return search
                }) != nil
            } else {
                let search = openId.contains(data.menu_id ?? "")
                DataLog.d("search menu_id " + (data.menu_id ?? ""), tag:"openPageID")
                if search { find = data }
                return search
            }
        })
        
        guard let data = find else { return }
        
        self.pagePresenter.openPopup(
            PageKidsProvider.getPageObject(.kidsMultiBlock)
                .addParam(key: .datas, value: data.blocks)
                .addParam(key: .title, value: data.menu_nm)
                .addParam(key: .subId, value: openId)
        )
    }
    
}
