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
    @Binding var seris:[SerisData]
  
    var infinityScrollModel: InfinityScrollModel
    var topIdx:Int
    var useTracking:Bool
    
    @State var playerWidth: CGFloat = 0
   
    var body: some View {
        HStack(spacing:0){
            VStack(spacing:0){
                SynopsisTop(
                    pageObservable: self.pageObservable,
                    playerModel: self.playerModel,
                    playerListViewModel: self.playerListViewModel,
                    prerollModel: self.prerollModel,
                    playGradeData: self.synopsisModel?.playGradeData,
                    title: self.title,
                    imgBg: self.imgBg,
                    imgContentMode: self.imgContentMode,
                    textInfo: self.textInfo,
                    epsdId: self.synopsisData?.epsdId,
                    playListData: self.playListData,
                    isPlayAble: self.isPlayAble,
                    isPlayViewActive: self.isPlayViewActive)
                    .modifier(Ratio16_9(
                                geometry:  self.isFullScreen ? geometry : nil,
                                width:self.playerWidth,
                                isFullScreen: self.isFullScreen))
                    .padding(.top, self.isFullScreen ? 0 : self.sceneObserver.safeAreaTop)
                
               
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
                            seris: self.$seris,
                            topIdx : self.topIdx,
                            synopsisData: self.synopsisData,
                            isPairing: self.isPairing,
                            episodeViewerData: self.episodeViewerData,
                            purchasViewerData: self.purchasViewerData,
                            summaryViewerData: self.summaryViewerData,
                            hasAuthority: self.hasAuthority,
                            relationTab: self.relationTab,
                            relationDatas: self.relationDatas,
                            hasRelationVod: self.sceneOrientation == .portrait ? self.hasRelationVod : nil,
                            useTracking:self.useTracking,
                            funtionLayout : (self.sceneOrientation == .portrait && SystemEnvironment.isTablet)
                                ? .horizontal : .vertical
                            )
                           
                            .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                            
                        
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



 

