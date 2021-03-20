//
//  MultiBlack.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/21.
//

import Foundation
import SwiftUI

extension MultiBlock{
    static let spacing:CGFloat = Dimen.margin.medium
}
struct MultiBlock:PageComponent {
    @EnvironmentObject var sceneObserver:SceneObserver
    
    var viewModel: InfinityScrollModel = InfinityScrollModel()
    var viewPagerModel:ViewPagerModel = ViewPagerModel()
    var pageObservable:PageObservable = PageObservable()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var topDatas:[BannerData]? = nil
    var datas:[BlockData] = []
    var headerSize:Int = 0
    var useBodyTracking:Bool = false
    var useTracking:Bool = false
    var marginHeader : CGFloat = 0
    var marginTop : CGFloat = 0
    var marginBottom : CGFloat = 0
    var monthlyViewModel: InfinityScrollModel? = nil
    var monthlyDatas:[MonthlyData]? = nil
    var monthlyAllData:BlockItem? = nil
    var useFooter:Bool = false
    var isRecycle = true
    var isLegacy:Bool = false
    var action: ((_ data:MonthlyData) -> Void)? = nil
   
    
    var body :some View {
        if !self.isLegacy  { //#
            InfinityScrollView(
                viewModel: self.viewModel,
                axes: .vertical,
                scrollType : .reload(isDragEnd: false),
                marginTop : self.marginTop,
                marginBottom : self.marginBottom ,
                spacing: 0,
                isRecycle : self.isRecycle,
                useTracking:self.useBodyTracking){
                
                if self.topDatas != nil  && self.topDatas?.isEmpty == false{
                    TopBanner(
                        pageObservable: self.pageObservable,
                        viewModel:self.viewPagerModel,
                        infinityScrollModel:self.viewModel,
                        datas: self.topDatas! )
                        .modifier(MatchHorizontal(height: TopBanner.imageHeight
                                                - self.marginTop
                                                - TopBanner.maginBottomLogo
                                                + self.marginHeader
                        ))
                    .modifier(ListRowInset(spacing: Self.spacing * 2))
                }
                
               
                
                if self.monthlyDatas != nil {
                   MonthlyBlock(
                        viewModel:self.monthlyViewModel ?? InfinityScrollModel(),
                        pageDragingModel:self.pageDragingModel,
                        monthlyDatas:self.monthlyDatas!,
                        allData: self.monthlyAllData,
                        useTracking:self.useTracking,
                        action:self.action
                   )
                   .modifier(ListRowInset(spacing: Self.spacing))
                }
                if !self.datas.isEmpty  {
                    if self.headerSize > 1 {
                        VStack(spacing:Self.spacing){
                            ForEach(self.datas[..<min(self.headerSize, self.datas.count)]) { data in
                                MultiBlockCell(
                                    pageObservable:self.pageObservable,
                                    pageDragingModel: self.pageDragingModel,
                                    data: data ,
                                    useTracking: self.useTracking)
                                    .onAppear(){
                                        if data.index == self.datas.last?.index {
                                            self.viewModel.event = .bottom
                                        }
                                    }
                            }
                        }
                        
                        .modifier(ListRowInset(spacing: Self.spacing))
                        
                        if self.datas.count > self.headerSize {
                            ForEach(self.datas[self.headerSize..<self.datas.count]) { data in
                                MultiBlockCell(
                                    pageObservable:self.pageObservable,
                                    pageDragingModel: self.pageDragingModel,
                                    data: data ,
                                    useTracking: self.useTracking)
                                    .modifier(ListRowInset(spacing: Self.spacing))
                                    .onAppear(){
                                        if data.index == self.datas.last?.index {
                                            self.viewModel.event = .bottom
                                        }
                                    }
                            }
                            
                        }
                    } else {
                        ForEach(self.datas) { data in
                            MultiBlockCell(
                                pageObservable:self.pageObservable,
                                pageDragingModel: self.pageDragingModel,
                                data: data ,
                                useTracking: self.useTracking)
                                .modifier(ListRowInset(spacing: Self.spacing))
                                .onAppear(){
                                    if data.index == self.datas.last?.index {
                                        self.viewModel.event = .bottom
                                    }
                                }
                        }
                    }
                    if self.useFooter {
                        Footer()
                            .modifier(ListRowInset(spacing: 0))
                    }
                }
                
               
            }
            
        } else {
            InfinityScrollView(
                viewModel: self.viewModel,
                axes: .vertical,
                scrollType : .reload(isDragEnd: false),
                marginTop : 0,
                marginBottom : self.marginBottom + self.sceneObserver.safeAreaBottom,
                spacing: 0,
                isRecycle : self.isRecycle,
                useTracking:self.useBodyTracking){
                    
                VStack(spacing: Self.spacing){
                    if self.topDatas != nil  && self.topDatas?.isEmpty == false {
                        ZStack{
                            TopBannerBg(
                                viewModel:self.viewPagerModel,
                                datas: self.topDatas! )
                                .offset(y:(TopBanner.imageHeight - TopBanner.height)/2)
                            TopBanner(
                                pageObservable: self.pageObservable,
                                viewModel:self.viewPagerModel,
                                infinityScrollModel:self.viewModel,
                                datas: self.topDatas! )
                                
                        }
                        .modifier(MatchHorizontal(height: TopBanner.height))
                        .clipped()
                        .padding(.top, self.marginHeader)
                       
                    } else if self.monthlyDatas != nil {
                        MonthlyBlock(
                             viewModel:self.monthlyViewModel ?? InfinityScrollModel(),
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
                    ForEach(self.datas) { data in
                        MultiBlockCell(
                            pageObservable:self.pageObservable,
                            pageDragingModel: self.pageDragingModel,
                            data: data ,
                            useTracking: self.useTracking)
                            .modifier(ListRowInset(spacing: Self.spacing))
                            .onAppear(){
                                if data.index == self.datas.last?.index  {
                                    self.viewModel.event = .bottom
                                }
                            }
                    }
                    if self.useFooter {
                        Footer()
                            .modifier(ListRowInset(spacing: 0))
                    }
                } else {
                    Spacer().modifier(MatchParent())
                        .modifier(ListRowInset(spacing: 0))
                }
               
            }
            
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
                PosterBlock(
                    pageObservable:self.pageObservable,
                    pageDragingModel:self.pageDragingModel,
                    data: data,
                    useTracking:self.useTracking
                    )
            case .video :
                VideoBlock(
                    pageObservable:self.pageObservable,
                    pageDragingModel:self.pageDragingModel,
                    data: data,
                    useTracking:self.useTracking
                    )
            case .theme :
                ThemaBlock(
                    pageObservable:self.pageObservable,
                    pageDragingModel:self.pageDragingModel,
                    data: data,
                    useTracking:self.useTracking
                    )
            case .ticket :
                TicketBlock(
                    pageObservable:self.pageObservable,
                    pageDragingModel:self.pageDragingModel,
                    data: data,
                    useTracking:self.useTracking
                    )
            case .banner :
                BannerBlock(
                    pageObservable:self.pageObservable,
                    data: data)
            
            }
        }//body
    }
}
