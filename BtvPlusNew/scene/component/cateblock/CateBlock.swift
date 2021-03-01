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
    static let videoRowsize:Int = 2
    static let posterRowsize:Int = 3
    
    enum ListType:String {
        case video, poster
    }
}






struct CateBlock: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    @ObservedObject var viewModel:CateBlockModel = CateBlockModel()
    var key:String? = nil
    var useTracking:Bool = false
    
    
    @State var posterCellHeight:CGFloat = 0
    @State var videoCellHeight:CGFloat = 0
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            if !self.isError {
                if #available(iOS 14.0, *) {
                    ZStack(alignment: .topLeading){
                        VStack{
                            ReflashSpinner(
                                progress: self.$reloadDegree
                            )
                            Spacer()
                        }
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            axes: .vertical,
                            marginVertical : 0,
                            marginHorizontal : 0,
                            spacing: Dimen.margin.thin,
                            isRecycle: true,
                            useTracking:self.useTracking
                        ){
                            SortTab(
                                count:self.totalCount,
                                isSortAble: self.isSortAble
                                ){ sort in
                                    self.sortType = sort
                                    self.reload()
                                }
                            .modifier(ContentEdges())
                            
                            ForEach(self.posters) { data in
                                PosterSet( data:data )
                                    .frame(height:self.posterCellHeight)
                                    .onAppear(){
                                        if data.index == self.posters.last?.index {
                                            if self.isPaging { self.load() }
                                        }
                                    }
                            }
                            ForEach(self.videos) { data in
                                VideoSet( data:data )
                                    .frame(height:self.videoCellHeight)
                                    .onAppear(){
                                        if data.index == self.videos.last?.index {
                                            if self.isPaging { self.load() }
                                        }
                                    }
                            }
                            if self.posters.isEmpty && self.videos.isEmpty {
                                Spacer().modifier(MatchParent())
                            }
                            
                        }
                    }
                    .padding(.bottom, self.sceneObserver.safeAreaBottom)
                    .background(Color.brand.bg)
                    
                }else{
                    List {
                        SortTab(
                            count:self.totalCount,
                            isSortAble: self.isSortAble
                            ){ sort in
                                self.sortType = sort
                                self.reload()
                            }
                        .modifier(ListRowInset(
                                    firstIndex: 0, index: 0,
                                    marginHorizontal:Dimen.margin.thin,
                                    spacing: Dimen.margin.thin, marginTop: 0))
                        
                        ForEach(self.posters) { data in
                            PosterSet( data:data )
                                .frame(height:self.posterCellHeight)
                                .modifier(ListRowInset( spacing: Dimen.margin.thin))
                                .onAppear(){
                                    if data.index == self.posters.last?.index {
                                        if self.isPaging { self.load() }
                                    }
                                }
                        }
                        ForEach(self.videos) { data in
                            VideoSet( data:data )
                                .frame(height:self.videoCellHeight)
                                .modifier(ListRowInset( spacing: Dimen.margin.thin))
                                .onAppear(){
                                    if data.index == self.videos.last?.index {
                                        if self.isPaging { self.load() }
                                    }
                                }
                        }
                        if self.posters.isEmpty && self.videos.isEmpty {
                            Spacer().modifier(MatchParent())
                                .listRowBackground(Color.brand.bg)
                        }
                    }
                    .modifier(MatchParent())
                    .background(Color.brand.bg)
                    .onAppear(){
                        UITableView.appearance().backgroundColor = Color.brand.bg.uiColor()
                        UITableView.appearance().separatorStyle = .none
                        UITableView.appearance().separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
                    }
                    
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
    @State var reloadDegree:Double = 0
    @State var isPaging:Bool = true
    @State var isSortAble:Bool = false
    
    func reload(){
        self.posters = []
        self.videos = []
        self.infinityScrollModel.reload()
        self.load()
    }
    
    
    func load(){
        if  !self.infinityScrollModel.isLoadable { return }
        withAnimation{ self.isError = false }
        self.infinityScrollModel.onLoad()
        if let api = self.viewModel.data?.getRequestApi(apiId:self.tag) {
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
                self.infinityScrollModel.page + 1),
            isOptional:true
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
    
    private func loadedGrid(_ res:ApiResultResponds){
        guard let data = res.data as? GridEvent else { return }
        if self.infinityScrollModel.page == 0 {
            self.totalCount = data.total_content_count ?? 0
        }
        if self.viewModel.listType == .poster {
            setPosterSets(datas: data.contents)
        }else{
            setVideoSets(datas: data.contents)
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
    
    
    func setPosterSets(loadedDatas:[PosterData]) {
        let count = Self.posterRowsize
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
        let count = Self.videoRowsize
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
}



#if DEBUG
struct CateBody_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            CateBlock(
                
            )
            .environmentObject(PagePresenter())
        }.background(Color.blue)
    }
}
#endif

