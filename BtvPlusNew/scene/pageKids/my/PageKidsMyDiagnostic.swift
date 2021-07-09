//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
extension PageKidsMyDiagnostic{
   
    static let tabWidth:CGFloat = SystemEnvironment.isTablet ? 186 : 123
}

struct PageKidsMyDiagnostic: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
    @ObservedObject var readingListScrollModel: InfinityScrollModel = InfinityScrollModel()
    @ObservedObject var tabNavigationModel:NavigationModel = NavigationModel()
  
    @State var isPairing:Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
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
                            MenuTab(
                                viewModel: self.tabNavigationModel,
                                buttons: DiagnosticReportType.allCases.map{$0.name},
                                selectedIdx: DiagnosticReportType.allCases.firstIndex(of: self.type) ?? 0,
                                isDivision: true)
                                .frame(width: Self.tabWidth * CGFloat(DiagnosticReportType.allCases.count))
                        }
                        .padding(.bottom, DimenKids.margin.thin)
                        .background(Color.app.white)
                        if self.isReadingSelect {
                            ResultReadingListView(
                                infinityScrollModel: self.readingListScrollModel,
                                kid: self.kid ?? Kid() ){ data in
                                self.selectReadingArea(data: data)
                            }
                            .modifier(MatchParent())
                        }else if self.isEmptyResult {
                            EmptyDiagnosticView(type: self.type, kid: self.kid ?? Kid()){ type in
                                self.startReport(startType: type)
                            }
                            .modifier(MatchParent())
                        } else if self.isError {
                            ErrorKidsData()
                                .modifier(MatchParent())
                        } else{
                            if let resultData = self.resultEnglishReportViewData {
                                ResultEnglishReportView(data: resultData){
                                    self.moveExamPage(moveType: .english)
                                }
                                .modifier(MatchParent())
                            } else if let resultData = self.resultReadingReportViewData {
                                ResultReadingReportView(data: resultData){ isRetry in
                                    if isRetry {
                                        self.moveExamPage(moveType: .infantDevelopment)
                                    } else {
                                        self.startReport(startType: .infantDevelopment)
                                    }
                                }
                                .modifier(MatchParent())
                            } else if let resultData = self.resultCreativeReportViewData {
                                ResultCreativeReportView(data: resultData){
                                    self.moveExamPage(moveType: .creativeObservation)
                                }
                                .modifier(MatchParent())
                            } else {
                                Spacer()
                            }
                        }
                        
                        
                    } else {
                        NeedPairingInfo(
                            title: String.kidsText.kidsMyNeedPairing,
                            text: String.kidsText.kidsMyNeedPairingSub)
                            .modifier(MatchParent())
                    }
                    
                }
                .background(
                    Image(AssetKids.image.myBg)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFill()
                        .modifier(MatchParent())
                        .opacity(self.isEmptyResult ? 1 : 0)
                )
    
                .modifier(PageFullScreen(style:.kids))
                .modifier(PageDraging(geometry: geometry, pageDragingModel: self.pageDragingModel))
              
            }//draging
            .onReceive(self.readingListScrollModel.$event){evt in
                guard let evt = evt else {return}
                switch evt {
                case .pullCompleted:
                    self.pageDragingModel.uiEvent = .pullCompleted(geometry)
                case .pullCancel :
                    self.pageDragingModel.uiEvent = .pullCancel(geometry)
                default : break
                }
            }
            .onReceive(self.readingListScrollModel.$pullPosition){ pos in
                self.pageDragingModel.uiEvent = .pull(geometry, pos)
            }
            .onReceive(self.pairing.$status){status in
                self.isPairing = ( status == .pairing )
            }
            .onReceive(self.tabNavigationModel.$index){ idx in
                if !self.isInitPage {return}
                self.loadResult(DiagnosticReportType.allCases[idx])
            }
            .onReceive(self.pairing.$kid){ kid in
                self.kid = kid
                if !self.isInitPage {return}
                self.loadResult(self.type)
            }
            .onReceive(dataProvider.$result) { res in
                guard let res = res else { return }
                switch res.type {
                case .getKidStudy :
                    guard let study  = res.data as? KidStudy  else { return }
                    self.setupStudyData(study)
                case .getEnglishLvReportResult :
                    if self.type != .english {return}
                    guard let report  = res.data as? KidsReport  else { return self.setupEmptyResult() }
                    self.setupKidsReport(report)
                case .getReadingReport:
                    if self.type != .infantDevelopment {return}
                    guard let report  = res.data as? ReadingReport  else { return self.setupEmptyResult() }
                    self.setupReadingReport(report)
                case .getReadingReportResult(_, let area):
                    if self.type != .infantDevelopment {return}
                    if self.readingArea != area {return}
                    guard let report  = res.data as? KidsReport  else { return self.setupEmptyResult() }
                    self.setupKidsReport(report)
                case .getCreativeReportResult:
                    if self.type != .creativeObservation {return}
                    guard let report  = res.data as? CreativeReport  else { return self.setupEmptyResult() }
                    self.setupCreativeReport(report)
                    
                case .getEnglishLvReportQuestion :
                    guard let result = res.data as? KidsExamQuestionResult else { return }
                    if result.result != ApiCode.success { return }
                    self.loadResult(.english)
                case .getReadingReportQuestion :
                    guard let result = res.data as? KidsExamQuestionResult else { return }
                    if result.result != ApiCode.success { return }
                    self.resultSentence = nil
                    self.readingArea = nil
                    self.loadResult(.infantDevelopment)
                case .getCreativeReportQuestion :
                    guard let result = res.data as? KidsExamQuestionResult else { return }
                    if result.result != ApiCode.success { return }
                    self.loadResult(.creativeObservation)
                default: break
                }
            }
            .onReceive(dataProvider.$error) { err in
                guard let err = err else { return }
                switch err.type {
                case .getEnglishLvReportResult :
                    if self.type != .english {return}
                    self.setupErrorResult()
                case .getReadingReport:
                    if self.type != .infantDevelopment {return}
                    self.setupErrorResult()
                case .getReadingReportResult(_, let area):
                    if self.type != .infantDevelopment {return}
                    if self.readingArea != area {return}
                    self.setupErrorResult()
                case .getCreativeReportResult:
                    if self.type != .creativeObservation {return}
                    self.setupErrorResult()
               
                default: break
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.isInitPage = true
                    if let result = self.result  {
                        self.setupKidsReportContent(result)
                    } else {
                        self.loadResult(self.type)
                    }
                }
            }
            .onAppear{
                guard let obj = self.pageObject  else { return }
                if let type = obj.getParamValue(key: .type) as? DiagnosticReportType {
                    self.type = type
                }
                if let data = obj.getParamValue(key: .data) as? KidsReportContents {
                    self.result = data
                }
                if let area = obj.getParamValue(key: .subType) as? String {
                    self.readingArea = area
                }
                if let sentence = obj.getParamValue(key: .id) as? String {
                    self.resultSentence = sentence
                }
            }
        }//geo
    }//body
    @State var isInitPage:Bool = false
    @State var kid:Kid? = nil
    @State var type:DiagnosticReportType = .english
    @State var result:KidsReportContents? = nil
    @State var isLoading:Bool = false
    @State var isError:Bool = false
    @State var isEmpty:Bool = true
    @State var isEmptyResult:Bool = false
    @State var isReadingSelect:Bool = false
    
    @State var resultSentence:String? = nil
    @State var readingArea:String? = nil
    
    @State var resultEnglishReportViewData:ResultEnglishReportViewData? = nil
    @State var resultReadingReportViewData:ResultReadingReportViewData? = nil
    @State var resultCreativeReportViewData:ResultCreativeReportViewData? = nil
    private func resetPage(){
        self.isError = false
        self.isEmptyResult = false
        self.isReadingSelect = false
        self.resultEnglishReportViewData = nil
        self.resultReadingReportViewData = nil
        self.resultCreativeReportViewData = nil
    }
    
    private func loadResult(_ type:DiagnosticReportType){
        guard let kid = self.kid else { return }
        self.isLoading = false
        self.resetPage()
        withAnimation{ self.type = type }
        self.result = nil
        switch type {
        case .english:
            self.dataProvider.requestData(q: .init(type: .getEnglishLvReportResult(kid)))
        case .infantDevelopment:
            if let area = self.readingArea {
                self.dataProvider.requestData(q: .init(type: .getReadingReportResult(kid, area: area)))
            } else {
                if self.resultSentence != nil{
                    self.dataProvider.requestData(q: .init(type: .getReadingReport(kid)))
                } else {
                    self.dataProvider.requestData(q: .init(type: .getKidStudy(kid)))
                }
            }
        case .creativeObservation:
            self.dataProvider.requestData(q: .init(type: .getCreativeReportResult(kid)))
        }
    }
    
    private func setupEmptyResult(){
        self.isLoading = false
        withAnimation{
            self.isEmptyResult = true
        }
    }
    
    private func setupErrorResult(){
        self.isLoading = false
        withAnimation{
            self.isError = true
        }
    }
    private func setupStudyData(_ data:KidStudy){
        guard let kid = self.kid else { return }
        self.resultSentence = DiagnosticReportModel().setData(data, kid: self.kid).studyData.resultSentence
        self.readingArea = nil
        if self.type == .infantDevelopment {
            self.dataProvider.requestData(q: .init(type: .getReadingReport(kid)))
        }
    }
    private func setupKidsReport(_ report:KidsReport){
        if report.contents?.test_rslt_yn?.bool == true , let contents = report.contents {
            self.isLoading = false
            self.setupKidsReportContent(contents)
        } else {
            setupEmptyResult()
        }
    }
    
    private func setupKidsReportContent(_ contents:KidsReportContents){
        withAnimation{
            switch self.type {
            case .english :
                self.resultEnglishReportViewData = ResultEnglishReportViewData().setData(contents, kid: self.kid)
            case .infantDevelopment :
                self.resultReadingReportViewData = ResultReadingReportViewData().setData(contents, kid: self.kid)
            case .creativeObservation :
                self.resultCreativeReportViewData = ResultCreativeReportViewData().setData(contents, kid: self.kid)
                break
            }
        }
        
    }
    
    private func setupReadingReport(_ report:ReadingReport){
        guard let kid = self.kid else { return }
        if let resultSentence = self.resultSentence {
            guard let find = report.contents?.areas?.first(where: {$0.hcls_area_nm == resultSentence}) else {
                self.setupEmptyResult()
                return
            }
            guard let area = find.hcls_area_cd else {
                self.setupEmptyResult()
                return
            }
            self.readingArea = area
            self.dataProvider.requestData(q: .init(type: .getReadingReportResult(kid, area: area)))
        } else {
            self.setupEmptyResult()
        }
    }
    
    private func setupCreativeReport(_ report: CreativeReport){
        if report.contents?.test_rslt_yn?.bool == true, let contents = report.contents {
            self.isLoading = false
            self.setupKidsReportContent(contents)
        } else {
            setupEmptyResult()
        }
    }
    
    private func startReport(startType: DiagnosticReportType){
        switch startType {
        case .infantDevelopment:
            self.isReadingSelect = true
        default:
            self.moveExamPage(moveType: startType)
        }
    }
    
    private func selectReadingArea(data: ReadingListData){
        self.type = .infantDevelopment
        if data.isComplete {
            if data.area == self.readingArea {
                self.isReadingSelect = false
                if self.resultReadingReportViewData == nil {
                    self.loadResult(.infantDevelopment)
                }
            } else {
                self.resultSentence = data.title
                self.readingArea = data.area
                self.loadResult(.infantDevelopment)
            }
        } else {
            self.moveExamPage(moveType: .infantDevelopment, moveId: data.type.code, moveTitle:data.title)
        }
    }
    
    private func moveExamPage(moveType: DiagnosticReportType, moveId:String? = nil, moveTitle:String? = nil){
        switch moveType {
        case .english:
            self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsEnglishLvTestSelect))
        case .infantDevelopment:
            self.pagePresenter.openPopup(
                PageKidsProvider.getPageObject(.kidsExam)
                    .addParam(key: .type, value: DiagnosticReportType.infantDevelopment)
                    .addParam(key: .id, value: moveId ?? self.readingArea)
                    .addParam(key: .text, value: moveTitle ?? self.resultSentence)
            )
            break
        case .creativeObservation:
            self.pagePresenter.openPopup(
                PageKidsProvider.getPageObject(.kidsExam)
                    .addParam(key: .type, value: DiagnosticReportType.creativeObservation)
            )
            break
        }
    }
}

#if DEBUG
struct PageKidsMyDiagnostic_Previews: PreviewProvider { 
    static var previews: some View {
        ZStack{
            PageKidsMyDiagnostic().contentBody
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
