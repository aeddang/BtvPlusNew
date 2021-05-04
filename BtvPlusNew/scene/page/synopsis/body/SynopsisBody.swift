//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI

extension SynopsisBody {
    static let spacing:CGFloat = SystemEnvironment.isTablet ? Dimen.margin.regularExtra : Dimen.margin.regular
}

struct SynopsisBody: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var componentViewModel:PageSynopsis.ComponentViewModel
    var infinityScrollModel: InfinityScrollModel
    var relationContentsModel:RelationContentsModel
    var peopleScrollModel: InfinityScrollModel
    var pageDragingModel:PageDragingModel
    var tabNavigationModel:NavigationModel
    @Binding var isBookmark:Bool?
    @Binding var isLike:LikeStatus?
    @Binding var seris:[SerisData]
  
    var topIdx:Int = UUID.init().hashValue
    var synopsisData:SynopsisData? = nil
    var isPairing:Bool? = nil
    var episodeViewerData:EpisodeViewerData? = nil
    var purchasViewerData:PurchaseViewerData? = nil
    var summaryViewerData:SummaryViewerData? = nil
    var srisId:String? = nil
    var epsdId:String? = nil
    var hasAuthority:Bool? = nil

    var relationTab:[NavigationButton] = []
    var relationDatas:[PosterDataSet] = []
    var hasRelationVod:Bool? = nil
    var useTracking:Bool = false
    var funtionLayout:Axis = .vertical
    
    private var usePullTracking:Bool
    {
        get{
            if #available(iOS 14.0, *) { return self.useTracking }
            else {return false}
        }
    }
    var headerSize:Int = 0
   
    var body: some View {
        InfinityScrollView(
            viewModel: self.infinityScrollModel,
            marginTop : 0,
            marginBottom : self.sceneObserver.safeAreaBottom,
            spacing:0,
            isRecycle:true,
            useTracking:false
            ){
            if #available(iOS 14.0, *) {
                Spacer().modifier(MatchHorizontal(height: 1)).background(Color.transparent.clearUi)
                    .id(self.topIdx)
                    .modifier(ListRowInset(spacing: Self.spacing))
                
                if let episodeViewerData = self.episodeViewerData {
                    Text(episodeViewerData.episodeTitle)
                        .modifier(BoldTextStyle( size: Font.size.boldExtra ))
                        .lineLimit(2)
                        .modifier(ContentHorizontalEdges())
                        .modifier(ListRowInset(spacing: SystemEnvironment.isTablet ? Dimen.margin.thinExtra : Dimen.margin.lightExtra))
                    if self.funtionLayout == .horizontal {
                        HStack(alignment:.top , spacing:0){
                            EpisodeViewer(data:episodeViewerData)
                            Spacer()
                            FunctionViewer(
                                synopsisData :self.synopsisData,
                                srisId: self.srisId,
                                epsdId:self.epsdId,
                                isBookmark: self.$isBookmark,
                                isLike: self.$isLike
                            )
                        }
                        .modifier(ListRowInset(spacing: Self.spacing))
                    } else {
                        EpisodeViewer(data:episodeViewerData)
                            .modifier(ListRowInset(spacing: Self.spacing))
                        HStack(spacing:0){
                            FunctionViewer(
                                synopsisData :self.synopsisData,
                                srisId: self.srisId,
                                epsdId:self.epsdId,
                                isBookmark: self.$isBookmark,
                                isLike: self.$isLike
                            )
                            Spacer()
                        }
                        .modifier(ListRowInset(spacing: Self.spacing))
                    }
                }
                
                if self.hasAuthority != nil && self.purchasViewerData != nil {
                    PurchaseViewer(
                        componentViewModel: self.componentViewModel,
                        data:self.purchasViewerData! )
                        .modifier(ListRowInset(spacing: Self.spacing))
                }
                if self.hasAuthority == false && self.isPairing == false {
                    FillButton(
                        text: String.button.connectBtv
                    ){_ in
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.pairing)
                        )
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: Self.spacing))
                }
                
                if self.summaryViewerData != nil {
                    SummaryViewer(
                        peopleScrollModel:self.peopleScrollModel,
                        data: self.summaryViewerData!,
                        useTracking: self.usePullTracking,
                        isSimple: self.hasRelationVod == nil ? true : false
                    )
                    .modifier(ListRowInset(spacing: Self.spacing))
                }
                if let hasRelationVod = self.hasRelationVod {
                    RelationVodList(
                        componentViewModel: self.componentViewModel,
                        relationContentsModel: self.relationContentsModel,
                        tabNavigationModel: self.tabNavigationModel,
                        seris: self.$seris,
                        synopsisData: self.synopsisData,
                        relationTab: self.relationTab,
                        relationDatas: self.relationDatas,
                        hasRelationVod: hasRelationVod,
                        screenSize: self.sceneObserver.screenSize.width
                        )
                }
                
            } else {
                //IOS 13
                VStack(alignment:.leading , spacing:Self.spacing){
                    if let episodeViewerData = self.episodeViewerData {
                        Text(episodeViewerData.episodeTitle)
                            .modifier(BoldTextStyle( size: Font.size.boldExtra ))
                            .lineLimit(2)
                            .modifier(ContentHorizontalEdges())
                            
                        if self.funtionLayout == .horizontal {
                            HStack(alignment:.top , spacing:0){
                                EpisodeViewer(data:episodeViewerData)
                                Spacer()
                                FunctionViewer(
                                    synopsisData :self.synopsisData,
                                    srisId: self.srisId,
                                    epsdId:self.epsdId,
                                    isBookmark: self.$isBookmark,
                                    isLike: self.$isLike
                                )
                            }
                            
                        } else {
                            EpisodeViewer(data:episodeViewerData)
                            HStack(spacing:0){
                                FunctionViewer(
                                    synopsisData :self.synopsisData,
                                    srisId: self.srisId,
                                    epsdId:self.epsdId,
                                    isBookmark: self.$isBookmark,
                                    isLike: self.$isLike
                                )
                                Spacer()
                            }
                        }
                    }
                    
                    if self.hasAuthority != nil && self.purchasViewerData != nil {
                        PurchaseViewer(
                            componentViewModel: self.componentViewModel,
                            data:self.purchasViewerData! )
                    }
                    if self.hasAuthority == false && self.isPairing == false {
                        FillButton(
                            text: String.button.connectBtv
                        ){_ in
                            self.pagePresenter.openPopup(
                                PageProvider.getPageObject(.pairing)
                            )
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .modifier(ContentHorizontalEdges())
                    }
                    
                    if self.summaryViewerData != nil {
                        SummaryViewer(
                            peopleScrollModel:self.peopleScrollModel,
                            data: self.summaryViewerData!,
                            useTracking: self.usePullTracking
                        )
                    }
                }
                .modifier(ListRowInset(index:1, spacing: Self.spacing, marginTop:Self.spacing))
                
                if let hasRelationVod = self.hasRelationVod {
                    RelationVodList(
                        componentViewModel: self.componentViewModel,
                        relationContentsModel: self.relationContentsModel,
                        tabNavigationModel: self.tabNavigationModel,
                        seris: self.$seris,
                        synopsisData: self.synopsisData,
                        relationTab: self.relationTab,
                        relationDatas: self.relationDatas,
                        hasRelationVod: hasRelationVod,
                        screenSize: self.sceneObserver.screenSize.width
                        )
                }
            }
        }
        
    }//body
   
}


