//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine


struct PageWatchedList: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:WatchedBlockModel = WatchedBlockModel()
    @State var title:String = String.pageTitle.watched
    @State var menuId:String? = nil
    @State var marginBottom:CGFloat = 0
    @State var isInit:Bool = false
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
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    WatchedBlock(
                        infinityScrollModel:self.infinityScrollModel,
                        viewModel:self.viewModel,
                        pageObservable:self.pageObservable,
                        useTracking:true,
                        marginBottom: self.marginBottom
                    )
                }
                .modifier(PageFull(style:.dark))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    if self.isInit {return}
                    DispatchQueue.main.async {
                        self.isInit = true
                        self.viewModel.update(menuId:self.menuId, key:nil)
                    }
                }
            }
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                withAnimation{ self.marginBottom = bottom }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                
                if let data = obj.getParamValue(key: .data) as? BlockData {
                    //self.title = data.name
                    self.menuId = data.menuId
                } else {
                    self.menuId = obj.getParamValue(key: .id) as? String
                    
                }
                self.title = obj.getParamValue(key: .title) as? String ?? self.title
                
                let action = MenuNaviActionBodyItem(category:WatchedBlockType.mobile.category)  //btv
                self.naviLogManager.actionLog(.pageShow, pageId: .recentContents , actionBody: action)
            }
            .onDisappear{
                
            }
        }//geo
    }//body
   
    
}




