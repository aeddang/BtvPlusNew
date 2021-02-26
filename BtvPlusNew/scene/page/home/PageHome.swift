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
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    
    @State var reloadDegree:Double = 0
    
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            if self.blocks.isEmpty {
                Spacer()
            }else{
                VStack{
                    ReflashSpinner(
                        progress: self.$reloadDegree
                    )
                    .padding(.top, self.topDatas == nil ? Dimen.app.pageTop : (self.sceneObserver.safeAreaTop + Dimen.margin.regular))
                    Spacer()
                }
                MultiBlock(
                    viewModel: self.infinityScrollModel,
                    pageObservable: self.pageObservable,
                    topDatas: self.topDatas,
                    datas: self.blocks,
                    useTracking:self.useTracking,
                    marginVertical: Dimen.app.bottom + self.sceneObserver.safeAreaTop,
                    monthlyDatas: self.monthlyDatas
                    ){ data in
                    self.reload(selectedMonthlyId: data.prdPrcId)
                }
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
                case .pullCancel :
                    if !self.infinityScrollModel.isLoading {
                        if self.reloadDegree >= ReflashSpinner.DEGREE_MAX { self.reload() }
                    }
                    withAnimation{
                        self.reloadDegree = 0
                    }
                default : do{}
                }
            }
        }
        .onReceive(self.infinityScrollModel.$pullPosition){ pos in
            if pos < InfinityScrollModel.PULL_RANGE && pos > InfinityScrollModel.PULL_COMPLETED_RANGE{ return }
            if self.reloadDegree >= ReflashSpinner.DEGREE_MAX
                && Double(pos) < self.reloadDegree
            {
                return
            }
            withAnimation{
                self.reloadDegree = Double(pos)
            }
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            self.useTracking = ani
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
            self.delayRequestSubscription?.cancel()
            self.delayRequestSubscription = nil
            self.anyCancellable.forEach{$0.cancel()}
            self.anyCancellable.removeAll()
            self.pageSceneObserver.useTopFix = nil
        }
        
    }//body
    
    @State var originBlocks:Array<BlockData> = []
    @State var topDatas:Array<BannerData>? = nil
    @State var originMonthlyDatas:[String:MonthlyData]? = nil
    @State var monthlyDatas:Array<MonthlyData>? = nil
    @State var selectedMonthlyId:String? = Self.finalSelectedMonthlyId
    @State var blocks:Array<BlockData> = []
    @State var menuId:String = ""
    @State var anyCancellable = Set<AnyCancellable>()
    @State var useTracking:Bool = false
    
    private func reload(selectedMonthlyId:String? = nil){
        self.delayRequestSubscription?.cancel()
        self.delayRequestSubscription = nil
        self.isDataCompleted = false
        self.useTracking = false
        self.selectedMonthlyId = selectedMonthlyId ?? self.selectedMonthlyId
        self.originBlocks = []
        self.blocks = []
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
        guard let banners = resData.banners else { return self.topDatas = [] }
        if banners.isEmpty { return self.topDatas = [] }
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
            
            self.monthlyDatas = monthlyDatas
        }
        self.requestMonthly()
        self.setupMonthly()
    }

    private func requestMonthly(){
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
       
        let blocks = blocksData.map{ data in
            BlockData().setDate(data)
        }
        .filter{ block in
            switch block.dataType {
            case .cwGrid : return block.menuId != nil && block.cwCallId != nil
            case .grid : return block.menuId != nil
            default : return true
            }
        }
        
        self.originBlocks = blocks
        blocks.forEach{ block in
            block.$status.sink(receiveValue: { stat in
                self.onBlock(stat:stat, block:block)
            }).store(in: &anyCancellable)
        }
        self.addBlock()
    }
   
    
   //Block init
    
    
    private var setNum = 7
    @State var requestNum = 0
    @State var completedNum = 0
    @State var isDataCompleted = false
    
    private func requestBlockCompleted(){
        PageLog.d("addBlock completed", tag: "BlockProtocol")
        self.isDataCompleted = true
    }
    private func onBlock(stat:BlockStatus, block:BlockData){
        self.useTracking = true
        
        switch stat {
        case .passive: self.removeBlock(block)
        case .active: break
        default: return
        }
        self.completedNum += 1
        PageLog.d("completedNum " + completedNum.description, tag: "BlockProtocol")
        if self.completedNum == self.requestNum {
            self.completedNum = 0
            self.delayRequest()
        }
    }
    
    @State var delayRequestSubscription:AnyCancellable?
    func delayRequest(){
        self.delayRequestSubscription?.cancel()
        self.delayRequestSubscription = Timer.publish(
            every: 0.05, on: .current, in: .tracking)
            .autoconnect()
            .sink() {_ in
                self.delayRequestSubscription?.cancel()
                self.delayRequestSubscription = nil
                self.addBlock()
            }
    }
    
   
    
    private func addBlock(){
        let max = min(setNum, self.originBlocks.count)
        if max == 0 {
            self.requestBlockCompleted()
            return
        }
        let set = self.originBlocks[..<max]
        self.originBlocks.removeSubrange(..<max)
        PageLog.d("addBlock" + set.debugDescription, tag: "BlockProtocol")
        if set.isEmpty { return }
        self.requestNum = set.count
        DispatchQueue.main.async {
            withAnimation {
                self.blocks.append(contentsOf: set)
            }
        }
    }
    
    private func removeBlock(_ block:BlockData){
        DispatchQueue.main.async {
            guard let find = self.blocks.firstIndex(of: block) else { return }
            self.blocks.remove(at: find)
        }
    }
    
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

