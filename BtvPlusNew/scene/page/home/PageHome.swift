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
    static fileprivate(set) var finalSelectedMonthlyId:String? = nil //현제 기획요청으로 사용안함
    static let maxMonthlyCount = 8
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

    @State var headerHeight:CGFloat = 0
    @State var marginHeader:CGFloat = 0
    @State var marginBottom:CGFloat = 0
    @State var isTop:Bool = true
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
                    useBodyTracking:true,
                    useTracking:false,
                    marginHeader : self.marginHeader,
                    marginTop:self.headerHeight,
                    marginBottom: self.marginBottom,
                    topDatas: self.topDatas,
                    /*
                    monthlyViewModel : self.monthlyViewModel,
                    monthlyDatas: self.sortedMonthlyDatas ,
                    monthlyAllData: self.monthlyAllData,
                    */
                    tipBlock: self.tipBlockData,
                    header: self.monthlyheader,
                    headerSize: MonthlyBlock.height + MultiBlock.spacing,
                    useQuickMenu: self.useQuickMenu,
                    useFooter: self.useFooter)
            }
            .modifier(PageFull())
            
            .onReceive(self.dataProvider.bands.$event){ evt in
                guard let evt = evt else { return }
                switch evt {
                case .updated: self.reset()
                default: break
                }
            }
            .onReceive(self.appSceneObserver.$event){ evt in
                guard let evt = evt else { return }
                switch evt {
                case .update(let type):
                    switch type {
                    case .purchase(_, _, _) :
                        self.reset()
                    default : break
                    }
                default : break
                }
            }
            .onReceive(self.infinityScrollModel.$event){evt in
                guard let evt = evt else {return}
                if self.pagePresenter.currentTopPage?.pageID != .home { return }
                switch evt {
                case .top :
                    withAnimation { self.isTop = true }
                    self.appSceneObserver.useTopFix = true
                    self.appSceneObserver.event = .pairingHitch(isOn: true)
                    
                case .down :
                    withAnimation{ self.isTop = false }
                    self.appSceneObserver.useTopFix = false
                    self.appSceneObserver.event = .pairingHitch(isOn: false)
                    
                case .up :
                    self.appSceneObserver.useTopFix = true
                    self.appSceneObserver.event = .pairingHitch(isOn: false)
                default : break
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
                var margin:CGFloat = self.topDatas == nil ? 0 : hei
                if self.monthlyDatas != nil {
                    margin += (MonthlyBlock.height + Dimen.margin.thin)
                }
                withAnimation{
                    self.marginHeader = margin
                }
            }
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                withAnimation{ self.marginBottom = bottom }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    if self.isInit {return}
                    DispatchQueue.main.async {
                        self.isInit = true
                        self.reload(selectedMonthlyId: self.selectedMonthlyId)
                        if self.pairing.status != .pairing {
                            self.appSceneObserver.event = .pairingHitch(isOn: true)
                        }
                    }
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                self.menuId = (obj.getParamValue(key: .id) as? String) ?? self.menuId
                self.openId = obj.getParamValue(key: .subId) as? String
                self.selectedMonthlyId = obj.getParamValue(key: .type) as? String
                
                self.appSceneObserver.gnbMenuId = self.menuId
            }
            .onDisappear{
                self.appSceneObserver.useTopFix = nil
                
            }
        }//geo
    }//body
    @State var isInit:Bool = false
    @State var currentBand:Band? = nil
    @State var topDatas:[BannerData]? = nil
    @State var originMonthlyDatas:[String:MonthlyData]? = nil
    @State var monthlyAllData:BlockItem? = nil
    @State var monthlyDatas:[MonthlyData]? = nil
    @State var sortedMonthlyDatas:[MonthlyData]? = nil
    @State var tipBlockData:TipBlockData? = nil
    @State var selectedMonthlyId:String? = nil
    @State var menuId:String = ""

    @State var openId:String? = nil
    @State var prcPrdId:String? = nil
    @State var useFooter:Bool = false
    @State var useQuickMenu:Bool = false
    @State var isFree:Bool = false
    @State var monthlyheader:MonthlyBlock? = nil
  
    private func reset(){
        /*
        self.currentBand  = nil
        self.topDatas = nil
        self.originMonthlyDatas = nil
        self.monthlyheader = nil
        self.monthlyAllData = nil
        self.monthlyDatas = nil
        self.sortedMonthlyDatas = nil
        self.tipBlockData = nil
        self.monthlyViewModel.isUpdate = true
        if self.pairing.status != .pairing {
            self.selectedMonthlyId = nil
        }
        self.reload()
        */
        if self.pairing.status != .pairing {
            Self.finalSelectedMonthlyId = nil
        }
        guard let obj = self.pageObject  else { return }
        DataLog.d("UPDATEED GNBDATA reset home", tag:self.tag)
        //DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.pagePresenter.changePage(
                PageProvider.getPageObject(.home)
                    .addParam(key: .id, value: obj.getParamValue(key:.id)).addParam(key: UUID().uuidString , value: ""),
                isCloseAllPopup: false
            )
        //}
    }
    
    private func reload(selectedMonthlyId:String? = nil){
        self.selectedMonthlyId = selectedMonthlyId ?? self.selectedMonthlyId
        self.monthlyDatas?.forEach{ data in
            data.reset()
        }
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
            self.isFree = false
            self.useFooter = true
            self.useQuickMenu = true
            self.setupBlocks()
        case EuxpNetwork.GnbTypeCode.GNB_OCEAN.rawValue:
            self.isFree = true
            self.setupOcean()
            self.setupBlocks()
        case EuxpNetwork.GnbTypeCode.GNB_MONTHLY.rawValue :
            self.isFree = true
            self.setupOriginMonthly()
        case EuxpNetwork.GnbTypeCode.GNB_FREE.rawValue :
            self.isFree = true
            self.setupBlocks()
        default: self.setupBlocks()
        }
    }
    //Ocean
    private func setupOcean(){
        if let oceanBlock = self.dataProvider.bands.getMonthlyBlockData(name: self.currentBand?.name) {
            self.selectedMonthlyId = oceanBlock.prd_prc_id
        } else {
            self.selectedMonthlyId = EuxpNetwork.PrdPrcIdCode.OCEAN.rawValue
        }
        if self.pairing.status == .pairing {
            self.pairing.authority.requestAuth(.updateMonthlyPurchase(isPeriod: false))
        } else {
            self.setupPurchaseTip()
        }
    }
    
    private func updatedMonthlyPurchaseInfo( _ info:MonthlyPurchaseInfo){
        guard let band = self.currentBand  else { return }
        if band.gnbTypCd != EuxpNetwork.GnbTypeCode.GNB_OCEAN.rawValue {return}
        if self.pairing.authority.monthlyPurchaseList?.first(where: {$0.prod_id == self.selectedMonthlyId}) != nil {
            self.tipBlockData = TipBlockData()
                .setupTip(
                    icon: Asset.icon.logoOcean,
                    strongTrailing: String.monthly.oceanAuthLeading,
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
        if self.pairing.authority.periodMonthlyPurchaseList?.first(where: {$0.prod_id == self.selectedMonthlyId}) != nil {
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
        guard let blocksData = self.dataProvider.bands.getData(menuId: self.menuId)?.blocks else {
            self.tipBlockData = TipBlockData()
                .setupTip(
                    leading: String.monthly.oceanPurchaseLeading,
                    icon: Asset.icon.logoOcean,
                    trailing: String.monthly.oceanPurchaseTrailing)
            return
            
        }
        
        let phaseData = MonthlyData().setData(band: band, prdPrcId: self.selectedMonthlyId, blocks: blocksData)
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
                    leading: String.monthly.oceanPurchaseLeading,
                    icon: Asset.icon.logoOcean,
                    trailing: String.monthly.oceanPurchaseTrailing,
                    data: phaseData)
        }
    }
    
    
    
    
    //Monthly
    private func setupOriginMonthly(){
        if self.originMonthlyDatas == nil {
            //if self.selectedMonthlyId == nil { self.selectedMonthlyId = Self.finalSelectedMonthlyId }
            var originMonthlyDatas = [String:MonthlyData]()
            let maxCount = Self.maxMonthlyCount
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
                if self.selectedMonthlyId == nil, let openId = self.openId {
                    let find = data.blocks?.filter({$0.menu_id != nil}).first(where: {openId.contains( $0.menu_id! )})
                    if find != nil {
                        self.selectedMonthlyId = data.prd_prc_id
                    }
                }
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
        if self.monthlyheader == nil {
            if self.pairing.status == .pairing {
                self.pairing.authority.requestAuth(.updateTicket)
            } else {
                self.syncronizeMonthly()
            }
        } else {
            self.setupMonthly()
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
        
        self.syncronizeMonthly()
    }

    private func syncronizeMonthly(){
        guard let monthlyDatas = self.monthlyDatas else {return}
        let joins = monthlyDatas.filter{$0.isJoin}
        let subJoins = monthlyDatas.filter{$0.isSubJoin}
        //let dupleJoins:[MonthlyData] = []
        
        let dupleJoins = subJoins.filter{ sub in
            joins.first(where: {sub.subJoinId == $0.subJoinId}) != nil
        }
        dupleJoins.forEach{
            $0.resetJoin()
        }
         
        self.monthlyDatas?.sort(by: {$0.sortIdx > $1.sortIdx})
        var idx = 0
        self.monthlyDatas?.forEach{
            $0.posIdx = idx
            idx += 1
        }
        let maxCount =  max(Self.maxMonthlyCount, joins.count + subJoins.count - dupleJoins.count)
        
        if (self.monthlyDatas?.count ?? 0) > maxCount, let monthlyDatas = self.monthlyDatas {
            self.sortedMonthlyDatas = monthlyDatas[0..<maxCount].map{$0}
        } else {
            self.sortedMonthlyDatas = self.monthlyDatas
        }
        
        if self.sortedMonthlyDatas?.isEmpty == false, let datas = self.sortedMonthlyDatas {
           self.monthlyheader =  MonthlyBlock(
                viewModel:self.monthlyViewModel ,
                monthlyDatas:datas,
                allData: self.monthlyAllData,
                useTracking:false
           ){ data in
               self.reload(selectedMonthlyId: data.prdPrcId)
           }
           self.setupMonthly()
          // self.monthlyViewModel.isUpdate = true
        }
    }
    
    private func setupMonthly(){
        guard let monthlyDatas = self.sortedMonthlyDatas else { return }
        if monthlyDatas.isEmpty { return }
        if self.selectedMonthlyId == nil { self.selectedMonthlyId = monthlyDatas.first?.prdPrcId }
        if self.originMonthlyDatas?[self.selectedMonthlyId ?? ""] == nil { self.selectedMonthlyId = monthlyDatas.first?.prdPrcId }
        guard let selectData = self.originMonthlyDatas?[self.selectedMonthlyId ?? ""] else { return }
        //Self.finalSelectedMonthlyId = self.selectedMonthlyId
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
        self.viewModel.update(datas: blocksData ,
                              openId: self.openId,
                              selectedTicketId:self.selectedMonthlyId,
                              isFree: self.isFree)
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

