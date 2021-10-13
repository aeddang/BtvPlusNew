//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PageCashCharge: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var viewModel:BuzzViewModel = BuzzViewModel()
    @State var title:String? = nil
    @State var webViewHeight:CGFloat = 0
    @State var isBuzzReady = false
    @State var isUiReady = false
    var body: some View {
        GeometryReader { geometry in
        
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                if self.isUiReady{
                    BuzzView(
                        viewModel:self.viewModel
                    )
                    .modifier(PageFull(style:.white))
                } else {
                    Spacer().modifier(MatchParent())
                        .modifier(PageFull(style:.white))
                }
            }//draging
            .onReceive(self.viewModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .close : self.pagePresenter.closePopup(self.pageObject?.id)
                case .info(let v) :
                    self.appSceneObserver.alert =
                        .confirm(String.alert.cashCharge,
                                 String.alert.cashChargeText,
                                 confirmText: String.alert.cashChargeButton){ isOk in
                        if !isOk {return}
                            BuzzAdBenefit.showInquiryPage(on: v, unitId: SystemEnvironment.isStage
                                                          ? Buzz.BAB_SDK_KR_iOS_DEV_UNIT_ID : Buzz.BAB_SDK_KR_iOS_PRD_UNIT_ID )
                    }
                    
                }
                
            }
            .onReceive(self.pageObservable.$isAnimationComplete) { ani in
                if ani {
                    withAnimation{
                        self.isUiReady = true
                    }
                }
            }
            .onAppear{
                Buzz.initate()
                //self.appSceneObserver.isApiLoading = true
                Buzz().initate(pairing: self.pairing){
                    //self.appSceneObserver.isApiLoading = false
                    withAnimation{
                        self.isBuzzReady = true
                    }
                }
            }
            .onDisappear{
                Buzz().destory()
            }
            
        }//geo
    }//body
    
   
}

#if DEBUG
struct PageCashCharge_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageCashCharge().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
