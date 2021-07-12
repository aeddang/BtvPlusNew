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
    private(set) var openId:String? = nil
    private(set) var selectedTicketId:String? = nil
    
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }

    init(requestSize:Int? = nil) {
        if #available(iOS 14.0, *)  {
            self.requestSize = requestSize ?? 12
        } else {
            self.requestSize = requestSize ?? 12
        }
    }
    
    func reload() {
        self.datas?.forEach({$0.reset()})
        self.isUpdate = true
    }
    
    func update(datas:[BlockItem], openId:String?, selectedTicketId:String? = nil, themaType:BlockData.ThemaType = .category, isAdult:Bool = false) {
        self.type = .btv
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
        self.selectedTicketId = selectedTicketId
        self.openId = openId
        self.isAdult = isAdult
        self.isUpdate = true
    }
    
    func updateKids(datas:[BlockItem], openId:String?) {
        self.type = .kids
        self.datas = datas.map{ block in
            BlockData().setDataKids(block)
        }
        .filter{ block in
            switch block.dataType {
            case .cwGrid : return block.menuId != nil && block.cwCallId != nil
            case .grid : return block.menuId != nil
            default : return true
            }
        }
        self.openId = openId
        self.isUpdate = true
    }
    
    func updateKids(data:KidsGnbItemData, openId:String?) {
        self.type = .kids
        self.datas = [ BlockData().setDataKids(data: data) ]
        self.openId = openId
        self.isUpdate = true
    }
}

extension MultiBlockBody {
    private static var isLegacy:Bool {
        get{
            if #available(iOS 14.0, *) { return false }
            else { return false }
        }
    }
    private static var isRecycle:Bool {
        get{
            if #available(iOS 14.0, *) { return true }
            else { return false }
        }
    }
    private static var isPreLoad:Bool {
        get{
            if #available(iOS 14.0, *) { return true }
            else { return true }
        }
    }
    
    static let tabHeight:CGFloat = Dimen.tab.thin + Dimen.margin.thinExtra
    static let tabHeightKids:CGFloat = DimenKids.tab.thin + DimenKids.margin.thinExtra
    static let kisHomeHeight:CGFloat = SystemEnvironment.isTablet ? 410 : 205
    
}


struct MultiBlockBody: PageComponent {
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var sceneObserver:PageSceneObserver
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
    var useFooter:Bool = false
    var isRecycle = Self.isRecycle
    
    var action: ((_ data:MonthlyData) -> Void)? = nil
    
    @State var reloadDegree:Double = 0
    @State var reloadDegreeMax:Double = Double(InfinityScrollModel.PULL_COMPLETED_RANGE)
    @State var headerOffset:CGFloat = 0
    @State var needAdult:Bool = false
    
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            if self.needAdult{
                AdultAlert()
                    .modifier(MatchParent())
            } else if !self.isError {
                ZStack(alignment: .topLeading){
                    if !Self.isLegacy  {
                        if self.topDatas != nil && self.topDatas?.isEmpty == false {
                            TopBannerBg(
                                pageObservable : self.pageObservable,
                                viewModel:self.viewPagerModel,
                                datas: self.topDatas! )
        
                                .padding(.top, max(self.headerOffset, -TopBanner.imageHeight))
                                .offset(y: self.marginHeader )
                                
                        }
                        ReflashSpinner(
                            progress: self.$reloadDegree,
                            progressMax: self.reloadDegreeMax
                        )
                        .padding(.top, self.topDatas != nil ? (TopBanner.height + self.marginHeader)  : self.marginTop)
                                 
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
                            useFooter:self.useFooter,
                            isRecycle:self.isRecycle,
                            isLegacy:Self.isLegacy,
                            action:self.action)
                    } else {
                        ReflashSpinner(
                            progress: self.$reloadDegree,
                            progressMax: self.reloadDegreeMax
                        )
                        .padding(.top, self.topDatas != nil ? (TopBanner.height + self.marginHeader)  : self.marginTop)
                        
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
                            marginTop: self.topDatas == nil ? self.marginTop : self.marginHeader,
                            marginBottom: self.marginBottom,
                            marginHorizontal: self.marginHorizontal,
                            monthlyViewModel : self.monthlyViewModel,
                            monthlyDatas: self.monthlyDatas,
                            monthlyAllData: self.monthlyAllData,
                            tipBlock:self.tipBlock,
                            useFooter:self.useFooter,
                            isRecycle:self.isRecycle,
                            isLegacy:Self.isLegacy,
                            action:self.action)
                    }
                }
            } else {
                if self.viewModel.type == .btv {
                    EmptyAlert()
                        .modifier(MatchParent())
                } else {
                    ErrorKidsData(text:String.alert.dataError)
                        .modifier(MatchParent())
                }
            }
        }
        .modifier(MatchParent())
        .onReceive(self.infinityScrollModel.$event){evt in
            guard let evt = evt else {return}
            switch evt {
            case .bottom :
                if Self.isRecycle {
                    self.addBlock()
                }
            case .pullCompleted :
                PageLog.d("reload pullCompleted " + self.infinityScrollModel.isLoading.description, tag: self.tag)
                if !self.isLoading { self.viewModel.reload() }
                withAnimation{ self.reloadDegree = 0}
            case .pullCancel :
                withAnimation{ self.reloadDegree = 0}
            default : do{}
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
                PageLog.d("reload self.viewModel.$isUpdate " + self.infinityScrollModel.isLoading.description, tag: self.tag)
                if !self.isLoading { self.reload() }
                
            }
        }
        .onReceive(dataProvider.$result) { res in
            guard let data = self.loadingBlocks.first(where: { $0.id == res?.id}) else {return}
            var leadingBanners:[BannerData]? = nil
            var total:Int? = nil
            let max = Self.isRecycle ? 100 : 10
            switch data.dataType {
            case .cwGrid:
                guard let resData = res?.data as? CWGrid else {return data.setBlank()}
                guard let grid = resData.grid else {return data.setBlank()}
                if grid.isEmpty {return data.setBlank()}
                total = resData.total_count
                grid.forEach{ g in
                    if let blocks = g.block {
                        switch data.uiType {
                        case .poster :
                            data.posters = blocks[0...min(max, blocks.count-1)].map{ d in
                                PosterData().setData(data: d, cardType: data.cardType)
                            }
                        case .video :
                            data.videos = blocks[0...min(max, blocks.count-1)].map{ d in
                                VideoData().setData(data: d, cardType: data.cardType)
                            }
                        case .theme :
                            data.themas = blocks[0...min(max, blocks.count-1)].map{ d in
                                ThemaData().setData(data: d, cardType: data.cardType)
                            }
                        default: break
                        }
                    }
                }
            case .cwGridKids:
                guard let resData = res?.data as? CWGridKids else {return data.setBlank()}
                guard let grid = resData.grid else {return data.setBlank()}
                if grid.isEmpty {return data.setBlank()}
                total = resData.total_count
                grid.forEach{ g in
                    if let blocks = g.block {
                        switch data.uiType {
                        case .poster :
                            data.posters = blocks[0...min(max, blocks.count-1)].map{ d in
                                PosterData(pageType: .kids).setData(data: d, cardType: data.cardType)
                            }
                        case .video :
                            data.videos = blocks[0...min(max, blocks.count-1)].map{ d in
                                VideoData(pageType: .kids).setData(data: d, cardType: data.cardType)
                            }
                        default: break
                        }
                    }
                }
            case .grid:
                guard let resData = res?.data as? GridEvent else {return data.setBlank()}
                guard let blocks = resData.contents else {return data.setBlank()}
                if blocks.isEmpty {return data.setBlank()}
                total = resData.total_content_count
                switch data.uiType {
                case .poster :
                    data.posters = blocks[0...min(max, blocks.count-1)].map{ d in
                        PosterData().setData(data: d, cardType: data.cardType)
                    }

                case .video :
                    data.videos = blocks[0...min(max, blocks.count-1)].map{ d in
                        VideoData().setData(data: d, cardType: data.cardType)
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
                        PosterData().setData(data: d, cardType: data.cardType)
                    }
                case .video :
                    data.videos = blocks[0...min(max, blocks.count-1)].map{ d in
                        VideoData().setData(data: d, cardType: data.cardType)
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
                        PosterData().setData(data: d, cardType: data.cardType)
                    }
                case .video :
                    data.videos = watchBlocks.map{ d in
                        VideoData().setData(data: d, cardType: data.cardType)
                    }
                default: break
                }
            
            case .banner:
                guard let resData = res?.data as? EventBanner else {return data.setBlank()}
                guard let banners = resData.banners else {return data.setBlank()}
                if banners.isEmpty {return data.setBlank()}
                    data.banners = banners.map{ d in
                        BannerData().setData(data: d, cardType:data.cardType)
                }
            default: do {}
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
            
            data.setDatabindingCompleted(total: total)
            
        }
        .onReceive(dataProvider.$error) { err in
            guard let data = self.loadingBlocks.first(where: { $0.id == err?.id}) else {return}
            data.setError(err)
    
        }
        .onDisappear{
            self.addBlockSubscription?.cancel()
            self.addBlockSubscription = nil
            self.anyCancellable.forEach{$0.cancel()}
            self.anyCancellable.removeAll()
        }
    }//body

    @State var originBlocks:[BlockData] = []
    @State var loadingBlocks:[BlockData] = []
    @State var blocks:[BlockData] = []
    @State var blockSets:[BlockDataSet] = []
    @State var anyCancellable = Set<AnyCancellable>()
    @State var isError:Bool = false
    @State var isLoading:Bool = false
   
    func reload(){
        if self.viewModel.isAdult && !SystemEnvironment.isAdultAuth {
            withAnimation {self.needAdult = true}
            return
        }
        if needAdult {
            withAnimation {self.needAdult = false}
        }
    
        self.isError = false
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
        self.blocks = []
        self.infinityScrollModel.reload()
        self.originBlocks = viewModel.datas ?? []
        PageLog.d("reload self.originBlocks " + self.originBlocks.count.description, tag: self.tag)
        
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
            self.isError = true
        }
        
        
    }
    private func onBlock(stat:BlockStatus, block:BlockData){
        DispatchQueue.main.async {
            switch stat {
            case .passive:
                DataLog.d("passive " + block.name, tag: "BlockProtocolB")
                self.removeBlock(block)
            case .active:
                DataLog.d("active " + block.name, tag: "BlockProtocolB")
                break
            default: return
            }
            self.completedNum += 1
            PageLog.d("requestNum " + requestNum.description, tag: "BlockProtocolB")
            PageLog.d("completedNum " + completedNum.description, tag: "BlockProtocolB")
            if self.completedNum == self.requestNum {
                self.completedNum = 0
                if !Self.isPreLoad {
                    self.addBlock()
                } else{
                    self.addLoadedBlocks(self.loadingBlocks)
                    PageLog.d("self.blocks " + self.blocks.count.description, tag: self.tag)
                    self.loadingBlocks = []
                    if self.blocks.isEmpty {
                        self.addBlock()
                    } else if !Self.isRecycle {
                        self.delayAddBlock()
                    }
                }
            }
        }
    }
    
    @State var addBlockSubscription:AnyCancellable?
    func delayAddBlock(){
        self.addBlockSubscription = Timer.publish(
            every: 0.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.addBlockSubscription?.cancel()
                self.addBlock()
            }
        
    }
    
    
    private func addLoadedBlocks (_ loadedBlocks:[BlockData]){
        var idx = self.blocks.count
        let addBlocks = loadedBlocks
            .filter{$0.status == .active}
            .map{$0}
        addBlocks.forEach{
            DataLog.d("addLoadedBlocks " + $0.name + " " + $0.status.rawValue, tag: "BlockProtocolB")
            $0.index = idx
            idx += 1
        }
        self.blocks.append(contentsOf: addBlocks)
        self.isLoading = false
    }

    private func addBlock(){
        var max = 0
        if  !Self.isPreLoad {
            max = self.originBlocks.count
        } else {
            max = min(self.viewModel.requestSize, self.originBlocks.count)
        }
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
        if  !Self.isPreLoad {
            self.blocks.append(contentsOf: set)
        }else{
            self.isLoading = true
            self.loadingBlocks.append(contentsOf: set)
            self.loadingBlocks.forEach{ block in
                if let apiQ = block.getRequestApi(pairing:self.pairing.status, kid:self.pairing.kid) {
                    dataProvider.requestData(q: apiQ)
                } else{
                    if block.uiType == .kidsHome {
                        block.listHeight = Self.kisHomeHeight
                        block.setDatabindingCompleted()
                        
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
                        block.setDatabindingCompleted()
                        return
                    } else{
                        block.setRequestFail()
                    }
                }
            }
        }
    }
    
    private func removeBlock(_ block:BlockData){
        if !Self.isPreLoad {
            if let find = self.blocks.firstIndex(of: block) {
                self.blocks.remove(at: find)
                return
            }
        }
    }
    
}

