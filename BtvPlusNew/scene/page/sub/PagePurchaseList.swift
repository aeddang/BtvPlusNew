//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine


struct PagePurchaseList: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:PurchaseBlockModel = PurchaseBlockModel()
    
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
                        title: String.pageTitle.purchaseList,
                        isBack : true,
                        style: .dark
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    PurchaseBlock(
                        infinityScrollModel:self.infinityScrollModel,
                        viewModel:self.viewModel,
                        pageObservable:self.pageObservable,
                        useTracking:self.useTracking
                    )
                }
                .modifier(PageFull(style:.dark))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
                if ani {
                    self.viewModel.update(menuId:self.menuId, key:nil)
                }
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                self.useTracking = page?.id == self.pageObject?.id
            }
            .onAppear{
                
            }
            .onDisappear{
               
            }
        }//geo
    }//body
   
    
}




