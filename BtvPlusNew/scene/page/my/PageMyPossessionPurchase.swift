//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PageMyPossessionPurchase: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @ObservedObject var collectionScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var collectionModel:PurchaseBlockModel = PurchaseBlockModel()
   
    @State var useTracking:Bool = false
    @State var pages: [PageViewProtocol] = []
    let titles: [String] = [
        String.app.rent,
        String.app.owner
    ]
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.myTerminatePurchase,
                        isBack: true,
                        style: .dark
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    PurchaseBlock(
                        infinityScrollModel:self.collectionScrollModel,
                        viewModel:self.collectionModel,
                        pageObservable:self.pageObservable,
                        useTracking:true,
                        type: .possession
                    )
                }
                .modifier(PageFull(style:.dark))
                .modifier(PageDragingSecondPriority(geometry: geometry, pageDragingModel: self.pageDragingModel))
                .clipped()
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
                if ani {
                    self.collectionModel.initUpdate()
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

#if DEBUG
struct PageMyPossessionPurchase_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMyPossessionPurchase().contentBody
                .environmentObject(Repository())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
                .environmentObject(Pairing())
                .frame(width: 320, height: 640, alignment: .center)
        }
    }
}
#endif
