//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI


struct RelationVodBody: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var componentViewModel:SynopsisViewModel
    var infinityScrollModel: InfinityScrollModel
    var relationContentsModel:RelationContentsModel
    var tabNavigationModel:NavigationModel
    @Binding var seris:[SerisData]
    var epsdId:String?
    var relationTab:[NavigationButton] = []
    var relationDatas:[PosterDataSet] = []
    var hasRelationVod:Bool = false
    var screenSize:CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            RelationVodHeader(
                componentViewModel: self.componentViewModel,
                relationContentsModel: self.relationContentsModel,
                tabNavigationModel: self.tabNavigationModel,
                relationDatas: self.relationDatas,
                seris: self.$seris,
                epsdId: self.epsdId,
                relationTab: self.relationTab,
                hasRelationVod : self.hasRelationVod
                )
            
            InfinityScrollView(
                viewModel: self.infinityScrollModel,
                marginTop : 0,
                marginBottom : self.sceneObserver.safeAreaIgnoreKeyboardBottom,
                spacing:0,
                isRecycle:true,
                useTracking:true
                ){
                
                RelationVodListBody(
                    relationContentsModel: self.relationContentsModel,
                    componentViewModel: self.componentViewModel,
                    infinityScrollModel : self.infinityScrollModel,
                    seris: self.$seris,
                    relationDatas: self.relationDatas,
                    hasRelationVod: self.hasRelationVod,
                    screenSize: self.screenSize,
                    serisType: .small,
                    useIndex: true
                    )
            }
            
        }
        .padding(.top, RelationVodList.spacing)
        .background(Color.app.blueDeep)
       
    }//body
   
}
extension RelationVodList {
    static let spacing:CGFloat = SystemEnvironment.isTablet ? Dimen.margin.regularExtra : Dimen.margin.regular
}

struct RelationVodList: PageComponent{
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var componentViewModel:SynopsisViewModel
    var relationContentsModel:RelationContentsModel
    var tabNavigationModel:NavigationModel
    @Binding var seris:[SerisData]
    var epsdId:String?
    var relationTab:[NavigationButton] = []
    var relationDatas:[PosterDataSet] = []
    var hasRelationVod:Bool = false
    var screenSize:CGFloat 
    var body: some View {
        RelationVodHeader(
            componentViewModel: self.componentViewModel,
            relationContentsModel: self.relationContentsModel,
            tabNavigationModel: self.tabNavigationModel,
            relationDatas: self.relationDatas,
            seris: self.$seris,
            epsdId: self.epsdId,
            relationTab: self.relationTab,
            hasRelationVod : self.hasRelationVod
            )
        
        RelationVodListBody(
            relationContentsModel: self.relationContentsModel,
            componentViewModel: self.componentViewModel,
            seris: self.$seris,
            relationDatas: self.relationDatas,
            hasRelationVod: self.hasRelationVod,
            screenSize: self.screenSize
            )
        
    }//body
   
}


struct RelationVodHeader: PageComponent{
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var componentViewModel:SynopsisViewModel
    var relationContentsModel:RelationContentsModel
    var tabNavigationModel:NavigationModel
    var relationDatas:[PosterDataSet]
    @Binding var seris:[SerisData]
    var epsdId:String? = nil
    var relationTab:[NavigationButton]
    var hasRelationVod:Bool
 
    var body: some View {
        if self.hasRelationVod == false {
            Text(String.pageText.synopsisRelationVod)
                .modifier(BoldTextStyle( size: Font.size.regular, color:Color.app.white ))
                .frame(height:Dimen.tab.regular)
                .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: RelationVodList.spacing))
            VStack(spacing:0){
                EmptyAlert(text:String.pageText.synopsisNoRelationVod)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer().modifier(MatchHorizontal(height: 0))
            }
            .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: RelationVodList.spacing))
        } else if self.relationTab.count == 1 {
            Text(self.relationTab.first!.data)
                .modifier(BoldTextStyle( size: Font.size.regular, color:Color.app.white ))
                .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: RelationVodList.spacing))
                
        } else{
            CPTabDivisionNavigation(
                viewModel:self.tabNavigationModel,
                buttons: self.relationTab
            )
            .frame(height:Dimen.tab.regular)
            .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: RelationVodList.spacing))
        }
        
        if self.relationContentsModel.hasSris && self.relationDatas.isEmpty{
            SerisTab(
                componentViewModel:self.componentViewModel,
                data:self.relationContentsModel,
                seris: self.$seris
            ){ season in
                self.componentViewModel.uiEvent = .changeSynopsis(season.synopsisData, isSrisChange:true)
            }
            .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: Dimen.margin.thin))
        }
    }//body
    
   
}

struct RelationVodListBody: PageComponent{
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    var relationContentsModel:RelationContentsModel
    var componentViewModel:SynopsisViewModel
    var infinityScrollModel: InfinityScrollModel? = nil
    
    @Binding var seris:[SerisData]
   
    var relationDatas:[PosterDataSet]
    var hasRelationVod:Bool
    var screenSize:CGFloat
    var serisType:SerisType = .big
    var useIndex:Bool = false
    
    var body: some View {
        if !self.relationDatas.isEmpty {
            ForEach(self.relationDatas) { data in
                PosterSet(
                    data:data,
                    screenSize : self.screenSize
                ){data in
                    self.componentViewModel.uiEvent = .changeSynopsis(data.synopsisData)
                }
                .frame(height: PosterSet.listSize(data: data, screenWidth: self.screenSize).height)
                .modifier(ListRowInset(spacing: Dimen.margin.thin))
            }
        } else if self.relationContentsModel.hasSris {
            if self.seris.isEmpty {
                VStack(spacing:0){
                    EmptyAlert(
                        title: String.pageText.synopsisNoRelationSeries,
                        text: String.pageText.synopsisNoRelationSeriesMessage,
                        textHorizontal :String.pageText.synopsisNoRelationSeriesMessageHorizontal)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, Dimen.margin.regular)
                        
                    Spacer().modifier(MatchHorizontal(height: 0))
                }
                .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: RelationVodList.spacing))
                
            } else {
                ForEach(self.seris) { data in
                    SerisItem(
                        relationContentsModel: self.relationContentsModel,
                        data:data.setListType(self.serisType) )
                        .id(data.hashId)
                        .onTapGesture {
                            if data.hasLog {
                                self.naviLogManager.actionLog(
                                    .clickContentsList,
                                    pageId: data.logPage,
                                    actionBody: data.actionLog, contentBody: data.contentLog)
                            }
                            self.componentViewModel.uiEvent = .changeVod(data.epsdId)
                        }
                        .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin, spacing: Dimen.margin.thin))
                }
                if let tip = self.relationContentsModel.serisTip?.replace("\n", with: "") {
                    VStack(alignment:.leading, spacing:0){
                        Text(tip).modifier(LightTextStyle(size: Font.size.tiny, color: Color.app.greyExtra))
                            .padding(.top, Dimen.margin.thin)
                        Spacer()
                    }
                    .frame( height: self.seris.first?.type.size.height)
                    .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin, spacing: Dimen.margin.thin))
                }
            }
            
        
        } else {
            Spacer().modifier(MatchHorizontal(height: RelationVodList.spacing ))
        }
        
    }//body
    
}
