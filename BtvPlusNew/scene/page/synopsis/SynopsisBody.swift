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
    var relationContentsModel:RelationContentsModel
    var peopleScrollModel: InfinityScrollModel
    var pageDragingModel:PageDragingModel
    
    @Binding var isBookmark:Bool?
    @Binding var seris:[SerisData]
    @Binding var relationTabIdx:Int

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
    
    @State var safeAreaBottom:CGFloat = 0

    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.regular) {
            if self.episodeViewerData != nil {
                EpisodeViewer(data:self.episodeViewerData!)
                    .padding(.top, Dimen.margin.regularExtra)
                
                HStack(spacing:0){
                    FunctionViewer(
                        synopsisData :self.synopsisData,
                        srisId: self.srisId,
                        isHeart: self.$isBookmark
                    )
                    Spacer()
                }
            }
            
            if self.hasAuthority != nil && self.purchasViewerData != nil {
                PurchaseViewer(
                    componentViewModel: self.componentViewModel,
                    data:self.purchasViewerData! )
            }
            if self.hasAuthority == false && self.isPairing == false {
                FillButton(
                    text: String.button.connectBtv
                ){_ in
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.pairing)
                    )
                }
                .padding(.horizontal, Dimen.margin.thin)
            }
            if self.summaryViewerData != nil {
                SummaryViewer(
                    peopleScrollModel:self.peopleScrollModel,
                    data: self.summaryViewerData!)
            }
            if self.hasRelationVod != nil {
                if self.hasRelationVod == false {
                    Text(String.pageText.synopsisRelationVod)
                        .modifier(BoldTextStyle( size: Font.size.regular, color:Color.app.white ))
                        .padding(.horizontal, Dimen.margin.thin)
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
                }
                else if self.relationTab.count == 1 {
                    Text(self.relationTab.first!)
                        .modifier(BoldTextStyle( size: Font.size.regular, color:Color.app.white ))
                        .padding(.horizontal, Dimen.margin.thin)
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
                    .padding(.horizontal, Dimen.margin.thin)
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
            }
            Spacer().frame(height: self.safeAreaBottom)
        }
        .onReceive(self.sceneObserver.$safeAreaBottom){ pos in
            self.safeAreaBottom = pos
        }
    }//body
}





