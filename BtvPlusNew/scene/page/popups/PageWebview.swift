//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct WebviewJson :Codable{
    var url:String? = nil
    var title:String? = nil
    init(json: [String:Any]) throws {}
}

struct PageWebview: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var webViewModel = WebViewModel()
    
    @State var webViewHeight:CGFloat = 0
   
    @State var title:String? = nil
    @State var marginBottom:CGFloat = Dimen.app.bottom
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    if self.title != nil {
                        PageTab(
                            title: self.title,
                            isClose: true
                        )
                        .padding(.top, self.sceneObserver.safeAreaTop)
                    }
                    ZStack(alignment: .topLeading){
                        DragDownArrow(
                            infinityScrollModel: self.infinityScrollModel)
                        /*
                        BtvWebView( viewModel: self.webViewModel )
                            .modifier(MatchHorizontal(height: self.webViewHeight))
                            .modifier(MatchParent())
                            .padding(.bottom, self.marginBottom)
                        */
                        
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            scrollType : .web(isDragEnd: true),
                            isRecycle:false,
                            useTracking:true ){
                            BtvWebView( viewModel: self.webViewModel , useNativeScroll:false)
                                .modifier(MatchHorizontal(height: self.webViewHeight))
                                .onReceive(self.webViewModel.$screenHeight){height in
                                    self.setWebviewSize(geometry: geometry)
                                }
                        }
                        .padding(.bottom, self.marginBottom)
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
                }
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//draging
            .onReceive(self.webViewModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .callFuncion(let method, _, _) :
                    switch method {
                    case WebviewMethod.bpn_closeWebView.rawValue :
                        self.pagePresenter.goBack()
                        break
                    default : break
                    }
                    
                default : break
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
                self.marginBottom = self.appSceneObserver.safeBottomLayerHeight
                guard let obj = self.pageObject  else { return }
                self.title = obj.getParamValue(key: .title) as? String
                if let link = obj.getParamValue(key: .data) as? String{
                    if link.hasPrefix("http") { self.webViewModel.request = .link(link) }
                    else {self.webViewModel.request = .link(ApiPath.getRestApiPath(.WEB) + link)}
                }
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    
    private func setWebviewSize(geometry:GeometryProxy){
        self.webViewHeight = geometry.size.height
            - Dimen.app.top
            - (self.appSceneObserver.useBottom ? Dimen.app.bottom : 0)
            - self.sceneObserver.safeAreaTop
            - self.sceneObserver.safeAreaIgnoreKeyboardBottom
    }
}

#if DEBUG
struct PageWebview_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageWebview().contentBody
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
