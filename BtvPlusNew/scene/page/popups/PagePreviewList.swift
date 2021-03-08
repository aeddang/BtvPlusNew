//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine


struct PagePreviewList: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var playerModel: BtvPlayerModel = BtvPlayerModel(useFullScreenAction:false)
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:PlayBlockModel = PlayBlockModel()
    @State var title:String? = nil
    @State var menuId:String? = nil
    @State var useTracking:Bool = false
  
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: self.title,
                        isBack : true,
                        style: .dark
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    PlayBlock(
                        infinityScrollModel:self.infinityScrollModel,
                        viewModel:self.viewModel,
                        pageObservable:self.pageObservable,
                        playerModel:self.playerModel,
                        useTracking:self.useTracking,
                        marginTop: Dimen.margin.thin,
                        marginBottom: Dimen.margin.thin
                    )
                    
                }
                .modifier(PageFull(style:.dark))
                .highPriorityGesture(
                    DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
                        .onChanged({ value in
                            if self.useTracking { self.useTracking = false }
                            self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ value in
                            self.pageDragingModel.uiEvent = .draged(geometry, value)
                            self.useTracking = true
                        })
                )
                .gesture(
                    self.pageDragingModel.cancelGesture
                        .onChanged({_ in
                            self.useTracking = true
                            self.pageDragingModel.uiEvent = .dragCancel})
                        .onEnded({_ in
                            self.useTracking = true
                            self.pageDragingModel.uiEvent = .dragCancel})
                )
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.viewModel.update(menuId:self.menuId, key:nil)
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                self.useTracking = page?.id == self.pageObject?.id
            }
           
            .onAppear{
                guard let obj = self.pageObject  else { return }
                
                if let data = obj.getParamValue(key: .data) as? CateData {
                    self.title = data.title
                    if let cateData = data.blocks?.filter({ $0.menu_id != nil }).first {
                        self.menuId = cateData.menu_id
                        return
                    }
                }
                if let data = obj.getParamValue(key: .data) as? BlockData {
                    self.title = data.name
                    self.menuId = data.menuId
                } else {
                    self.menuId = obj.getParamValue(key: .id) as? String
                    
                }
                self.title = obj.getParamValue(key: .title) as? String ?? self.title

            }
            .onDisappear{
               
            }
        }//geo
    }//body
   
    
}


#if DEBUG
struct PagePreviewList_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePreviewList().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(SceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(PageSceneObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

