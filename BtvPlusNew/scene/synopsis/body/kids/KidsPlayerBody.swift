//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI

struct KidsPlayerBody: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    
    var geometry:GeometryProxy
    var pageObservable:PageObservable 
    var pageDragingModel:PageDragingModel
    
    var synopsisData:SynopsisData?
    var synopsisModel:SynopsisModel?
    var componentViewModel:PageSynopsis.ComponentViewModel
    
    var playerModel:BtvPlayerModel
    var playerListViewModel:InfinityScrollModel
    var prerollModel:PrerollModel
    var playListData:PlayListData
    
    var episodeViewerData:EpisodeViewerData?
    var purchasViewerData:PurchaseViewerData?
    var summaryViewerData:SummaryViewerData?

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
    
    var sceneOrientation: SceneOrientation
    
    @Binding var isBookmark:Bool?
   
    var playerWidth:CGFloat = 0
    var castleHeight:CGFloat = 0
    var body: some View {
        ZStack(alignment: .leading){
            VStack{
                HStack(alignment: .center){
                    ZStack (alignment: .topLeading){
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
                                    viewModel:self.playerModel,
                                    title: self.title,
                                    textInfo: self.textInfo,
                                    imgBg: self.isPlayViewActive ? self.imgBg : nil,
                                    contentMode: self.imgContentMode,
                                    isActive: self.isPlayViewActive
                                )
                                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                                
                            }
                            
                        }
                        .modifier(Ratio16_9(
                                    geometry: self.isFullScreen ? geometry : nil,
                                    width:self.playerWidth,
                                    isFullScreen: self.isFullScreen))
                        .clipShape(RoundedRectangle(cornerRadius: self.isFullScreen ? 0 : DimenKids.radius.heavy))
                        .overlay(
                            RoundedRectangle(cornerRadius: self.isFullScreen ? 0 : DimenKids.radius.heavy)
                                .strokeBorder(Color.app.ivoryDeep,
                                        lineWidth: self.isFullScreen ? 0 : DimenKids.stroke.heavy)
                        )
                        Image(AssetKids.image.synopsisCastleBg)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: self.playerWidth, height: self.castleHeight)
                            .padding(.top, -self.castleHeight)
                    }
                    .modifier(Ratio16_9(
                                geometry: self.isFullScreen ? geometry : nil,
                                width:self.playerWidth,
                                isFullScreen: self.isFullScreen))
                    
                    if !SystemEnvironment.isTablet && !self.isFullScreen{
                        FunctionViewerKids(
                            componentViewModel: self.componentViewModel,
                            synopsisData: self.synopsisData,
                            summaryViewerData: self.summaryViewerData,
                            isBookmark: self.$isBookmark,
                            isRecommandAble: self.synopsisModel?.isCancelProgram == false
                        )
                        .padding(.horizontal, DimenKids.margin.regular)
                        .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                    }
                }
                .padding(.top, self.isFullScreen
                            ? 0
                            : KidsSynopsis.topHeight + (SystemEnvironment.isTablet ?  DimenKids.margin.regularExtra : DimenKids.margin.medium ) )
                
                if !self.isFullScreen{
                    if self.hasAuthority != nil, let purchasViewerData = self.purchasViewerData {
                        PurchaseViewerKids(
                            componentViewModel: self.componentViewModel,
                            data: purchasViewerData)
                            .padding(.top, DimenKids.margin.light)
                            //.padding(.trailing, DimenKids.margin.regular)
                            .frame(width:self.playerWidth + DimenKids.icon.light + DimenKids.margin.regular)
                            .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                        
                    } else {
                        Spacer()
                            .modifier(MatchParent())
                            .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                    }
                }
            }// vstack
            if !self.isFullScreen {
                VStack(alignment: .leading,spacing:0){
                    if let episodeViewerData = self.episodeViewerData, let purchasViewerData = self.purchasViewerData {
                        EpisodeViewerKids(
                            episodeViewerData: episodeViewerData,
                            purchaseViewerData: purchasViewerData)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    if SystemEnvironment.isTablet {
                        Spacer()
                        FunctionViewerKids(
                            componentViewModel: self.componentViewModel,
                            synopsisData: self.synopsisData,
                            summaryViewerData: self.summaryViewerData,
                            isBookmark: self.$isBookmark,
                            isRecommandAble: self.synopsisModel?.isCancelProgram == false
                        )
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(height:KidsSynopsis.topHeight)
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
        }// zstack
    }//body
    
}




/*
KidsPlayerBody(
    geometry: self.geometry,
    pageObservable: self.pageObservable,
    pageDragingModel: self.pageDragingModel,
    componentViewModel: self.componentViewModel,
    playerModel: self.playerModel,
    playerListViewModel: self.playerListViewModel,
    prerollModel: self.prerollModel,
    playListData: self.playListData,
    imgContentMode: self.imgContentMode,
    isPlayAble: self.isPlayAble,
    progressError: self.progressError,
    isPlayViewActive: self.isPlayViewActive,
    isFullScreen: self.isFullScreen,
    sceneOrientation: self.sceneOrientation,
    isBookmark: self.$isBookmark,
    playerWidth: self.playerWidth,
    castleHeight: self.castleHeight
)
.padding(.top,self.isFullScreen ? 0 : DimenKids.margin.mediumExtra)
*/
