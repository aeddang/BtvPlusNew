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
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var vsManager:VSManager
    var componentViewModel:SynopsisViewModel
    var infinityScrollModel: InfinityScrollModel
    var relationContentsModel:RelationContentsModel
    var peopleScrollModel: InfinityScrollModel
    var pageDragingModel:PageDragingModel
    var tabNavigationModel:NavigationModel
    @Binding var isBookmark:Bool?
    @Binding var isLike:LikeStatus?
    var isPosson:Bool
    var possonType:PossonType
    @Binding var seris:[SerisData]
    var synopsisData:SynopsisData? = nil
    var synopsisModel:SynopsisModel? = nil
    var isPairing:Bool? = nil
    var episodeViewerData:EpisodeViewerData? = nil
    var purchaseViewerData:PurchaseViewerData? = nil
    var summaryViewerData:SummaryViewerData? = nil
    var epsdId:String?
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
            scrollType: .vertical(isDragEnd: false),
            marginTop : Self.spacing,
            marginBottom : Self.spacing + Dimen.app.bottom + self.sceneObserver.safeAreaIgnoreKeyboardBottom,
            spacing:0,
            isRecycle:true,
            useTracking:true
            ){
            
            //VStack(alignment: .leading, spacing: 0){
                if let episodeViewerData = self.episodeViewerData {
                    Text(episodeViewerData.episodeTitle)
                        .modifier(BoldTextStyle( size: Font.size.boldExtra ))
                        .lineLimit(2)
                        .modifier(ContentHorizontalEdges())
                        .modifier(ListRowInset(spacing: SystemEnvironment.isTablet ? Dimen.margin.thinExtra : Dimen.margin.lightExtra))
                    if self.funtionLayout == .horizontal {
                        ZStack(alignment:.top ){
                            HStack(spacing:0){
                                EpisodeViewer(data:episodeViewerData)
                                    .accessibility(hidden: true)
                                Spacer()
                            }
                            if self.possonType != .oksusu {
                                HStack(spacing:0){
                                    Spacer()
                                    FunctionViewer(
                                        componentViewModel: self.componentViewModel,
                                        synopsisData :self.synopsisData,
                                        synopsisModel:self.synopsisModel,
                                        purchaseViewerData: self.purchaseViewerData,
                                        funtionLayout:self.funtionLayout,
                                        isBookmark: self.$isBookmark,
                                        isLike: self.$isLike
                                    )
                                }
                                .padding(.top, self.synopsisModel?.isRecommand == true ? -RecommandTip.height : 0)
                            }
                        }
                        .modifier(ListRowInset(spacing: SynopsisBody.spacing))
                    } else {
                        EpisodeViewer(data:episodeViewerData)
                            .modifier(ListRowInset(spacing: SynopsisBody.spacing))
                            .accessibility(hidden: true)
                        if self.possonType != .oksusu {
                            HStack(spacing:0){
                                FunctionViewer(
                                    componentViewModel: self.componentViewModel,
                                    synopsisData :self.synopsisData,
                                    synopsisModel:self.synopsisModel,
                                    purchaseViewerData: self.purchaseViewerData,
                                    funtionLayout:self.funtionLayout,
                                    isBookmark: self.$isBookmark,
                                    isLike: self.$isLike
                                )
                                Spacer()
                            }
                            .modifier(ListRowInset(spacing: SynopsisBody.spacing))
                        }
                    }
                }
                
                if self.hasAuthority != nil , let purchaseViewerData = self.purchaseViewerData {
                    PurchaseViewer(
                        componentViewModel: self.componentViewModel,
                        data: purchaseViewerData,
                        isPosson:self.isPosson,
                        possonType:self.possonType
                    )
                    .modifier(ListRowInset(spacing: SynopsisBody.spacing))
                }
                if self.hasAuthority == false && self.isPairing == false && !self.isPosson && self.synopsisModel?.isRecommandAble == true{
                    FillButton(
                        text: String.button.connectBtv
                    ){_ in
                        
                        self.appSceneObserver.pairingCompletedMovePage = nil
                        self.pagePresenter.openPopup(
                            PageProvider.getPageObject(.pairing)
                                .addParam(key: PageParam.subType, value: "mob-uixp-synop")
                        )
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: SynopsisBody.spacing))
                }
                
                if self.summaryViewerData != nil && self.synopsisModel?.isCancelProgram == false{
                    SummaryViewer(
                        componentViewModel:self.componentViewModel,
                        peopleScrollModel:self.peopleScrollModel,
                        data: self.summaryViewerData!,
                        useTracking: self.usePullTracking,
                        isSimple: self.hasRelationVod == nil ? true : false
                    )
                    .modifier(ListRowInset(spacing: SynopsisBody.spacing))
                }
           // }
            if let hasRelationVod = self.hasRelationVod {
                RelationVodList(
                    componentViewModel: self.componentViewModel,
                    relationContentsModel: self.relationContentsModel,
                    tabNavigationModel: self.tabNavigationModel,
                    seris: self.$seris,
                    epsdId: self.epsdId,
                    relationTab: self.relationTab,
                    relationDatas: self.relationDatas,
                    hasRelationVod: hasRelationVod,
                    screenSize: self.sceneObserver.screenSize.width
                )
            }
                
        }
    }//body
}



