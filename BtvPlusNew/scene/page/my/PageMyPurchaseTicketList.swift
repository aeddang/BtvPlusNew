//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine



struct PageMyPurchaseTicketList: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()

    @State var marginBottom:CGFloat = 0
    @State var sceneOrientation: SceneOrientation = .portrait
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.vertical
            ) {
                VStack(spacing:0){
                    PageTab(
                        title: String.pageTitle.purchaseTicketList,
                        isClose : true
                    )
                    .padding(.top, self.sceneObserver.safeAreaTop)
                    if !self.isError {
                        ZStack(alignment: .topLeading){
                            DragDownArrow(
                                infinityScrollModel: self.infinityScrollModel)
                            PurchaseTicketList(
                                viewModel: self.infinityScrollModel,
                                dataSets: self.datas,
                                useTracking:true,
                                padding: SystemEnvironment.isTablet
                                    ? self.sceneOrientation == .landscape ? Dimen.margin.heavy :  Dimen.margin.thin
                                    : Dimen.margin.thin,
                                marginBottom: self.marginBottom + Dimen.button.medium + Dimen.margin.thin
                            )
                            
                            if let allData = self.monthlyAllData , !SystemEnvironment.isEvaluation {
                                VStack{
                                    Spacer().modifier(MatchParent())
                                    FillButton(
                                        text: String.button.allTicket,
                                        isSelected: true
                                    ){_ in
                                        
                                        self.pagePresenter.openPopup(
                                            PageProvider.getPageObject(.multiBlock)
                                                .addParam(key: .id, value: allData.menu_id)
                                                .addParam(key: .title, value: allData.menu_nm)
                                                .addParam(key: .data, value: allData.blocks)
                                                .addParam(key: .type, value: BlockData.ThemaType.ticket)
                                        )
                                        
                                    }
                                    Spacer()
                                        .modifier(MatchHorizontal(height: self.sceneObserver.safeAreaBottom))
                                        .background(Color.brand.bg)
                                }
                            }
                        }
                        .modifier(MatchParent())
                        .onReceive(self.infinityScrollModel.$event){evt in
                            guard let evt = evt else {return}
                            switch evt {
                            
                            case .pullCompleted:
                                self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                            case .pullCancel :
                                self.pageDragingModel.uiEvent = .pullCancel(geometry)
                            default : do{}
                            }
                        }
                        .onReceive(self.infinityScrollModel.$pullPosition){ pos in
                            self.pageDragingModel.uiEvent = .pull(geometry, pos)
                        }
                       
                    } else {
                        EmptyMyData(
                            text:String.pageText.myPurchaseEmpty)
                        .modifier(MatchParent())
                    }
                   
                }
                
                .modifier(PageFull())
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }
            .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
                withAnimation{ self.marginBottom = bottom }
            }
            .onReceive(self.pairing.authority.$monthlyPurchaseInfo){ _ in
                self.updatedTickets()
            }
            .onReceive(self.pairing.authority.$periodMonthlyPurchaseInfo){ _ in
                self.updatedTickets()
            }
            .onReceive(self.sceneObserver.$isUpdated){ update in
                if !update {return}
                self.updatedTickets()
            }
            .onReceive(self.sceneObserver.$isUpdated){ _ in
                self.sceneOrientation = self.sceneObserver.sceneOrientation
            }
            .onAppear(){
                self.setupMonthlyDatas()
                self.sceneOrientation = self.sceneObserver.sceneOrientation
                if self.pairing.authority.monthlyPurchaseInfo == nil {
                    self.pairing.authority.requestAuth(.updateMonthlyPurchase(isPeriod: false))
                }
                if self.pairing.authority.periodMonthlyPurchaseInfo == nil {
                    self.pairing.authority.requestAuth(.updateMonthlyPurchase(isPeriod: true))
                }
            }
            
            .onDisappear{
               
            }
        }//geo
    }//body
   
    @State var isError:Bool = false
    @State var isScroll:Bool = false
    @State var datas:[PurchaseTicketDataSet] = []
    @State var monthlyAllData:BlockItem? = nil
    
    private func setupMonthlyDatas (){
        guard let blocksData = self.dataProvider.bands.getData(gnbTypCd: EuxpNetwork.GnbTypeCode.GNB_MONTHLY.rawValue)?.blocks else {return}
        guard let find = blocksData.first(where: {$0.prd_prc_id == nil}) else {return}
        self.monthlyAllData = find
    }
    
    
    private func updatedTickets(){
        guard let monthlyPurchaseInfo = self.pairing.authority.monthlyPurchaseInfo else { return }
        guard let periodMonthlyPurchaseInfo = self.pairing.authority.periodMonthlyPurchaseInfo else { return }
        
        var dataSets:[PurchaseTicketDataSet] = []
        self.isError = false
        
        let mTickets:[PurchaseTicketData] = monthlyPurchaseInfo.purchaseList?.map{PurchaseTicketData().setData(data: $0)} ?? []
        let pTickets:[PurchaseTicketData] = periodMonthlyPurchaseInfo.purchaseList?.map{PurchaseTicketData().setData(data: $0)} ?? []
        var allTickets:[PurchaseTicketData] = []
        allTickets.append(contentsOf: mTickets)
        allTickets.append(contentsOf: pTickets)
        
        let count:Int = SystemEnvironment.isTablet ? 2 : 1 //Int(round(self.sceneObserver.screenSize.width / ListItem.purchaseTicket.size.width))
        var rows:[PurchaseTicketDataSet] = []
        var cells:[PurchaseTicketData] = []
        var total = 0
        allTickets.forEach{ d in
            if cells.count < count {
                cells.append(d)
            }else{
                rows.append(
                    PurchaseTicketDataSet( count: count, datas: cells, isFull: true, index:total)
                )
                total += 1
                cells = [d]
            }
        }
        if !cells.isEmpty {
            rows.append(
                PurchaseTicketDataSet( count: count, datas: cells,isFull: cells.count == count, index: total)
            )
        }
        dataSets.append(contentsOf: rows)
        if dataSets.isEmpty {  self.isError = true }
       
       
        self.datas = dataSets
        
        
    }
    
    func errorMyInfo(_ err:ApiResultError?){
        if let apiError = err?.error as? ApiError {
            self.appSceneObserver.alert = .alert(String.alert.connect, ApiError.getViewMessage(message: apiError.message))
        }else{
            self.appSceneObserver.alert = .alert(String.alert.connect, String.alert.needConnectStatus)
        }
        self.isError = true
    }
}


#if DEBUG
struct PagePurchaseTicketList_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageMyPurchaseTicketList().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(AppSceneObserver())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif

