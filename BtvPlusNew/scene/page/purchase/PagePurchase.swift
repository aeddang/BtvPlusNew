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
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var webViewModel = WebViewModel()
    
    @State var webViewHeight:CGFloat = 0
    @State var useTracking:Bool = false
    @State var purchaseWebviewModel:PurchaseWebviewModel? = nil
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
                    ZStack(alignment: .topLeading){
                        DragDownArrow(
                            infinityScrollModel: self.infinityScrollModel)
                        InfinityScrollView(
                            viewModel: self.infinityScrollModel,
                            scrollType : .web(isDragEnd: true),
                            isRecycle:false,
                            useTracking:self.useTracking
                        ){
                            BtvWebView( viewModel: self.webViewModel, useNativeScroll:false )
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
                .modifier(PageFull(style:.white))
                .highPriorityGesture(
                    DragGesture(minimumDistance: PageDragingModel.MIN_DRAG_RANGE, coordinateSpace: .local)
                        .onChanged({ value in
                            self.pageDragingModel.uiEvent = .drag(geometry, value)
                        })
                        .onEnded({ value in
                            self.pageDragingModel.uiEvent = .draged(geometry, value)
                        })
                )
                .gesture(
                    self.pageDragingModel.cancelGesture
                        .onChanged({_ in
                            self.pageDragingModel.uiEvent = .dragCancel})
                        .onEnded({_ in
                            self.pageDragingModel.uiEvent = .dragCancel})
                )
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
                    switch method {
                    case WebviewMethod.bpn_setPurchaseResult.rawValue :
                        guard let json = json else { return }
                        guard let param = AppUtil.getJsonParam(jsonString: json) else { return }
                        if let result = param["result"] as? Bool,let pid = param["pid"] as? String {
                            if !result { return }
                            let listPrice = param["listPrice"] as? String
                            let paymentPrice = param["paymentPrice"] as? String
                            self.appSceneObserver.event = .update(.purchase(pid, listPrice, paymentPrice))
                        }
                        break
                    case WebviewMethod.bpn_closeWebView.rawValue :
                        self.pagePresenter.goBack()
                        break
                        
                    default : break
                    }
                    
                default : do{}
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
            }
            .onReceive(dataProvider.$result) { res in
                guard let res = res else { return }
                if res.id != self.tag { return }
                guard let resData = res.data as? GridEvent else {return}
                guard let first = resData.contents?.first else {return}
                guard let model = self.purchaseWebviewModel else {return}
                model.addEpsdId(epsdId: first.epsd_id)
                model.srisId = first.sris_id ?? ""
                let linkUrl = ApiPath.getRestApiPath(.WEB) + BtvWebView.purchase + (model.gurry)
                self.webViewModel.request = .link(linkUrl)
            }
            .onReceive(dataProvider.$error) { err in
                if err?.id != self.tag { return }
                
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let data = obj.getParamValue(key: .data) as? PurchaseWebviewModel {
                    self.purchaseWebviewModel = data
                    let linkUrl = ApiPath.getRestApiPath(.WEB) + BtvWebView.purchase + (data.gurry)
                    self.webViewModel.request = .link(linkUrl)
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
                    guard let block = data.blocks?.first( where: { BlockData().setDate($0).dataType == .grid }) else {return}
                    let menuId = block.menu_id ?? data.menuId
                    self.dataProvider.requestData(
                        q:.init(
                            id: self.tag,
                            type: .getGridEvent(menuId , .popularity , 1, 1)))
                }
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
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
