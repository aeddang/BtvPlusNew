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
    
    @State var playerWidth: CGFloat = 0
   
    var body: some View {
        HStack(spacing:0){
            VStack(spacing:0){
                if let episodeViewerData = self.episodeViewerData {
                    EpisodeViewerKids(
                        data: episodeViewerData,
                        purchaseViewerData: self.purchasViewerData) 
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
                                width:self.playerWidth,
                                isFullScreen: self.isFullScreen))
                    FunctionViewerKids(
                        componentViewModel: self.componentViewModel,
                        isBookmark: self.$isBookmark
                    )
                
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





