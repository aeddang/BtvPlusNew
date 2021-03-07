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
    
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            MultiBlockBody (
                viewModel: self.viewModel,
                infinityScrollModel: self.infinityScrollModel,
                viewPagerModel:self.viewPagerModel,
                pageObservable: self.pageObservable,
                useBodyTracking:self.useTracking,
                useTracking:false,
                marginTop:Dimen.app.top + self.sceneObserver.safeAreaTop,
                marginBottom: Dimen.app.bottom + self.sceneObserver.safeAreaBottom,
                topDatas: self.topDatas,
                monthlyViewModel : self.monthlyViewModel,
                monthlyDatas: self.monthlyDatas,
                isRecycle:true
                ){ data in
                
                self.reload(selectedMonthlyId: data.prdPrcId)
            }
        }
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
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            self.useTracking = ani
        }
        .onReceive(self.pagePresenter.$currentTopPage){ page in
            self.useTracking = page?.id == self.pageObject?.id
        }
        .onReceive(self.viewModel.$event){evt in
            guard let evt = evt else { return }
            switch evt {
            case .onResult(_, let res, _):
                switch res.type {
                case .getEventBanner :
                    self.respondTopBanner(res: res)
                case .getMonthly(let lowLevelPpm, _, _) :
                    self.respondMonthly(res: res, lowLevelPpm: lowLevelPpm)
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
    @State var monthlyDatas:Array<MonthlyData>? = nil
    @State var selectedMonthlyId:String? = Self.finalSelectedMonthlyId
    
    @State var menuId:String = ""
    
    
    private func reload(selectedMonthlyId:String? = nil){
       
        self.selectedMonthlyId = selectedMonthlyId ?? self.selectedMonthlyId
        self.monthlyDatas?.forEach{$0.reset()}
        guard let band = self.dataProvider.bands.getData(menuId: self.menuId) else { return }
        switch band.gnbTypCd {
        case "BP_02" : self.setupOriginMonthly()
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
        self.topDatas = banners.map{ d in
            BannerData().setData(data: d, type: .page)
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
            var monthlyDatas = Array<MonthlyData>()
            guard let blocksData = self.dataProvider.bands.getData(menuId: self.menuId)?.blocks else {return}
            zip( blocksData,0...blocksData.count)
            .filter{ block, _ in
                if block.prd_prc_id == nil {return false}
                guard let blocks = block.blocks else {return false}
                return !blocks.isEmpty
            }
            .forEach{ data, idx in
                let monthly = MonthlyData().setData(data: data, idx: idx)
                if monthly.prdPrcId == self.selectedMonthlyId { monthly.setSelected(true) }
                originMonthlyDatas[monthly.prdPrcId] = monthly
                if monthlyDatas.count < maxCount { monthlyDatas.append(monthly) }
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
        if self.monthlyDatas == nil {return}
        if self.pairing.status == .pairing {
            self.viewModel.request = .init(
                id: self.menuId,
                type: .getMonthly(false),  isOptional: true)
            
            self.viewModel.request = .init(
                id: self.menuId,
                type: .getMonthly(true),  isOptional: true)
        }
    }
    
    
    private func respondMonthly(res:ApiResultResponds?, lowLevelPpm:Bool){
        guard let resData = res?.data as? MonthlyInfo else { return }
        guard let purchases = resData.purchaseList else { return }
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

