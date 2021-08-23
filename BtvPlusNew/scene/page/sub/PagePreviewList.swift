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
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
     
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var playerModel: BtvPlayerModel = BtvPlayerModel(useFullScreenAction:false)
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:PlayBlockModel = PlayBlockModel()
    @State var title:String? = nil
    @State var menuId:String? = nil
    @State var safeAreaTop:CGFloat = 0
    @State var marginBottom:CGFloat = 0
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: self.title,
                        isBack : true,
                        style: .dark
                    )
                    .padding(.top, self.safeAreaTop)
                    PlayBlock(
                        infinityScrollModel:self.infinityScrollModel,
                        viewModel:self.viewModel,
                        pageObservable:self.pageObservable,
                        playerModel:self.playerModel,
                        useTracking:true,
                        marginTop: Dimen.margin.thin,
                        marginBottom: self.marginBottom 
                    )
                    
                }
                .modifier(PageFull(style:.normal))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.viewModel.update(menuId:self.menuId, key:nil)
                }
            }
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if update {
                    self.safeAreaTop = self.sceneObserver.safeAreaTop
                }
            }
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                withAnimation{ self.marginBottom = bottom }
            }
            .onAppear{
                self.safeAreaTop = self.sceneObserver.safeAreaTop
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
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

