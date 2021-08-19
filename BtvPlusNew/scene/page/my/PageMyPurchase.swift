//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PageMyPurchase: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var viewPagerModel:ViewPagerModel = ViewPagerModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @ObservedObject var purchaseScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var purchaseModel:PurchaseBlockModel = PurchaseBlockModel()
    
    @ObservedObject var collectionScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var collectionModel:PurchaseBlockModel = PurchaseBlockModel()
   
    @State var pages: [PageViewProtocol] = []
    @State var marginBottom:CGFloat = 0
    let titles: [String] = [
        String.app.rent,
        String.app.owner
    ]
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.purchaseList,
                        isBack: true,
                        style: .dark
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    if !self.pages.isEmpty {
                        CPPageViewPager(
                            pageObservable: self.pageObservable,
                            viewModel: self.viewPagerModel,
                            pages: self.pages,
                            titles: self.titles,
                            usePull: .horizontal)
                            { idx in
                                switch idx {
                                case 0 : self.purchaseModel.initUpdate()
                                case 1 : self.collectionModel.initUpdate()
                                default : break
                                }
                            }
                    } else {
                        Spacer()
                    }
                }
                .modifier(PageFull(style:.dark))
                .modifier(PageDragingSecondPriority(geometry: geometry, pageDragingModel: self.pageDragingModel))
                .clipped()
            }
            
            .onReceive(self.purchaseScrollModel.$scrollPosition){ pos in
                self.viewPagerModel.request = .reset
            }
            .onReceive(self.collectionScrollModel.$scrollPosition){ pos in
                self.viewPagerModel.request = .reset
            }
            .onReceive(self.viewPagerModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pullCompleted:
                    self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                case .pullCancel :
                    self.pageDragingModel.uiEvent = .pullCancel(geometry)
                case .pull(let pos) :
                    self.pageDragingModel.uiEvent = .pull(geometry, pos)
                }
            }
            
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.pages = [
                        PurchaseBlock(
                            infinityScrollModel:self.purchaseScrollModel,
                            viewModel:self.purchaseModel,
                            pageObservable:self.pageObservable,
                            useTracking:true,
                            marginBottom: self.marginBottom,
                            type: .normal
                        ),
                        PurchaseBlock(
                            infinityScrollModel:self.collectionScrollModel,
                            viewModel:self.collectionModel,
                            pageObservable:self.pageObservable,
                            useTracking:true,
                            marginBottom: self.marginBottom,
                            type: .collection
                        )
                    ]
                }
            }
            
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                withAnimation{ self.marginBottom = bottom }
            }
            .onAppear{
                
            }
            .onDisappear{
               
            }
        }//geo
    }//body
    
   
}

#if DEBUG
struct PageMyPurchase_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMyPurchase().contentBody
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
