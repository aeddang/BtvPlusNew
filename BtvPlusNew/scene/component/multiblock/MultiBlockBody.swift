//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
enum MultiBlockLogType{
    case home, list
}

class MultiBlockModel: PageDataProviderModel {
    private(set) var type:PageType = .btv
    private(set) var datas:[BlockData]? = nil
    private(set) var requestSize:Int = 0
    private(set) var isAdult:Bool = false
    fileprivate(set) var openId:String? = nil
    private(set) var title:String? = nil
    private(set) var selectedTicketId:String? = nil
    private(set) var isFree:Bool = false
    private(set) var logType:MultiBlockLogType = .list
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }

    init(requestSize:Int? = nil, pageType:PageType = .btv, logType:MultiBlockLogType) {
        self.type = pageType
        self.logType = logType
        self.requestSize = requestSize ?? 12
    }
    
    private(set) var pageTitle:String? = nil
    private(set) var tabTitle:String? = nil
    func setupActionLog(pageTitle:String?, tabTitle:String?) {
        self.pageTitle = pageTitle
        self.tabTitle = tabTitle
    }
    
    func reload() {
        self.datas?.forEach({$0.reset()})
        self.isUpdate = true
    }
    
    func update(datas:[BlockItem], openId:String?, selectedTicketId:String? = nil,
                themaType:BlockData.ThemaType = .category, isAdult:Bool = false, title:String? = nil, isFree:Bool = false) {
        self.type = .btv
        self.isFree = isFree
        let total = datas.count
        self.datas = zip(0...total, datas).map{idx,  block in
            BlockData(logType: self.logType, idx: idx, totalBlockNum: total)
                .setData(block, themaType:themaType)
                .setupActionLog(pageTitle: self.pageTitle, tabTitle: self.tabTitle)
        }
        .filter{ block in
            switch block.dataType {
            case .cwGrid : return block.menuId != nil && block.cwCallId != nil
            case .grid : return block.menuId != nil
            default : return true
            }
        }
        self.title = title
        self.selectedTicketId = selectedTicketId
        self.openId = openId
        self.isAdult = isAdult
        self.isUpdate = true
    }
    
    func updateKids(datas:[BlockItem], openId:String? = nil, title:String? = nil) {
        self.type = .kids
        self.title = title
        let total = datas.count
        self.datas = zip(0...total,datas).map{idx, block in
            BlockData(pageType: .kids, logType: self.logType, idx: idx, totalBlockNum: total)
                .setDataKids(block)
                .setupActionLog(pageTitle: self.pageTitle, tabTitle: self.tabTitle)
        }
        .filter{ block in
            switch block.dataType {
            case .cwGridKids : return block.cwCallId != nil
            case .cwGrid : return block.menuId != nil && block.cwCallId != nil
            case .grid : return block.menuId != nil
            default : return true
            }
        }
        self.openId = openId
        self.isUpdate = true
    }
    
    func updateKids(data:KidsGnbItemData, openId:String? = nil, isTicket:Bool = false) {
        self.type = .kids
        self.datas = [ BlockData(pageType: .kids, logType: self.logType).setDataKids(data: data, isTicket:isTicket) ]
        self.openId = openId
        self.isUpdate = true
    }
}

extension MultiBlockBody {
    static let maxCellCount:Int = 100
    static let tabHeight:CGFloat = Dimen.tab.thin + Dimen.margin.thinExtra
    static let tabHeightKids:CGFloat = DimenKids.tab.thin + DimenKids.margin.thinExtra
    static let kisHomeHeight:CGFloat = SystemEnvironment.isTablet ? 410 : 215
   
}

struct MultiBlockBody: PageComponent {
   
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    var pageObservable:PageObservable
    var viewModel:MultiBlockModel = MultiBlockModel(logType: .list)
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var viewPagerModel:ViewPagerModel = ViewPagerModel()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var useBodyTracking:Bool = false
    var useTracking:Bool = false
    var marginHeader : CGFloat = 0
    var marginTop : CGFloat = 0
    var marginBottom : CGFloat = 0
    var marginHorizontal : CGFloat = 0
    var topDatas:[BannerData]? = nil
    var monthlyViewModel: MonthlyBlockModel = MonthlyBlockModel()
    var monthlyDatas:[MonthlyData]? = nil
    var monthlyAllData:BlockItem? = nil
    var tipBlock:TipBlockData? = nil
    var header:PageViewProtocol? = nil
    var headerSize:CGFloat = 0
    var useQuickMenu:Bool = false
    var useFooter:Bool = false
    var isRecycle = true
    var action: ((_ data:MonthlyData) -> Void)? = nil
    
    @State var reloadDegree:Double = 0
    @State var reloadDegreeMax:Double = Double(InfinityScrollModel.PULL_COMPLETED_RANGE)
    @State var headerOffset:CGFloat = 0
    @State var needAdult:Bool = false
    @State var isHorizontal:Bool = false
   
    let checkID = UUID().uuidString
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            if self.needAdult{
                AdultAlert()
                    .modifier(MatchParent())
            } else {
                ZStack(alignment: .topLeading){
                    
                    if self.topDatas != nil && self.topDatas?.isEmpty == false {
                        
                        TopBannerBg(
                            pageObservable : self.pageObservable,
                            viewModel:self.viewPagerModel,
                            datas: self.topDatas!,
                            ratio: 1.0 + (CGFloat(self.reloadDegree/self.reloadDegreeMax)/5),
                            useQuickMenu: self.useQuickMenu
                        )
                        .padding(.top, isHorizontal
                                    ? max(self.headerOffset, -TopBanner.imageHeightHorizontal)
                                    : max(self.headerOffset, -TopBanner.imageHeight)
                        )
                        .offset(y: self.marginHeader )
                            
                    }
                    ReflashSpinner(
                        progress: self.$reloadDegree,
                        progressMax: self.reloadDegreeMax
                    )
                    .padding(.top, self.topDatas != nil
                                ? isHorizontal
                                    ? (TopBanner.heightHorizontal + self.marginHeader)
                                    : (TopBanner.height + self.marginHeader)
                                : self.marginTop)
                    
                    MultiBlock(
                        viewModel: self.viewModel,
                        infinityScrollModel: self.infinityScrollModel,
                        viewPagerModel:self.viewPagerModel,
                        pageObservable: self.pageObservable,
                        pageDragingModel: self.pageDragingModel,
                        topDatas: self.topDatas,
                        datas: self.blocks,
                        useBodyTracking:self.useBodyTracking,
                        useTracking:self.useTracking,
                        marginHeader:self.marginHeader,
                        marginTop:self.marginTop,
                        marginBottom: self.marginBottom,
                        marginHorizontal: self.marginHorizontal,
                        monthlyViewModel : self.monthlyViewModel,
                        monthlyDatas: self.monthlyDatas,
                        monthlyAllData: self.monthlyAllData,
                        tipBlock:self.tipBlock,
                        header:self.header,
                        headerSize:self.headerSize,
                        useQuickMenu:self.useQuickMenu,
                        useFooter:self.useFooter,
                        isHorizontal: self.isHorizontal,
                        isRecycle:self.isRecycle,
                        action:self.action)
                    
                    if self.isError {
                        if self.viewModel.type == .btv {
                            EmptyAlert()
                                .modifier(MatchParent())
                        } else {
                            ErrorKidsData(
                                icon: self.errorMsg == nil ?  Asset.icon.alert : nil,
                                text:self.errorMsg ?? String.alert.dataError) 
                                .modifier(MatchParent())
                        }
                    }
                }
            }
             
        }
        .modifier(MatchParent())
        
        .onReceive(self.infinityScrollModel.$event){evt in
            guard let evt = evt else {return}
            switch evt {
            case .bottom :
                self.addBlock()
                
            case .pullCompleted :
                PageLog.d("reload pullCompleted " + self.infinityScrollModel.isLoading.description, tag: self.tag)
                if !self.isLoading { self.viewModel.reload() }
                withAnimation{ self.reloadDegree = 0}
            case .pullCancel :
                withAnimation{ self.reloadDegree = 0}
            default : break
            }
            
        }
        .onReceive(self.infinityScrollModel.$scrollPosition){pos in
            let willOffset = min(ceil(pos),0)
            if  willOffset != self.headerOffset {
                self.headerOffset = willOffset
            }
        }
        .onReceive(self.infinityScrollModel.$pullPosition){ pos in
            if pos < InfinityScrollModel.PULL_RANGE { return }
            self.reloadDegree = Double(pos - InfinityScrollModel.PULL_RANGE)
        }
        .onReceive(self.viewModel.$isUpdate){ update in
            if update {
                if !self.isLoading { self.reload() }
            }
        }
        .onReceive(self.repository.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .updatedWatchLv, .updatedAdultAuth :self.reload()
            default: break
            }
        }
        .onReceive(dataProvider.$result) { res in
            self.onDataBinding(res: res)
        }
        .onReceive(dataProvider.$error) { err in
            guard let data = self.loadingBlocks.first(where: { $0.id == err?.id}) else {return}
            PageLog.d("request onDataBinding error", tag: self.tag)
            data.setError(err)
        }
        .onReceive(self.sceneObserver.$isUpdated){update in
            if update {
                if !SystemEnvironment.isTablet {return}
                self.isHorizontal = self.sceneObserver.sceneOrientation == .landscape
            }
        }
        .onAppear(){
            if SystemEnvironment.isTablet {
                self.isHorizontal = self.sceneObserver.sceneOrientation == .landscape
            }
        }
        .onDisappear{
            self.addBlockSubscription?.cancel()
            self.addBlockSubscription = nil
            self.anyCancellable.forEach{$0.cancel()}
            self.anyCancellable.removeAll()
        }
    }//body

    @State var pageType:PageType = .btv
    @State var firstBlock:BlockData? = nil
    @State var originBlocks:[BlockData] = []
    @State var loadingBlocks:[BlockData] = []
    @State var blocks:[BlockData] = []
    @State var blockSets:[BlockDataSet] = []
    @State var anyCancellable = Set<AnyCancellable>()
    @State var isError:Bool = false
    @State var isLoading:Bool = false
    @State var errorMsg:String? = nil
    @State var currentOpenId:String? = nil
    
    func reload(){
        PageLog.d("reload", tag: self.tag)
        if self.viewModel.isAdult && !SystemEnvironment.isAdultAuth {
            withAnimation {self.needAdult = true}
            return
        }
        if needAdult {
            withAnimation {self.needAdult = false}
        }
        self.pageType = self.viewModel.type
        self.isError = false
        self.errorMsg = nil
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
        self.blocks = []
        self.firstBlock = nil
        
        self.infinityScrollModel.reload()
        self.originBlocks = viewModel.datas ?? []
        if self.originBlocks.count == 1, let data = self.originBlocks.first {
            self.firstBlock = data
        }
       
        if SystemEnvironment.isEvaluation {
            self.originBlocks = self.originBlocks.filter{!$0.isAdult}
        }
        self.currentOpenId = self.viewModel.openId
        self.viewModel.openId = nil
        PageLog.d("reload init", tag: self.tag)
        self.setupBlocks()
    }

    private func setupBlocks(){
        self.originBlocks.forEach{ block in
            block.$status.sink(receiveValue: { stat in
                
                self.onBlock(stat:stat, block:block)
            }).store(in: &anyCancellable)
        }
        PageLog.d("setupBlocks ", tag: self.tag)
        self.addBlock()
    
    }
    
    @State var requestNum = 0
    @State var completedNum = 0
    private func requestBlockCompleted(){
        PageLog.d("addBlock completed", tag: self.tag)
        if !self.loadingBlocks.isEmpty {
            self.addLoadedBlocks(self.loadingBlocks)
            PageLog.d("self.blocks " + self.blocks.count.description, tag: self.tag)
            self.loadingBlocks = []
        }
       
        if self.blocks.isEmpty {
            if let data = self.firstBlock {
                if let msg = data.errorMassage {
                    if !msg.isEmpty {
                        self.errorMsg = msg
                    }
                } else if data.dataType == .watched || data.cardType == .watchedVideo {
                    self.errorMsg = self.pageType == .btv
                        ? String.pageText.myWatchedEmpty
                        : String.kidsText.kidsMyPlayWatchedEmpty
                    
                } else {
                    self.errorMsg = self.pageType == .btv
                        ? nil
                        : String.kidsText.kidsMyPlayFavoriteEmpty
                }
            }
            withAnimation {
                self.isError = true
            }
        }
    }
    
    private func onBlock(stat:BlockStatus, block:BlockData){
        DispatchQueue.main.async {
            switch stat {
            case .passive:
                DataLog.d("passive " + block.name, tag: self.tag)
            case .active:
                DataLog.d("active " + block.name, tag: self.tag)
            default: return
            }
            self.completedNum += 1
            PageLog.d("requestNum " + requestNum.description, tag: self.tag)
            PageLog.d("completedNum " + completedNum.description, tag: self.tag)
            if self.completedNum == self.requestNum {
                self.completedNum = 0
                self.addLoadedBlocks(self.loadingBlocks)
                PageLog.d("self.blocks " + self.blocks.count.description, tag: self.tag)
                self.loadingBlocks = []
                if self.blocks.isEmpty {
                    self.addBlock()
                }
            }
        }
    }
    
    @State var addBlockSubscription:AnyCancellable?
    func delayAddBlock(){
        self.addBlockSubscription = Timer.publish(
            every: 0.05, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                
                self.addBlock()
            }
    }
    
    private func addLoadedBlocks (_ loadedBlocks:[BlockData]){
        var idx = self.blocks.count
        var addBlocks:[BlockData] = []
       
        loadedBlocks.filter{$0.status == .active}.forEach{
            if $0.childrenBlock.isEmpty {
                addBlocks.append($0)
            } else {
                addBlocks.append(contentsOf:$0.childrenBlock)
            }
            DataLog.d("addLoadedBlocks " + $0.name + " " + $0.status.rawValue, tag: self.tag + self.checkID)
            $0.index = idx
            idx += 1
        }
        self.blocks.append(contentsOf: addBlocks)
        self.isLoading = false
        self.appSceneObserver.isApiLoading = false
        
        if self.pageObservable.layer != .top {return}
        if let openId = self.currentOpenId {
            let findIds = openId.contains("/") == true ? openId.split(separator: "/") :  openId.split(separator: "|")
            if let find = addBlocks.first(where:  { block in
                PageLog.d("addLoadedBlocks find block" + block.name, tag: self.tag + self.checkID)
                guard let menuId = block.menuId else {return false}
                return findIds.first(where: {$0 == menuId}) != nil
            }) {
                PageLog.d("addLoadedBlocks open " + find.name, tag: self.tag + self.checkID)
                PageLog.d("addLoadedBlocks open " + find.menuId!, tag: self.tag + self.checkID)
                DispatchQueue.main.async {
                    if self.openPage(opneBlock: find, openId: openId) {
                        self.currentOpenId = nil
                    }
                }
            } else {
                self.delayAddBlock()
            }
        }
        
    }

    private func addBlock(){
        self.addBlockSubscription?.cancel()
        PageLog.d("addBlockLoad prev originBlocks " + self.originBlocks.count.description, tag: self.tag)
        let max = min(self.viewModel.requestSize, self.originBlocks.count)
        if max == 0 {
            self.requestBlockCompleted()
            return
        }
        let set = self.originBlocks[..<max]
        self.originBlocks.removeSubrange(..<max)
        PageLog.d("addBlockLoad next originBlocks " + self.originBlocks.count.description, tag: self.tag)
        PageLog.d("addBlockLoad blocks " + set.count.description, tag: self.tag)
        if set.isEmpty { return }
        self.requestNum = set.count
        self.isLoading = true
        self.appSceneObserver.isApiLoading = true
        self.loadingBlocks.append(contentsOf: set)
        
        let usePrice:Bool = !self.viewModel.isFree
        self.loadingBlocks.forEach{ block in
            if let apiQ = block.getRequestApi(pairing:self.pairing.status, kid:self.pairing.kid) {
                DataLog.d("request api " + block.name, tag: self.tag)
                dataProvider.requestData(q: apiQ)
            } else{
                if block.uiType == .kidsHome || block.uiType == .kidsTicket {
                    block.listHeight = Self.kisHomeHeight
                    block.setDatabindingCompleted(parentTitle: self.viewModel.title, openId: self.currentOpenId)
                    
                }else if block.dataType == .theme , let blocks = block.blocks {
                    if block.uiType == .theme {
                        let themas = blocks.map{ data in
                            ThemaData(usePrice:usePrice).setData(data: data, cardType: block.cardType)
                        }
                        if let size = themas.first?.type {
                            block.listHeight = size.size.height + Self.tabHeight
                        }
                        block.themas = themas
                        DataLog.d("ThemaData " + block.name, tag: self.tag)
                    } else {
                        let tickets = blocks.map{ data in
                            TicketData().setData(data: data, cardType: block.cardType)
                        }
                        if let size = tickets.first?.type {
                            block.listHeight = size.size.height + Self.tabHeight
                        }
                        block.tickets = tickets
                        DataLog.d("TicketData " + block.name, tag: self.tag)
                    }
                    block.setDatabindingCompleted(parentTitle: self.viewModel.title)
                    return
                } else{
                    block.setRequestFail()
                }
            }
        }
    }
    
    
    private func openPage(opneBlock:BlockData, openId:String) -> Bool{
        switch opneBlock.uiType {
        case .banner :
            BannerData.move(pagePresenter: self.pagePresenter, dataProvider: self.dataProvider, data:opneBlock.banners?.first)
            
        case .bannerList:
            let data = opneBlock.banners?.filter{$0.menuId != nil}.first(where: { openId.contains($0.menuId!) })
            BannerData.move(pagePresenter: self.pagePresenter, dataProvider: self.dataProvider, data:data)
           
        case .poster, .video:
            if self.pageType == .btv {
               self.pagePresenter.openPopup(
                   PageProvider.getPageObject(.categoryList)
                       .addParam(key: .data, value: opneBlock)
                       .addParam(key: .type, value: opneBlock.uiType.listType ?? CateBlock.ListType.poster)
                       .addParam(key: .subType, value:opneBlock.cardType)
                       .addParam(key: .isFree, value:self.viewModel.isFree)
               )
           } else {
               self.pagePresenter.openPopup(
                   PageKidsProvider.getPageObject(.kidsCategoryList)
                       .addParam(key: .data, value: opneBlock)
                       .addParam(key: .type, value: opneBlock.uiType.listType ?? CateBlock.ListType.poster)
                       .addParam(key: .subType, value:opneBlock.cardType)
                       .addParam(key: .isFree, value:self.viewModel.isFree)
               )
           }
           
            
        case .theme:
            guard let data = opneBlock.themas?.filter({$0.menuId != nil}).first(where: { openId.contains($0.menuId!) }) else {
                ComponentLog.e("not found data", tag: self.tag)
                return true
            }
            if data.blocks != nil && data.blocks?.isEmpty == false {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.multiBlock)
                        .addParam(key: .id, value: data.menuId)
                        .addParam(key: .title, value: data.title)
                        .addParam(key: .data, value: data.blocks)
                        .addParam(key: .subId, value: openId)
                        .addParam(key: .isFree, value:self.viewModel.isFree)
                )
            }else{
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.categoryList)
                        .addParam(key: .title, value: data.title)
                        .addParam(key: .id, value: data.menuId)
                        .addParam(key: .type, value: data.cateType)
                        .addParam(key: .isFree, value:self.viewModel.isFree)
                )
            }
            
        case .ticket, .kidsTicket:
            //티캣 구매 이동없음
            break
        case .tv:
            //검색 결과 이동없음
            break
        case .kidsHome:
            return false // 키즈 홈블럭에서 처리
        }
        return true
    }
}

