//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI
extension PackageBody {
    static let spacing:CGFloat = SystemEnvironment.isTablet ? Dimen.margin.regularExtra : Dimen.margin.regular
}
struct PackageBody: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var componentViewModel:SynopsisViewModel
    var infinityScrollModel: InfinityScrollModel
    var synopsisListViewModel: InfinityScrollModel
    var peopleScrollModel: InfinityScrollModel
    
    var synopsisPackageModel:SynopsisPackageModel
    var isPairing:Bool? = nil
    var isPosson:Bool 
    var contentID:String? = nil
    var episodeViewerData:EpisodeViewerData? = nil
    var summaryViewerData:SummaryViewerData? = nil
    var useTop:Bool = true
    var useTracking:Bool = false
    var marginBottom:CGFloat = 0
    var action: ((_ data:PosterData) -> Void)? = nil
    var body: some View {
        InfinityScrollView(
            viewModel: self.infinityScrollModel,
            marginTop : 0,
            marginBottom : self.marginBottom,
            spacing:0,
            isRecycle:false,
            useTracking:true
            ){
            if self.useTop {
                if SystemEnvironment.isTablet {
                    TopViewer(
                        componentViewModel:self.componentViewModel,
                        data: synopsisPackageModel)
                        .frame(height:TopViewer.height)
                        .modifier(ListRowInset(spacing: Dimen.margin.regular))
                } else {
                    TopViewer(
                        componentViewModel:self.componentViewModel,
                        data: synopsisPackageModel)
                        .frame(height:round(self.sceneObserver.screenSize.width * TopViewer.imgRatio)
                                + (synopsisPackageModel.hasAuthority ? 0 : TopViewer.bottomHeight))
                        .modifier(ListRowInset(spacing: Dimen.margin.regular))
                }
            }
            if !self.synopsisPackageModel.posters.isEmpty == true {
                VStack(alignment: .leading, spacing: 0){
                    Text(String.pageText.synopsisPackageContent + " " + self.synopsisPackageModel.posters.count.description)
                        .modifier(BlockTitle())
                        .modifier(ContentHorizontalEdges())
                        
                    PosterViewList(
                        viewModel: self.synopsisListViewModel,
                        datas: self.synopsisPackageModel.posters,
                        contentID: self.contentID,
                        useTracking: self.useTracking,
                        hasAuthority: self.synopsisPackageModel.hasAuthority,
                        text: self.synopsisPackageModel.contentMoreText
                    ) { data in
                        
                        
                        self.action?(data)
                    }
                    .padding(.top, Dimen.margin.thinExtra)
                }
                .frame( height:
                            (ListItem.poster.type01.height)
                            + Dimen.tab.thin + Dimen.margin.thinExtra
                            + Dimen.margin.thin + Dimen.button.lightExtra
                            + Dimen.margin.light
                )
                .padding(.top, self.useTop ? 0 : Self.spacing)
                .modifier(ListRowInset(spacing:  Self.spacing))
            }
            
            if self.episodeViewerData != nil {
                EpisodeViewer(data:self.episodeViewerData!)
                    .modifier(ListRowInset(spacing:  Self.spacing))
            }
                
            if self.summaryViewerData != nil {
                SummaryViewer(
                    componentViewModel:self.componentViewModel,
                    peopleScrollModel:self.peopleScrollModel,
                    data: self.summaryViewerData!,
                    useTracking: self.useTracking,
                    isSimple : true
                )
                .modifier(ListRowInset(spacing:  Self.spacing))
            }
        }
        
    }//body
   
}



