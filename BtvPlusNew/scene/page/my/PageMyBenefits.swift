//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
extension PageMyBenefits{
    enum MenuType: Int {
        case coupon = 0
        case point = 1
        case cash = 2
        case discount = 3
    }
    static func getType(_ value:String)->MenuType{
        switch value {
            case "point": return .cash
            case "coupon": return .coupon
            case "bpoint": return .point
        default : return .coupon
        }
    }
}

struct PageMyBenefits: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pairing:Pairing
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
    
    @ObservedObject var cardModel:CardBlockModel = CardBlockModel()
   
    @State var useTracking:Bool = false
    @State var pages: [PageViewProtocol] = []
    @State var titles: [String] = []
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.myBenefits,
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
                            isDivisionTab: SystemEnvironment.isTablet
                                ? true
                            : self.pairing.pairingDeviceType == .apple ? true  : false
                            )
                            { idx in
                                switch idx {
                                case 0 : self.couponModel.initUpdate()
                                case 1 : self.pointModel.initUpdate()
                                case 2 :
                                    if self.pairing.pairingDeviceType == .apple {
                                        self.cardModel.initUpdate(type: .member)
                                    } else {
                                        self.cashModel.initUpdate()
                                    }
                                case 3 : self.cardModel.initUpdate(type: .member)
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
           
            .onReceive(self.couponScrollModel.$scrollPosition){ pos in
                self.viewPagerModel.request = .reset
            }
            .onReceive(self.pointScrollModel.$scrollPosition){ pos in
                self.viewPagerModel.request = .reset
            }
            .onReceive(self.cashScrollModel.$scrollPosition){ pos in
                self.viewPagerModel.request = .reset
            }
            
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
                if ani {
                    let coupon = CouponBlock(
                        infinityScrollModel:self.couponScrollModel,
                        viewModel:self.couponModel,
                        pageObservable:self.pageObservable,
                        useTracking:true,
                        type: .coupon
                    )
                    
                    let point = CouponBlock(
                        infinityScrollModel:self.pointScrollModel,
                        viewModel:self.pointModel,
                        pageObservable:self.pageObservable,
                        useTracking:true,
                        type: .point
                    )
                    
                    let cash = CouponBlock(
                        infinityScrollModel:self.cashScrollModel,
                        viewModel:self.cashModel,
                        pageObservable:self.pageObservable,
                        useTracking:true,
                        type: .cash
                    )
                    
                    let discount = DiscountView(
                        viewPagerModel: self.viewPagerModel,
                        cardModel: self.cardModel,
                        pageObservable: self.pageObservable
                    )
                    if self.pairing.pairingDeviceType == .apple {
                        self.pages = [
                            coupon, point, discount
                        ]
                        self.titles = [
                            String.pageText.myBenefitsCoupon,
                            String.pageText.myBenefitsPoint,
                            String.pageText.myBenefitsDiscount
                        ]
                    } else {
                        self.pages = [
                            coupon, point, cash, discount
                        ]
                        self.titles = [
                            String.pageText.myBenefitsCoupon,
                            String.pageText.myBenefitsPoint,
                            String.pageText.myBenefitsCash,
                            String.pageText.myBenefitsDiscount
                        ]
                    }
                    
                }
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
