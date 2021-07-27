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
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                BuzzView(
                    viewModel:self.viewModel
                )
                .modifier(PageFull())
                
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
                        
                            BuzzAdBenefit.showInquiryPage(on: v)
                    }
                    
                }
                
            }
            .onAppear{
                Buzz.initate()
                Buzz().initate(pairing: self.pairing)
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
