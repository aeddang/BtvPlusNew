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
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var webViewModel = WebViewModel()
    
    @State var purchaseId:String? = nil
    @State var purchaseWebviewModel:PurchaseWebviewModel? = nil
    @State var marginBottom:CGFloat = 0
    @State var purchaseLink:String = ""
    @State var isRetryPurchase:Bool = false
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.purchase,
                        isClose: true,
                        style: .white
                    ){
                        self.sendLog(action: .clickOrderCompletedConfirm)
                        self.pagePresenter.goBack()
                    }
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    BtvWebView( viewModel: self.webViewModel)
                        .modifier(MatchParent())
                }
                .padding(.bottom, self.marginBottom)
                .modifier(PageFull(style:.white))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }//dragin
            .onReceive(self.webViewModel.$event){ evt in
                guard let evt = evt else {return}
                switch evt {
                case .callFuncion(let method, let json, _) :
                    switch method {
                    case WebviewMethod.bpn_setPurchaseResult.rawValue :
                        guard let json = json else { return }
                        guard let param = AppUtil.getJsonParam(jsonString: json) else { return }
                        if let result = param["result"] as? Bool,let pid = param["pid"] as? String {
                            if !result {
                                self.isRetryPurchase = true
                                return
                            }
                            if pid.isEmpty { return }
                            let listPrice = param["listPrice"] as? String
                            let paymentPrice = param["paymentPrice"] as? String
                            self.purchaseId = pid
                            self.pairing.authority.reset()
                            self.appSceneObserver.event =
                                .update(.purchase(pid, listPrice:listPrice, paymentPrice:paymentPrice))
                        }
                        
                        break
                    case WebviewMethod.bpn_showTopBar.rawValue :
                        if self.isRetryPurchase { //웹뷰스크롤안것도 네이티브서 고침...
                            self.webViewModel.request = .link(self.purchaseLink)
                            self.isRetryPurchase = false
                        }
                        break
                    case WebviewMethod.bpn_closeWebView.rawValue :
                        self.appSceneObserver.event = .update(.purchaseCompleted(purchaseId: self.purchaseId))
                        self.pagePresenter.goBack()
                        break
                        
                    default : break
                    }
                    
                default : break
                }
            }
            .onReceive(dataProvider.$result) { res in
                guard let res = res else { return }
                if res.id != self.tag { return }
                guard let resData = res.data as? GridEvent else {return}
                guard let first = resData.contents?.first else {return}
                guard let model = self.purchaseWebviewModel else {return}
                model.addEpsdId(epsdId: first.epsd_id)
                model.srisId = first.sris_id ?? ""
                self.purchaseLink = ApiPath.getRestApiPath(.WEB) + BtvWebView.purchase + (model.gurry)
                self.webViewModel.request = .link(self.purchaseLink)
            }
            .onReceive(dataProvider.$error) { err in
                if err?.id != self.tag { return }
                
            }
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                self.marginBottom = bottom
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    guard let obj = self.pageObject  else { return }
                    if let data = obj.getParamValue(key: .data) as? PurchaseWebviewModel {
                        self.purchaseWebviewModel = data
                        self.purchaseLink = ApiPath.getRestApiPath(.WEB) + BtvWebView.purchase + (data.gurry)
                        self.webViewModel.request = .link(self.purchaseLink)
                    }
                    if let data = obj.getParamValue(key: .data) as? BlockItem {
                        self.purchaseWebviewModel = PurchaseWebviewModel().setParam(data:data)
                        self.dataProvider.requestData(
                            q:.init(
                                id: self.tag,
                                type: .getGridEvent(data.menu_id , .popularity , 1, 1)))
                    }
                    
                    if let data = obj.getParamValue(key: .data) as? TicketData {
                        self.purchaseWebviewModel = PurchaseWebviewModel().setParam(data:data)
                        let menuId = data.blocks?.first?.menu_id ?? data.menuId
                        self.dataProvider.requestData(
                            q:.init(
                                id: self.tag,
                                type: .getGridEvent(menuId , .popularity , 1, 1)))
                    }
                    
                    if let data = obj.getParamValue(key: .data) as? MonthlyData {
                        self.purchaseWebviewModel = PurchaseWebviewModel().setParam(data:data)
                        guard let block = data.blocks?.first( where: { BlockData().setData($0).dataType == .grid }) else {return}
                        let menuId = block.menu_id ?? data.menuId
                        self.dataProvider.requestData(
                            q:.init(
                                id: self.tag,
                                type: .getGridEvent(menuId , .popularity , 1, 1)))
                    }
                }
            }
            .onAppear{
               
            }
            .onDisappear{
            }
            
        }//geo
    }//body
    
    
    
    private func sendLog(action:NaviLog.Action) {
        self.naviLogManager.contentsLog(
            pageId: .purchaseOrderCompleted,
            action: action,
            actionBody: .init(config:"")
        )
        
    }
}

#if DEBUG
struct PagePurchase_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePurchase().contentBody
                .environmentObject(Repository())
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
