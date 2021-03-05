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
    @Published private(set) var isUpdate = false {
        didSet{ if self.isUpdate { self.isUpdate = false} }
    }
    
    init(headerSize:Int = 5, requestSize:Int = 5) {
        self.headerSize = headerSize
        self.requestSize = requestSize
    }
    
    func reload() {
        self.datas?.forEach({$0.reset()})
        self.isUpdate = true
    }
    
    func update(datas:[BlockItem]) {
        self.datas = datas.map{ block in
            BlockData().setDate(block)
        }
        .filter{ block in
            switch block.dataType {
            case .cwGrid : return block.menuId != nil && block.cwCallId != nil
            case .grid : return block.menuId != nil
            default : return true
            }
        }
        self.isUpdate = true
    }
    
}


struct MultiBlockBody: PageComponent {
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var sceneObserver:SceneObserver
    var viewModel:MultiBlockModel = MultiBlockModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var viewPagerModel:ViewPagerModel = ViewPagerModel()
    var pageObservable:PageObservable = PageObservable()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var useBodyTracking:Bool = false
    var useTracking:Bool = false
    var marginTop : CGFloat = 0
    var marginBottom : CGFloat = 0
    var topDatas:[BannerData]? = nil
    var monthlyViewModel: InfinityScrollModel? = nil
    var monthlyDatas:[MonthlyData]? = nil
    var isRecycle = true
    var action: ((_ data:MonthlyData) -> Void)? = nil
    
    @State var reloadDegree:Double = 0
    @State var reloadDegreeMax:Double = ReflashSpinner.DEGREE_MAX
    @State var headerOffset:CGFloat = 0
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            ZStack(alignment: .topLeading){
                if self.topDatas != nil {
                    TopBannerBg(
                        viewModel:self.viewPagerModel,
                        datas: self.topDatas! )
                        .padding(.top, max(self.headerOffset, -TopBanner.imageHeight))
                }
                
                ReflashSpinner(
                    progress: self.$reloadDegree,
                    progressMax: self.reloadDegreeMax
                )
                .padding(.top,
                         self.marginTop
                         + (self.topDatas != nil ? TopBanner.height - self.marginTop : 0)
                         + (self.monthlyDatas != nil ? MonthlyBlock.height + MultiBlock.spacing : 0) )
                
                MultiBlock(
                    viewModel: self.infinityScrollModel,
                    pageObservable: self.pageObservable,
                    pageDragingModel: self.pageDragingModel,
                    topDatas: nil,
                    datas: self.blocks,
                    headerSize: self.viewModel.headerSize,
                    useBodyTracking:self.useBodyTracking,
                    useTracking:self.useTracking,
                    marginTop:self.marginTop
                        + (self.topDatas != nil ? (TopBanner.height - self.marginTop) : 0)
                        + (self.monthlyDatas != nil ? MonthlyBlock.height + MultiBlock.spacing : 0),
                    marginBottom: self.marginBottom,
                    monthlyViewModel : nil,
                    monthlyDatas: nil,
                    isRecycle:self.isRecycle,
                    action:self.action
                    )
                
                if self.topDatas != nil {
                    TopBanner(
                        viewModel:self.viewPagerModel,
                        datas: self.topDatas! )
                        .modifier(MatchHorizontal(height: TopBanner.height))
                        .padding(.top, max(self.headerOffset, -TopBanner.imageHeight))
                }
                if self.monthlyDatas != nil {
                   MonthlyBlock(
                        viewModel:self.monthlyViewModel ?? InfinityScrollModel(),
                        pageDragingModel:self.pageDragingModel,
                        monthlyDatas:self.monthlyDatas!,
                        useTracking:self.useTracking,
                        action:self.action
                   )
                   .padding(.top, max(
                                self.marginTop + self.headerOffset
                                + (self.topDatas != nil ? (TopBanner.height - self.marginTop) : 0)
                                , -MonthlyBlock.height ))
                }
            }
        }
        .onReceive(self.infinityScrollModel.$event){evt in
            guard let evt = evt else {return}
            switch evt {
            case .pullCancel :
                if !self.infinityScrollModel.isLoading {
                    if self.reloadDegree >= self.reloadDegreeMax {
                        self.viewModel.reload()
                    }
                }
                withAnimation{
                    self.reloadDegree = 0
                }
            default : do{}
            }
            
        }
        .onReceive(self.infinityScrollModel.$scrollPosition){pos in
            self.headerOffset = min(pos,0)
        }
        .onReceive(self.infinityScrollModel.$pullPosition){ pos in
            if pos < InfinityScrollModel.PULL_RANGE { return }
            withAnimation{
                self.reloadDegree = Double(pos - InfinityScrollModel.PULL_RANGE)
            }
        }
        .onReceive(self.viewModel.$isUpdate){ update in
            if update {
                self.reload()
            }
        }
        .onReceive(dataProvider.$result) { res in
            guard let data = self.loadingBlocks.first(where: { $0.id == res?.id}) else {return}
           
            switch data.dataType {
            case .cwGrid:
                guard let resData = res?.data as? CWGrid else {return data.setBlank()}
                guard let grid = resData.grid else {return data.setBlank()}
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
                
                
            case .bookMark:
                guard let resData = res?.data as? BookMark else {return data.setBlank()}
                guard let blocks = resData.bookmarkList else {return data.setBlank()}
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
                guard let blocks = resData.watchList else {return data.setBlank()}
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
            data.setDatabindingCompleted()
            ComponentLog.d("Remote " + data.name, tag: "BlockProtocol")
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
    
    @State var originBlocks:Array<BlockData> = []
    @State var loadingBlocks:[BlockData] = []
    @State var blocks:[BlockData] = []
    @State var anyCancellable = Set<AnyCancellable>()
    
    func reload(){
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
        self.blocks = []
        self.infinityScrollModel.reload()
        self.originBlocks = viewModel.datas ?? []
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
        //self.blocks.append(contentsOf: self.loadingBlocks)
        //self.loadingBlocks = []
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
            //self.blocks.append(contentsOf: self.loadingBlocks)
            //self.loadingBlocks = []
            self.addBlock()
        }
    }
    
    
    private func addBlock(){
        var max = 0
        if  #available(iOS 14.0, *) {
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
        PageLog.d("addBlock" + set.debugDescription, tag: "BlockProtocol")
        if set.isEmpty { return }
        self.requestNum = set.count
        /*
        self.loadingBlocks.append(contentsOf: set)
        self.loadingBlocks.forEach{ s in
            if let apiQ = s.getRequestApi() {
                dataProvider.requestData(q: apiQ)
            }
        }
        */
        self.blocks.append(contentsOf: set)
    }
    
    private func removeBlock(_ block:BlockData){
        if let find = self.blocks.firstIndex(of: block) {
            self.blocks.remove(at: find)
            return
        }
    }
    
}

