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
    @EnvironmentObject var naviLogManager:NaviLogManager
    var componentViewModel:SynopsisViewModel
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
            marginBottom : self.sceneObserver.safeAreaIgnoreKeyboardBottom,
            isAlignCenter : true,
            spacing:0,
            isRecycle:true,
            useTracking:true,
        
            bgColor:Color.app.white){
            
            if !self.seris.isEmpty {
                SerisTabKids(
                    data:self.relationContentsModel,
                    seris: self.$seris
                ){ season in
                    self.componentViewModel.uiEvent = .changeSynopsis(season.synopsisData,isSrisChange:true)
                }
                .modifier(ListRowInset(spacing: DimenKids.margin.medium))
                ForEach(self.seris) { data in
                    SerisItemKids(
                        relationContentsModel: self.relationContentsModel, 
                        data:data.setListType(.kids),
                        isSelected: self.epsdId == data.contentID )
                        .id(data.hashId)
                        .onTapGesture {
                            if data.hasLog {
                                self.naviLogManager.actionLog(
                                    .clickContentsList,
                                    pageId: data.logPage,
                                    actionBody: data.actionLog, contentBody: data.contentLog)
                            }
                            
                            if data.isQuiz {
                                self.pagePresenter.openPopup(
                                    PageKidsProvider.getPageObject(.kidsExam)
                                        .addParam(key: .type, value: DiagnosticReportType.finalQuiz)
                                        .addParam(key: .id, value:data.srisId)
                                        .addParam(key: .text, value:data.quizTitle)
                                )
                            } else {
                                self.componentViewModel.uiEvent = .changeVod(data.epsdId)
                            }
                           
                            
                        }
                        .modifier(ListRowInset(spacing: DimenKids.margin.thinExtra))
                }
                .onAppear(){
                   // guard let find = self.seris.first(where: {self.epsdId == $0.contentID}) else {return}
                    //infinityScrollModel.uiEvent = .scrollTo(find.index, .center)
                }
            } else if !self.relationDatas.isEmpty {
                Text(String.kidsText.synopsisRelationVod)
                    .modifier(BoldTextStyleKids(size: Font.sizeKids.regularExtra, color: Color.app.brownDeep))
                    .modifier(ListRowInset( spacing: DimenKids.margin.light))
                
                ForEach(self.relationDatas) { dataSet in
                    if let data = dataSet.datas.first {
                        PosterItem( data:data )
                        .onTapGesture {
                            if data.hasLog {
                                self.naviLogManager.actionLog(
                                    .clickContentsList,
                                    pageId: data.logPage,
                                    actionBody: data.actionLog, contentBody: data.contentLog)
                            }
                            self.componentViewModel.uiEvent = .changeSynopsis(data.synopsisData)
                        }
                        .frame(height: data.type.size.height)
                        .modifier(ListRowInset( spacing: DimenKids.margin.thin))
                    }
                }
            } else {
                Spacer().modifier(MatchHorizontal(height: RelationVodList.spacing ))
            }
            
        }
        .background(Color.app.white)
       
    }//body
   
}







