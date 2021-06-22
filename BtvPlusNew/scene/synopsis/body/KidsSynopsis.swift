//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI
extension KidsSynopsis {
    static let topHeight:CGFloat = SystemEnvironment.isTablet ? 252 : 99
    static let bottomHeight:CGFloat = SystemEnvironment.isTablet ? 164 : 70
    static let listWidth:CGFloat = SystemEnvironment.isTablet ? 243 : 150
    
    static let playerSize:CGSize = SystemEnvironment.isTablet ? CGSize(width: 705, height: 394) : CGSize(width: 368, height: 206)
}

struct KidsSynopsis: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    
    var geometry:GeometryProxy
    var pageObservable:PageObservable = PageObservable()
    var pageDragingModel:PageDragingModel
    
    var synopsisData:SynopsisData?
    var synopsisModel:SynopsisModel?
    var componentViewModel:PageSynopsis.ComponentViewModel
    
    var playerModel: BtvPlayerModel
    var playerListViewModel:InfinityScrollModel
    var prerollModel:PrerollModel
    var playListData:PlayListData
    
    var peopleScrollModel: InfinityScrollModel
    var episodeViewerData:EpisodeViewerData?
    var purchasViewerData:PurchaseViewerData?
    var summaryViewerData:SummaryViewerData?
    
    var tabNavigationModel:NavigationModel
    var relationBodyModel: InfinityScrollModel
    var relationContentsModel:RelationContentsModel
    var relationTab:[NavigationButton]
    var relationDatas:[PosterDataSet]
    var hasRelationVod:Bool?
    
    var title:String?
    var imgBg:String?
    var imgContentMode:ContentMode
    var textInfo:String?
    var hasAuthority:Bool?
    var isPlayAble:Bool
    var progressError:Bool
    
    var isPairing:Bool?
    var isPlayViewActive:Bool
    var isFullScreen:Bool
    var isUiActive:Bool
    var isUIView:Bool
    var sceneOrientation: SceneOrientation
    
    @Binding var isBookmark:Bool?
    @Binding var seris:[SerisData]
  
    var infinityScrollModel: InfinityScrollModel
    var topIdx:Int
    var useTracking:Bool
    
    var body: some View {
        HStack(alignment: .top, spacing:0){
            if !self.isFullScreen {
                Button(action: {
                    self.pagePresenter.goBack()
                }) {
                    Image(AssetKids.icon.back)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: DimenKids.icon.regularExtra,
                               height: DimenKids.icon.regularExtra)
                }
                .padding(.trailing, DimenKids.margin.light)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            VStack(alignment: .leading,spacing:0){
                if !self.isFullScreen {
                    if let episodeViewerData = self.episodeViewerData, let purchasViewerData = self.purchasViewerData {
                        EpisodeViewerKids(
                            episodeViewerData: episodeViewerData,
                            purchaseViewerData: purchasViewerData)
                            .fixedSize(horizontal: true, vertical: false)
                            .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                    }
                    
                    if SystemEnvironment.isTablet {
                        FunctionViewerKids(
                            componentViewModel: self.componentViewModel,
                            synopsisData: self.synopsisData,
                            summaryViewerData: self.summaryViewerData,
                            isBookmark: self.$isBookmark
                        )
                        .padding(.top, DimenKids.margin.medium)
                        .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel)) 
                    }
                }
                HStack{
                    ZStack {
                        KidsPlayer(
                            pageObservable:self.pageObservable,
                            viewModel:self.playerModel,
                            prerollModel:self.prerollModel,
                            listViewModel: self.playerListViewModel,
                            playGradeData: self.synopsisModel?.playGradeData,
                            title: self.title,
                            thumbImage: self.imgBg,
                            thumbContentMode: self.imgContentMode,
                            contentID:self.synopsisData?.epsdId,
                            listData: self.playListData
                        )
                        if !self.isPlayAble {
                            PlayViewerKids(
                                pageObservable:self.pageObservable,
                                title: self.title,
                                textInfo: self.textInfo,
                                imgBg: self.isPlayViewActive ? self.imgBg : nil,
                                contentMode: self.imgContentMode,
                                isActive: self.isPlayViewActive
                            )
                            
                        }
                    }
                    .modifier(Ratio16_9(
                                geometry:  self.isFullScreen ? geometry : nil,
                                width:Self.playerSize.width,
                                isFullScreen: self.isFullScreen))
                    .clipShape(RoundedRectangle(cornerRadius: self.isFullScreen ? 0 : DimenKids.radius.heavy))
                    .overlay(
                        RoundedRectangle(cornerRadius: self.isFullScreen ? 0 : DimenKids.radius.heavy)
                            .stroke(Color.app.ivoryDeep,
                                    lineWidth: self.isFullScreen ? 0 : DimenKids.stroke.heavy)
                    )
                    if !SystemEnvironment.isTablet && !self.isFullScreen{
                        FunctionViewerKids(
                            componentViewModel: self.componentViewModel,
                            synopsisData: self.synopsisData,
                            summaryViewerData: self.summaryViewerData,
                            isBookmark: self.$isBookmark
                        )
                        .modifier(KidsContentHorizontalEdges())
                        .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                    }
                }
                .padding(.top, self.isFullScreen
                            ? 0
                            : (SystemEnvironment.isTablet ?  DimenKids.margin.regularExtra : DimenKids.margin.medium ) )
            } // vstack
            
            if self.sceneOrientation == .landscape && !self.isFullScreen {
                 if let hasRelationVod = self.hasRelationVod {
                     RelationVodBody(
                         componentViewModel: self.componentViewModel,
                         infinityScrollModel: self.relationBodyModel,
                         relationContentsModel: self.relationContentsModel,
                         tabNavigationModel: self.tabNavigationModel,
                         seris: self.$seris,
                         synopsisData: self.synopsisData,
                         relationTab: self.relationTab,
                         relationDatas: self.relationDatas,
                         hasRelationVod: hasRelationVod,
                         screenSize : Self.listWidth
                         )
                         .frame(width: Self.listWidth)
                         .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                 } else {
                     Spacer()
                         .frame(width: Self.listWidth)
                         .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                 }
            }
        }
        .padding(.top,self.isFullScreen ? 0 : DimenKids.margin.mediumExtra)
        .modifier(MatchParent())
        .background(
            Image(AssetKids.image.synopsisBg)
                .renderingMode(.original)
                .resizable()
                .scaledToFill()
                .modifier(MatchParent())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
        )
        
        .onReceive(self.sceneObserver.$isUpdated){ _ in
            
        }
        .onAppear{
            
        }
    }//body
}





