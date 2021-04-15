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
   
    private(set) var datas:[BlockData]? = nil
    private(set) var headerSize:Int = 0
    private(set) var requestSize:Int = 0
    private(set) var isAdult:Bool = false
    private(set) var openId:String? = nil
    private(set) var selectedTicketId:String? = nil
    
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }
    
    init(headerSize:Int = 0, requestSize:Int = 30) {
        self.headerSize = headerSize
        self.requestSize = requestSize
    }
    
    func reload() {
        self.datas?.forEach({$0.reset()})
        self.isUpdate = true
    }
    
    func update(datas:[BlockItem], openId:String?, selectedTicketId:String? = nil, themaType:BlockData.ThemaType = .category, isAdult:Bool = false) {
        self.datas = datas.map{ block in
            BlockData().setDate(block, themaType:themaType)
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
    private static var isPreLoad:Bool = true
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
    
    var topDatas:[BannerData]? = nil
    var monthlyViewModel: InfinityScrollModel = InfinityScrollModel()
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
                                viewModel:self.viewPagerModel,
                                datas: self.topDatas! )
                                .padding(.top, max(self.headerOffset, -TopBanner.imageHeight))
                                .offset(y: self.marginHeader)
                            
                        }
                        
                        ReflashSpinner(
                            progress: self.$reloadDegree,
                            progressMax: self.reloadDegreeMax
                        )
                        .padding(.top, self.topDatas != nil ? (TopBanner.height + self.marginHeader)  : self.marginTop)
                                 
                        MultiBlock(
                            viewModel: self.infinityScrollModel,
                            viewPagerModel:self.viewPagerModel,
                            pageObservable: self.pageObservable,
                            pageDragingModel: self.pageDragingModel,
                            topDatas: self.topDatas,
                            datas: self.blocks,
                            headerSize: self.viewModel.headerSize,
                            useBodyTracking:self.useBodyTracking,
                            useTracking:self.useTracking,
                            marginHeader:self.marginHeader,
                            marginTop:self.marginTop,
                            marginBottom: self.marginBottom,
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
                            viewModel: self.infinityScrollModel,
                            viewPagerModel:self.viewPagerModel,
                            pageObservable: self.pageObservable,
                            pageDragingModel: self.pageDragingModel,
                            topDatas: self.topDatas,
                            datas: self.blocks,
                            headerSize: self.viewModel.headerSize,
                            useBodyTracking:self.useBodyTracking,
                            useTracking:self.useTracking,
                            marginHeader:self.marginHeader,
                            marginTop: self.topDatas == nil ? self.marginTop : self.marginHeader,
                            marginBottom: self.marginBottom,
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
                EmptyAlert()
                    .modifier(MatchParent())
            }
        }
        .modifier(MatchParent())
        .onReceive(self.infinityScrollModel.$event){evt in
            guard let evt = evt else {return}
            switch evt {
            case .bottom : self.addBlock()
            case .pullCompleted :
                if !self.infinityScrollModel.isLoading { self.viewModel.reload() }
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
            if update { self.reload() }
        }
        .onReceive(dataProvider.$result) { res in
            guard let data = self.loadingBlocks.first(where: { $0.id == res?.id}) else {return}
            var banners:[BannerData]? = nil
            var total:Int? = nil
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
                            data.posters = blocks.map{ d in
                                PosterData().setData(data: d, cardType: data.cardType)
                            }
                        case .video :
                            data.videos = blocks.map{ d in
                                VideoData().setData(data: d, cardType: data.cardType)
                            }
                        case .theme :
                            data.themas = blocks.map{ d in
                                ThemaData().setData(data: d, cardType: data.cardType)
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
                    data.posters = blocks.map{ d in
                        PosterData().setData(data: d, cardType: data.cardType)
                    }

                case .video :
                    data.videos = blocks.map{ d in
                        VideoData().setData(data: d, cardType: data.cardType)
                    }
                    
                case .theme :
                    data.themas = blocks.map{ d in
                        ThemaData().setData(data: d, cardType: data.cardType)
                    }
                    
                default: break
                }
                
                banners = resData.banners?.map{d in
                    BannerData().setData(data: d, type: .list)
                }
                
            case .bookMark:
                guard let resData = res?.data as? BookMark else {return data.setBlank()}
                guard let blocks = resData.bookmarkList else {return data.setBlank()}
                if blocks.isEmpty {return data.setBlank()}
                total = resData.bookmark_tot?.toInt()
                switch data.uiType {
                case .poster :
                    data.posters = blocks.map{ d in
                        PosterData().setData(data: d, cardType: data.cardType)
                    }
                case .video :
                    data.videos = blocks.map{ d in
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
                if watchBlocks.isEmpty {return data.setBlank()}
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
                switch data.uiType {
                case .banner :
                    data.banners = banners.map{ d in
                        BannerData().setData(data: d)
                    }
                default: break
                }
            default: do {}
            }
            
            var listHeight:CGFloat = 0
            var padding = Dimen.margin.thin
            if let size = data.posters?.first?.type {
                listHeight = size.size.height
            }
            if let video = data.videos?.first{
                listHeight = video.type.size.height + video.bottomHeight
            }
            if let size = data.themas?.first?.type {
                listHeight = size.size.height
                padding = size.spacing
            }
            if listHeight != 0 {
                if let banner = banners {
                    let ratio = ListItem.banner.type03
                    let w = listHeight * ratio.width/ratio.height
                    banner.forEach{ $0.setBannerSize(width: w , height: listHeight, padding: padding) }
                    data.leadingBanners = banner
                }
                data.listHeight = listHeight
            }
            data.setDatabindingCompleted(total: total)
            
        }
        .onReceive(dataProvider.$error) { err in
            guard let data = self.loadingBlocks.first(where: { $0.id == err?.id}) else {return}
            data.setError(err)
    
        }
        .onDisappear{
            self.anyCancellable.forEach{$0.cancel()}
            self.anyCancellable.removeAll()
        }
    }//body

    @State var originBlocks:[BlockData] = []
    @State var loadingBlocks:[BlockData] = []
    @State var blocks:[BlockData] = []
    @State var anyCancellable = Set<AnyCancellable>()
    @State var isError:Bool = false
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
        PageLog.d("addBlock completed", tag: "BlockProtocol")
        if !self.loadingBlocks.isEmpty {
            self.addLoadedBlocks(self.loadingBlocks) 
            PageLog.d("self.blocks " + self.blocks.count.description, tag: "BlockProtocol")
            self.loadingBlocks = []
        }
        if self.blocks.isEmpty {
            self.isError = true
        }
    }
    private func onBlock(stat:BlockStatus, block:BlockData){
        switch stat {
        case .passive: self.removeBlock(block)
        case .active: break
        default: return
        }
        self.completedNum += 1
        PageLog.d("completedNum " + completedNum.description, tag: "BlockProtocol")
        if self.completedNum == self.requestNum {
            self.completedNum = 0
            if  !Self.isPreLoad {
                self.addBlock()
            } else{
                self.addLoadedBlocks(self.loadingBlocks)
                PageLog.d("self.blocks " + self.blocks.count.description, tag: "BlockProtocol")
                self.loadingBlocks = []
                if self.blocks.isEmpty {
                    self.addBlock()
                }
            }
        }
    }
    private func addLoadedBlocks (_ loadedBlocks:[BlockData]){
        var idx = self.blocks.count
        loadedBlocks.forEach{
            $0.index = idx
            idx += 1
        }
        self.blocks.append(contentsOf: loadedBlocks)
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
        if set.isEmpty { return }
        self.requestNum = set.count
        if  !Self.isPreLoad {
            self.blocks.append(contentsOf: set)
        }else{
            self.loadingBlocks.append(contentsOf: set)
            self.loadingBlocks.forEach{ s in
                if let apiQ = s.getRequestApi(pairing:self.pairing.status) {
                    dataProvider.requestData(q: apiQ)
                } else{
                    if s.dataType == .theme , let _ = s.blocks {
                        s.setDatabindingCompleted()
                        return
                    } else{
                        s.setRequestFail()
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
        } else{
            if let find = self.loadingBlocks.firstIndex(of: block) {
                self.loadingBlocks.remove(at: find)
                return
            }
        }
    }
    
}

