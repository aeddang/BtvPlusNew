//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI

struct PageCategory: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var viewModel:PageDataProviderModel = PageDataProviderModel()
    @ObservedObject var navigationModel:NavigationModel = NavigationModel()
    @State var listWidth:CGFloat = 0
    @State var headerHeight:CGFloat = 0
    @State var marginBottom:CGFloat = Dimen.app.bottom
    var body: some View {
        PageDataProviderContent(
            pageObservable:self.pageObservable,
            viewModel : self.viewModel
        ){
            VStack(alignment: .center, spacing: 0){
                if self.datas.isEmpty {
                    Spacer().modifier(MatchParent())
                } else {
                    CateList( datas: self.datas)
                        .padding(.top, self.headerHeight)
                        .modifier(MatchVertical(
                                    width: self.listWidth - Dimen.margin.lightExtra
                                    + (ListItem.cate.width - ListItem.cate.size.width)))
                }
                DivisionTab(
                    viewModel: self.navigationModel,
                    buttons: self.tabs,
                    strokeWidth : 0,
                    divisionMargin: Dimen.margin.thin,
                    radius: Dimen.radius.regular,
                    height: Dimen.tab.heavyExtra,
                    strokeColor : Color.app.white.opacity(0.1),
                    bgColor : Color.app.blueLight
                    )
                    .frame(width: self.listWidth + Dimen.margin.regular)
                    .padding(.bottom, Dimen.margin.thin)
            }
            .padding(.bottom, Dimen.margin.thin + self.marginBottom)
        }
        .modifier(PageFull())
        .onReceive(self.appSceneObserver.$headerHeight){ hei in
            withAnimation{ self.headerHeight = hei }
            
        }
        .onReceive(self.sceneObserver.$screenSize){ _ in
            if SystemEnvironment.isTablet {
                self.resetSize()
            }
        }
        .onReceive(self.appSceneObserver.$safeBottomLayerHeight){ bottom in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation{ self.marginBottom = bottom }
            }
        }
        .onReceive(self.navigationModel.$index) { idx in
            guard let datas = self.tabDatas else { return }
            if idx < 0 || idx >= datas.count { return }
            let data = datas[idx]
            /*삭제됨
            self.naviLogManager.actionLog(.clickCategoryMenu,
                                          actionBody: .init(
                                            menu_id: data.menuId,
                                            menu_name: data.title,
                                            result:  "N"))
            */
            self.openPopup(data: data)
            
        }
        .onReceive(self.viewModel.$event ){ evt in
            guard let evt = evt else {return}
            switch evt {
            case .onResult(_, _, _) : do{}
            default : break
            }
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                if self.isInit {return}
                DispatchQueue.main.async {
                    self.isInit = true
                    self.appSceneObserver.useTopFix = true
                    self.setupDatas(menuId:self.menuId, openId: self.openId)
                }
            }
        }
        .onAppear{
            guard let obj = self.pageObject  else { return }
            self.openId = obj.getParamValue(key: .subId) as? String
            self.menuId = (obj.getParamValue(key: .id) as? String) ??  EuxpNetwork.GnbTypeCode.GNB_CATEGORY.rawValue
            self.marginBottom = self.appSceneObserver.safeBottomLayerHeight
            self.appSceneObserver.gnbMenuId = menuId
        }
        .onDisappear{
            self.appSceneObserver.useTopFix = nil
        }
    }//body
    
    @State var menuId:String = EuxpNetwork.GnbTypeCode.GNB_CATEGORY.rawValue
    @State var openId:String? = nil
    @State var isInit:Bool = false
    @State var tabs:[NavigationButton] = []
    @State var originDatas:[CateData]? = nil
    @State var datas:[CateDataSet] = []
    
    @State var tabDatas:[CateData]? = nil
    private func setupDatas(menuId:String, openId:String? = nil){
        guard let blocksData = self.dataProvider.bands.getData(menuId: menuId)?.blocks else { return }
        var cateDatas = blocksData.map{ block in
            CateData().setData(data: block)
        }
        if SystemEnvironment.isEvaluation {
            cateDatas = cateDatas.filter{!$0.isAdult}
        }
        self.originDatas = cateDatas
        if !cateDatas.isEmpty {
            self.originDatas?.insert(CateData().setZemkids(), at: 1)
        }else{
            self.originDatas?.append(CateData().setZemkids())
        }
        
        let openData:CateData? = self.resetSize(openId: openId)
        self.openId = nil
        guard let open = openData else { return }
        DispatchQueue.main.async{
            self.openPopup(data: open, openId: openId)
        }
        
    }
    
    @discardableResult
    private func resetSize(openId:String? = nil) -> CateData?{
        if SystemEnvironment.isTablet {
            self.listWidth = self.sceneObserver.sceneOrientation == .portrait ? 530 : 770
        } else {
            let margin:CGFloat = Dimen.margin.heavyExtra
            self.listWidth = self.sceneObserver.screenSize.width - margin * 2.0
        }
       
        guard let cateDatas = self.originDatas else { return nil }
        self.datas = []
        var tabDatas:[CateData] = []
        let count = self.sceneObserver.sceneOrientation == .portrait ? CateList.cellCount : CateList.horizenlalCellCount
        var rows:[CateDataSet] = []
        var cells:[CateData] = []
        var total = cateDatas.count
        var openData:CateData? = nil
        
        let findIds = openId?.contains("/") == true
            ? openId?.split(separator: "/")
            :  openId?.split(separator: "|")
        cateDatas.forEach{ d in
            d.isRowFirst = false
            if let menuId = d.menuId, let fids = findIds{
                if fids.first(where: {$0 == menuId}) != nil {
                    openData = d
                }
            }
            switch d.subType{
            case .tip :
                d.icon = Asset.icon.cateTip
                tabDatas.append(d)
            case .event :
                d.icon = Asset.icon.cateEvent
                tabDatas.append(d)
            default :
                if cells.count < count {
                    cells.append(d)
                }else{
                    rows.append(
                        CateDataSet( count: count, datas: cells, isFull: true, index: total)
                    )
                    cells = [d]
                    total += 1
                }
            }
        }
        if !cells.isEmpty {
            rows.append(
                CateDataSet( count: count, datas: cells,isFull: cells.count == count, index: total)
            )
        }
        rows.forEach{$0.datas.first?.isRowFirst = true}
        withAnimation{
            self.datas.append(contentsOf: rows)
        }
        if self.tabDatas == nil {
            self.tabDatas = tabDatas
            self.navigationModel.index = -1
            var naviDatas:[(String,String)] = tabDatas.map { ($0.title ?? "", $0.icon ) }
            
            self.tabDatas?.insert(CateData().setCashCharge(), at: 0)
            naviDatas.insert((String.button.cashCharge, Asset.icon.cateBCash ), at: 0)
            
            self.tabs = NavigationBuilder(
                textModifier: TextModifier(
                    family:Font.family.medium,
                    size: Font.size.thin ,
                    color: Color.app.greyLight,
                    activeColor: Color.app.white
                    )
                )
            .getNavigationButtons(
                datas: naviDatas,
                size: SystemEnvironment.isTablet
                    ? CGSize(width: Dimen.icon.regularExtra, height:  Dimen.icon.regularExtra)
                    : CGSize(width: Dimen.icon.thin, height: Dimen.icon.thin)
                )
        }
        return openData
    }
    
    private func openPopup(data:CateData, openId:String? = nil){
        switch data.subType {
        case .prevList :
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.previewList)
                    .addParam(key: .title, value: data.title)
                    .addParam(key: .id, value: data.menuId)
                    .addParam(key: .data, value: data)
                    .addParam(key: .needAdult, value: data.isAdult)
                    .addParam(key: .subId, value: openId)
            )
        case .kids :
            let link = self.pageObject?.getParamValue(key: .link) as? String
            self.pagePresenter.changePage(PageKidsProvider
                                            .getPageObject(.kidsHome)
                                            .addParam(key: .id, value: openId)
                                            .addParam(key: .link, value: link)
            )
            
        case .event :
            
            self.pagePresenter.openPopup(
                PageProvider
                    .getPageObject(.webviewList)
                    .addParam(key: .data, value: BtvWebView.event)
                    .addParam(key: .title , value: data.title)
            )
        case .tip :
            self.pagePresenter.openPopup(
                PageProvider
                    .getPageObject(.webviewList)
                    .addParam(key: .data, value: BtvWebView.tip)
                    .addParam(key: .title , value: data.title)
            )
        case .cashCharge :
            self.pagePresenter.openPopup(
                PageProvider
                    .getPageObject(.cashCharge)
            )
        default :
            if data.blocks != nil && data.blocks?.isEmpty == false {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.multiBlock)
                        .addParam(key: .id, value: data.menuId)
                        .addParam(key: .data, value: data)
                        .addParam(key: .needAdult, value: data.isAdult)
                        .addParam(key: .subId, value: openId)
                )
            }else{
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.categoryList)
                        .addParam(key: .title, value: data.title)
                        .addParam(key: .id, value: data.menuId)
                        .addParam(key: .type, value: data.cateType)
                        .addParam(key: .needAdult, value: data.isAdult)
                        .addParam(key: .subId, value: openId)
                )
            }
        }
    }
    
   
}


#if DEBUG
struct PageCategory_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PageCategory().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(DataProvider())
                .environmentObject(Repository())
                .environmentObject(AppSceneObserver())
                .frame(width: 320, height: 640, alignment: .center)
        }
    }
}
#endif

