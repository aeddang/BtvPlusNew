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
                        if self.isUiView && isUiActive, let homeBlockData = self.homeBlockData {
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
                                        KidsCategoryItem(data:cateData)
                                            .padding(.top, DimenKids.margin.medium)
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
            case .bottom : self.isUiActive = false
            case .top, .below : self.isUiActive = true
            }
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
                self.isUiView = true
            } else {
                let homeData = KidsHomeBlockData().setData(data: self.data)
                self.homeBlockData = homeData
                self.data.kidsHomeBlockData = homeData
                withAnimation{
                    self.isUiView = true
                }
            }
            if self.data.uiType == .kidsTicket && self.pairing.status == .pairing {
                if let list = self.pairing.authority.purchaseTicketList {
                    self.updatedMonthly(purchases: list, lowLevelPpm: false)
                }
                if let list = self.pairing.authority.purchaseLowLevelTicketList {
                    self.updatedMonthly(purchases: list, lowLevelPpm: true)
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
   
    
}
