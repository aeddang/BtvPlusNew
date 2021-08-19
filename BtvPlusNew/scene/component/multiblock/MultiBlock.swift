//
//  MultiBlack.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI

class BlockDataSet:Identifiable {
    private(set) var id = UUID().uuidString
    var datas:[BlockData] = []
    var index:Int = -1
}

extension MultiBlock{
    static let spacing:CGFloat = SystemEnvironment.isTablet ? Dimen.margin.regularExtra : Dimen.margin.medium
    static let headerSize:Int = 5
    static let headerSizeMin:Int = 3
}
struct MultiBlock:PageComponent {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var viewModel:MultiBlockModel = MultiBlockModel()
    var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var viewPagerModel:ViewPagerModel = ViewPagerModel()
    var pageObservable:PageObservable = PageObservable()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var topDatas:[BannerData]? = nil
    var datas:[BlockData] = []
    var useBodyTracking:Bool = false
    var useTracking:Bool = false
    var marginHeader : CGFloat = 0
    var marginTop : CGFloat = 0
    var marginBottom : CGFloat = 0
    var marginHorizontal : CGFloat = 0
    var monthlyViewModel: MonthlyBlockModel? = nil
    var monthlyDatas:[MonthlyData]? = nil
    var monthlyAllData:BlockItem? = nil
    var tipBlock:TipBlockData? = nil
    var header:PageViewProtocol? = nil
    var headerSize: CGFloat = 0
    var useFooter:Bool = false
    var isHorizontal:Bool = false
    var isRecycle = true
    var isLegacy:Bool = false

    var action: ((_ data:MonthlyData) -> Void)? = nil

    @State var topBanner:TopBanner?
    private func getTopBanner() -> TopBanner {
        if let top = self.topBanner {
           // ComponentLog.d("Recycle Top", tag: self.tag + "Top")
            return top
        }
        let newTop = TopBanner(
            pageObservable: self.pageObservable,
            viewModel:self.viewPagerModel,
            infinityScrollModel:self.infinityScrollModel,
            datas: self.topDatas ?? []
        )
        ComponentLog.d("New Top" , tag: self.tag + "Top")
        DispatchQueue.main.async {
            self.topBanner = newTop
        }
        return newTop
    }
    
    @State var topBannerBg:TopBannerBg?
    private func getTopBannerBg() -> TopBannerBg {
        if let top = self.topBannerBg {
           // ComponentLog.d("Recycle TopBg", tag: self.tag + "Top")
            return top
        }
        let newTop = TopBannerBg(
            pageObservable : self.pageObservable,
            viewModel:self.viewPagerModel,
            datas: self.topDatas! )
        ComponentLog.d("New TopBg" , tag: self.tag + "Top")
        DispatchQueue.main.async {
            self.topBannerBg = newTop
        }
        return newTop
    }
    
   
    
    @State var headerBlock:HeaderBlockCell?
    @State var headerCount:Int = 0
    @State var headerId:String = ""
    @discardableResult
    private func getHeaderBlock() -> HeaderBlockCell{
        let count = min((self.topDatas?.isEmpty == false ? Self.headerSizeMin : Self.headerSize), self.datas.count)
        var key:String = self.datas[0..<count].reduce("", {$0 + "|" + ($1.menuId ?? "")}) 
        key = key + (self.tipBlock?.id ?? "")
        if key == self.headerId, let header = self.headerBlock {
            //ComponentLog.d("Recycle Header " + key , tag: self.tag + "Header")
            DispatchQueue.main.async {
                self.headerCount = count
            }
            return header
        }
        
        let newHeader =
            HeaderBlockCell(
                pageObservable: self.pageObservable,
                pageDragingModel: self.pageDragingModel,
                tipBlock: self.tipBlock,
                datas: self.datas[0..<count],
                useTracking:self.useTracking
            )
        ComponentLog.d("New Header " + key , tag: self.tag + "Header")
        DispatchQueue.main.async {
            self.headerId = key
            self.headerCount = count
            self.headerBlock = newHeader
        }

        return newHeader
    }
    var body :some View {
        if !self.isLegacy  { //#
            InfinityScrollView(
                viewModel: self.infinityScrollModel,
                axes: .vertical,
                scrollType : .reload(isDragEnd: false),
                header : self.header,
                headerSize : self.headerSize,
                marginTop : self.marginTop,
                marginBottom : self.marginBottom,
                marginHorizontal: self.marginHorizontal,
                spacing: 0,
                isRecycle : self.isRecycle,
                useTracking:self.useBodyTracking){
                
                if let topDatas = self.topDatas ,!topDatas.isEmpty {
                    self.getTopBanner()
                        .modifier(MatchHorizontal(height: isHorizontal ? TopBanner.uiRangeHorizontal : TopBanner.uiRange))
                    .modifier(ListRowInset(spacing: isHorizontal
                                            ? TopBanner.heightHorizontal - self.marginTop + self.marginHeader - TopBanner.uiRangeHorizontal
                                            : TopBanner.height - self.marginTop + self.marginHeader - TopBanner.uiRange
                    ))
                }
                
                if let datas = self.monthlyDatas  {
                   MonthlyBlock(
                        viewModel:self.monthlyViewModel ?? MonthlyBlockModel(),
                        pageDragingModel:self.pageDragingModel,
                        monthlyDatas:datas,
                        allData: self.monthlyAllData,
                        useTracking:self.useTracking
                   ){ data in
                        self.headerCount = 999
                        self.action?(data)
                   }
                   .modifier(MatchHorizontal(height:  MonthlyBlock.height))
                   .modifier(ListRowInset(spacing: Self.spacing))
                }
                
                if !self.datas.isEmpty {
                    if self.viewModel.type == .btv {
                        if let headerBlock = self.getHeaderBlock() {
                            headerBlock
                            if headerCount < self.datas.count {
                                ForEach( self.datas[headerCount..<self.datas.count]) { data in
                                    MultiBlockCell(
                                        pageObservable:self.pageObservable,
                                        pageDragingModel: self.pageDragingModel,
                                        data: data ,
                                        useTracking: self.useTracking)
                                        .modifier(ListRowInset(spacing: Self.spacing))
                                        .onAppear(){
                                            if data.index == self.datas.last?.index {
                                                self.infinityScrollModel.event = .bottom
                                            }
                                        }
                                }
                            }
                            if self.useFooter {
                                Footer()
                                    .modifier(ListRowInset(spacing: Dimen.margin.regular))
                            }
                        }
                    } else {
                        ForEach( self.datas) { data in
                            MultiBlockCell(
                                pageObservable:self.pageObservable,
                                pageDragingModel: self.pageDragingModel,
                                data: data ,
                                useTracking: self.useTracking)
                                .modifier(ListRowInset(spacing: Self.spacing))
                                .onAppear(){
                                    if data.index == self.datas.last?.index {
                                        self.infinityScrollModel.event = .bottom
                                    }
                                }
                        }
                    }
                }
            }
            .onAppear(){
                
            }
            .onReceive(self.viewModel.$isUpdate){ update in
                
                //if update { self.getHeaderBlock() }
            }
            
        } else {
            InfinityScrollView(
                viewModel: self.infinityScrollModel,
                axes: .vertical,
                scrollType : .reload(isDragEnd: false),
                header : self.header,
                headerSize : self.headerSize,
                marginTop : 0,
                marginBottom : self.marginBottom + self.sceneObserver.safeAreaBottom,
                marginHorizontal: self.marginHorizontal,
                spacing: 0,
                isRecycle : self.isRecycle,
                useTracking:self.useBodyTracking){
                
                VStack(spacing: Self.spacing){
                    if self.topDatas != nil  && self.topDatas?.isEmpty == false {
                        ZStack{
                            self.getTopBannerBg()
                                .offset(y:(TopBanner.imageHeight - TopBanner.height)/2)
                            self.getTopBanner()
                        }
                        .modifier(MatchHorizontal(height: TopBanner.height))
                        .clipped()
                        .padding(.top, self.marginHeader)
                       
                    } else if self.monthlyDatas != nil {
                        MonthlyBlock(
                             viewModel:self.monthlyViewModel ?? MonthlyBlockModel(),
                             pageDragingModel:self.pageDragingModel,
                             monthlyDatas:self.monthlyDatas!,
                             useTracking:self.useTracking,
                             action:self.action
                        )
                        .padding(.top, self.marginTop)
                        .padding(.bottom, Self.spacing)
                        
                    } else {
                        Spacer().modifier(MatchHorizontal(height: self.marginTop))
                    }
                }
                .modifier(ListRowInset(spacing: 0))
                
                if !self.datas.isEmpty {
                    ForEach(self.datas, id: \.id) { data in
                        MultiBlockCell(
                            pageObservable:self.pageObservable,
                            pageDragingModel: self.pageDragingModel,
                            data: data ,
                            useTracking: self.useTracking)
                            .modifier(ListRowInset(spacing: Self.spacing))
                            .onAppear(){
                                if data.index == self.datas.last?.index  {
                                    self.infinityScrollModel.event = .bottom
                                }
                                //self.infinityScrollModel.onAppear(idx: data.index + 2)
                            }
                            .onDisappear(){
                                //self.infinityScrollModel.onDisappear(idx: data.index + 2)
                            }
                    }
                    if self.useFooter {
                        Footer()
                            .modifier(ListRowInset(spacing: Dimen.margin.regular))
                    }
                } else {
                    Spacer().modifier(MatchParent())
                        .modifier(ListRowInset(spacing: 0))
                }
            }
        }
    }
    
    
    struct HeaderBlockCell:PageComponent {
        var pageObservable:PageObservable
        var pageDragingModel:PageDragingModel
        var tipBlock:TipBlockData? = nil
        var datas:ArraySlice<BlockData>
        var useTracking:Bool = false
        var body :some View {
            VStack(spacing:MultiBlock.spacing){
                if let data = self.tipBlock {
                    TipBlock(data:data)
                        .modifier(MatchHorizontal(height:  Dimen.tab.light))
                }
                ForEach( self.datas ) { data in
                    MultiBlockCell(
                        pageObservable:self.pageObservable,
                        pageDragingModel: self.pageDragingModel,
                        data: data,
                        useTracking: self.useTracking)
                }
            }
            .modifier(ListRowInset(spacing: MultiBlock.spacing))
            
        }//body
    }
    
}


struct MultiBlockCell:PageComponent {
    
    var pageObservable:PageObservable
    var pageDragingModel:PageDragingModel
    var data:BlockData
    var useTracking:Bool = false
    var body :some View {
        
        switch data.uiType {
        case .poster :
            if data.pageType == .kids {
                PosterBlockKids(
                    pageObservable:self.pageObservable,
                    pageDragingModel:self.pageDragingModel,
                    data: data,
                    useTracking:self.useTracking
                    )
                .frame(height:data.listHeight)
                
            } else {
                PosterBlock(
                    pageObservable:self.pageObservable,
                    pageDragingModel:self.pageDragingModel,
                    data: data,
                    useTracking:self.useTracking
                    )
                .frame(height:data.listHeight)
            }
            
        case .video :
            if data.pageType == .kids {
                VideoBlockKids(
                    pageObservable:self.pageObservable,
                    pageDragingModel:self.pageDragingModel,
                    data: data,
                    useTracking:self.useTracking
                    )
                .frame(height:data.listHeight)
               
            } else {
                VideoBlock(
                    pageObservable:self.pageObservable,
                    pageDragingModel:self.pageDragingModel,
                    data: data,
                    useTracking:self.useTracking
                    )
                .frame(height:data.listHeight)
            }
            
        case .theme :
            ThemaBlock(
                pageObservable:self.pageObservable,
                pageDragingModel:self.pageDragingModel,
                data: data,
                useTracking:self.useTracking
                )
            .frame(height:data.listHeight)
            
        case .tv :
            TvBlock(
                pageObservable:self.pageObservable,
                pageDragingModel:self.pageDragingModel,
                data: data,
                useTracking:self.useTracking
            )
            .frame(height:data.listHeight)
            
        case .banner :
            BannerBlock(
                pageObservable:self.pageObservable,
                data: data
            )
            .frame(height:data.listHeight)
        
        case .bannerList :
            BannerListBlock(
                pageObservable:self.pageObservable,
                pageDragingModel:self.pageDragingModel,
                data: data,
                useTracking:self.useTracking
            )
            .frame(height:data.listHeight)
            
        case .ticket :
            TicketBlock(
                pageObservable:self.pageObservable,
                pageDragingModel:self.pageDragingModel,
                data: data,
                useTracking:self.useTracking
            )
            .frame(height:data.listHeight)

        case .kidsHome :
            KidsHomeBlock(
                pageObservable:self.pageObservable,
                pageDragingModel:self.pageDragingModel,
                data: data,
                useTracking:self.useTracking
            )
            .frame(height:data.listHeight)
            
        case .kidsTicket :
            KidsHomeBlock(
                pageObservable:self.pageObservable,
                pageDragingModel:self.pageDragingModel,
                data: data,
                useTracking:false
            )
            .frame(height:data.listHeight)
        }
    }//body
}
