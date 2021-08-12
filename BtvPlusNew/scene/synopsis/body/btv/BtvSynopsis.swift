//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI
extension BtvSynopsis {
    static let listWidth:CGFloat = 384
}

struct BtvSynopsis: PageComponent{
    
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
    
    var peopleScrollModel:InfinityScrollModel
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
    var epsdId:String?
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
    @Binding var isLike:LikeStatus?
    var isRecommand:Bool?
    @Binding var seris:[SerisData]
  
    var infinityScrollModel: InfinityScrollModel
    var topIdx:Int
    var useTracking:Bool
    
    var uiType:PageSynopsis.UiType
    var dragOpacity: Double
    
    @State var playerWidth: CGFloat = 0
   
    var body: some View {
        HStack( spacing:0){
            VStack(spacing:0){
                HStack(spacing:0){
                    SynopsisTop(
                        geometry: self.geometry,
                        pageObservable: self.pageObservable,
                        pageDragingModel: self.pageDragingModel,
                        playerModel: self.playerModel,
                        playerListViewModel: self.playerListViewModel,
                        prerollModel: self.prerollModel,
                        playGradeData: self.synopsisModel?.playGradeData,
                        title: self.title,
                        epsdId: self.epsdId,
                        imgBg: self.imgBg,
                        imgContentMode: self.imgContentMode,
                        textInfo: self.textInfo,
                        playListData: self.playListData,
                        isPlayAble: self.isPlayAble,
                        isPlayViewActive: self.isPlayViewActive,
                        uiType: self.uiType
                        )
                        .modifier(Ratio16_9(
                                    geometry:  (self.isFullScreen && self.uiType == .normal) ? geometry : nil,
                                    width:self.uiType == .normal ? self.playerWidth : Dimen.app.layerPlayerSize.width,
                                    isFullScreen: self.isFullScreen))
                        .padding(.top, (self.isFullScreen || self.uiType == .simple) ? 0 : self.sceneObserver.safeAreaTop)
                    if self.uiType == .simple {
                        VStack(alignment: .leading, spacing: Dimen.margin.thin){
                            if let episodeViewerData = self.episodeViewerData {
                                Text(episodeViewerData.episodeTitle)
                                    .modifier(BoldTextStyle( size: Font.size.regular ))
                                    .lineLimit(1)
                                    .modifier(ContentHorizontalEdges())
                                EpisodeViewer(data:episodeViewerData, isSimple:true)
                            }
                        }
                        .modifier(MatchHorizontal(height: Dimen.app.layerPlayerSize.height))
                        .background(Color.app.blueLight)
                        .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                    }
                }
                if !self.isFullScreen {
                    if self.isUIView && self.isUiActive && !self.progressError {
                        SynopsisBody(
                            componentViewModel: self.componentViewModel,
                            infinityScrollModel: self.infinityScrollModel,
                            relationContentsModel: self.relationContentsModel,
                            peopleScrollModel: self.peopleScrollModel,
                            pageDragingModel: self.pageDragingModel,
                            tabNavigationModel: self.tabNavigationModel,
                            isBookmark: self.$isBookmark,
                            isLike: self.$isLike,
                            isRecommand: self.isRecommand,
                            seris: self.$seris,
                            topIdx : self.topIdx,
                            synopsisData: self.synopsisData,
                            synopsisModel: self.synopsisModel,
                            isPairing: self.isPairing,
                            episodeViewerData: self.episodeViewerData,
                            purchasViewerData: self.purchasViewerData,
                            summaryViewerData: self.summaryViewerData,
                            epsdId: self.epsdId,
                            hasAuthority: self.hasAuthority,
                            relationTab: self.relationTab,
                            relationDatas: self.relationDatas,
                            hasRelationVod: self.sceneOrientation == .portrait ? self.hasRelationVod : nil,
                            useTracking:self.useTracking,
                            funtionLayout : (self.sceneOrientation == .portrait && SystemEnvironment.isTablet)
                                ? .horizontal : .vertical
                            )
                            .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                            .opacity(self.dragOpacity)
                        
                    } else {
                        ZStack{
                            if self.progressError {
                                EmptyAlert(text: self.synopsisData == nil ? String.alert.dataError : String.alert.apiErrorServer)
                                    
                            } else {
                                Spacer().modifier(MatchParent())
                            }
                        }
                        .modifier(MatchParent())
                        .background(Color.brand.bg)
                        .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                        .opacity(self.dragOpacity)
                    }
                }
            } // vstack
            
            if self.sceneOrientation == .landscape && !self.isFullScreen {
                 if let hasRelationVod = self.hasRelationVod {
                     RelationVodBody(
                         componentViewModel: self.componentViewModel,
                         infinityScrollModel: self.relationBodyModel,
                         relationContentsModel: self.relationContentsModel,
                         tabNavigationModel: self.tabNavigationModel,
                         seris: self.$seris,
                         epsdId: self.epsdId,
                         relationTab: self.relationTab,
                         relationDatas: self.relationDatas,
                         hasRelationVod: hasRelationVod,
                         screenSize : Self.listWidth
                         )
                         .frame(width: Self.listWidth)
                         .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                         .opacity(self.dragOpacity)
                 } else {
                     Spacer()
                         .frame(width: Self.listWidth)
                         .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                         .opacity(self.dragOpacity)
                 }
            }
        }
        .modifier(MatchParent())
        .onReceive(self.sceneObserver.$isUpdated){ _ in
            self.playerWidth = self.sceneObserver.sceneOrientation == .landscape
                ? geometry.size.width - Self.listWidth
                : geometry.size.width
        }
        .onAppear{
            self.playerWidth = self.sceneObserver.sceneOrientation == .landscape
                ? geometry.size.width - Self.listWidth
                : geometry.size.width
        }
    }//body
}



 

