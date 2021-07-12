//
//  PlayViewer.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/05.
//

import Foundation
import SwiftUI


struct RelationVodBodyKids: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var componentViewModel:PageSynopsis.ComponentViewModel
    var infinityScrollModel: InfinityScrollModel
    var relationContentsModel:RelationContentsModel
    @Binding var seris:[SerisData]
    
    var epsdId:String?
    var relationDatas:[PosterDataSet] = []
    var screenSize:CGFloat

    var body: some View {
        InfinityScrollView(
            viewModel: self.infinityScrollModel,
            marginTop : self.sceneObserver.safeAreaTop + DimenKids.margin.medium,
            marginBottom : self.sceneObserver.safeAreaBottom,
            isAlignCenter : true,
            spacing:0,
            isRecycle:true,
            useTracking:false,
            bgColor:Color.app.white){
            
            if !self.seris.isEmpty {
                SerisTabKids(
                    data:self.relationContentsModel,
                    seris: self.$seris
                ){ season in
                    self.componentViewModel.uiEvent = .changeSynopsis(season.synopsisData)
                }
                .modifier(ListRowInset(spacing: DimenKids.margin.medium, bgColor: Color.app.white))
                ForEach(self.seris) { data in
                    SerisItemKids( data:data.setListType(.kids), isSelected: self.epsdId == data.contentID )
                        .id(data.index)
                        .onTapGesture {
                            self.componentViewModel.uiEvent = .changeVod(data.epsdId)
                        }
                        .modifier(ListRowInset(spacing: DimenKids.margin.thinExtra, bgColor: Color.app.white))
                }
                .onAppear(){
                    guard let find = self.seris.first(where: {self.epsdId == $0.contentID}) else {return}
                    infinityScrollModel.uiEvent = .scrollTo(find.index, .center)
                }
            } else if !self.relationDatas.isEmpty {
                Text(String.kidsText.synopsisRelationVod)
                    .modifier(BoldTextStyleKids(size: Font.sizeKids.regularExtra, color: Color.app.brownDeep))
                    .modifier(ListRowInset( spacing: DimenKids.margin.light, bgColor: Color.app.white))
                
                ForEach(self.relationDatas) { dataSet in
                    if let data = dataSet.datas.first {
                        PosterItem( data:data )
                        .onTapGesture {
                            self.componentViewModel.uiEvent = .changeSynopsis(data.synopsisData)
                        }
                        .frame(height: data.type.size.height)
                        .modifier(ListRowInset( spacing: DimenKids.margin.thin, bgColor: Color.app.white))
                    }
                }
            } else {
                Spacer().modifier(MatchHorizontal(height: RelationVodList.spacing ))
            }
            
        }
        .background(Color.app.white)
       
    }//body
   
}






