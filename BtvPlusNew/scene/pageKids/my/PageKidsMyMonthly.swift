//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
extension PageKidsMyMonthly{
    static let tabWidth:CGFloat = SystemEnvironment.isTablet ? 186 : 123
}

struct PageKidsMyMonthly: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    @ObservedObject var viewModel:MonthlyReportModel = MonthlyReportModel()
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var tabNavigationModel:NavigationModel = NavigationModel()
  
    @State var isPairing:Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                pageObservable: self.pageObservable, 
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                
                VStack (alignment: .center, spacing:0){
                    PageKidsTab(
                        title:String.kidsTitle.kidsMyDiagnostic,
                        isBack: true)
                    
                    if self.isPairing {
                        ZStack{
                            Spacer().modifier(MatchHorizontal(height: 0))
                            if !self.tabs.isEmpty {
                                MenuTab(
                                    viewModel: self.tabNavigationModel,
                                    buttons: self.tabs,
                                    selectedIdx: self.tabIdx,
                                    isDivision: true)
                                    .frame(width: Self.tabWidth * CGFloat(self.tabs.count))
                            }
                        }
                        .frame(height:MenuTab.height)
                        .padding(.bottom, DimenKids.margin.thin)
                        .background(Color.app.white)
                        HStack(spacing:DimenKids.margin.lightExtra){
                            Button(action: {
                                self.loadResult(move: -1)
                            }) {
                                Image( AssetKids.icon.arrowL)
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: DimenKids.icon.micro)
                            }
                            Text(self.date)
                                .modifier(BoldTextStyleKids(
                                            size: Font.sizeKids.light,
                                            color: Color.app.sepia))
                            Button(action: {
                                if self.isLast { return }
                                self.loadResult(move: 1)
                            }) {
                                Image( AssetKids.icon.arrowR)
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: DimenKids.icon.micro)
                            }
                            .opacity( self.isLast ? 0.3 : 1.0)
                        }
                        .padding(.vertical, DimenKids.margin.tinyExtra)
                        .padding(.horizontal, DimenKids.margin.thin)
                        .background(Color.app.white)
                        .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.mediumExtra))
                        .padding(.top, SystemEnvironment.isTablet ? DimenKids.margin.mediumUltra : DimenKids.margin.thin)
                        
                        if self.isError {
                            ErrorKidsData()
                                .modifier(MatchParent())
                        } else if let currentReport = self.currentReport {
                            
                            HStack(spacing:DimenKids.margin.regularExtra){
                                MonthlyGraphBox(
                                    title:String.app.watchTime,
                                    value:currentReport.learningTime.description + String.app.min,
                                    subTitle:self.dateMonth + String.app.recommend
                                        + " " + currentReport.recommendTime.description
                                        + String.app.min,
                                    thumbImg:self.profile,
                                    valuePct:self.watchTimePct,
                                    guideImg:AssetKids.shape.graphGuideTime,
                                    guidePct:self.guideTimePct,
                                    color:Color.app.yellow,
                                    icon: AssetKids.icon.graphGuideTime,
                                    text:String.kidsText.kidsMyMonthlyReportTime
                                        + " : " + currentReport.recommendTime.description
                                        + String.app.min
                                )
                                
                                MonthlyGraphBox( 
                                    title:String.app.watchCount,
                                    value:currentReport.learningCount.description + String.app.watchCountUnit,
                                    subTitle:self.dateMonth + String.app.recommend
                                        + " " + currentReport.recommendCount.description
                                        + String.app.watchCountUnit,
                                    thumbImg:self.profile,
                                    valuePct:self.watchCountPct,
                                    guideImg:AssetKids.shape.graphGuideNum,
                                    guidePct:self.guideCountPct,
                                    color:Color.app.green,
                                    icon: AssetKids.icon.graphGuideNum,
                                    text:String.kidsText.kidsMyMonthlyReportCount
                                        + " : " + currentReport.recommendCount.description
                                        + String.app.watchCountUnit
                                )
                                
                                ZStack(){
                                    Image(AssetKids.shape.monthlyResultBg)
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .modifier(MatchParent())
                                    VStack(spacing:DimenKids.margin.tiny){
                                        Text(String.kidsText.kidsMyMonthlyReportComment)
                                            .modifier(BoldTextStyleKids(
                                                        size: Font.sizeKids.thinExtra,
                                                        color:  Color.app.white))
                                        if let review = currentReport.review {
                                            ScrollView(.vertical, showsIndicators: false){
                                                Text(review)
                                                    .modifier(BoldTextStyleKids(
                                                                size: Font.sizeKids.tinyExtra,
                                                                color: Color.app.white))
                                            }
                                        }
                                    }
                                    .padding(.top, DimenKids.margin.mediumExtra)
                                    .padding(.horizontal, DimenKids.margin.mediumExtra)
                                    .padding(.bottom, SystemEnvironment.isTablet ? 120 : 73)
                                }
                                .frame(width: MonthlyGraphBox.size.width, height: MonthlyGraphBox.size.height)
                            }
                            .padding(.top, DimenKids.margin.regular)
                            Spacer()
                                .padding(.bottom, self.sceneObserver.safeAreaIgnoreKeyboardBottom)
                        } else {
                            Spacer()
                        }
                        
                    } else {
                        NeedPairingInfo(
                            title: String.kidsText.kidsMyNeedPairing,
                            text: String.kidsText.kidsMyNeedPairingSub)
                            .modifier(MatchParent())
                    }
                    
                }
                .modifier(PageFullScreen(style:.kids))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
              
            }//draging
            .onReceive(self.pairing.$status){status in
                self.isPairing = ( status == .pairing )
            }
            .onReceive(self.tabNavigationModel.$index){ idx in
                if !self.isInitPage {return}
                self.selectResult(idx: idx)
               
            }
            .onReceive(self.pairing.$kid){ kid in
                self.kid = kid
                if !self.isInitPage {return}
                self.loadResult()
            }
            .onReceive(dataProvider.$result) { res in
                guard let res = res else { return }
                switch res.type {
                case .getMonthlyReport :
                    guard let monthlyReport  = res.data as? MonthlyReport  else { return }
                    self.viewModel.setData(monthlyReport)
                default: break
                }
            }
            .onReceive(dataProvider.$error) { err in
                guard let err = err else { return }
                switch err.type {
                case .getMonthlyReport :
                    self.setupErrorResult()
                default: break
                }
            }
            .onReceive(self.viewModel.$isUpdated){ isUpdate in
                if isUpdate {
                    self.setupResult()
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    if self.isInitPage {return}
                    DispatchQueue.main.async {
                        self.isInitPage = true
                        if self.viewModel.datas.isEmpty {
                            self.loadResult()
                        } else {
                            self.setupResult()
                        }
                    }
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let data = obj.getParamValue(key: .data) as? MonthlyReportModel {
                    self.kid = data.kid
                    if let index = obj.getParamValue(key: .index) as? Int {
                        self.tabIdx = index
                    }
                    self.viewModel.setData(colon: data)
                    self.setupDate()
                }
                if let type = obj.getParamValue(key: .type) as? KidsPlayType {
                    self.initReportType = type
                }
            }
        }//geo
    }//body
    
    @State var isInitPage:Bool = false
    @State var kid:Kid? = nil
    @State var isLoading:Bool = false
    @State var isError:Bool = false
    @State var isEmpty:Bool = true
   
    @State var currentDate:Date = Date()
    @State var currentReport:MonthlyReportData? = nil
    @State var tabs:[String] = []
    @State var tabIdx:Int = 0
    @State var initReportType:KidsPlayType? = nil
    
    @State var isLast:Bool = true
    @State var date:String = ""
    @State var dateMonth:String = ""
    @State var profile:String = AssetKids.image.noProfile
    
    @State var watchTimePct:Float = 0
    @State var watchCountPct:Float = 0
    @State var guideTimePct:Float = 0
    @State var guideCountPct:Float = 0
    
    private func resetPage(){
        self.isError = false
        self.currentReport = nil
    }
    private func setupDate(){
        
        let today = Date().toDateFormatter(dateFormat: "yyyy" + String.app.year + " MM") + String.app.month
        let date = self.currentDate.toDateFormatter(dateFormat: "yyyy" + String.app.year + " MM") + String.app.month
        self.isLast = today == date
        self.date = date.subString(2)
    }
    private func loadResult(move:Int = 0){
        guard let kid = self.kid else { return }
        self.currentDate = Calendar.current.date(byAdding: .month, value: move, to: self.currentDate) ?? self.currentDate
        self.setupDate()
        self.resetPage()
        self.isLoading = true
        self.dataProvider.requestData(q: .init(type: .getMonthlyReport(kid, self.currentDate), isOptional: false))
    }
    private func setupResult(){
        self.isLoading = false
        if self.tabs.isEmpty && !self.viewModel.datas.isEmpty{
            if let initReport = initReportType ,
               let find = self.viewModel.datas
                .firstIndex(where: { KidsPlayType.getType($0.svcPropCd) == initReport }){
                
                self.tabIdx = find
                self.initReportType = nil
            }
            
            withAnimation{
                self.tabs = self.viewModel.datas.map{$0.title}
            }
        }
        self.dateMonth = self.viewModel.date.toDateFormatter(dateFormat: "MM" + String.app.month) + " "
        if let kid = self.kid {
            self.profile = AssetKids.characterList[ kid.characterIdx ]
        } else {
            self.profile = AssetKids.image.noProfile
        }
        self.selectResult(idx: self.tabIdx)
    }
    private func selectResult(idx:Int){
        if idx >= self.tabs.count {return}
        self.tabIdx = idx
        let select = self.viewModel.datas[idx]
        withAnimation{
            self.currentReport = select
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 ) {
            withAnimation{
                self.guideTimePct = select.averageTimePct
                self.guideCountPct = select.averageCountPct
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 ) {
            withAnimation{
                self.watchTimePct = select.learningTimePct
                self.watchCountPct = select.learningCountPct
            }
        }
       
    }
    private func selectedData(_ select:MonthlyReportData){
        
    }
    
    private func setupErrorResult(){
        self.isLoading = false
        withAnimation{
            self.isError = true
        }
    }
}

#if DEBUG
struct PageKidsMyMonthly_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            PageKidsMyMonthly().contentBody
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
