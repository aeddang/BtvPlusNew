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
    static let bottomHeight:CGFloat = SystemEnvironment.isTablet ? 74 : 38
    static let listWidth:CGFloat = SystemEnvironment.isTablet ? 260 : 150
    //static let playerAreaWidth:CGFloat = SystemEnvironment.isTablet ? 705 : 440
    //static let playerSize:CGSize = SystemEnvironment.isTablet ? CGSize(width: 705, height: 394) : CGSize(width: 368, height: 206)
    
    func getPlayerAreaWidth(sceneObserver:PageSceneObserver) -> CGFloat {
        let h = sceneObserver.screenSize.height
            - Self.topHeight - Self.bottomHeight
            - (DimenKids.margin.regularExtra * 2) - DimenKids.margin.thin
            - (sceneObserver.safeAreaTop + sceneObserver.safeAreaIgnoreKeyboardBottom)
        
        let limitW = sceneObserver.screenSize.width
            - Self.listWidth
            - ( DimenKids.icon.regularExtra + DimenKids.margin.light ) //뒤로버튼 영역
            - ( SystemEnvironment.isTablet
                    ? -DimenKids.margin.thin
                    : (DimenKids.margin.regularExtra * 2) - DimenKids.margin.thin ) //기능 박스 영역
            - (DimenKids.margin.mediumExtra*2) //좌우 여백
        
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
    var purchaseViewerData:PurchaseViewerData?
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
    var isPosson:Bool
    var progressError:Bool
    
    var isPairing:Bool?
    var isPlayViewActive:Bool
    var isFullScreen:Bool
    var isUiActive:Bool
    var isUIView:Bool
    var sceneOrientation: SceneOrientation
    
    @Binding var isBookmark:Bool?
    @Binding var seris:[SerisData]
    @State var playerWidth:CGFloat = 0
    @State var castleHeight:CGFloat = 0
    var body: some View {
        ZStack(alignment: .center){
            HStack(alignment: .bottom, spacing:0){
                Image(AssetKids.image.synopsisKidBg)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: SystemEnvironment.isTablet ? 97 : 60,
                           height: SystemEnvironment.isTablet ? 146 : 90)
                Spacer().modifier(MatchParent())
                Spacer().modifier(MatchVertical(width: self.sceneObserver.safeAreaEnd))
                    .background(Color.app.white)
            }
            .background(PageStyle.kidsLight.bgColor)
            .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
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
                
                ZStack(alignment: .topLeading){
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
                                    /*
                                    .modifier(PageDragingSecondPriority(geometry: geometry, pageDragingModel: self.pageDragingModel))*/
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
                                    synopsisModel:self.synopsisModel,
                                    purchaseViewerData:self.purchaseViewerData,
                                    summaryViewerData: self.summaryViewerData,
                                    isBookmark: self.$isBookmark,
                                    isPosson: self.isPosson
                                )
                                .padding(.horizontal, DimenKids.margin.regular)
                                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                            }
                        }
                        .padding(.top, self.isFullScreen
                                    ? 0
                                    : KidsSynopsis.topHeight + (SystemEnvironment.isTablet ?  DimenKids.margin.regularExtra : DimenKids.margin.medium ) )
                        
                        if !self.isFullScreen{
                            if self.hasAuthority != nil, let purchaseViewerData = self.purchaseViewerData {
                                PurchaseViewerKids(
                                    componentViewModel: self.componentViewModel,
                                    data: purchaseViewerData,
                                    isPairing: self.isPairing)
                                    .padding(.top, DimenKids.margin.light)
                                    .frame(width:
                                            SystemEnvironment.isTablet
                                            ? self.playerWidth
                                            : self.playerWidth + DimenKids.icon.light + DimenKids.margin.regular)
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
                            Spacer().modifier(MatchHorizontal(height: 0))
                            if let episodeViewerData = self.episodeViewerData, let purchaseViewerData = self.purchaseViewerData {
                                EpisodeViewerKids(
                                    episodeViewerData: episodeViewerData,
                                    purchaseViewerData: purchaseViewerData)
                                    
                                    //.fixedSize(horizontal: true, vertical: false)
                            }
                            if SystemEnvironment.isTablet {
                                Spacer()
                                FunctionViewerKids(
                                    componentViewModel: self.componentViewModel,
                                    synopsisData: self.synopsisData,
                                    synopsisModel:self.synopsisModel,
                                    purchaseViewerData:self.purchaseViewerData,
                                    summaryViewerData: self.summaryViewerData,
                                    isBookmark: self.$isBookmark,
                                    isPosson:self.isPosson
                                )
                                //.fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .frame(height:KidsSynopsis.topHeight)
                        .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                    }
                }// zstack
                .padding(.top,self.isFullScreen ? 0 : DimenKids.margin.mediumExtra)
                
                if self.sceneOrientation == .landscape && !self.isFullScreen {
                    HStack(alignment: .top, spacing:0){
                        Spacer().modifier(MatchParent())
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
                        } else {
                            Spacer()
                                .frame(width: Self.listWidth)
                                .background(Color.app.white)
                        }
                        
                    }
                    .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
                }
            }
            .modifier(PageFullMargin())
        }
        
        .onReceive(self.sceneObserver.$isUpdated){ _ in
            self.updatePlayerSize()
        }
        .onAppear{
            self.updatePlayerSize()
        }
    }//body
    
    private func updatePlayerSize(){
        self.playerWidth = self.getPlayerAreaWidth(sceneObserver: self.sceneObserver)
        self.castleHeight = self.playerWidth * 80/368
    }
}





