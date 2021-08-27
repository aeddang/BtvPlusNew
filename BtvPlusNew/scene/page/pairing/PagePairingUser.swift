//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PagePairingUser: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var webViewModel = WebViewModel()
    
    @State var webViewHeight:CGFloat = 0
  
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.connectCertificationBtv,
                        isClose: true,
                        style: .white
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    
                    ZStack(alignment: .topLeading){
                        DragDownArrow(
                            infinityScrollModel: self.infinityScrollModel)
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            scrollType : .web(isDragEnd: true),
                            isRecycle:false,
                            useTracking:true
                        ){
                            BtvWebView( viewModel: self.webViewModel )
                                .modifier(MatchHorizontal(height: self.webViewHeight))
                                .onReceive(self.webViewModel.$screenHeight){height in
                                    self.webViewHeight = geometry.size.height
                                        - Dimen.app.top
                                        - self.sceneObserver.safeAreaTop
                                        - self.sceneObserver.safeAreaBottom
                                }
                            
                        }
                    }
                    .padding(.bottom, self.sceneObserver.safeAreaBottom)
                    .modifier(MatchParent())
                    
                    .onReceive(self.infinityScrollModel.$event){evt in
                        guard let evt = evt else {return}
                        switch evt {
                        case .pullCompleted :
                            self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                        case .pullCancel :
                            self.pageDragingModel.uiEvent = .pullCancel(geometry)
                        default : do{}
                        }
                    }
                    .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                        self.pageDragingModel.uiEvent = .pull(geometry, pos)
                    }
                }
                .modifier(PageFull(style: .white))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            .onReceive(self.pairing.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .connected :
                    self.pagePresenter.closePopup(self.pageObject?.id)
                case .connectError(let header) :
                    self.appSceneObserver.alert = .pairingError(header)
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
                                self.repository.updateFirstMemberAuth()
                                self.appSceneObserver.alert = .alert(
                                    String.alert.identifySuccess, String.alert.identifySuccessMe){
                                        self.pagePresenter.openPopup(
                                            PageProvider.getPageObject(.pairingDevice)
                                                .addParam(key: .type, value: PairingRequest.user(cid))
                                        )
                                    }
                            }else{
                                self.appSceneObserver.alert = .alert(
                                    String.alert.identifyFail, String.alert.identifyFailMe, nil)
                            }
                        }else{
                            self.appSceneObserver.alert = .alert(
                                String.alert.identifyFail, String.alert.identifyFailMe, nil)
                        }
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    }
                default : break
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
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
