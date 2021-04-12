//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI
struct PackageBody: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var infinityScrollModel: InfinityScrollModel
    var synopsisListViewModel: InfinityScrollModel
    var peopleScrollModel: InfinityScrollModel
    
    var synopsisPackageModel:SynopsisPackageModel
    var isPairing:Bool? = nil
    var contentID:String? = nil
    var episodeViewerData:EpisodeViewerData? = nil
    var summaryViewerData:SummaryViewerData? = nil
    var useTracking:Bool = false
    var action: ((_ data:PosterData) -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.infinityScrollModel,
            marginTop : 0,
            marginBottom : self.sceneObserver.safeAreaBottom,
            spacing:0,
            isRecycle:false,
            useTracking:false
            ){
            
            TopViewer( data: self.synopsisPackageModel)
                .modifier(ListRowInset(spacing: Dimen.margin.regular))
            
            if !self.synopsisPackageModel.posters.isEmpty {
                VStack(alignment: .leading, spacing: 0){
                    Text(String.pageText.synopsisPackageContent + " " + self.synopsisPackageModel.posters.count.description)
                        .modifier(BlockTitle())
                        .modifier(ContentHorizontalEdges())
                    PosterViewList(
                        viewModel: self.synopsisListViewModel,
                        datas: self.synopsisPackageModel.posters,
                        contentID: self.contentID,
                        useTracking: self.useTracking
                    ) { data in
                        self.action?(data)
                    }
                    .padding(.top, Dimen.margin.thinExtra)
                }
                .frame( height:
                            (ListItem.poster.type01.height)
                            + Dimen.tab.thin + Dimen.margin.thinExtra
                            + Dimen.margin.thin + Dimen.button.lightExtra
                            + Dimen.margin.thin
                )
                .modifier(ListRowInset(spacing: Dimen.margin.regular))
            } else {
                Spacer().modifier(MatchParent())
                    .modifier(ListRowInset(spacing: 0))
            }
            
            if self.episodeViewerData != nil {
                EpisodeViewer(data:self.episodeViewerData!)
                    .modifier(ListRowInset(spacing: Dimen.margin.regular))
            } else {
                Spacer().modifier(MatchParent())
                    .modifier(ListRowInset(spacing: 0))
            }
                
            if self.summaryViewerData != nil {
                SummaryViewer(
                    peopleScrollModel:self.peopleScrollModel,
                    data: self.summaryViewerData!,
                    useTracking: self.useTracking,
                    isSimple : true
                )
                .modifier(ListRowInset(spacing: Dimen.margin.regular))
            } else {
                Spacer().modifier(MatchParent())
                    .modifier(ListRowInset(spacing: 0))
            }
        }
        
    }//body
   
}


