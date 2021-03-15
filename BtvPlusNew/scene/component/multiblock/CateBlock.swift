//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI


class CateBlockModel: PageDataProviderModel {
    private(set) var listType:CateBlock.ListType = .poster
    private(set) var dataType:BlockData.DataType = .grid
    private(set) var key:String? = nil
    private(set) var menuId:String? = nil
    private(set) var data:BlockData? = nil
    
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }
    
    func update(data:BlockData, listType:CateBlock.ListType, key:String? = nil) {
        self.data = data
        self.listType = listType
        self.key = key
        self.isUpdate = true
        self.menuId = data.menuId
    }
    
    func update(menuId:String?, listType:CateBlock.ListType, key:String? = nil) {
        self.listType = listType
        self.menuId = menuId
        self.key = key
        self.isUpdate = true
        self.data = nil
    }
}

extension CateBlock{
    static let videoCellsize:CGFloat = ListItem.video.size.width
    static let posterCellsize:CGFloat = ListItem.poster.type01.width
    static let bannerCellsize:CGFloat = ListItem.banner.type02.width
    static let headerSize:Int = 0
    enum ListType:String {
        case video, poster, banner
    }
}

struct CateBlock: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:CateBlockModel = CateBlockModel()
    var key:String? = nil
    var useTracking:Bool = false
    var marginTop : CGFloat = 0
    var marginBottom : CGFloat = 0
    var spacing: CGFloat = Dimen.margin.thin
    
    @State var reloadDegree:Double = 0
    
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel){
           
            if !self.isError {
                ZStack(alignment: .topLeading){
                    ReflashSpinner(
                        progress: self.$reloadDegree)
                        .padding(.top, self.marginTop)
                    InfinityScrollView(
                        viewModel: self.infinityScrollModel,
                        axes: .vertical,
                        scrollType : .reload(isDragEnd:false),
                        marginTop : self.marginTop,
                        marginBottom : self.marginBottom,
                        marginHorizontal : 0,
                        spacing:0,
                        isRecycle: true,
                        useTracking:self.useTracking
                    ){
                        if self.useTop {
                            SortTab(
                                count:self.totalCount,
                                isSortAble: self.isSortAble
                                ){ sort in
                                    self.sortType = sort
                                    self.reload()
                                }
                            .modifier(ListRowInset(
                                        marginHorizontal:Dimen.margin.thin,
                                        spacing: self.spacing))
                        }
                        
                        ForEach(self.posters) { data in
                            PosterSet(
                                pageObservable:self.pageObservable,
                                data:data )
                                .frame(height:self.posterCellHeight)
                                .modifier(ListRowInset( spacing: self.spacing))
                                .onAppear(){
                                    if data.index == self.posters.last?.index {
                                        if self.isPaging { self.load() }
                                    }
                                }
                        }
                        ForEach(self.videos) { data in
                            VideoSet(
                                pageObservable:self.pageObservable,
                                data:data )
                                .frame(height:self.videoCellHeight)
                                .modifier(ListRowInset( spacing: self.spacing))
                                .onAppear(){
                                    if data.index == self.videos.last?.index {
                                        if self.isPaging { self.load() }
                                    }
                                }
                        }
                        ForEach(self.banners) { data in
                            BannerSet(
                                pageObservable:self.pageObservable,
                                data:data )
                                .frame(height:self.bannerCellHeight)
                                .modifier(ListRowInset( spacing: self.spacing))
                                .onAppear(){
                                    if data.index == self.banners.last?.index {
                                        if self.isPaging { self.load() }
                                    }
                                }
                        }
                        if self.posters.isEmpty && self.videos.isEmpty  && self.banners.isEmpty{
                            Spacer().modifier(MatchParent())
                                .listRowBackground(Color.brand.bg)
                        }
                    }
                    .modifier(MatchParent())
                
                }
               
            } else {
                ZStack{
                    VStack(alignment: .center, spacing: 0){
                        Spacer().modifier(MatchHorizontal(height:0))
                        Image(Asset.icon.alert)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Dimen.icon.mediumUltra, height: Dimen.icon.mediumUltra)
                            .padding(.top, Dimen.margin.medium)
                        Text(String.alert.dataError)
                            .modifier(BoldTextStyle(size: Font.size.regular, color: Color.app.greyLight))
                            .multilineTextAlignment(.center)
                            .padding(.top, Dimen.margin.regularExtra)
                    }
                }
                .modifier(MatchParent())
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
            self.resetSize()
        }
        .onReceive(self.viewModel.$isUpdate){ update in
            if update {
                self.reload()
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
        
    }//body
    
    @State var sortType:EuxpNetwork.SortType = SortTab.finalSortType
    @State var totalCount:Int = 0
    @State var isError:Bool = false
    @State var posters:[PosterDataSet] = []
    @State var videos:[VideoDataSet] = []
    @State var banners:[BannerDataSet] = []
    
    @State var isPaging:Bool = true
    @State var isSortAble:Bool = false
    @State var useTop:Bool = false
    
    @State var loadedPosterDatas:[PosterData]? = nil
    @State var loadedVideoDatas:[VideoData]? = nil
    @State var loadedBannerDatas:[BannerData]? = nil
    
    @State var posterCellHeight:CGFloat = 0
    @State var videoCellHeight:CGFloat = 0
    @State var bannerCellHeight:CGFloat = 0
    
    func reload(){
        self.posters = []
        self.videos = []
        self.banners = []
        self.infinityScrollModel.reload()
        self.load()
    }
    
    
    func load(){
        if  !self.infinityScrollModel.isLoadable { return }
        withAnimation{ self.isError = false }
        self.infinityScrollModel.onLoad()
        if let api = self.viewModel.data?.getRequestApi(apiId:self.tag, pairing:self.pairing.status, isOption: false) {
            if self.viewModel.data!.dataType != .grid {
                self.isPaging = false
                withAnimation{ self.isSortAble = false }
                self.viewModel.request = api
                return
            }
        }

        self.isPaging = true
        withAnimation{ self.isSortAble = true }
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
    
    private func resetSize(){
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
        }
    }
    
    private func loadedBlock(_ res:ApiResultResponds) {
        guard let data = self.viewModel.data else { return self.onError() }
        switch data.dataType {
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
        let loadedDatas:[PosterData] = datas.map { d in
            return PosterData().setData(data: d)
        }
        setPosterSets(loadedDatas: loadedDatas)
    }
    
    func setVideoSets(datas:[BookMarkItem]?) {
        guard let datas = datas else {
            if self.videos.isEmpty {  self.onError() }
            return
        }
        let loadedDatas:[VideoData] = datas.map{ d in
            return VideoData().setData(data: d)
        }
        setVideoSets(loadedDatas: loadedDatas)
    }
    
    
    func setPosterSets(datas:[WatchItem]?) {
        guard let datas = datas else {
            if self.posters.isEmpty { self.onError() }
            return
        }
        let loadedDatas:[PosterData] = datas.map { d in
            return PosterData().setData(data: d)
        }
        
        setPosterSets(loadedDatas: loadedDatas)
    }
    
    func setVideoSets(datas:[WatchItem]?) {
        guard let datas = datas else {
            if self.videos.isEmpty {  self.onError() }
            return
        }
        let loadedDatas:[VideoData] = datas.map{ d in
            return VideoData().setData(data: d)
        }
        setVideoSets(loadedDatas: loadedDatas)
    }
    
    func setPosterSets(datas:[ContentItem]?) {
        guard let datas = datas else {
            if self.posters.isEmpty { self.onError() }
            return
        }
        let loadedDatas:[PosterData] = datas.map { d in
            return PosterData().setData(data: d)
        }
        setPosterSets(loadedDatas: loadedDatas)
    }
    
    func setVideoSets(datas:[ContentItem]?) {
        guard let datas = datas else {
            if self.videos.isEmpty {  self.onError() }
            return
        }
        let loadedDatas:[VideoData] = datas.map{ d in
            return VideoData().setData(data: d)
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
    
    
    func setPosterSets(loadedDatas:[PosterData]) {
        withAnimation{self.useTop = true}
        if self.loadedPosterDatas != nil {
            self.loadedPosterDatas?.append(contentsOf: loadedDatas)
        } else{
            self.loadedPosterDatas = loadedDatas
        }
        
        let count:Int = Int(floor(self.sceneObserver.screenSize.width / Self.posterCellsize))
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
            let size = PosterSet.listSize(data: data, screenWidth: self.sceneObserver.screenSize.width)
            self.posterCellHeight = size.height
        }
        self.infinityScrollModel.onComplete(itemCount: loadedDatas.count)
    }
    
    func setVideoSets(loadedDatas:[VideoData]) {
        withAnimation{self.useTop = true}
        if self.loadedVideoDatas != nil {
            self.loadedVideoDatas?.append(contentsOf: loadedDatas)
        } else{
            self.loadedVideoDatas = loadedDatas
        }
        let count:Int = Int(floor(self.sceneObserver.screenSize.width / Self.videoCellsize))
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
            let size = VideoSet.listSize(data: data, screenWidth: self.sceneObserver.screenSize.width, isFull: true)
            self.videoCellHeight = size.height
        }
        self.infinityScrollModel.onComplete(itemCount: loadedDatas.count)
    }
    
    func setBannerSets(loadedDatas:[BannerData]) {
        withAnimation{self.useTop = false}
        if self.loadedBannerDatas != nil {
            self.loadedBannerDatas?.append(contentsOf: loadedDatas)
        } else{
            self.loadedBannerDatas = loadedDatas
        }
        
        let count:Int = Int(round(self.sceneObserver.screenSize.width / Self.bannerCellsize))
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
            let size = BannerSet.listSize(data: data, screenWidth: self.sceneObserver.screenSize.width)
            self.bannerCellHeight = size.height
        }
        self.infinityScrollModel.onComplete(itemCount: loadedDatas.count)
    }
}





