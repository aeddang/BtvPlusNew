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
  
    @State var movePage:PageObject? = nil
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
                        title: String.oksusu.certification,
                        isClose: true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    HStack(alignment: .top, spacing:0){
                        BtvWebView( viewModel: self.webViewModel)
                        Spacer().modifier(MatchVertical(width: 0))
                    }
                    .modifier(MatchParent())
                    .background(Color.app.white)
    
                }
                .padding(.bottom, self.marginBottom)
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            
            .onReceive(self.webViewModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .callFuncion(let method, let json, _) :
                    if method == WebviewMethod.bpn_setIdentityVerfResult.rawValue {
                        if let jsonData = json?.parseJson() {
                            if let ci = jsonData["ci"] as? String {
                                /*
                                self.isCompleted = true
                                self.repository.updateFirstMemberAuth()
                                self.appSceneObserver.alert = .alert(
                                    String.alert.identifySuccess, String.alert.identifySuccessMe, nil){
        
                                    self.pagePresenter.onPageEvent(
                                        self.pageObject,
                                        event:.init(type: .certification, data: ci))
                                    
                                }
                                
                                if let page = self.movePage {
                                    if page.isPopup {
                                        self.pagePresenter.openPopup(page.addParam(key: .cid, value: ci))
                                    } else {
                                        self.pagePresenter.changePage(page.addParam(key: .cid, value: ci))
                                    }
                                }
                                self.pagePresenter.closePopup(self.pageObject?.id)
                               */
                            }else{
                                self.appSceneObserver.alert = .alert(
                                    String.alert.identifyFail, String.alert.identifyFailMe, nil)
                            }
                        }else{
                            self.appSceneObserver.alert = .alert(
                                String.alert.identifyFail, String.alert.identifyFailMe, nil)
                            
                        }
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
                guard let obj = self.pageObject  else { return }
                if let data = obj.getParamValue(key: .data) as? PageObject {
                    self.movePage = data
                }
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
