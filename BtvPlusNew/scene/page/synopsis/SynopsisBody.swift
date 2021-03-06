//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI



struct SynopsisBody: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    var componentViewModel:PageSynopsis.ComponentViewModel
    var infinityScrollModel: InfinityScrollModel
    var relationContentsModel:RelationContentsModel
    var peopleScrollModel: InfinityScrollModel
    var pageDragingModel:PageDragingModel

    @Binding var isBookmark:Bool?
    @Binding var isLike:LikeStatus?
    @Binding var relationTabIdx:Int
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
    
    var relationTab:[String] = []
    var relationDatas:[PosterDataSet] = []
    var hasRelationVod:Bool? = nil
    var useTracking:Bool = false
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
            Spacer().modifier(MatchHorizontal(height: 1)).background(Color.transparent.clearUi)
                .id(self.topIdx)
                .modifier(ListRowInset(spacing: Dimen.margin.regular))
            
            if self.episodeViewerData != nil {
                EpisodeViewer(data:self.episodeViewerData!)
                    .modifier(ListRowInset(spacing: Dimen.margin.regular))
                HStack(spacing:0){
                    FunctionViewer(
                        synopsisData :self.synopsisData,
                        srisId: self.srisId,
                        isBookmark: self.$isBookmark,
                        isLike: self.$isLike
                    )
                    Spacer()
                }
                .modifier(ListRowInset(spacing: Dimen.margin.regular))
            }
            
            if self.hasAuthority != nil && self.purchasViewerData != nil {
                PurchaseViewer(
                    componentViewModel: self.componentViewModel,
                    data:self.purchasViewerData! )
                    .modifier(ListRowInset(spacing: Dimen.margin.regular))
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
                .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: Dimen.margin.regular))
            }
            
            if self.summaryViewerData != nil {
                SummaryViewer(
                    peopleScrollModel:self.peopleScrollModel,
                    data: self.summaryViewerData!,
                    useTracking: self.usePullTracking
                )
                .modifier(ListRowInset(spacing: Dimen.margin.regular))
            }
            
            if self.hasRelationVod != nil {
                if self.hasRelationVod == false {
                    Text(String.pageText.synopsisRelationVod)
                        .modifier(BoldTextStyle( size: Font.size.regular, color:Color.app.white ))
                        .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: Dimen.margin.regular))
                    VStack(alignment: .center, spacing: 0){
                        Spacer().modifier(MatchHorizontal(height:0))
                        Image(Asset.icon.alert)
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: Dimen.icon.mediumUltra, height: Dimen.icon.mediumUltra)
                            .padding(.top, Dimen.margin.medium)
                        Text(String.pageText.synopsisNoRelationVod)
                            .modifier(BoldTextStyle(size: Font.size.regular, color: Color.app.greyLight))
                            .multilineTextAlignment(.center)
                            .padding(.top, Dimen.margin.regularExtra)
                    }
                    .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: Dimen.margin.regular))
                }
                else if self.relationTab.count == 1 {
                    Text(self.relationTab.first!)
                        .modifier(BoldTextStyle( size: Font.size.regular, color:Color.app.white ))
                        .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: Dimen.margin.regular))
                }
                else{
                    CPTabDivisionNavigation(
                        buttons: NavigationBuilder(
                            index:self.relationTabIdx,
                            marginH:Dimen.margin.regular)
                            .getNavigationButtons(texts:self.relationTab),
                        index: self.$relationTabIdx
                    )
                    .frame(height:Dimen.tab.regular)
                    .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: Dimen.margin.regular))
                }
            }
         
            if !self.seris.isEmpty {
                SerisTab(
                    data:self.relationContentsModel,
                    seris: self.$seris
                ){ season in
                    self.componentViewModel.uiEvent = .changeSynopsis(season.synopsisData)
                }
                .modifier(ListRowInset(marginHorizontal:Dimen.margin.thin ,spacing: Dimen.margin.thin))
               
                ForEach(self.seris) { data in
                    SerisItem( data:data, isSelected: self.synopsisData?.epsdId == data.contentID )
                        .padding(.horizontal, Dimen.margin.thin)
                        .onTapGesture {
                            self.componentViewModel.uiEvent = .changeVod(data.epsdId)
                        }
                        .modifier(ListRowInset( spacing: Dimen.margin.thin))
                }
            } else if !self.relationDatas.isEmpty {
                ForEach(self.relationDatas) { data in
                    PosterSet( data:data ){data in
                        self.componentViewModel.uiEvent = .changeSynopsis(data.synopsisData)
                    }
                    .frame(height: PosterSet.listSize(data: data, screenWidth: self.sceneObserver.screenSize.width).height)
                    .modifier(ListRowInset( spacing: Dimen.margin.thin))
                    
                }
            } else {
                Spacer().modifier(MatchParent())
                    .modifier(ListRowInset(spacing: 0))
            }
        }
    }//body
    
}



/*
InfinityScrollView(
    viewModel: self.infinityScrollModel,
    spacing:Dimen.margin.regular,
    isRecycle:true,
    useTracking:false
    ){
    
    SynopsisBody(
        componentViewModel: self.componentViewModel,
        relationContentsModel: self.relationContentsModel,
        peopleScrollModel: self.peopleScrollModel,
        pageDragingModel: self.pageDragingModel,
        isBookmark: self.$isBookmark,
       // seris: self.$seris,
        relationTabIdx: self.$relationTabIdx,
        synopsisData: self.synopsisData,
        isPairing: self.isPairing,
        episodeViewerData: self.episodeViewerData,
        purchasViewerData: self.purchasViewerData,
        summaryViewerData: self.summaryViewerData,
        srisId: self.srisId, epsdId: self.epsdId,
        hasAuthority: self.hasAuthority,
        relationTab: self.relationTab,
        relationDatas: self.relationDatas,
        hasRelationVod: self.hasRelationVod,
        useTracking:self.useTracking)
    .onReceive( [self.relationTabIdx].publisher ){ idx in
        if idx == self.selectedRelationTabIdx { return }
        self.selectedRelationContent(idx:idx)
    }
    
    .onReceive(self.componentViewModel.$uiEvent){evt in
        guard let evt = evt else { return }
        switch evt {
        case .changeVod(let epsdId) : self.changeVod(epsdId:epsdId)
        case .changeSynopsis(let data): self.changeVod(synopsisData: data)
        case .changeOption(let option) : self.changeOption(option)
        case .purchase : self.purchase()
        }
    }
    
    .onReceive(self.peopleScrollModel.$event){evt in
        guard let evt = evt else {return}
        switch evt {
        case .pullCancel : self.pageDragingModel.uiEvent = .pulled(geometry)
        default : do{}
        }
    }
    .onReceive(self.peopleScrollModel.$pullPosition){ pos in
        self.pageDragingModel.uiEvent = .pull(geometry, pos)
    }
    
    if !self.seris.isEmpty {
        SerisTab(
            data:self.relationContentsModel,
            seris: self.$seris
        ){ season in
            self.componentViewModel.uiEvent = .changeSynopsis(season.synopsisData)
        }
        .padding(.horizontal, Dimen.margin.thin)
    }
    
    ForEach(self.seris) { data in
        SerisItem( data:data, isSelected: self.synopsisData?.epsdId == data.contentID )
            .padding(.horizontal, Dimen.margin.thin)
        .onTapGesture {
            self.componentViewModel.uiEvent = .changeVod(data.epsdId)
        }
    }
    
    VStack(spacing:Dimen.margin.thin){
        ForEach(self.relationDatas) { data in
            PosterSet( data:data )
        }
    }
    
    Spacer().frame(height: self.safeAreaBottom)
}
.modifier(MatchParent())
*/
