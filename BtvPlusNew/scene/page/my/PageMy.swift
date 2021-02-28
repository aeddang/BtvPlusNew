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
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @State var isPairing:Bool = false
    
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
                    if self.isPairing {
                        PairingBlock()
                    }else {
                        DisconnectBlock()
                    }
                }
                .highPriorityGesture(
                    DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
                        .onChanged({ value in
                            self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ _ in
                            self.pageDragingModel.uiEvent = .draged(geometry)
                        })
                )
                .gesture(
                    self.pageDragingModel.cancelGesture
                        .onChanged({_ in self.pageDragingModel.uiEvent = .dragCancel})
                        .onEnded({_ in self.pageDragingModel.uiEvent = .dragCancel})
                )
                .modifier(PageFull())
            }
            .onReceive(self.pairing.$status){status in
                self.isPairing = ( status == .pairing )
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
                .environmentObject(SceneObserver())
                .environmentObject(PageSceneObserver())
                .environmentObject(NetworkObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
