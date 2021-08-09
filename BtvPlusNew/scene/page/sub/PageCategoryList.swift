//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine


struct PageCategoryList: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var viewModel:CateBlockModel = CateBlockModel()
    @State var title:String? = nil
    @State var listType:CateBlock.ListType = .poster
    @State var cardType:BlockData.CardType? = nil
    @State var menuId:String? = nil
    @State var blockData:BlockData? = nil
    @State var useTracking:Bool = false
    @State var marginBottom:CGFloat = 0
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
                    CateBlock(
                        pageObservable: self.pageObservable,
                        infinityScrollModel:self.infinityScrollModel,
                        viewModel:self.viewModel,
                        useTracking:self.useTracking,
                        marginBottom:self.marginBottom + Dimen.margin.regular
                    )
                    .background(Color.brand.bg)
                    
                }
                
                .modifier(PageFull(style:.dark))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    if let data = self.blockData {
                        self.viewModel.update(data: data, listType:self.listType,
                                              cardType: self.cardType, isAdult:data.isAdult, key:nil)
                    }else{
                        self.viewModel.update(menuId:self.menuId, listType:self.listType,
                                              cardType: self.cardType, isAdult:false, key:nil)
                    }
                }
                self.useTracking = ani
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                self.useTracking = page?.id == self.pageObject?.id
            }
            .onReceive(self.sceneObserver.$safeAreaIgnoreKeyboardBottom){ bottom in
                self.marginBottom = self.sceneObserver.safeAreaIgnoreKeyboardBottom
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let data = obj.getParamValue(key: .data) as? BlockData {
                    self.title = data.name
                    self.blockData = data
                } else {
                    self.menuId = obj.getParamValue(key: .id) as? String
                    
                }
                self.title = obj.getParamValue(key: .title) as? String ?? self.title 
                self.listType = obj.getParamValue(key: .type) as? CateBlock.ListType ?? .poster
                self.cardType = obj.getParamValue(key: .subType) as? BlockData.CardType
            }
            .onDisappear{
               
            }
        }//geo
    }//body
   
    
}


#if DEBUG
struct PageCate_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageCategoryList().contentBody
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

