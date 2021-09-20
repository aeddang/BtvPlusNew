//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI


class CateBlockModel: PageDataProviderModel {
    private(set) var type:PageType = .btv
    private(set) var listType:CateBlock.ListType = .poster
    private(set) var dataType:BlockData.DataType = .grid
    private(set) var cardType:BlockData.CardType? = nil
    private(set) var key:String? = nil
    private(set) var menuId:String? = nil
    private(set) var data:BlockData? = nil
    private(set) var datas:[BlockData]? = nil
    private(set) var selectIdx:Int = -1
    private(set) var isAdult:Bool = false
    private(set) var isFree:Bool = false
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }
    
    init(pageType:PageType = .btv) {
        self.type = pageType
    }
    
    func setupDropDown(datas:[BlockData]) {
        self.datas = datas
    }
    
    func update(data:BlockData, listType:CateBlock.ListType, idx:Int = -1,
                cardType:BlockData.CardType? = nil, isAdult:Bool = false, isFree:Bool = false,
                key:String? = nil) {
        self.data = data
        self.selectIdx = idx
        self.listType = listType
        self.cardType = cardType
        self.key = key
        self.isFree = isFree
        self.menuId = data.menuId
        self.isAdult = isAdult
        self.isUpdate = true
    }
    
    func update(menuId:String?, listType:CateBlock.ListType,
                cardType:BlockData.CardType? = nil, isAdult:Bool = false, isFree:Bool = false,
                key:String? = nil) {
        self.listType = listType
        self.menuId = menuId
        self.cardType = cardType
        self.key = key
        self.data = nil
        self.isFree = isFree
        self.isAdult = isAdult
        self.isUpdate = true
    }
    
    var info:String? {
        get{
            switch self.data?.dataType {
            case .watched : return String.pageText.myWatchedInfo
            case .bookMark : return String.pageText.myBookMarkedInfo
            default : return nil
            }
        }
    }
}

extension CateBlock{
    static let videoCellsize:CGFloat = ListItem.video.size.width
    static let posterCellsize:CGFloat = ListItem.poster.type01.width
    static let bannerCellsize:CGFloat = ListItem.banner.type02.width
    static let tvCellsize:CGFloat = ListItem.tv.size.width
    
    static let kidsVideoCellsize:CGFloat = ListItemKids.video.type02.width
    static let kidsPosterCellsize:CGFloat = ListItemKids.poster.type01.width
    static let headerSize:Int = 0
    enum ListType:String {
        case video, poster, banner, tv
    }
    
    static let listPadding:CGFloat = SystemEnvironment.currentPageType == .btv
        ? SystemEnvironment.isTablet ? Dimen.margin.tiny : Dimen.margin.thin
        : DimenKids.margin.thinUltra
}

struct CateBlock: PageComponent{
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:CateBlockModel = CateBlockModel()
    var key:String? = nil
    var useTracking:Bool = false
    var headerSize:CGFloat = SystemEnvironment.currentPageType == .btv ? Dimen.tab.lightExtra : DimenKids.tab.lightExtra
    var marginTop : CGFloat = Dimen.margin.regular
    var marginBottom : CGFloat = 0
    var marginHorizontal:CGFloat = Self.listPadding
    var spacing: CGFloat = Self.listPadding
    var size: CGFloat? = nil
    var menuTitle:String? = nil
    @State var reloadDegree:Double = 0
    @State var needAdult:Bool = false
    @State var menus:[String]? = nil
    
    @State var selectedMenuIdx:Int = -1
    @State var selectedTitle:String? = nil
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel){
           
            if self.needAdult{
                AdultAlert()
                .modifier(MatchParent())
            } else if !self.isError {
                ZStack(alignment: .topLeading){
                    ReflashSpinner(
                        progress: self.$reloadDegree)
                        .padding(.top, self.marginTop)
                    
                    InfinityScrollView(
                        viewModel: self.infinityScrollModel,
                        axes: .vertical,
                        scrollType : .reload(isDragEnd:false),
                        showIndicators: true,
                        header:self.useTop ?
                            CateBlockHeader(
                                pageType: self.viewModel.type,
                                totalCount: self.totalCount,
                                isSortAble: self.isSortAble,
                                info: self.viewModel.info,
                                menuTitle: self.menuTitle,
                                selectedTitle: self.selectedTitle,
                                selectedMenuIdx: self.selectedMenuIdx,
                                menus: self.menus,
                                marginTop: self.marginTop,
                                marginHorizontal: self.marginHorizontal,
                                menuAction: self.menuAction,
                                action: self.sortAction)
                            : nil,
                        headerSize: self.headerSize + self.spacing,
                        marginTop : self.marginTop ,
                        marginBottom : self.marginBottom,
                        marginHorizontal : 0,
                        spacing:0,
                        isRecycle: true,
                        useTracking:self.useTracking
                    ){
                        
                        ForEach(self.posters) { data in
                            PosterSet(
                                pageObservable:self.pageObservable,
                                data:data,
                                screenSize: self.screenSize,
                                padding:self.spacing
                                )
                                .frame(height:self.posterCellHeight)
                                .modifier(ListRowInset( marginHorizontal: self.marginHorizontal - self.spacing , spacing: self.spacing))
                                .onAppear(){
                                    if data.index == self.posters.last?.index {
                                        if self.isPaging { self.load() }
                                    }
                                }
                        }
                        ForEach(self.videos) { data in
                            VideoSet(
                                pageObservable:self.pageObservable,
                                data:data,
                                screenSize: self.screenSize,
                                padding:self.spacing
                                )
                                .frame(height:self.videoCellHeight)
                                .modifier(ListRowInset( marginHorizontal: self.marginHorizontal - self.spacing, spacing: self.spacing))
                                .onAppear(){
                                    if data.index == self.videos.last?.index {
                                        if self.isPaging { self.load() }
                                    }
                                }
                        }
                        ForEach(self.banners) { data in
                            BannerSet(
                                pageObservable:self.pageObservable,
                                data:data,
                                screenSize: self.screenSize,
                                padding:self.spacing
                                )
                                .frame(height:self.bannerCellHeight)
                                .modifier(ListRowInset( marginHorizontal: self.marginHorizontal - self.spacing, spacing: self.spacing))
                                .onAppear(){
                                    if data.index == self.banners.last?.index {
                                        if self.isPaging { self.load() }
                                    }
                                }
                        }
                        ForEach(self.tvs) { data in
                            TvSet(
                                pageObservable:self.pageObservable,
                                data:data,
                                screenSize: self.screenSize,
                                padding:self.spacing
                                )
                                .frame(height:self.tvCellHeight)
                                .modifier(ListRowInset(marginHorizontal: self.marginHorizontal - self.spacing, spacing: self.spacing))
                                .onAppear(){
                                }
                        }
                        if self.posters.isEmpty && self.videos.isEmpty  && self.banners.isEmpty && self.tvs.isEmpty{
                            Spacer().modifier(MatchParent())
                                .listRowBackground(Color.brand.bg)
                        }
                    }
                    .modifier(MatchParent())
                
                }
               
            } else {
                if self.viewModel.type == .btv {
                    if self.viewModel.data?.dataType == .bookMark {
                        EmptyMyData( text:String.pageText.myBookMarkedEmpty ).modifier(MatchParent())
                    } else  if self.viewModel.data?.dataType == .watched {
                        EmptyMyData( text:String.pageText.myWatchedEmpty ).modifier(MatchParent())
                    } else {
                        EmptyAlert().modifier(MatchParent())
                    }
                } else {
                    ErrorKidsData(
                        text: self.viewModel.data?.dataType == .watched
                            ? String.alert.dataError
                            : String.kidsText.kidsMyWatchedEmpty
                        ).modifier(MatchParent())
                }
                
            }
            
        }
        .onReceive(self.infinityScrollModel.$event){evt in
            guard let evt = evt else {return}
            switch evt {
            case .pullCompleted :
                if !self.infinityScrollModel.isLoading { self.reload() }
                withAnimation{ self.reloadDegree = 0 }
            case .pullCancel :
                withAnimation{ self.reloadDegree = 0 }
            default : do{}
            }
            
        }
        .onReceive(self.infinityScrollModel.$pullPosition){ pos in
            if pos < InfinityScrollModel.PULL_RANGE { return }
            self.reloadDegree = Double(pos - InfinityScrollModel.PULL_RANGE)
        }
        .onReceive(self.sceneObserver.$screenSize){ _ in
            self.resetLoad()
        }
        .onReceive(self.viewModel.$isUpdate){ update in
            if update {
                self.sortType = self.viewModel.type == .btv ? SortTab.finalSortType : SortTabKids.finalSortType
                self.setupMenu()
                self.reload()
            }
        }
        .onReceive(self.repository.$event){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .updatedWatchLv, .updatedAdultAuth :self.reload()
            default: break
            }
        }
        .onReceive(self.viewModel.$event){evt in
            guard let evt = evt else { return }
            switch evt {
            case .onResult(_, let res, _):
                self.loaded(res)
            case .onError(_,  _, _):
                self.onError()
            default : break
            }
        }
        .onAppear(){
           
        }
        
    }//body
    
    struct CateBlockHeader:PageComponent {
        var pageType:PageType
        var totalCount:Int
        var isSortAble:Bool
        var info:String?
        var menuTitle:String? = nil
        var selectedTitle:String? = nil
        var selectedMenuIdx:Int = -1
        var menus:[String]? = nil
        var marginTop : CGFloat
        var marginHorizontal:CGFloat
        let menuAction: (_ menuIdx:Int) -> Void
        let action: (_ type:EuxpNetwork.SortType) -> Void
        var body :some View {
            if pageType == .btv {
                SortTab(
                    count:self.totalCount,
                    isSortAble: self.isSortAble,
                    info: info,
                    menuTitle:menuTitle,
                    selectedTitle:selectedTitle,
                    selectedMenuIdx:selectedMenuIdx,
                    menus:menus,
                    menuAction: self.menuAction, 
                    action:self.action
                )
                .padding(.horizontal, marginHorizontal)
            } else {
                SortTabKids(
                    menuTitle: self.menuTitle,
                    count: self.totalCount,
                    isSortAble: self.isSortAble
                ){ sort in
                    self.action(sort)
                }
                .padding(.horizontal, marginHorizontal)
            }
        }
    }
    
    func setupMenu() {
        if let datas = self.viewModel.datas {
            self.selectedMenuIdx = self.viewModel.selectIdx
            let menus:[String] = datas.map{$0.name}
            if self.selectedMenuIdx >= 0 && self.selectedMenuIdx < menus.count {
                self.selectedTitle = menus[self.selectedMenuIdx]
                self.menus = menus
            }
        }
    }
    func menuAction(_ idx:Int) {
        guard let menus = self.menus else { return }
        if idx >= 0 && idx < menus.count {
            guard let select = self.viewModel.datas?[idx] else { return }
            self.viewModel
                .update(data:select, listType: select.uiType.listType ?? .poster, idx: idx)
        }
    }
    func sortAction(_ sort:EuxpNetwork.SortType) {
        self.sortType = sort
        self.reload()
    }
    
    @State var title:String? = nil  // 현제 사용안함
    @State var sortType:EuxpNetwork.SortType = SortTab.finalSortType
    @State var totalCount:Int = 0
    @State var isError:Bool = false
    @State var posters:[PosterDataSet] = []
    @State var videos:[VideoDataSet] = []
    @State var banners:[BannerDataSet] = []
    @State var tvs:[TvDataSet] = []
    
    @State var isPaging:Bool = false
    
    @State var isInitSortAble:Bool = true
    @State var isSortAble:Bool = false
    @State var useTop:Bool = false
    
    @State var loadedPosterDatas:[PosterData]? = nil
    @State var loadedVideoDatas:[VideoData]? = nil
    @State var loadedBannerDatas:[BannerData]? = nil
    @State var loadedTvDatas:[TvData]? = nil
    
    @State var screenSize:CGFloat = 0
   
    @State var posterCellHeight:CGFloat = 0
    @State var videoCellHeight:CGFloat = 0
    @State var bannerCellHeight:CGFloat = 0
    @State var tvCellHeight:CGFloat = 0
    
    func reload(){
        if self.viewModel.isAdult && !SystemEnvironment.isAdultAuth {
            self.needAdult = true
            return
        }
        if needAdult {
            withAnimation {self.needAdult = false}
        }
        self.posters = []
        self.videos = []
        self.banners = []
        self.tvs = []
        self.infinityScrollModel.reload()
        self.load()
    }
    
    private func setupSortAble(poster:BlockData?) -> [PosterData]?{
        guard let data = poster else {return nil}
        guard let datas = data.allPosters else {return nil}
        if datas.isEmpty {return nil}
        let type = self.sortType
        switch type {
        //case .latest, .title, .price: return nil
        default :
            self.totalCount = datas.count
            self.isSortAble = false
            withAnimation{self.useTop = true}
            return datas
        }
    }
    
    private func setupSortAble(video:BlockData?) -> [VideoData]?{
        guard let data = video else {return nil}
       
        guard let datas = data.allVideos else {return nil}
        if datas.isEmpty {return nil}
        switch self.sortType {
        //case .latest , .title, .price: return nil
        default :
            self.totalCount = datas.count
            self.isSortAble = false
            self.isPaging = false
            withAnimation{self.useTop = true}
            return datas
        }
    }
    
    private func setupSortAble(tv:BlockData?) -> [TvData]?{
        guard let data = tv else {return nil}
        guard let datas = data.allTvs else {return nil}
        if datas.isEmpty {return nil}
        self.totalCount = datas.count
        self.isSortAble = false
        withAnimation{self.useTop = true}
        return datas
    }

    func load(){
        if !self.infinityScrollModel.isLoadable { return }
        self.resetSize()
        withAnimation{ self.isError = false }
        self.infinityScrollModel.onLoad()
        if self.isInitSortAble {
            if let datas = self.setupSortAble(poster:self.viewModel.data) {
                self.setPosterSets(loadedDatas: datas)
                return
            }
            if let datas = self.setupSortAble(video:self.viewModel.data) {
                self.setVideoSets(loadedDatas: datas)
                return
            }
            
            if let datas = self.setupSortAble(tv:self.viewModel.data)  {
                self.setTvSets(loadedDatas: datas)
                return
            }
            self.isInitSortAble = false
        }
       
        if let api = self.viewModel.data?.getRequestApi(
            apiId:self.tag,
            pairing:self.pairing.status,
            kid: self.pairing.kid,
            sortType: self.sortType,
            isOption: false)
        {
            guard let blockData = self.viewModel.data else { return }
            if blockData.dataType != .grid {
                self.isPaging = false
                withAnimation{
                    self.isSortAble = blockData.dataType == .cwGridKids && blockData.cardType != .watchedVideo ? true : false
                    
                }
                self.viewModel.request = api
                return
            }
        }

        self.isPaging = true
        withAnimation{ self.isSortAble = self.viewModel.data?.cardType == .rankingPoster  ? false : true }
        self.viewModel.request = .init(
            id: self.tag,
            type: .getGridEvent(
                self.viewModel.menuId,
                self.sortType,
                self.infinityScrollModel.page + 1)
        )
    }
    
    private func onError(){
        withAnimation{ self.isError = true }
    }
    
    private func loaded(_ res:ApiResultResponds){
        if self.isPaging {
            loadedGrid(res)
        }else{
            loadedBlock(res)
        }
    }
    
    private func resetLoad(){
        self.resetSize()
        if let loadedVideo = self.loadedVideoDatas {
            self.loadedVideoDatas = nil
            self.videos = []
            self.setVideoSets(loadedDatas: loadedVideo)
        }
        if let loadedPoster = self.loadedPosterDatas{
            self.posters = []
            self.loadedPosterDatas = nil
            self.setPosterSets(loadedDatas: loadedPoster)
        }
        if let loadedBanner = self.loadedBannerDatas{
            self.banners = []
            self.loadedBannerDatas = nil
            self.setBannerSets(loadedDatas: loadedBanner)
        }
        if let loadedTv = self.loadedTvDatas{
            self.tvs = []
            self.loadedTvDatas = nil
            self.setTvSets(loadedDatas: loadedTv)
        }
    }
    private func resetSize(){
        if let size = self.size {
            self.screenSize = size
        } else {
            let safeArea = self.sceneObserver.safeAreaStart + self.sceneObserver.safeAreaEnd
            self.screenSize = self.sceneObserver.screenSize.width + safeArea - ((self.marginHorizontal - self.spacing)*2)
        }
    }
    private func loadedGrid(_ res:ApiResultResponds){
        guard let data = res.data as? GridEvent else { return }
        if self.infinityScrollModel.page == 0 {
            self.totalCount = data.total_content_count ?? 0
        }
        
        switch self.viewModel.listType{
        case .poster : setPosterSets(datas: data.contents)
        case .video : setVideoSets(datas: data.contents)
        case .banner : setBannerSets(datas: data.banners)
        default : break
        }
    }
    
    private func loadedBlock(_ res:ApiResultResponds) {
        guard let data = self.viewModel.data else { return self.onError() }
        switch data.dataType {
        case .cwGridKids:
            guard let resData = res.data as? CWGridKids else {return }
            guard let grid = resData.grid else { return self.onError() }
            if grid.isEmpty { return self.onError() }
            
            var allDatas:[ContentItem] = []
            grid.filter{ $0.cw_call_id == self.viewModel.data?.cwCallId }
                .forEach{ g in
                
                if let blocks = g.block {
                    allDatas.append(contentsOf: blocks)
                }
            }
            self.totalCount = allDatas.count
            if self.viewModel.listType == .poster {
                setPosterSets(datas: allDatas)
            }else{
                setVideoSets(datas: allDatas)
            }
            
            
        case .cwGrid:
            guard let resData = res.data as? CWGrid else {return}
            guard let grid = resData.grid else { return self.onError() }
            var allDatas:[ContentItem] = []
            grid.forEach{ g in
                if let blocks = g.block {
                    allDatas.append(contentsOf: blocks)
                }
            }
            self.totalCount = allDatas.count
            if self.viewModel.listType == .poster {
                setPosterSets(datas: allDatas)
            }else{
                setVideoSets(datas: allDatas)
            }
        case .grid:
            guard let resData = res.data as? GridEvent else { return self.onError() }
            guard let blocks = resData.contents else { return self.onError() }
            self.totalCount = blocks.count
            if self.viewModel.listType == .poster {
                setPosterSets(datas: blocks)
            }else{
                setVideoSets(datas: blocks)
            }
            
        case .bookMark:
            guard let resData = res.data as? BookMark else { return self.onError() }
            guard let blocks = resData.bookmarkList else { return self.onError() }
            self.totalCount = blocks.count
            if self.viewModel.listType == .poster {
                setPosterSets(datas: blocks)
            }else{
                setVideoSets(datas: blocks)
            }
            
        case .watched:
            guard let resData = res.data as? Watch else { return self.onError() }
            guard let blocks = resData.watchList else { return self.onError() }
            self.totalCount = blocks.count
            if self.viewModel.listType == .poster {
                setPosterSets(datas: blocks)
            }else{
                setVideoSets(datas: blocks)
            }
            
        default: self.onError()
        }
    }
    
    func setPosterSets(datas:[BookMarkItem]?) {
        guard let datas = datas else {
            if self.posters.isEmpty { self.onError() }
            return
        }
        let type = self.viewModel.type
        let loadedDatas:[PosterData] = datas.map { d in
            return PosterData(pageType: type, usePrice: !self.viewModel.isFree)
                .setData(data: d, cardType: .bookmarkedPoster)
        }
        setPosterSets(loadedDatas: loadedDatas)
    }
    
    func setVideoSets(datas:[BookMarkItem]?) {
        guard let datas = datas else {
            if self.videos.isEmpty {  self.onError() }
            return
        }
        let type = self.viewModel.type
        let loadedDatas:[VideoData] = datas.map{ d in
            return VideoData(pageType: type, usePrice: !self.viewModel.isFree)
                .setData(data: d, cardType: self.viewModel.cardType ?? .video)
        }
        setVideoSets(loadedDatas: loadedDatas)
    }
    
    
    func setPosterSets(datas:[WatchItem]?) {
        guard let datas = datas else {
            if self.posters.isEmpty { self.onError() }
            return
        }
        let type = self.viewModel.type
        let loadedDatas:[PosterData] = datas.map { d in
            return PosterData(pageType: type, usePrice: !self.viewModel.isFree).setData(data: d)
        }
        
        setPosterSets(loadedDatas: loadedDatas)
    }
    
    func setVideoSets(datas:[WatchItem]?) {
        guard let datas = datas else {
            if self.videos.isEmpty {  self.onError() }
            return
        }
        let type = self.viewModel.type
        let loadedDatas:[VideoData] = datas.map{ d in
            return VideoData(pageType: type, usePrice: !self.viewModel.isFree)
                .setData(data: d, cardType: self.viewModel.cardType ?? .watchedVideo)
        }
        setVideoSets(loadedDatas: loadedDatas)
    }
    
    func setPosterSets(datas:[ContentItem]?) {
        guard let datas = datas else {
            if self.posters.isEmpty { self.onError() }
            return
        }
        let type = self.viewModel.type
        let loadedDatas:[PosterData] = datas.map { d in
            return PosterData(pageType: type, usePrice: !self.viewModel.isFree)
                .setData(data: d)
        }
        setPosterSets(loadedDatas: loadedDatas)
    }
    
    func setVideoSets(datas:[ContentItem]?) {
        guard let datas = datas else {
            if self.videos.isEmpty {  self.onError() }
            return
        }
        let type = self.viewModel.type
        let loadedDatas:[VideoData] = datas.map{ d in
            return VideoData(pageType: type, usePrice: !self.viewModel.isFree)
                .setData(data: d, cardType: self.viewModel.cardType ?? .video)
        }
        setVideoSets(loadedDatas: loadedDatas)
    }
    
    func setBannerSets(datas:[EventBannerItem]?) {
        guard let datas = datas else {
            if self.banners.isEmpty {  self.onError() }
            return
        }
        let loadedDatas:[BannerData] = datas.map{ d in
            return BannerData().setData(data: d)
        }
        setBannerSets(loadedDatas: loadedDatas)
    }
    
    func setPosterSets(datas:[PosterData]?) {
        guard let datas = datas else {
            if self.posters.isEmpty { self.onError() }
            return
        }
        setPosterSets(loadedDatas: datas)
    }
    
    func setVideoSets(datas:[VideoData]?) {
        guard let datas = datas else {
            if self.videos.isEmpty {  self.onError() }
            return
        }
        setVideoSets(loadedDatas: datas)
    }
    
    
    private func modifyCount(_ count:Int) -> Int{
        if count <= 3 {return count} //123
        if count == 4 {return count}
        if count <= 6 {return 5} //56
        if count <= 8 {return 6}
        return 8
    }
    
    private func setPosterSets(loadedDatas:[PosterData]) {
        withAnimation{self.useTop = true}
        if self.loadedPosterDatas != nil {
            self.loadedPosterDatas?.append(contentsOf: loadedDatas)
        } else{
            self.loadedPosterDatas = loadedDatas
        }
        if self.viewModel.cardType == .rankingPoster, let posters =  self.loadedPosterDatas {
            zip( posters, 0...posters.count).forEach{ data , idx in
                data.setRank(idx)
            }
        }
        
        
        let cellSize = self.viewModel.type == .btv ? Self.posterCellsize : Self.kidsPosterCellsize
        let count:Int = modifyCount(Int(floor(self.screenSize / cellSize)))
        var rows:[PosterDataSet] = []
        var cells:[PosterData] = []
        var total = self.posters.count
        loadedDatas.forEach{ d in
            if cells.count < count {
                cells.append(d)
            }else{
                rows.append(
                    PosterDataSet( count: count, datas: cells, isFull: true, index:total)
                )
                total += 1
                cells = [d]
            }
        }
        if !cells.isEmpty {
            rows.append(
                PosterDataSet( count: count, datas: cells,isFull: cells.count == count, index: total)
            )
        }
        self.posters.append(contentsOf: rows)
        if self.posters.isEmpty { self.onError() }
        if let data = self.posters.first {
            let size = PosterSet.listSize(data: data, screenWidth: self.screenSize , padding: self.spacing)
            self.posterCellHeight = size.height
        }
        self.infinityScrollModel.onComplete(itemCount: loadedDatas.count)
    }
    
    private func setVideoSets(loadedDatas:[VideoData]) {
        withAnimation{self.useTop = true}
        if self.loadedVideoDatas != nil {
            self.loadedVideoDatas?.append(contentsOf: loadedDatas)
        } else{
            self.loadedVideoDatas = loadedDatas
        }
       
        let cellSize = self.viewModel.type == .btv ? Self.videoCellsize : Self.kidsVideoCellsize
        let count:Int = modifyCount(Int(floor(self.screenSize / cellSize)))
        
        
        var rows:[VideoDataSet] = []
        var cells:[VideoData] = []
        var total = self.videos.count
        loadedDatas.forEach{ d in
            if cells.count < count {
                cells.append(d)
            }else{
                rows.append(
                    VideoDataSet( count: count, datas: cells, isFull: true, index: total)
                )
                cells = [d]
                total += 1
            }
        }
        if !cells.isEmpty {
            rows.append(
                VideoDataSet( count: count, datas: cells,isFull: cells.count == count, index: total)
            )
        }
        self.videos.append(contentsOf: rows)
        if self.videos.isEmpty { self.onError() }
        
        if let data = self.videos.first {
            let size = VideoSet.listSize(data: data, screenWidth: self.screenSize, padding: self.spacing, isFull:true)
            self.videoCellHeight = size.height
        }
        self.infinityScrollModel.onComplete(itemCount: loadedDatas.count)
    }
    
    private func setBannerSets(loadedDatas:[BannerData]) {
        withAnimation{self.useTop = false}
        if self.loadedBannerDatas != nil {
            self.loadedBannerDatas?.append(contentsOf: loadedDatas)
        } else{
            self.loadedBannerDatas = loadedDatas
        }
        
        let count:Int = modifyCount(Int(round(self.screenSize / Self.bannerCellsize)))
        var rows:[BannerDataSet] = []
        var cells:[BannerData] = []
        var total = self.banners.count
        loadedDatas.forEach{ d in
            if cells.count < count {
                cells.append(d)
            }else{
                rows.append(
                    BannerDataSet( count: count, datas: cells, isFull: true, index:total)
                )
                total += 1
                cells = [d]
            }
        }
        if !cells.isEmpty {
            rows.append(
                BannerDataSet( count: count, datas: cells,isFull: cells.count == count, index: total)
            )
        }
        self.banners.append(contentsOf: rows)
        if self.banners.isEmpty { self.onError() }
        if let data = self.banners.first {
            let size = BannerSet.listSize(data: data, screenWidth: self.screenSize, padding: self.spacing)
            self.bannerCellHeight = size.height
        }
        self.infinityScrollModel.onComplete(itemCount: loadedDatas.count)
    }
    
    private func setTvSets(loadedDatas:[TvData]) {
        withAnimation{self.useTop = true}
        if self.loadedTvDatas != nil {
            self.loadedTvDatas?.append(contentsOf: loadedDatas)
        } else{
            self.loadedTvDatas = loadedDatas
        }
        
        let count:Int = modifyCount(Int(round(self.screenSize / Self.tvCellsize)))
        var rows:[TvDataSet] = []
        var cells:[TvData] = []
        var total = self.tvs.count
        loadedDatas.forEach{ d in
            if cells.count < count {
                cells.append(d)
            }else{
                rows.append(
                    TvDataSet( count: count, datas: cells, isFull: true, index:total)
                )
                total += 1
                cells = [d]
            }
        }
        if !cells.isEmpty {
            rows.append(
                TvDataSet( count: count, datas: cells,isFull: cells.count == count, index: total)
            )
        }
        self.tvs.append(contentsOf: rows)
        if self.tvs.isEmpty { self.onError() }
        if let data = self.tvs.first {
            let size = TvSet.listSize(data: data, screenWidth: self.screenSize, padding: self.spacing)
            self.tvCellHeight = size.height
        }
        self.infinityScrollModel.onComplete(itemCount: loadedDatas.count)
    }
}





