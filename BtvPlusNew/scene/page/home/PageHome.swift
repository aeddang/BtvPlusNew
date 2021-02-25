//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
struct PageHome: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    
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
                    .padding(.top, self.topData == nil ? Dimen.app.pageTop : self.sceneObserver.safeAreaTop)
                    Spacer()
                }
                MultiBlock(
                    viewModel: self.infinityScrollModel,
                    topDatas: self.topData,
                    datas: self.blocks,
                    useTracking:self.useTracking,
                    marginVertical: Dimen.app.bottom + self.sceneObserver.safeAreaTop
                    )
            }
        }
        .modifier(PageFull())
        .onAppear{
            guard let obj = self.pageObject  else { return }
            DispatchQueue.main.async {
                self.menuId = (obj.getParamValue(key: .id) as? String) ?? self.menuId
                self.setupBlocks()
            }
            
        }
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
            if pos < 30 && pos > 120{ return }
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
                self.setupTopBanner(res: res)
            default : break
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
    @State var topData:Array<BannerData>? = nil
    @State var blocks:Array<BlockData> = []
    @State var menuId:String = ""
    @State var anyCancellable = Set<AnyCancellable>()
    @State var useTracking:Bool = false
    
    private func reload(){
        self.delayRequestSubscription?.cancel()
        self.delayRequestSubscription = nil
        self.isDataCompleted = false
        self.useTracking = false
        self.originBlocks = []
        self.blocks = []
        self.setupBlocks()
        
    }
    
    
    private func setupBlocks(){
        guard let blocksData = self.dataProvider.bands.getData(menuId: self.menuId)?.blocks else {return}
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
        if self.dataProvider.bands.getData(menuId: self.menuId)?.bnrUse == true && self.topData == nil{
            self.viewModel.request = .init(
                id: self.menuId,
                type: .getEventBanner(self.menuId, .page),  isOptional: true)
        }
    }
    
    private func setupTopBanner(res:ApiResultResponds?){
        guard let resData = res?.data as? EventBanner else {return}
        guard let banners = resData.banners else { return self.topData = [] }
        if banners.isEmpty { return self.topData = [] }
        self.topData = banners.map{ d in
            BannerData().setData(data: d, type: .page)
        }
        self.pageSceneObserver.useTopFix = true
    }
    
    private var setNum = 5
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

