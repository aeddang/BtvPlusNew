//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI

struct PackageBodyKids: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
   
    var synopsisListViewModel: InfinityScrollModel
    var synopsisPackageModel:SynopsisPackageModel
    
    var isPairing:Bool? = nil
    var contentID:String? = nil
    var episodeViewerData:EpisodeViewerData? = nil
    var useTracking:Bool = false
    var action: ((_ data:PosterData) -> Void)? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            TopViewerKids( data: synopsisPackageModel)
                .frame(height:TopViewerKids.height)
                .modifier(ContentHorizontalEdgesKids())
                
            VStack(alignment: .leading, spacing: DimenKids.margin.thinExtra){
                Text(String.pageText.synopsisPackageContent + " " + self.synopsisPackageModel.posters.count.description)
                    .modifier(BlockTitleKids())
                    .modifier(ContentHorizontalEdgesKids())
    
                PosterViewList(
                    viewModel: self.synopsisListViewModel,
                    datas: self.synopsisPackageModel.posters,
                    contentID: self.contentID,
                    episodeViewerData: self.episodeViewerData,
                    useTracking: self.useTracking,
                    hasAuthority: self.synopsisPackageModel.hasAuthority,
                    text: self.synopsisPackageModel.contentMoreText,
                    margin: DimenKids.margin.regular + sceneObserver.safeAreaStart
                ) { data in
                    self.action?(data)
                }
            }
            .modifier(MatchParent())
        }
        
    }//body
   
}



