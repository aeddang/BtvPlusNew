//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PageMyBenefits: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var viewPagerModel:ViewPagerModel = ViewPagerModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @ObservedObject var couponScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var couponModel:CouponBlockModel = CouponBlockModel()
    
    @ObservedObject var pointScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var pointModel:CouponBlockModel = CouponBlockModel()
    
    @ObservedObject var cashScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var cashModel:CouponBlockModel = CouponBlockModel()
   
    @State var useTracking:Bool = false
    @State var pages: [PageViewProtocol] = []
    let titles: [String] = [
        String.pageText.myBenefitsCoupon,
        String.pageText.myBenefitsPoint,
        String.pageText.myBenefitsCash
    ]
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.myBenefits,
                        isClose: true,
                        style: .dark
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    CPPageViewPager(
                        pageObservable: self.pageObservable,
                        viewModel: self.viewPagerModel,
                        pages: self.pages,
                        titles: self.titles)
                        { idx in
                            switch idx {
                            case 0 : self.couponModel.initUpdate()
                            case 1 : self.pointModel.initUpdate()
                            case 2 : self.cashModel.initUpdate()
                            default : break
                            }
                        }
                }
                .modifier(PageFull(style:.dark))
                .modifier(PageDragingSecondPriority(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            .onReceive(self.couponScrollModel.$scrollPosition){ pos in
                self.viewPagerModel.request = .reset
            }
            .onReceive(self.pointScrollModel.$scrollPosition){ pos in
                self.viewPagerModel.request = .reset
            }
            .onReceive(self.cashScrollModel.$scrollPosition){ pos in
                self.viewPagerModel.request = .reset
            }
            .onReceive(self.couponScrollModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pullCompleted:
                    self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                case .pullCancel :
                    self.pageDragingModel.uiEvent = .pullCancel(geometry)
                default : break
                }
            }
            .onReceive(self.couponScrollModel.$pullPosition){pos in
                self.pageDragingModel.uiEvent = .pull(geometry, pos)
            }
            .onReceive(self.pointScrollModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pullCompleted:
                    self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                case .pullCancel :
                    self.pageDragingModel.uiEvent = .pullCancel(geometry)
                default : break
                }
            }
            .onReceive(self.pointScrollModel.$pullPosition){pos in
                self.pageDragingModel.uiEvent = .pull(geometry, pos)
            }
            .onReceive(self.cashScrollModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pullCompleted:
                    self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                case .pullCancel :
                    self.pageDragingModel.uiEvent = .pullCancel(geometry)
                default : break
                }
            }
            .onReceive(self.cashScrollModel.$pullPosition){pos in
                self.pageDragingModel.uiEvent = .pull(geometry, pos)
            }
            
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                self.useTracking = page?.id == self.pageObject?.id
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
            .onAppear{
                if let obj = self.pageObject  {
                    if let idx = obj.getParamValue(key: .id) as? Int {
                        self.viewPagerModel.index = idx
                    }
                }
                self.pages = [
                    CouponBlock(
                        infinityScrollModel:self.couponScrollModel,
                        viewModel:self.couponModel,
                        pageObservable:self.pageObservable,
                        useTracking:true,
                        type: .coupon
                    ),
                    CouponBlock(
                        infinityScrollModel:self.pointScrollModel,
                        viewModel:self.pointModel,
                        pageObservable:self.pageObservable,
                        useTracking:true,
                        type: .point
                    ),
                    CouponBlock(
                        infinityScrollModel:self.cashScrollModel,
                        viewModel:self.cashModel,
                        pageObservable:self.pageObservable,
                        useTracking:true,
                        type: .cash
                    )
                ]
            }
            .onDisappear{
               
            }
        }//geo
    }//body
    
   
}

#if DEBUG
struct PageMyBenefits_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMyBenefits().contentBody
                .environmentObject(Repository())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
                .environmentObject(Pairing())
                .frame(width: 565, height: 640, alignment: .center)
        }
    }
}
#endif
