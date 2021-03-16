//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
extension PageHome{
    static fileprivate(set) var finalSelectedMonthlyId:String? = nil
}

struct PageHome: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var viewModel:MultiBlockModel = MultiBlockModel()
    
    @ObservedObject var viewPagerModel:ViewPagerModel = ViewPagerModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var monthlyViewModel: InfinityScrollModel = InfinityScrollModel()
    
   
    @State var useTracking:Bool = false
    @State var headerHeight:CGFloat = 0
    @State var marginHeader:CGFloat = 0
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            MultiBlockBody (
                pageObservable: self.pageObservable,
                viewModel: self.viewModel,
                infinityScrollModel: self.infinityScrollModel,
                viewPagerModel:self.viewPagerModel,
                useBodyTracking:self.useTracking,
                useTracking:false,
                marginHeader : self.marginHeader,
                marginTop:self.headerHeight,
                marginBottom: self.sceneObserver.safeAreaBottom,
                topDatas: self.topDatas,
                monthlyViewModel : self.monthlyViewModel,
                monthlyDatas: self.monthlyDatas,
                monthlyAllData: self.monthlyAllData,
                useFooter: self.useFooter,
                isRecycle:true
                ){ data in
                    self.reload(selectedMonthlyId: data.prdPrcId)
                    
            }
        }
        .padding(.bottom, Dimen.app.bottom )
        .modifier(PageFull())
        
        .onReceive(self.dataProvider.bands.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .updated: self.reload()
            default: do{}
            }
        }
        .onReceive(self.infinityScrollModel.$event){evt in
            guard let evt = evt else {return}
            if self.pagePresenter.currentTopPage?.pageID == .home {
                switch evt {
                case .top : self.pageSceneObserver.useTopFix = true
                case .down : self.pageSceneObserver.useTopFix = false
                default : break
                }
            }
        }
        .onReceive(self.pageSceneObserver.$headerHeight){ hei in
            self.headerHeight = hei
        }
        .onReceive(self.pageSceneObserver.$safeHeaderHeight){ hei in
            withAnimation{
                self.marginHeader = self.topDatas == nil ? 0 : self.pageSceneObserver.safeHeaderHeight
            }
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            self.useTracking = ani
        }
        .onReceive(self.pagePresenter.$currentTopPage){ page in
            self.useTracking = page?.id == self.pageObject?.id
        }
        .onReceive(self.pairing.authority.$purchaseLowLevelTicketList){ list in
            guard let list = list else { return }
            self.updatedMonthly(purchases: list, lowLevelPpm: true)
        }
        .onReceive(self.pairing.authority.$purchaseTicketList){ list in
            guard let list = list else { return }
            self.updatedMonthly(purchases: list, lowLevelPpm: false)
        }
        .onReceive(self.viewModel.$event){evt in
            guard let evt = evt else { return }
            switch evt {
            case .onResult(_, let res, _):
                switch res.type {
                case .getEventBanner :
                    self.respondTopBanner(res: res)
                default: break
                }
               
            default : break
            }
        }
        .onAppear{
            guard let obj = self.pageObject  else { return }
            DispatchQueue.main.async {
                self.menuId = (obj.getParamValue(key: .id) as? String) ?? self.menuId
                self.reload()
            }
        }
        .onDisappear{
            self.pageSceneObserver.useTopFix = nil
        }
        
    }//body
    
    @State var topDatas:Array<BannerData>? = nil
    @State var originMonthlyDatas:[String:MonthlyData]? = nil
    @State var monthlyAllData:BlockItem? = nil
    @State var monthlyDatas:Array<MonthlyData>? = nil
    @State var selectedMonthlyId:String? = Self.finalSelectedMonthlyId
    @State var menuId:String = ""
    @State var useFooter:Bool = false
    
    private func reload(selectedMonthlyId:String? = nil){
       
        self.selectedMonthlyId = selectedMonthlyId ?? self.selectedMonthlyId
        self.monthlyDatas?.forEach{$0.reset()}
        guard let band = self.dataProvider.bands.getData(menuId: self.menuId) else { return }
        switch band.gnbTypCd {
        case EuxpNetwork.GnbTypeCode.GNB_HOME.rawValue :
            self.useFooter = true
            self.setupBlocks()
        case EuxpNetwork.GnbTypeCode.GNB_MONTHLY.rawValue :
            self.setupOriginMonthly()
        default: self.setupBlocks()
        }
        
        
        self.requestTopBanner()
    }
    
    private func requestTopBanner(){
        if self.dataProvider.bands.getData(menuId: self.menuId)?.bnrUse == true && self.topDatas == nil{
            self.viewModel.request = .init(
                id: self.menuId,
                type: .getEventBanner(self.menuId, .page),  isOptional: true)
        } else {
            if self.pagePresenter.currentTopPage?.pageID == PageID.home {
                self.pageSceneObserver.useTopFix = true
            }
        }
    }
    
    private func respondTopBanner(res:ApiResultResponds?){
        guard let resData = res?.data as? EventBanner else {return}
        guard let banners = resData.banners else { return }
        if banners.isEmpty { return }
        self.topDatas = banners.filter{$0.bbnr_exps_mthd_cd == "01"}.map{ d in
            BannerData().setData(data: d, type: .page)
        }
        let floating = banners.filter{$0.bbnr_exps_mthd_cd == "03"}.map{ d in
            BannerData().setData(data: d, type: .page)
        }
        if !floating.isEmpty {
            self.pageSceneObserver.event = .floatingBanner(floating)
        }
        if self.pagePresenter.currentTopPage?.pageID == PageID.home {
            self.pageSceneObserver.useTopFix = true
        }
    }
    
    //Monthly
    private func setupOriginMonthly(){
        
        if self.originMonthlyDatas == nil {
            var originMonthlyDatas = [String:MonthlyData]()
            let maxCount = 8
            var idx = 0
            var monthlyDatas = Array<MonthlyData>()
            guard let blocksData = self.dataProvider.bands.getData(menuId: self.menuId)?.blocks else {return}
            blocksData
            .filter{ block in
                if block.prd_prc_id == nil {
                    self.monthlyAllData = block
                    return false
                }
                guard let blocks = block.blocks else {return false}
                return !blocks.isEmpty
            }
            .forEach{ data in
                let monthly = MonthlyData().setData(data: data, idx: idx)
                if monthly.prdPrcId == self.selectedMonthlyId { monthly.setSelected(true) }
                originMonthlyDatas[monthly.prdPrcId] = monthly
                if monthlyDatas.count < maxCount { monthlyDatas.append(monthly) }
                idx += 1
            }
            self.originMonthlyDatas = originMonthlyDatas
            if !monthlyDatas.isEmpty {
                self.monthlyDatas = monthlyDatas
            }
        }
        self.requestMonthly()
        self.setupMonthly()
    }

    private func requestMonthly(){
        self.originMonthlyDatas?.forEach{$1.resetJoin()}
        self.pairing.authority.requestAuth(.updateTicket)
    }
    
    private func updatedMonthly( purchases:[MonthlyInfoItem], lowLevelPpm:Bool){
        if self.originMonthlyDatas == nil { return }
        purchases.forEach{ purchas in
            guard let id = purchas.prod_id else {return}
            guard let monthlyData = self.originMonthlyDatas?[id] else {return}
            monthlyData.setData(data:purchas, isLow:lowLevelPpm)
        }
    }
    
    private func setupMonthly(){
        guard let monthlyDatas = self.monthlyDatas else { return }
        if monthlyDatas.isEmpty { return }
        if self.selectedMonthlyId == nil { self.selectedMonthlyId = monthlyDatas.first?.prdPrcId }
        if self.originMonthlyDatas?[self.selectedMonthlyId ?? ""] == nil { self.selectedMonthlyId = monthlyDatas.first?.prdPrcId }
        guard let selectData = self.originMonthlyDatas?[self.selectedMonthlyId ?? ""] else { return }
        Self.finalSelectedMonthlyId = self.selectedMonthlyId
        selectData.setSelected(true)
        guard let blocksData = selectData.blocks else {return}
        self.requestBlocks(blocksData: blocksData)
    }
    
    //Block
    private func setupBlocks(){
        guard let blocksData = self.dataProvider.bands.getData(menuId: self.menuId)?.blocks else {return}
        self.requestBlocks(blocksData: blocksData)
    }
    
    private func requestBlocks(blocksData:[BlockItem]){
        self.viewModel.update(datas: blocksData)
    }
    //Block init
    
}


#if DEBUG
struct PageHome_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageHome().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(SceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(PageSceneObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

