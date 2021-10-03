//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct PageMyOksusuPurchase: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    
    @ObservedObject var collectionScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var collectionModel:PurchaseBlockModel = PurchaseBlockModel()
   
    @State var pages: [PageViewProtocol] = []
    @State var marginBottom:CGFloat = 0
    @State var isInit:Bool = false
    let titles: [String] = [
        String.app.rent,
        String.app.owner
    ]
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable,
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.myOksusu,
                        isBack: true,
                        style: .dark
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    PurchaseBlock(
                        infinityScrollModel:self.collectionScrollModel,
                        viewModel:self.collectionModel,
                        pageObservable:self.pageObservable,
                        useTracking:true,
                        marginBottom: self.marginBottom,
                        type: .oksusu
                    )
                }
                .modifier(PageFull(style:.dark))
                .modifier(PageDragingSecondPriority(geometry: geometry, pageDragingModel: self.pageDragingModel))
                .clipped()
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    if self.isInit {return}
                    DispatchQueue.main.async {
                        self.isInit = true
                        self.collectionModel.initUpdate()
                    }
                }
            }
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                withAnimation{ self.marginBottom = bottom }
            }
            
            .onReceive(self.dataProvider.$result){ res in
                guard let res = res else { return }
                switch res.type {
                
                case .connectTerminateStb(let type, _) :
                    if type == .delete {
                        self.appSceneObserver.event = .toast( String.oksusu.disconnectCompleted )
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    }
                    
                    guard let data = res.data as? ConnectTerminateStb  else {
                        if type != .info {
                            self.appSceneObserver.event = .toast( String.alert.apiErrorServer )
                        }
                        return
                    }
                    switch type {
                    case .regist :
                        self.appSceneObserver.event = .toast( String.oksusu.setupCompleted )
                        self.collectionModel.update()
                    case .info :
                        if data.stb_id != self.setup.oksusu {
                            self.appSceneObserver.alert = .alert(
                                String.oksusu.disconnect,
                                String.oksusu.disconnectAnotherUser,
                                confirmText:String.app.close
                            ){
                                self.sendLog(action: .clickContentsRetrievePopup, actionBody: .init(menu_id:"옥수수 팝업 메뉴아이디"))
                                self.setup.oksusu = ""
                                self.dataProvider.requestData(
                                    q:.init(id: self.tag,
                                            type: .connectTerminateStb(.delete, self.setup.possession),
                                            isOptional: true))
                            }
                        }
                    default : break
                    }
                default: break
                }
            }
            .onReceive(self.dataProvider.$error){ err in
                guard let err = err else { return }
                switch err.type {
                case .connectTerminateStb(let type, _) :
                    if type == .delete {
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    }
                default: break
                }
            }
            .onAppear{
                if self.setup.oksusu.isEmpty == false {
                    self.dataProvider.requestData(
                        q:.init(id: self.tag,
                                type: .connectTerminateStb(.info, self.setup.possession), isOptional: true))
                } else {
                    
                }
            }
            .onDisappear{
               
            }
        }//geo
    }//body
    
    private func sendLog(action:NaviLog.Action, actionBody:MenuNaviActionBodyItem? = nil) {
        self.naviLogManager.actionLog(action, actionBody: actionBody)
    }
   
}

#if DEBUG
struct PageMyOksusuPurchase_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMyOksusuPurchase().contentBody
                .environmentObject(Repository())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(KeyboardObserver())
                .environmentObject(Pairing())
                .frame(width: 320, height: 640, alignment: .center)
        }
    }
}
#endif