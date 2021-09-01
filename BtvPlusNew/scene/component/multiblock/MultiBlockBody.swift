//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine

class MultiBlockModel: PageDataProviderModel {
    private(set) var type:PageType = .btv
    private(set) var datas:[BlockData]? = nil
    private(set) var requestSize:Int = 0
    private(set) var isAdult:Bool = false
    fileprivate(set) var openId:String? = nil
    private(set) var title:String? = nil
    private(set) var selectedTicketId:String? = nil
    private(set) var isFree:Bool = false
    
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }

    init(requestSize:Int? = nil, pageType:PageType = .btv) {
        self.type = pageType
        self.requestSize = requestSize ?? 12
    }
    
    func reload() {
        self.datas?.forEach({$0.reset()})
        self.isUpdate = true
    }
    
    func update(datas:[BlockItem], openId:String?, selectedTicketId:String? = nil,
                themaType:BlockData.ThemaType = .category, isAdult:Bool = false, title:String? = nil, isFree:Bool = false) {
        self.type = .btv
        self.isFree = isFree
        self.datas = datas.map{ block in
            BlockData().setData(block, themaType:themaType)
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
        self.datas = datas.map{ block in
            BlockData(pageType: .kids).setDataKids(block)
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
        self.datas = [ BlockData(pageType: .kids).setDataKids(data: data, isTicket:isTicket) ]
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
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
    var pageObservable:PageObservable
    var viewModel:MultiBlockModel = MultiBlockModel()
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
    var useFooter:Bool = false
     
    var action: ((_ data:MonthlyData) -> Void)? = nil
    
    @State var reloadDegree:Double = 0
    @State var reloadDegreeMax:Double = Double(InfinityScrollModel.PULL_COMPLETED_RANGE)
    @State var headerOffset:CGFloat = 0
    @State var needAdult:Bool = false
    @State var isHorizontal:Bool = false
   
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
                            ratio: 1.0 + (CGFloat(self.reloadDegree/self.reloadDegreeMax)/5)
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
                        useFooter:self.useFooter,
                        isHorizontal: self.isHorizontal,
                        isRecycle:true,
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
            guard let data = self.loadingBlocks.first(where: { $0.id == res?.id}) else {return}
            var leadingBanners:[BannerData]? = nil
            var total:Int? = nil
            let max = Self.maxCellCount
            let useTag:Bool = !self.viewModel.isFree
             
            switch data.dataType {
            case .cwGrid:
                guard let resData = res?.data as? CWGrid else {return data.setBlank()}
                guard let grid = resData.grid else {return data.setBlank()}
                if grid.isEmpty {return data.setBlank()}
                total = resData.total_count
                data.setData(grids: grid)
                
            case .cwGridKids:
                guard let resData = res?.data as? CWGridKids else {return data.setBlank()}
                data.errorMassage = resData.status_reason
                guard let grid = resData.grid else {return data.setBlank()}
                if grid.isEmpty {return data.setBlank()}
                total = resData.total_count
                if grid.count == 1 {
                    grid.forEach{ g in
                        if let blocks = g.block {
                            switch data.uiType {
                            case .poster :
                                data.posters = blocks[0...min(max, blocks.count-1)].map{ d in
                                    PosterData(pageType: self.pageType, useTag:useTag).setData(data: d, cardType: data.cardType)
                                }
                            case .video :
                                data.videos = blocks[0...min(max, blocks.count-1)].map{ d in
                                    VideoData(pageType: self.pageType, useTag:useTag).setData(data: d, cardType: data.cardType)
                                }
                            default: break
                            }
                        }
                    }
                } else {
                    data.setData(grids: grid)
                }
                
            case .grid:
                guard let resData = res?.data as? GridEvent else {return data.setBlank()}
                guard let blocks = resData.contents else {return data.setBlank()}
                if blocks.isEmpty {return data.setBlank()}
                total = resData.total_content_count
                switch data.uiType {
                case .poster :
                    data.posters = blocks[0...min(max, blocks.count-1)].map{ d in
                        PosterData(pageType: self.pageType, useTag:useTag).setData(data: d, cardType: data.cardType)
                    }

                case .video :
                    data.videos = blocks[0...min(max, blocks.count-1)].map{ d in
                        VideoData(pageType: self.pageType, useTag:useTag).setData(data: d, cardType: data.cardType)
                    }
                    
                case .theme :
                    data.themas = blocks[0...min(max, blocks.count-1)].map{ d in
                        ThemaData().setData(data: d, cardType: data.cardType)
                    }
                default: break
                }
                leadingBanners = resData.banners?.map{d in
                    BannerData().setData(data: d, type: .list, cardType: .bigPoster)
                }
                
            case .bookMark:
                guard let resData = res?.data as? BookMark else {return data.setBlank()}
                guard let blocks = resData.bookmarkList else {return data.setBlank()}
                if blocks.isEmpty {return data.setBlank()}
                total = resData.bookmark_tot?.toInt()
                switch data.uiType {
                case .poster :
                    data.posters = blocks[0...min(max, blocks.count-1)].map{ d in
                        PosterData(pageType: self.pageType, useTag:useTag).setData(data: d, cardType: data.cardType)
                    }
                case .video :
                    data.videos = blocks[0...min(max, blocks.count-1)].map{ d in
                        VideoData(pageType: self.pageType, useTag:useTag).setData(data: d, cardType: data.cardType)
                    }
                default: break
                }
               
            case .watched:
                guard let resData = res?.data as? Watch else {return data.setBlank()}
                guard let originWatchBlocks = resData.watchList else {return data.setBlank()}
                var watchBlocks:[WatchItem] = originWatchBlocks
                if let ticketId = self.viewModel.selectedTicketId {
                    watchBlocks = originWatchBlocks.filter{$0.prod_id == ticketId}
                }
                if watchBlocks.count < 1 {return data.setBlank()}
                total = resData.watch_tot?.toInt()
                switch data.uiType {
                case .poster :
                    data.posters = watchBlocks.map{ d in
                        PosterData(pageType: self.pageType, useTag:useTag).setData(data: d, cardType: data.cardType)
                    }
                    .filter{$0.isContinueWatch}
                case .video :
                    data.videos = watchBlocks.map{ d in
                        VideoData(pageType: self.pageType, useTag:useTag).setData(data: d, cardType: data.cardType)
                    }
                    .filter{$0.isContinueWatch}
                default: break
                }
            
            case .banner:
                guard let resData = res?.data as? EventBanner else {return data.setBlank()}
                guard let banners = resData.banners else {return data.setBlank()}
                if banners.isEmpty {return data.setBlank()}
                    data.banners = banners.map{ d in
                        BannerData().setData(data: d, cardType:data.cardType)
                }
            default: break
            }
            
            var listHeight:CGFloat = 0
            var blockHeight:CGFloat = 0
            let tabHeight:CGFloat = self.viewModel.type == .btv ? Self.tabHeight : Self.tabHeightKids
            var padding = self.viewModel.type == .btv ? Dimen.margin.thin : DimenKids.margin.thin
            if let size = data.posters?.first?.type {
                listHeight = size.size.height
                blockHeight = listHeight + tabHeight
            }
            if let size = data.videos?.first{
                listHeight = size.type.size.height + size.bottomHeight
                blockHeight = listHeight + tabHeight
            }
            if let size = data.themas?.first?.type {
                listHeight = size.size.height
                blockHeight = listHeight + tabHeight
                padding = size.spacing
            }
            
            if let size = data.banners?.first?.type {
                listHeight = size.size.height
                blockHeight = listHeight
            }
            if blockHeight != 0 {
                if let banner = leadingBanners {
                    let ratio = ListItem.banner.type03
                    let w = round(listHeight * ratio.width/ratio.height)
                    banner.forEach{ $0.setBannerSize(width: w , height: listHeight, padding: padding) }
                    data.leadingBanners = banner
                }
                data.listHeight = blockHeight
            }
            data.setDatabindingCompleted(total: total, parentTitle: self.viewModel.title)
        }
        .onReceive(dataProvider.$error) { err in
            guard let data = self.loadingBlocks.first(where: { $0.id == err?.id}) else {return}
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
   
    func reload(){
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
        
        self.setupBlocks()
    }

    private func setupBlocks(){
        self.originBlocks.forEach{ block in
            block.$status.sink(receiveValue: { stat in
                self.onBlock(stat:stat, block:block)
            }).store(in: &anyCancellable)
        }
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
                }else if data.dataType == .watched || data.cardType == .watchedVideo {
                    self.errorMsg = String.pageText.myWatchedEmpty
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
                DataLog.d("passive " + block.name, tag: "BlockProtocolB")
            case .active:
                DataLog.d("active " + block.name, tag: "BlockProtocolB")
            default: return
            }
            self.completedNum += 1
            PageLog.d("requestNum " + requestNum.description, tag: "BlockProtocolB")
            PageLog.d("completedNum " + completedNum.description, tag: "BlockProtocolB")
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
            DataLog.d("addLoadedBlocks " + $0.name + " " + $0.status.rawValue, tag: "BlockProtocolB")
            $0.index = idx
            idx += 1
        }
        self.blocks.append(contentsOf: addBlocks)
        self.isLoading = false
        
        if let openId = self.viewModel.openId {
            let findIds = openId.split(separator: "|")
            if let find = addBlocks.first(where:  { block in
                guard let menuId = block.menuId else {return false}
                return findIds.first(where: {$0 == menuId}) != nil
            }) {
                if let listType = find.uiType.listType {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.categoryList)
                            .addParam(key: .data, value: find)
                            .addParam(key: .type, value: listType)
                            .addParam(key: .subType, value:find.cardType)
                    )
                }
                self.viewModel.openId = nil
            } else {
                self.delayAddBlock()
            }
        }
        
    }

    private func addBlock(){
        self.addBlockSubscription?.cancel()
        let max = min(self.viewModel.requestSize, self.originBlocks.count)
        if max == 0 {
            self.requestBlockCompleted()
            return
        }
        let set = self.originBlocks[..<max]
        self.originBlocks.removeSubrange(..<max)
        PageLog.d("addBlockLoad originBlocks " + self.originBlocks.count.description, tag: self.tag)
        PageLog.d("addBlockLoad blocks " + set.count.description, tag: self.tag)
        if set.isEmpty { return }
        self.requestNum = set.count
        self.isLoading = true
        self.loadingBlocks.append(contentsOf: set)
        self.loadingBlocks.forEach{ block in
            if let apiQ = block.getRequestApi(pairing:self.pairing.status, kid:self.pairing.kid) {
                dataProvider.requestData(q: apiQ)
            } else{
                if block.uiType == .kidsHome || block.uiType == .kidsTicket {
                    block.listHeight = Self.kisHomeHeight
                    block.setDatabindingCompleted(parentTitle: self.viewModel.title)
                    
                }else if block.dataType == .theme , let blocks = block.blocks {
                    if block.uiType == .theme {
                        let themas = blocks.map{ data in
                            ThemaData().setData(data: data, cardType: block.cardType)
                        }
                        if let size = themas.first?.type {
                            block.listHeight = size.size.height + Self.tabHeight
                        }
                        block.themas = themas
                        DataLog.d("ThemaData " + block.name, tag: "BlockProtocolA")
                    } else {
                        let tickets = blocks.map{ data in
                            TicketData().setData(data: data, cardType: block.cardType)
                        }
                        if let size = tickets.first?.type {
                            block.listHeight = size.size.height + Self.tabHeight
                        }
                        block.tickets = tickets
                        DataLog.d("TicketData " + block.name, tag: "BlockProtocolA")
                    }
                    block.setDatabindingCompleted(parentTitle: self.viewModel.title)
                    return
                } else{
                    block.setRequestFail()
                }
            }
        }
    }
    
}

