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
    @EnvironmentObject var naviLogManager:NaviLogManager
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var webViewModel = WebViewModel()
    
    
    @State var title:String? = nil
    @State var marginBottom:CGFloat = Dimen.app.bottom
    @State var marginOffSet:CGFloat = 0
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
                    BtvWebView( viewModel: self.webViewModel)
                        .modifier(MatchParent())
                        
                }
                .padding(.bottom, self.marginBottom - self.marginOffSet)
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
                self.marginBottom = bottom
                
            }
            .onAppear{
                self.marginBottom = self.appSceneObserver.safeBottomLayerHeight
                guard let obj = self.pageObject  else { return }
                let pushId = obj.getParamValue(key: .pushId) as? String ?? ""
                self.title = obj.getParamValue(key: .title) as? String
                if let link = obj.getParamValue(key: .data) as? String{
                    if link.contains(BtvWebView.event) == true {
                        self.naviLogManager.actionLog(.pageShow, pageId: .event, actionBody: .init(category:pushId))
                        self.marginOffSet = Dimen.margin.regular
                    }
                    if link.contains(BtvWebView.tip) == true {
                        self.marginOffSet = Dimen.margin.regular
                    }
                    if link.hasPrefix("http") { self.webViewModel.request = .link(link) }
                    else {self.webViewModel.request = .link(ApiPath.getRestApiPath(.WEB) + link)}
                }
                PageLog.d("self.marginOffSet " + self.marginOffSet.description, tag: self.tag)
                
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    
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
