//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PageCertification: PageView {
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
    @State var marginBottom:CGFloat = Dimen.app.bottom
    @State var title:String? = nil
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: self.title ?? String.pageTitle.certificationUser,
                        isClose: true
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
                            BtvWebView( viewModel: self.webViewModel , useNativeScroll:false)
                                .modifier(MatchHorizontal(height: self.webViewHeight))
                                .background(Color.app.white)
                                .onReceive(self.webViewModel.$screenHeight){height in
                                    self.setWebviewSize(geometry: geometry)
                                }
                        }
                        
                    }
                    .padding(.bottom, self.sceneObserver.safeAreaIgnoreKeyboardBottom)
                    .modifier(MatchParent())
                    
                    .onReceive(self.infinityScrollModel.$event){evt in
                        guard let evt = evt else {return}
                        switch evt {
                        case .pullCompleted :
                            self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                        case .pullCancel :
                            self.pageDragingModel.uiEvent = .pullCancel(geometry)
                        default : break
                        }
                    }
                    .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                        self.pageDragingModel.uiEvent = .pull(geometry, pos)
                    }
                }
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
                    let linkUrl = ApiPath.getRestApiPath(.WEB) + BtvWebView.identity
                    self.webViewModel.request = .link(linkUrl)
                }
            }
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation{ self.marginBottom = bottom }
                    self.setWebviewSize(geometry: geometry)
                }
            }
            .onReceive(self.sceneObserver.$isUpdated){ isUpdated in
                if isUpdated {
                    self.setWebviewSize(geometry: geometry)
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let data = obj.getParamValue(key: .data) as? PageObject {
                    self.movePage = data
                }
                if let title = obj.getParamValue(key: .title) as? String {
                    self.title = title
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
    private func setWebviewSize(geometry:GeometryProxy){
        self.webViewHeight = geometry.size.height
            - Dimen.app.top
    
            - self.sceneObserver.safeAreaTop
            - self.sceneObserver.safeAreaIgnoreKeyboardBottom
    }
   
}

#if DEBUG
struct PageCertification_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageCertification().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
               
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
