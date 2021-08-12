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
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var viewModel:MultiBlockModel = MultiBlockModel()
    @ObservedObject var viewPagerModel:ViewPagerModel = ViewPagerModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var monthlyViewModel: MonthlyBlockModel = MonthlyBlockModel()

    @State var useTracking:Bool = false
    @State var headerHeight:CGFloat = 0
    @State var marginHeader:CGFloat = 0
    @State var marginBottom:CGFloat = 0
    var body: some View {
        GeometryReader { geometry in
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
                    marginBottom: self.marginBottom,
                    topDatas: self.topDatas,
                    monthlyViewModel : self.monthlyViewModel,
                    monthlyDatas: self.sortedMonthlyDatas ,
                    monthlyAllData: self.monthlyAllData,
                    tipBlock: self.tipBlockData,
                    useFooter: self.useFooter
                    ){ data in
                        self.reload(selectedMonthlyId: data.prdPrcId)
                        
                }
                
            }
            //.padding(.bottom, self.sceneObserver.safeAreaBottom )
            .modifier(PageFull())
            
            .onReceive(self.dataProvider.bands.$event){ evt in
                guard let evt = evt else { return }
                switch evt {
                case .updated: self.reset()
                default: break
                }
            }
            .onReceive(self.infinityScrollModel.$event){evt in
                guard let evt = evt else {return}
                if self.pagePresenter.currentTopPage?.pageID == .home {
                    switch evt {
                    case .top : self.appSceneObserver.useTopFix = true
                        if self.useTracking {
                            self.appSceneObserver.event = .pairingHitch(isOn: true)
                        }
                    case .down :
                        self.appSceneObserver.useTopFix = false
                        self.appSceneObserver.event = .pairingHitch(isOn: false)
                        
                    case .up :
                        self.appSceneObserver.event = .pairingHitch(isOn: false)
                    default : break
                    }
                }
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                if page?.id == self.pageObject?.id {
                    if self.useTracking {return}
                    self.useTracking = true
                } else {
                    if !self.useTracking {return}
                    self.useTracking = false
                   
                }
            }
            .onReceive(self.pairing.authority.$purchaseLowLevelTicketList){ list in
                guard let list = list else { return }
                self.updatedMonthly(purchases: list, lowLevelPpm: true)
            }
            .onReceive(self.pairing.authority.$purchaseTicketList){ list in
                guard let list = list else { return }
                self.updatedMonthly(purchases: list, lowLevelPpm: false)
            }
            .onReceive(self.pairing.authority.$monthlyPurchaseInfo){ info in
                guard let info = info else { return }
                self.updatedMonthlyPurchaseInfo(info)
            }
            .onReceive(self.pairing.authority.$periodMonthlyPurchaseInfo){ info in
                guard let info = info else { return }
                self.updatedPeriodMonthlyPurchaseInfo(info)
            }
            .onReceive(self.pairing.authority.$event){ evt in
                guard let evt = evt else { return }
                switch evt {
                case .updateMyinfoError :
                    self.syncronizeMonthly()
                default : break
                }
            }
            .onReceive(self.viewModel.$event){evt in
                guard let evt = evt else { return }
                switch evt {
                case .onResult(_, let res, _):
                    switch res.type {
                    case .getEventBanner(_, let type) :
                        if self.topDatas != nil {return}
                        if res.id == self.menuId && type == .page {
                            self.respondTopBanner(res: res)
                            self.requestBand()
                        }
                    case .getMonthlyData(let prcPrdid, _ ) :
                        if self.selectedMonthlyId != prcPrdid {return}
                        guard let data = res.data as? MonthlyInfoData else { return }
                        self.updatedMonthlyInfoData(data)
                    
                    default: break
                    }
                case .onError(_, let res, _) :
                    switch res.type {
                    case .getEventBanner(_, let type) :
                        if self.topDatas != nil {return}
                        if res.id == self.menuId && type == .page {
                            self.requestBand()
                        }
                    case .getMonthlyData(let prcPrdid, _ ) :
                        if self.selectedMonthlyId != prcPrdid {return}
                        self.setupPurchaseTip()
                    default: break
                    }
                   
                default : break
                }
            }
            .onReceive(self.appSceneObserver.$headerHeight){ hei in
                self.headerHeight = hei
            }
            .onReceive(self.appSceneObserver.$safeHeaderHeight){ hei in
                withAnimation{
                    self.marginHeader = self.topDatas == nil ? 0 : hei
                }
            }
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                withAnimation{ self.marginBottom = bottom }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
                if ani {
                    self.reload()
                    if self.pairing.status != .pairing {
                        self.appSceneObserver.event = .pairingHitch(isOn: true)
                    }
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.menuId = (obj.getParamValue(key: .id) as? String) ?? self.menuId
                self.openId = obj.getParamValue(key: .subId) as? String
                
            }
            .onDisappear{
                self.appSceneObserver.useTopFix = nil
                
            }
        }//geo
    }//body
    
    @State var currentBand:Band? = nil
    @State var topDatas:Array<BannerData>? = nil
    @State var originMonthlyDatas:[String:MonthlyData]? = nil
    @State var monthlyAllData:BlockItem? = nil
    @State var monthlyDatas:Array<MonthlyData>? = nil
    @State var sortedMonthlyDatas:Array<MonthlyData>? = nil
    @State var tipBlockData:TipBlockData? = nil
    @State var selectedMonthlyId:String? = nil
    @State var menuId:String = ""
    @State var openId:String? = nil
    @State var prcPrdId:String? = nil
    @State var useFooter:Bool = false
    
    private func reset(){
        guard let obj = self.pageObject  else { return }
        DataLog.d("UPDATEED GNBDATA reset home", tag:self.tag)
        self.pagePresenter.changePage(
            PageProvider.getPageObject(.home)
                .addParam(key: .id, value: obj.getParamValue(key:.id))
                .addParam(key: UUID().uuidString , value: "")
        )
    }
    
    private func reload(selectedMonthlyId:String? = nil){
       
        self.selectedMonthlyId = selectedMonthlyId ?? self.selectedMonthlyId
        self.sortedMonthlyDatas?.forEach{$0.reset()}
        self.requestTopBanner()
    }
    
    private func requestTopBanner(){
        if self.dataProvider.bands.getData(menuId: self.menuId)?.bnrUse == true && self.topDatas == nil{
            self.viewModel.request = .init(
                id: self.menuId ,
                type: .getEventBanner(self.menuId, .page),  isOptional: true)
        } else {
            if self.pagePresenter.currentTopPage?.pageID == PageID.home {
                self.appSceneObserver.useTopFix = true
            }
            self.requestBand()
        }
    }
    
    private func respondTopBanner(res:ApiResultResponds?){
        guard let resData = res?.data as? EventBanner else {return}
        guard let banners = resData.banners else { return }
        if banners.isEmpty { return }
        let topDatas = banners.filter{$0.bbnr_exps_mthd_cd == "01"}.map{ d in
            BannerData().setData(data: d, type: .page, isFloat: false)
        }
        let floating = banners.filter{$0.bbnr_exps_mthd_cd == "03"}.map{ d in
            BannerData().setData(data: d, type: .page, isFloat: true)
        }
        if !floating.isEmpty {
            self.appSceneObserver.event = .floatingBanner(floating)
        }
        if self.pagePresenter.currentTopPage?.pageID == PageID.home {
            self.appSceneObserver.useTopFix = true
        }
        if topDatas.isEmpty == false {
            self.topDatas = topDatas
            withAnimation{
                self.marginHeader = self.topDatas == nil ? 0 : self.appSceneObserver.safeHeaderHeight
            }
        }
    }
    
    private func requestBand(){
        guard let band = self.dataProvider.bands.getData(menuId: self.menuId) else { return }
        self.currentBand = band
        switch band.gnbTypCd {
        case EuxpNetwork.GnbTypeCode.GNB_HOME.rawValue :
            self.useFooter = true
            self.setupBlocks()
        case EuxpNetwork.GnbTypeCode.GNB_OCEAN.rawValue:
            self.setupOcean()
            self.setupBlocks()
        case EuxpNetwork.GnbTypeCode.GNB_MONTHLY.rawValue :
            self.setupOriginMonthly()
        default: self.setupBlocks()
        }
    }
    
    //Ocean
    private func setupOcean(){
        guard let oceanBlock = self.dataProvider.bands.getMonthlyBlockData(name: self.currentBand?.name) else { return }
        self.selectedMonthlyId = oceanBlock.prd_prc_id
        if self.pairing.status == .pairing {
            self.pairing.authority.requestAuth(.updateMonthlyPurchase(isPeriod: false))
        } else {
            self.setupPurchaseTip()
        }
    }
    
    private func updatedMonthlyPurchaseInfo( _ info:MonthlyPurchaseInfo){
        guard let band = self.currentBand  else { return }
        if band.gnbTypCd != EuxpNetwork.GnbTypeCode.GNB_OCEAN.rawValue {return}
        if info.purchaseList?.first(where: {$0.prod_id == self.selectedMonthlyId}) != nil {
            self.tipBlockData = TipBlockData()
                .setupTip(
                    icon: Asset.icon.logoOcean,
                    trailing: String.monthly.oceanAuth)
            
        } else {
            if self.pageObservable.layer == .top {
                self.pairing.authority.requestAuth(.updateMonthlyPurchase(isPeriod: true))
            }
        }
    }
    
    private func updatedPeriodMonthlyPurchaseInfo( _ info:PeriodMonthlyPurchaseInfo){
        guard let band = self.currentBand  else { return }
        if band.gnbTypCd != EuxpNetwork.GnbTypeCode.GNB_OCEAN.rawValue {return}
        if info.purchaseList?.first(where: {$0.prod_id == self.selectedMonthlyId}) != nil {
            self.tipBlockData = TipBlockData()
                .setupTip(leading: String.monthly.oceanPeriodAuth)
            
        } else {
            self.viewModel.request = .init(type: .getMonthlyData(self.selectedMonthlyId, isDetail: false), isOptional:true)
            
        }
    }
    private func updatedMonthlyInfoData( _ data:MonthlyInfoData){
        self.setupPurchaseTip (isFirstFree: data.purchaseList?.first?.free_ppm_use_yn?.toBool() ?? false)
    }
    
    private func setupPurchaseTip (isFirstFree:Bool = false){
        guard let band = self.currentBand  else { return }
        guard let oceanBlock = self.dataProvider.bands.getMonthlyBlockData(name: band.name) else { return }
        let phaseData = MonthlyData().setData(data: oceanBlock)
        if isFirstFree {
            self.tipBlockData = TipBlockData()
                .setupPurchase(
                    leadingIcon: Asset.icon.oceanFree,
                    leading: String.monthly.oceanFirstFreeLeading,
                    icon: Asset.icon.logoOcean,
                    trailing: String.monthly.oceanFirstFreeTrailing,
                    data: phaseData)
        } else {
            self.tipBlockData = TipBlockData()
                .setupPurchase(
                    leading: String.monthly.oceanPhaseLeading,
                    icon: Asset.icon.logoOcean,
                    trailing: String.monthly.oceanPhaseTrailing,
                    data: phaseData)
        }
        
    }
    
    
    //Monthly
    private func setupOriginMonthly(){
        if self.originMonthlyDatas == nil {
            self.selectedMonthlyId = Self.finalSelectedMonthlyId
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
                monthly.posIdx = idx
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
    }

    private func requestMonthly(){
        self.originMonthlyDatas?.forEach{$1.resetJoin()}
        if self.pairing.status == .pairing {
            self.pairing.authority.requestAuth(.updateTicket)
        } else {
            self.syncronizeMonthly()
        }
    }
    
    private func updatedMonthly( purchases:[MonthlyInfoItem], lowLevelPpm:Bool){
        if self.originMonthlyDatas == nil { return }
        purchases.forEach{ purchas in
            guard let id = purchas.prod_id else {return}
            guard let monthlyData = self.originMonthlyDatas?[id] else {return}
            monthlyData.setData(data:purchas, isLow:lowLevelPpm)
            if !lowLevelPpm {
                if self.monthlyDatas?.firstIndex(of: monthlyData) == nil {
                    self.monthlyDatas?.append(monthlyData)
                }
            }
        }
        self.monthlyDatas?.sort(by: {$0.sortIdx > $1.sortIdx})
        var idx = 0
        self.monthlyDatas?.forEach{
            $0.posIdx = idx
            idx += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
            self.syncronizeMonthly()
        }
    }

    private func syncronizeMonthly(){
        self.sortedMonthlyDatas = self.monthlyDatas
        self.setupMonthly()
        self.monthlyViewModel.isUpdate = true
    }
    
    private func setupMonthly(){
        guard let monthlyDatas = self.sortedMonthlyDatas else { return }
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
        self.viewModel.update(datas: blocksData , openId: self.openId, selectedTicketId:self.selectedMonthlyId)
        self.openId = nil
       
    }
    //Block init
    
}


#if DEBUG
struct PageHome_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageHome().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

