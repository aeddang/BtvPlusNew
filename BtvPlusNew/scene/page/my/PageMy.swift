//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PageMy: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var watchedScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    
    @State var isPairing:Bool = false
    @State var marginBottom:CGFloat = 0
    @State var isOksusu:Bool = false
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
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
                    if self.isPairing {
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            marginBottom:self.marginBottom,
                            isRecycle:false,
                            useTracking: true
                            ){
                            PairingView(
                                pageObservable:self.pageObservable,
                                pageDragingModel: self.pageDragingModel,
                                watchedScrollModel:self.watchedScrollModel,
                                geometry: geometry,
                                isOksusu: self.isOksusu
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
                        }
                    } else {
                        DisconnectView(
                            pageObservable:self.pageObservable,
                            isOksusu: self.isOksusu
                        )
                        .padding(.bottom,
                                 self.sceneObserver.safeAreaIgnoreKeyboardBottom + Dimen.app.bottom)
                    }
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//PageDragingBody
            
            .onReceive(self.pairing.$status){status in
                self.isPairing = ( status == .pairing )
            }
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation{ self.marginBottom = bottom }
                }
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                self.setOksusuStatus()
            }
            
            .onAppear{
                self.marginBottom = self.appSceneObserver.safeBottomLayerHeight
                //self.repository.namedStorage?.oksusu = "{F-C9EF3812EAD-420A-B899-E8B55EB70644}"
                self.setOksusuStatus()
                /*
                if self.isOksusu {
                    self.dataProvider.requestData(q: .init(id: self.tag, type: .checkOksusu, isOptional: true))
                }
                */
            }
        }//geo
    }//body
    
    private func setOksusuStatus(){
       
        let isConnect = self.repository.namedStorage?.oksusu.isEmpty == false
        let isPurchaseConnect = self.repository.namedStorage?.oksusuPurchase.isEmpty == false
       
        if self.pairing.status == .pairing {
            self.isOksusu = isConnect && !isPurchaseConnect
        } else {
            self.isOksusu = isConnect
        }
    }
    

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
