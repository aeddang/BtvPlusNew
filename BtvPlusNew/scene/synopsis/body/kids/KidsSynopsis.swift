//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI
extension KidsSynopsis {
    static let topHeight:CGFloat = SystemEnvironment.isTablet ? 192 : 40
    static let bottomHeight:CGFloat = DimenKids.button.mediumRect.height
    static let listWidth:CGFloat = SystemEnvironment.isTablet ? 260 : 150
    static let playerAreaWidth:CGFloat = SystemEnvironment.isTablet ? 705 : 440
    static let playerSize:CGSize = SystemEnvironment.isTablet ? CGSize(width: 705, height: 394) : CGSize(width: 368, height: 206)
    
    func getPlayerAreaWidth(sceneObserver:PageSceneObserver) -> CGFloat {
        let h = sceneObserver.screenSize.height
            - Self.topHeight - Self.bottomHeight
            - (DimenKids.margin.regularExtra * 2) - DimenKids.margin.thin
            - (sceneObserver.safeAreaTop + sceneObserver.safeAreaBottom)
        
        let limitW = sceneObserver.screenSize.width
            - Self.listWidth - DimenKids.icon.regularExtra
            - (DimenKids.margin.regularExtra * 2) - DimenKids.margin.thin
            - (sceneObserver.safeAreaStart + sceneObserver.safeAreaEnd)
        
        let idealW = floor(h * 16 / 9)
        
        return min(limitW,idealW)
    }
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
    @Binding var seris:[SerisData]
  
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
                .padding(.top,self.isFullScreen ? 0 : DimenKids.margin.mediumExtra)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            VStack(alignment: .leading,spacing:0){
                if !self.isFullScreen {
                    VStack(alignment: .leading,spacing:0){
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
                    .frame(height:Self.topHeight)
                }
                HStack(alignment: .center){
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
                            contentID: self.epsdId,
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
                                width:getPlayerAreaWidth(sceneObserver: self.sceneObserver),
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
                        .padding(.horizontal, DimenKids.margin.regular)
                        .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                    }
                }
                .padding(.top, self.isFullScreen
                            ? 0
                            : (SystemEnvironment.isTablet ?  DimenKids.margin.regularExtra : DimenKids.margin.medium ) )
                
                if !self.isFullScreen{
                    if self.hasAuthority != nil, let purchasViewerData = self.purchasViewerData {
                        PurchaseViewerKids(
                            componentViewModel: self.componentViewModel,
                            data: purchasViewerData)
                            .padding(.top, DimenKids.margin.regularExtra)
                            .padding(.trailing, DimenKids.margin.regular)
                            .frame(width: Self.playerAreaWidth)
                            .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                        
                    } else {
                        Spacer()
                            .modifier(MatchParent())
                    }
                }
            } // vstack
            .padding(.top,self.isFullScreen ? 0 : DimenKids.margin.mediumExtra)
            if self.sceneOrientation == .landscape && !self.isFullScreen {
                HStack(alignment: .top, spacing:0){
                    Spacer()
                        .modifier(MatchParent())
                    if let hasRelationVod = self.hasRelationVod {
                        if hasRelationVod {
                             RelationVodBodyKids(
                                 componentViewModel: self.componentViewModel,
                                 infinityScrollModel: self.relationBodyModel,
                                 relationContentsModel: self.relationContentsModel,
                                 seris: self.$seris,
                                 epsdId: self.epsdId,
                                 relationDatas: self.relationDatas,
                                 screenSize : Self.listWidth)
                                .frame(width: Self.listWidth)
                                .background(Color.app.white)
                        } else{
                            RelationVodEmpty()
                                .frame(width: Self.listWidth)
                                .background(Color.app.white)
                        }
                    }
                }
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
        }
        
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





