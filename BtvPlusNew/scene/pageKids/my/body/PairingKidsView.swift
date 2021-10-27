//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI


struct PairingKidsView: PageComponent {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    
    var pageObservable:PageObservable = PageObservable()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var tabNavigationModel:NavigationModel = NavigationModel()
    var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    
    
    @State var kid:Kid? = nil
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ZStack{
                Spacer().modifier(MatchVertical(width: 0))
                VStack(spacing:DimenKids.margin.thin){
                    if let kid = self.kid{
                        KidProfileBox(data: kid)
                    } else {
                        KidProfileBox(data: Kid(), isEmpty:true)
                    }
                    RectButtonKids(
                        text: String.kidsTitle.registKidManagement,
                        kern: SystemEnvironment.isTablet ? Font.kern.thin :  Font.kern.regular ,
                        textModifier: BoldTextStyleKids(
                            size: SystemEnvironment.isTablet ? Font.sizeKids.tinyExtra : Font.sizeKids.tiny,
                            color: Color.app.sepia).textModifier,
                        bgColor: Color.app.ivoryLight,
                        size: CGSize(
                            width:DimenKids.item.profileBox.width ,
                            height: DimenKids.button.lightUltra),
                        cornerRadius:  DimenKids.radius.medium,
                        isMore: true
                    ) { _ in
                        
                        self.sendLog(action: .clickTabMenu,
                                     actionBody:.init(category: self.pairing.kid == nil ? "자녀프로필관리" : "프로필등록"))
                        self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsProfileManagement))
                    }
                }
                //.padding(.top,SystemEnvironment.isTablet ? DimenKids.margin.medium : DimenKids.margin.mediumExtra)
                .padding(.horizontal, DimenKids.margin.light)
            }
            .background(
                Image(AssetKids.image.profileBg)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFill()
                    .modifier(MatchParent())
            )
            .clipped()
            VStack(alignment: .leading, spacing:0){
                if !self.tabs.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false){
                        MenuNavi(
                            viewModel: self.tabNavigationModel,
                            buttons: self.tabs,
                            selectedIdx: self.tabIdx,
                            isDivision: false)
                            .padding(.horizontal, DimenKids.margin.thin)
                    }
                    
                }
                if self.isLoading {
                    Spacer()
                        .modifier(MatchParent())
                } else if self.isError {
                    ErrorKidsData(
                        icon: self.errorMsg == nil ?  Asset.icon.alert : nil,
                        text:self.errorMsg ?? String.alert.dataError)
                        .modifier(MatchParent())
                } else if let cateBlockModel = self.cateBlockModel {
                    CateBlock(
                        pageObservable: self.pageObservable,
                        viewModel:cateBlockModel,
                        headerSize: DimenKids.tab.thin,
                        marginBottom:self.sceneObserver.safeAreaIgnoreKeyboardBottom +  DimenKids.margin.thinUltra,
                        marginHorizontal: DimenKids.margin.thin,
                        spacing: DimenKids.margin.thinUltra,
                        size : self.cateSize,
                        menuTitle: String.kidsText.kidsMyWatch
                    )
                    .modifier(MatchParent())
                    .padding(.trailing,  self.sceneObserver.safeAreaEnd)
                    
                }else {
                    InfinityScrollView(
                        viewModel: self.infinityScrollModel,
                        axes:.horizontal,
                        marginStart: DimenKids.margin.thin,
                        marginEnd: DimenKids.margin.thin + self.sceneObserver.safeAreaEnd,
                        isAlignCenter:true,
                        spacing:DimenKids.margin.thinUltra,
                        isRecycle:false,
                        useTracking: true
                        ){
                        if let diagnosticReportModel = self.diagnosticReportModel, let monthlyReportModel = self.monthlyReportModel {
                            HStack(spacing:DimenKids.margin.thin){
                                DiagnosticReportCard(viewModel:diagnosticReportModel)
                                MonthlyReportCard(viewModel:monthlyReportModel)
                            }
                           
                        } else if let kidsCategoryListData = self.kidsCategoryListData {
                            KidsCategoryList(data:kidsCategoryListData)
                                
                        }  else {
                            HStack(spacing:DimenKids.margin.thin){
                                DiagnosticReportCard(viewModel:DiagnosticReportModel())
                                MonthlyReportCard(viewModel:MonthlyReportModel())
                            }
                        }
                    }
                    .modifier(MatchParent())
                    .padding(.bottom, DimenKids.margin.thin)
                }

            }
            .padding(.top, DimenKids.margin.mediumExtra)
            .modifier(MatchParent())
            
        }
        .modifier(ContentHeaderEdgesKids())
        .onReceive(dataProvider.$result) { res in
            guard let res = res else { return }
            switch res.type {
            case .getMonthlyReport :
                guard let monthlyReport  = res.data as? MonthlyReport  else { return }
                self.monthlyReportModel?.setData(monthlyReport, kid: self.kid, date: self.currentDate)
                
            case .getKidStudy :
                guard let study  = res.data as? KidStudy  else { return }
                self.diagnosticReportModel?.setData(study, kid: self.kid)
               
                
            default: break
            }
        }
        .onReceive(dataProvider.$error) { err in
            guard let err = err else { return }
            switch err.type {
            case .getMonthlyReport : self.onError()
            case .getKidStudy : self.onError()
            default: break
            }
        }
        .onReceive(self.pairing.$kid){ kid in
            self.kid = kid
            self.load()
        }
        .onReceive(self.pairing.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .editedKids :
                self.monthlyReportModel?.updatedKid()
                self.diagnosticReportModel?.updatedKid()
            default: break
            }
        }
        .onReceive(self.tabNavigationModel.$index){ idx in
            if self.tabs.isEmpty {return}
            self.load(idx:idx)
        }
        .onReceive(self.pageObservable.$isAnimationComplete){ ani in
            if ani {
                if self.isUiInit {return}
                DispatchQueue.main.async {
                    self.isUiInit = true
                    self.load()
                }
            }
        }
        .onAppear{
            let datas = self.dataProvider.bands.kidsGnbModel
                .getMyDatas()?
                .filter{$0.menu_nm != nil} ?? []
            self.tabDatas = datas
            self.tabs = self.tabDatas.map{$0.menu_nm ?? ""}
            guard let obj = self.pageObject  else { return }
            
            if let subId = obj.getParamValue(key: .subId) as? String { //최근본목록 찾기
                if let find = self.tabDatas.firstIndex(where: {$0.scn_mthd_cd == subId}){
                    self.tabIdx = find
                }
            }else if let openIdx = obj.getParamValue(key: .index) as? Int { // 순서로
                self.tabIdx = openIdx
            }
        }
    }//body
    @State var isUiInit:Bool = false
    @State var isLoading:Bool = false
    @State var tabIdx:Int = 0
    @State var tabDatas:[BlockItem] = []
    @State var tabs:[String] = []
    @State var currentDate:Date = Date()

    @State var diagnosticReportModel:DiagnosticReportModel? = nil
    @State var monthlyReportModel:MonthlyReportModel? = nil
   
    @State var kidsCategoryListData:KidsCategoryListData? = nil
    @State var cateBlockModel:CateBlockModel? = nil
    @State var cateSize:CGFloat = 0
    private func load (idx:Int? = nil){
        if !self.isUiInit { return }
        if self.isLoading { return }
        self.isLoading = true
        self.isError = false
        if let idx = idx {
            self.tabIdx = idx
        }
        self.diagnosticReportModel = nil
        self.monthlyReportModel = nil
        self.cateBlockModel = nil
        self.kidsCategoryListData = nil
        
        if tabIdx == 0 {
            self.loadMyKidData()
            self.onLoaded()
            
            
        } else {
            let data = tabDatas[tabIdx]
            if data.menu_id ==
                (SystemEnvironment.isStage
                 ? EuxpNetwork.MenuTypeCode.MENU_KIDS_MY_WATCH_STAGE.rawValue
                 : EuxpNetwork.MenuTypeCode.MENU_KIDS_MY_WATCH.rawValue) {
                let watcheBlockData:BlockData = BlockData(pageType: .kids).setDataKids(data)
                self.cateBlockModel = CateBlockModel(pageType: .kids)
                self.cateSize = self.sceneObserver.screenSize.width
                    - DimenKids.item.profileBox.width //프로필
                    - (DimenKids.margin.light*2) // 마진
                    - (DimenKids.margin.thin) // 마진
                    - (DimenKids.margin.regular*2) // 메이지 마진

                self.onLoaded()
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
                    self.cateBlockModel?.update(data: watcheBlockData, listType:.video, cardType: .watchedVideo)
                }
                
            } else {
                self.kidsCategoryListData = KidsCategoryListData().setData(data: data, useTitle: false)
                self.onLoaded()
            }
        }
        if tabIdx < tabDatas.count && tabIdx > 0{
            self.sendLog(action: .clickTabMenu, actionBody:.init(category:tabDatas[tabIdx].menu_nm))
        }
    }
    
    private func loadMyKidData (){
        self.diagnosticReportModel = DiagnosticReportModel()
        self.monthlyReportModel = MonthlyReportModel()
        if !self.tabDatas.isEmpty {
            self.diagnosticReportModel?.setupActionLog(tabTitle: self.tabDatas[0].menu_nm)
            self.monthlyReportModel?.setupActionLog(tabTitle: self.tabDatas[0].menu_nm)
        }
        guard let kid = self.kid else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.monthlyReportModel?.reset()
                self.diagnosticReportModel?.reset()
            }
            return
        }
        self.dataProvider.requestData(q: .init(type: .getKidStudy(kid), isOptional: false))
        self.dataProvider.requestData(q: .init(type: .getMonthlyReport(kid, self.currentDate), isOptional: false))
    }
    

    @State var isError:Bool = false
    @State var errorMsg:String? = nil
    private func onError (msg:String? = nil){
        errorMsg = msg
        self.isLoading = false
        withAnimation{
            
            self.isError = true
        }
    }
    private func onLoaded (){
        self.isLoading = false
    }
    
    private func sendLog(action:NaviLog.Action, actionBody:MenuNaviActionBodyItem? = nil){
        self.naviLogManager.actionLog(action, actionBody: actionBody)
    }
}

#if DEBUG
struct PairingKidsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            PairingKidsView().contentBody
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 360, height: 680, alignment: .center)
        }
    }
}
#endif
