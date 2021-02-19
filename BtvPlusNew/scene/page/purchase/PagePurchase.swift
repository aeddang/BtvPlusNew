//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PagePurchase: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:SceneObserver
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var networkObserver:NetworkObserver
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
                        title: String.pageTitle.purchase,
                        isClose: true,
                        style: .white
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    
                    InfinityScrollView( viewModel: self.infinityScrollModel ){
                        VStack{
                            BtvWebView( viewModel: self.webViewModel )
                                .modifier(MatchHorizontal(height: self.webViewHeight))
                                .onReceive(self.webViewModel.$screenHeight){height in
                                    let min = geometry.size.height - self.sceneObserver.safeAreaTop - Dimen.app.top
                                    self.webViewHeight = max( height, min)
                                }
                        }
                        
                    }
                    .padding(.bottom, self.sceneObserver.safeAreaBottom)
                    .modifier(MatchParent())
                    .onReceive(self.infinityScrollModel.$scrollPosition){pos in
                        self.pageDragingModel.uiEvent = .dragCancel(geometry)
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
                .modifier(PageFull(bgColor:Color.app.white))
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
                case .callFuncion(let method, let json, let cbName) :
                    switch method {
                    case WebviewMethod.getSTBInfo.rawValue :
                        guard let cb = cbName else { return }
                        if cb.isEmpty { return }
                        let dic = self.repository.getSTBInfo(isWifi: self.networkObserver.status == .wifi)
                        let jsonString = AppUtil.getJsonString(dic: dic) ?? ""
                        ComponentLog.d("jsonString : " + jsonString, tag: self.tag)
                        let js = BtvWebView.callJsPrefix + cb + "(\'" + jsonString + "\')"
                        ComponentLog.d(js, tag: self.tag)
                        self.webViewModel.request = .evaluateJavaScript(js)
                        
                    case WebviewMethod.bpn_setPurchaseResult.rawValue : break
                    default : break
                    }
                    
                default : do{}
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                let data = obj.getParamValue(key: .data) as? PurchaseWebviewModel
                let linkUrl = ApiPath.getRestApiPath(.WEB) + BtvWebView.purchase + (data?.gurry ?? "")
                self.webViewModel.request = .link(linkUrl)
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    
   
}

#if DEBUG
struct PagePurchase_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePurchase().contentBody
                .environmentObject(Repository())
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
