//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PageOksusuCertification: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var webViewModel = WebViewModel()
    
    @State var webViewHeight:CGFloat = 0
  
    @State var title:String? = nil
    @State var isCompleted:Bool = false
    @State var marginBottom:CGFloat = 0
   
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: self.title ?? String.oksusu.certification,
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    BtvWebView( viewModel: self.webViewModel)
                    .modifier(MatchParent())
                }
                .padding(.bottom, self.marginBottom)
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            .onReceive(self.webViewModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .callFuncion(let method, let json, _) :
                    switch method {
                    case WebviewMethod.bpn_setOssVerificationResult.rawValue :
                        if let jsonData = json?.parseJson() {
                            if let stbid = jsonData["stbid"] as? String {
                                self.pagePresenter.onPageEvent(
                                    self.pageObject,
                                    event:.init(type: .certification, data: stbid))
                                self.pagePresenter.closePopup(self.pageObject?.id)
                            }
                        }else{
                            self.appSceneObserver.alert = .alert(
                                String.alert.identifyFail, String.alert.identifyFailMe, nil)
                            
                        }
                    case WebviewMethod.bpn_setIdentityVerfResult.rawValue :
                        if let jsonData = json?.parseJson() {
                            if let ci = jsonData["ci"] as? String {
                                // 
                            }else{
                                self.appSceneObserver.alert = .alert(
                                    String.alert.identifyFail, String.alert.identifyFailMe, nil)
                            }
                        }else{
                            self.appSceneObserver.alert = .alert(
                                String.alert.identifyFail, String.alert.identifyFailMe, nil)
                            
                        }
                    case WebviewMethod.bpn_closeWebView.rawValue :
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    case WebviewMethod.bpn_showTopBar.rawValue :
                        guard let json = json else { return }
                        guard let param = AppUtil.getJsonParam(jsonString: json) else { return }
                        if let title = param["title"] as? String {
                            self.title = title
                        }
                    default : break
                    }
                    
                default : break
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    let linkUrl = ApiPath.getRestApiPath(.WEB) + BtvWebView.oksusuIdentity + "?type=oksusu&reqWeb=false"
                    self.webViewModel.request = .link(linkUrl)
                }
            }
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                self.marginBottom = bottom
            }
            
            .onAppear{
                
            }
            .onDisappear{
                if !self.isCompleted {
                    self.pagePresenter.onPageEvent(
                        self.pageObject,
                        event:.init(type: .certification, data: nil))
                }
            }
            
        }//geo
    }//body
    
   
}

#if DEBUG
struct PageOksusuCertification_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageOksusuCertification().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
               
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
