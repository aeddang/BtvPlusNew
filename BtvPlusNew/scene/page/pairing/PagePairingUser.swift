//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PagePairingUser: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var webViewModel = WebViewModel()
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: .constant(String.pageTitle.connectCertificationBtv),
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    CPWebView(
                        viewModel: self.webViewModel
                    )
                }
                .modifier(PageFull())
                
                .highPriorityGesture(
                    DragGesture(minimumDistance: 20, coordinateSpace: .local)
                        .onChanged({ value in
                            self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ _ in
                            self.pageDragingModel.uiEvent = .draged(geometry)
                        })
                )
            }//draging
            .onReceive(self.pairing.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .connected :
                    self.pagePresenter.closePopup(self.pageObject?.id)
                case .connectError(let header) :
                    self.pageSceneObserver.alert = .pairingError(header)
                default : do{}
                }
            }
            .onAppear{
                let linkUrl = ApiPath.getRestApiPath(.WEB) + "/view/v3.0/identityverification"
                self.webViewModel.event = .link(linkUrl)
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    
   
}

#if DEBUG
struct PagePairingUser_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePairingUser().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(SceneObserver())
                .environmentObject(PageSceneObserver())
                .environmentObject(KeyboardObserver())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
