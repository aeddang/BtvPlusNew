//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PageMy: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var watchedScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    @State var isPairing:Bool = false
    @State var marginBottom:CGFloat = 0
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.my,
                        isBack : true,
                        isSetting: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    InfinityScrollView(
                        viewModel: self.infinityScrollModel,
                        isRecycle:false,
                        useTracking: false
                        ){
                        if self.isPairing {
                            PairingView(
                                pageObservable:self.pageObservable,
                                pageDragingModel: self.pageDragingModel,
                                watchedScrollModel:self.watchedScrollModel
                            )
                            .onReceive(self.pageDragingModel.$nestedScrollEvent){evt in
                                guard let evt = evt else {return}
                                switch evt {
                                case .pullCompleted :
                                    self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                                case .pullCancel :
                                    self.pageDragingModel.uiEvent = .pullCancel(geometry)
                                case .pull(let pos) :
                                    self.pageDragingModel.uiEvent = .pull(geometry, pos)
                                default: break
                                }
                            }
                            
                        }else {
                            DisconnectView(
                                pageObservable:self.pageObservable
                            )
                        }
                    }
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//PageDragingBody
            .padding(.bottom, self.marginBottom)
            .onReceive(self.pairing.$status){status in
                self.isPairing = ( status == .pairing )
            }
            .onReceive(self.sceneObserver.$safeAreaIgnoreKeyboardBottom){ bottom in
                self.marginBottom = self.sceneObserver.safeAreaBottom + Dimen.app.bottom
            }
            .onAppear{
               
            }
        }//geo
    }//body
    
    

}

#if DEBUG
struct PageMy_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMy().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(NetworkObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
