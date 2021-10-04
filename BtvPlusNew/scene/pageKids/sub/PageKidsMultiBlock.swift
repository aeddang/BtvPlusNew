//
//  PageHome.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/11.
//

import Foundation
import SwiftUI
import Combine
import struct Kingfisher.KFImage
extension PageKidsMultiBlock{
    static let tabWidth:CGFloat = SystemEnvironment.isTablet ? 186 : 123
    static let tabMargin:CGFloat = DimenKids.margin.regular
    static let tabLimitedTitleSize:Int  = 10
}

struct PageKidsMultiBlock: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var tabNavigationModel:NavigationModel = NavigationModel()
    @ObservedObject var multiBlockViewModel:MultiBlockModel = MultiBlockModel()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var infinityScrollModel: InfinityScrollModel = InfinityScrollModel(limitedScrollIndex: 1)
    @State var scrollTabSize:Int = 3
    @State var isDivisionTab:Bool = true
    @State var guideImage:String? = nil
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                ZStack(alignment: .top){
                    MultiBlockBody(
                        pageObservable: self.pageObservable,
                        viewModel: self.multiBlockViewModel,
                        infinityScrollModel: self.infinityScrollModel,
                        pageDragingModel: self.pageDragingModel,
                        useBodyTracking:  self.useTracking,
                        useTracking:self.useTracking,
                        marginTop: DimenKids.app.pageTop + self.marginTop + DimenKids.margin.regular + self.sceneObserver.safeAreaTop,
                        marginBottom: self.sceneObserver.safeAreaIgnoreKeyboardBottom,
                        header: self.monthlyPurchaseTicket ?? self.monthlyGuide,
                        headerSize: self.monthlyHeaderSize
                    )
                    .onReceive(self.pageDragingModel.$nestedScrollEvent){evt in
                        guard let evt = evt else {return}
                        switch evt {
                        case .pullCompleted :
                            self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                        case .pullCancel :
                            self.pageDragingModel.uiEvent = .pullCancel(geometry)
                        case .pull(let pos) :
                            self.pageDragingModel.uiEvent = .pull(geometry, pos)
                        default: break
                        }
                    }
                    if let img = self.guideImage {
                        ZStack(alignment: .top){
                            KFImage(URL(string: img))
                                .resizable()
                                .placeholder {
                                    Image(AssetKids.noImg16_9)
                                        .resizable()
                                }
                                .cancelOnDisappear(true)
                                .aspectRatio(contentMode: .fit)
                                .modifier(MatchParent())
                        }
                        .padding(.top, DimenKids.app.pageTop + self.marginTop + self.sceneObserver.safeAreaTop)
                        .modifier(MatchParent())
                        .background(Color.kids.bg)
                    }
                    if self.floatRecommandData?.text.isEmpty == false && !self.userControl,
                       let float = self.floatRecommandData{
                        VStack(){
                            Spacer()
                            FloatRecommand(
                                isClose: self.$isFloatingClose,
                                data: float)
                        }
                        .modifier(MatchParent())
                    }
                    
                    
                    VStack(spacing: 0){
                        PageKidsTab(
                            title: self.title,
                            isBack : true,
                            style: .kidsWhite
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        if self.tabs.count > 1 {
                            ScrollMenuTab(
                                viewModel: self.tabNavigationModel,
                                tabIdx: self.selectedTabIdx,
                                tabs: self.tabs,
                                scrollTabSize:self.scrollTabSize,
                                tabWidth: Self.tabWidth,
                                tabColor: Color.app.ivoryLight,
                                bgColor: Color.app.white,
                                marginHorizontal: Self.tabMargin,
                                isDivision: self.isDivisionTab
                            )
                            .padding(.top, self.isTop ? 0 : -Self.tabMargin)
                            .modifier(ContentHorizontalEdgesKids(margin:Self.tabMargin))
                            .frame( height: self.isTop ? MenuTab.height : 0)
                            .padding(.bottom, self.isTop ? DimenKids.margin.thin : 0)
                            .onReceive(self.tabNavigationModel.$index){ idx in
                                if !self.isUiInit { return }
                                self.setupOriginData(idx: idx)
                            }
                            .clipped()
                        }
                        
                    }
                    .background(Color.app.white)
                }
                .onReceive(self.infinityScrollModel.$scrollPosition){_ in
                    self.scrollMove()
                }
                .onReceive(self.infinityScrollModel.$event){evt in
                    guard let evt = evt else {return}
                    switch evt {
                    case .top :
                        if self.isTop == true {return}
                        withAnimation{self.isTop = true}
                    case .down :
                        if self.isTop == false {return}
                        withAnimation{self.isTop = false}
                       
                    default : break
                    }
                    
                }
                .modifier(PageFullScreen(style:.kids))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
            }

            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                self.useTracking = ani
                if ani {
                    if self.isUiInit {return}
                    DispatchQueue.main.async {
                        self.isUiInit = true
                        self.setupOriginData()
                    }
                }
            }
            .onReceive(self.pairing.$event){ evt in
                guard let evt = evt else {return}
                guard let idx = self.finalSelectedIndex else {return}
                switch evt {
                case .pairingCompleted : self.setupOriginData(idx: idx )
                default : break
                }
            }
            .onReceive(self.pairing.$kidStudyData){ data in
                if !self.isUiInit {return}
                guard let _ = data else {return}
                self.setupRecommandGuide(data: self.tabDatas[self.selectedTabIdx])
            }
            .onReceive(self.pagePresenter.$currentTopPage){ page in
                if page?.id == self.pageObject?.id {
                    if self.useTracking {return}
                    self.useTracking = true
                    
                } else {
                    if !self.useTracking {return}
                    self.useTracking = false
                }
            }
            .onReceive(self.pairing.authority.$monthlyPurchaseInfo){ info in
                if self.monthlyData == nil {return}
                if let info = info {
                    self.updatedMonthlyPurchaseInfo(info)
                } else {
                    self.pairing.authority.requestAuth(.updateMonthlyPurchase(isPeriod: false))
                }
            }
            .onReceive(self.pairing.authority.$periodMonthlyPurchaseInfo){ info in
                if self.monthlyData == nil {return}
                if let info = info {
                    self.updatedPeriodMonthlyPurchaseInfo(info)
                } else {
                    self.pairing.authority.requestAuth(.updateMonthlyPurchase(isPeriod: true))
                }
            }
            .onAppear{
                let w = Float(geometry.size.width - (Self.tabMargin*2) - max(geometry.safeAreaInsets.leading,geometry.safeAreaInsets.trailing) )
                let limit = Int(floor(w / Float(Self.tabWidth)))
                self.scrollTabSize = limit
                guard let obj = self.pageObject  else { return }
                self.openId = obj.getParamValue(key: .subId) as? String
                self.title = obj.getParamValue(key: .title) as? String
                self.pageType = obj.getParamValue(key: .type) as? BlockData.UiType
                self.tabDatas = obj.getParamValue(key: .datas) as? [BlockItem] ?? []
                
                self.tabs = self.tabDatas.map{$0.menu_nm ?? ""}
                if self.tabDatas.count > 1 {
                    if self.tabs.first(where: {$0.count > Self.tabLimitedTitleSize}) != nil {
                        self.isDivisionTab = false
                    }
                    self.marginTop =  MenuTab.height + DimenKids.margin.thin
                }
               
                if let type =  obj.getParamValue(key: .type) as? KidsPlayType {
                    self.playType = type
                }
                
                if let monthly =  obj.getParamValue(key: .data) as? MonthlyData {
                    self.monthlyData = monthly
                    if let period = self.pairing.authority.periodMonthlyPurchaseInfo {
                        self.updatedPeriodMonthlyPurchaseInfo(period)
                    }else {
                        self.pairing.authority.requestAuth(.updateMonthlyPurchase(isPeriod: false))
                    }
                    if let monthly = self.pairing.authority.monthlyPurchaseInfo {
                        self.updatedMonthlyPurchaseInfo(monthly)
                    } else {
                        self.pairing.authority.requestAuth(.updateMonthlyPurchase(isPeriod: true))
                    }
                }
                
            }
            .onDisappear(){
                self.autoOpen?.cancel()
            }
            
        }//geo
    }//body
    
    @State private var autoOpen:AnyCancellable?
    @State private var userControl:Bool = false
    private func scrollMove(){
        self.autoOpen?.cancel()
        if !self.userControl {
            withAnimation{self.userControl = true}
        }
        self.autoOpen = Timer.publish(
            every: 0.5, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                self.autoOpen?.cancel()
                self.autoOpen = nil
                withAnimation{
                    self.userControl = false
                }
            }
    }
    
    
    @State var isUiInit:Bool = false
    @State var marginTop:CGFloat = 0
    @State var isTop:Bool = true
   
    @State var monthlyData:MonthlyData? = nil
    @State var monthlyGuide:MonthlyGuide? = nil
    @State var monthlyPurchaseTicket:MonthlyPurchaseTicket?  = nil
    @State var monthlyHeaderSize:CGFloat = 0
    
    @State var tabs:[String] = []
    @State var tabDatas:[BlockItem] = []
    @State var selectedTabIdx:Int = -1
    @State var playType:KidsPlayType? = nil
   
    
    @State var originDatas:[BlockItem] = []
    @State var useTracking:Bool = false
    @State var title:String? = nil
    @State var pageType:BlockData.UiType? = nil
    @State var finalSelectedIndex:Int? = nil
    @State var openId:String? = nil
    
    @State var floatRecommandData:FloatRecommandData? = nil
    @State var isFloatingClose:Bool = false
    private func setupOriginData(idx:Int? = nil){
        var moveIdx:Int = idx ?? 0
        let replaceOpenId = self.openId?.replace("/", with: "|")
        if idx == nil , let findIds = replaceOpenId?.split(separator: "|") {
            let tab = zip(0...self.tabDatas.count, self.tabDatas).first(
                where: { idx, t in
                    guard let menuId = t.cw_call_id_val else {return false}
                    return findIds.first(where: {$0 == menuId}) != nil
                }
            )
            moveIdx = tab?.0 ?? 0
        }
        
        
        finalSelectedIndex = nil
        selectedTabIdx = moveIdx
        let cdata = self.tabDatas[moveIdx]
        if cdata.menu_exps_prop_cd == "512" ,let path = cdata.bg_imgs?.first?.img_path {
            withAnimation{
                self.guideImage = ImagePath.thumbImagePath(filePath: path, size:CGSize(width: 0, height: 640))
            }
            return
        }
        originDatas = cdata.blocks ?? []
        var delay:Double = 0
        if originDatas.isEmpty {
            originDatas = [cdata]
            delay = 0.1
        }
        
        var actionBody = MenuNaviActionBodyItem()
        actionBody.menu_id = cdata.menu_id
        actionBody.menu_name = cdata.menu_nm
        actionBody.config = self.title
        self.naviLogManager.actionLog(.clickTabMenuButton, actionBody: actionBody)
        if self.monthlyData != nil {
            self.multiBlockViewModel.setupActionLog(pageTitle: self.title, tabTitle: cdata.menu_nm)
        }
        reload(delay: delay)
        self.setupRecommandGuide(data: cdata)
        
        
    }
    
    
    private func setupRecommandGuide(data:BlockItem){
        withAnimation{
            self.floatRecommandData = nil
        }
        guard let type = self.playType else { return }
        guard let cwId = data.cw_call_id_val else { return }
        guard let studyData = self.pairing.kidStudyData else { return }
        
        var findStudy:RecommendMenuItem? = nil
        findStudy = studyData
            .recomm_menus?.first(where: {KidsPlayType.getType($0.svc_prop_cd) == type})?
            .items?.first(where: {$0.cw_id == cwId})
        
        if findStudy == nil { //하드코딩으로 찾음...
            let kesType = KesNetwork.ScnMethodCode.teacher
            if kesType.cwIds.first(where: {$0 == cwId}) != nil {
                findStudy = studyData
                    .recomm_menus?.first(where: {KidsPlayType.getType($0.svc_prop_cd) == type})?
                    .items?.first(where: {$0.scn_mthd_cd == kesType.rawValue})
            }
            
        }
        if findStudy == nil { //하드코딩으로 찾음...
            let kesType = KesNetwork.ScnMethodCode.last
            if kesType.cwIds.first(where: {$0 == cwId}) != nil {
                findStudy = studyData
                    .recomm_menus?.first(where: {KidsPlayType.getType($0.svc_prop_cd) == type})?
                    .items?.first(where: {$0.scn_mthd_cd == kesType.rawValue})
            }
            
        }
        guard let find = findStudy else { return }
        guard let text = find.guidance_sentence else {return}
        if text.replace(" ", with:"").isEmpty {return}
        let isTextCompleted = find.recent_test_date?.isEmpty == false
        
        let recommandData = FloatRecommandData(
            playType: type,
            text: text,
            isMonthlyReport: find.scn_mthd_cd == "514",
            diagnosticReportType: find.scn_mthd_cd == "518" ? type.diagnosticReportType : nil,
            isDiagnosticReportCompleted: isTextCompleted)
        
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1.0) {
            DispatchQueue.main.async {
                withAnimation{
                    self.isFloatingClose = false
                    self.floatRecommandData = recommandData
                }
            }
        }
    }
    
    private func reload(delay:Double = 0){
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delay) {
            DispatchQueue.main.async {
                let title = self.tabs.count > 1 ?  self.tabs[self.selectedTabIdx] : nil
                self.multiBlockViewModel.updateKids(
                    datas: self.originDatas, openId: self.openId, title: title)
                self.openId = nil
            }
        }
       
    }
    
    private func updatedMonthlyPurchaseInfo( _ info:MonthlyPurchaseInfo){
        guard let monthlyData = self.monthlyData  else { return }
        if let item = self.pairing.authority.monthlyPurchaseList?
            .first(where: {
                monthlyData.isSubJoin ? $0.subs_id == monthlyData.subJoinId
                : $0.prod_id == monthlyData.prdPrcId })
            {
            self.setupMonthlyGuide(ticketData: PurchaseTicketData().setData(data: item))
        } else {
            if monthlyData.hasAuth {
                self.setupMonthlyGuide(ticketData: PurchaseTicketData())
            } else {
                self.setupMonthlyPurchaseTicket(monthlyData:monthlyData)
            }
        }
    }
    
    private func updatedPeriodMonthlyPurchaseInfo( _ info:PeriodMonthlyPurchaseInfo){
        guard let monthlyData = self.monthlyData else { return }
        if let item = self.pairing.authority.periodMonthlyPurchaseList?
            .first(where: { 
                monthlyData.isSubJoin ? $0.subs_id == monthlyData.subJoinId
                : $0.prod_id == monthlyData.prdPrcId })
            {
            self.setupMonthlyGuide(ticketData: PurchaseTicketData().setData(data: item))
          
        } else {
            if monthlyData.hasAuth {
                self.setupMonthlyGuide(ticketData: PurchaseTicketData())
            } else {
                self.setupMonthlyPurchaseTicket(monthlyData:monthlyData)
            }
        }
    }
    
    private func setupMonthlyGuide(ticketData:PurchaseTicketData){
        self.monthlyGuide = MonthlyGuide(data:ticketData)
        self.monthlyHeaderSize = DimenKids.tab.regular + DimenKids.margin.light
    }
    
    private func setupMonthlyPurchaseTicket(monthlyData:MonthlyData){
        if monthlyData.price == nil {return}
        self.monthlyPurchaseTicket = MonthlyPurchaseTicket(data: monthlyData)
        self.monthlyHeaderSize = DimenKids.tab.heavy + DimenKids.margin.light
    }
    
}



