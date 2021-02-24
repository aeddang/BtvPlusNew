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
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var webViewModel = WebViewModel()
    
    @State var webViewHeight:CGFloat = 0
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.connectCertificationBtv,
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    InfinityScrollView( viewModel: self.infinityScrollModel ){
                        BtvWebView( viewModel: self.webViewModel )
                            .modifier(MatchHorizontal(height: self.webViewHeight))
                            .onReceive(self.webViewModel.$screenHeight){height in
                                self.webViewHeight = max(
                                    height,
                                    geometry.size.height - Dimen.app.pageTop  )
                            }
                    }
                    .modifier(MatchParent())
                    .onReceive(self.infinityScrollModel.$scrollPosition){pos in
                        self.pageDragingModel.uiEvent = .dragCancel
                    }
                    .onReceive(self.infinityScrollModel.$event){evt in
                        guard let evt = evt else {return}
                        switch evt {
                        case .pullCancel : self.pageDragingModel.uiEvent = .pulled(geometry)
                        default : do{}
                        }
                    }
                    .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                        self.pageDragingModel.uiEvent = .pull(geometry, pos)
                    }
                }
                .modifier(PageFull())
                .highPriorityGesture(
                    DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
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
            .onReceive(self.webViewModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .callFuncion(let method, let json, _) :
                    if method == WebviewMethod.bpn_setIdentityVerfResult.rawValue {
                        if let jsonData = json?.parseJson() {
                            if let cid = jsonData["ci"] as? String {
                                self.pageSceneObserver.alert = .alert(
                                    String.alert.identifySuccess, String.alert.identifySuccessMe, nil)
                                self.pagePresenter.openPopup(
                                    PageProvider.getPageObject(.pairingDevice)
                                        .addParam(key: .type, value: PairingRequest.user(cid))
                                )
                            }else{
                                self.pageSceneObserver.alert = .alert(
                                    String.alert.identifyFail, String.alert.identifyFailMe, nil)
                            }
                        }else{
                            self.pageSceneObserver.alert = .alert(
                                String.alert.identifyFail, String.alert.identifyFailMe, nil)
                        }
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    }
                default : do{}
                }
            }
            .onAppear{
                let linkUrl = ApiPath.getRestApiPath(.WEB) + BtvWebView.identity
                self.webViewModel.request = .link(linkUrl)
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
