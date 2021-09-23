//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI


extension DiagnosticReportCard{
    static let cardWidth:CGFloat = SystemEnvironment.isTablet ? 344 : 179
    static let cardWidthWide:CGFloat = SystemEnvironment.isTablet ? 574 : 302
}

struct DiagnosticReportCard: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var pairing:Pairing
    @ObservedObject var viewModel:DiagnosticReportModel = DiagnosticReportModel()

    var body: some View {
        ZStack{
            ZStack(alignment: .bottom){ 
                ForEach(DiagnosticReportType.allCases , id:\.rawValue) { type in
                    if let name = type.name {
                        ReportPage(name: name)
                            .padding(.top, selectedType == type ? 0 : DimenKids.margin.heavy)
                    }
                }
            }
            .padding(.all, DimenKids.margin.tiny)
            Image( self.cardWidth == Self.cardWidthWide ? AssetKids.shape.cardFolderWide : AssetKids.shape.cardFolder)
                .renderingMode(.original)
                .resizable()
                .scaledToFill()
                .modifier(MatchParent())
            VStack(alignment: .center ,spacing:0){
                HStack(spacing:0){
                    Text(String.kidsText.kidsMyDiagnosticReport)
                        .modifier(BoldTextStyleKids(
                                    size: Font.sizeKids.light,
                                    color:  Color.app.brownDeep))
                        .padding(.leading, DimenKids.margin.light)
                        .padding(.vertical, DimenKids.margin.thin)
                        .fixedSize()
                    if self.isEmpty {
                        Spacer().modifier(MatchHorizontal(height: 1))
                    } else {
                        Button(action: {
                            self.selectData()
                        }) {
                            Spacer()
                                .background(Color.transparent.clearUi)
                                .modifier(MatchHorizontal(height: Font.sizeKids.light))
                        }
                    }
                }
                Spacer()
                if self.isLoading {
                    Spacer()
                    
                } else if self.isError {
                    ErrorKidsData()
                        .modifier(MatchParent())
                }else if self.isEmpty || self.isEmptyResult{
                    Button(action: {
                        
                        self.moveResultPage()
                        
                    }) {
                        Image( AssetKids.icon.addReport)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: DimenKids.icon.mediumUltraExtra,
                                   height: DimenKids.icon.mediumUltraExtra)
                    }
                    
                    Text(String.kidsText.kidsMyDiagnosticReportText)
                        .modifier(BoldTextStyleKids(
                                    size: Font.sizeKids.tiny,
                                    color:  Color.app.sepiaDeep))
                        .padding(.top, DimenKids.margin.light)
                    Text(String.kidsText.kidsMyDiagnosticReportStart)
                        .modifier(BoldTextStyleKids(
                                    size: Font.sizeKids.thin,
                                    color:  Color.app.brownDeep))
                        .padding(.top, DimenKids.margin.tinyExtra)
                } else {
                    if let lvGraphBoxData = self.lvGraphBoxData {
                        LvGraphBox(thumb: self.profile, data: lvGraphBoxData)
                            .padding(.horizontal, DimenKids.margin.light)
                            .padding(.bottom, DimenKids.margin.thin)
                            .onTapGesture {
                                self.moveResultPage()
                            }
                    }
                    if let creativeGraphBoxData = self.creativeGraphBoxData {
                        CreativeGraphBox( data: creativeGraphBoxData)
                            .padding(.horizontal, DimenKids.margin.light)
                            .padding(.bottom, DimenKids.margin.thin)
                            .onTapGesture {
                                self.moveResultPage()
                            }
                    }
                }
                Spacer()
            }
            if self.isLoading {
                ActivityIndicator(isAnimating: self.$isLoading, style: .medium)
            }
        }
        .frame(
            width:self.cardWidth,
            height: SystemEnvironment.isTablet ? 359 : 187)
        
        .onReceive(self.viewModel.$isUpdated){ isUpdated in
            if !isUpdated {return}
            self.updatedData()
        }
        
        .onReceive(dataProvider.$result) { res in
            guard let res = res else { return }
            switch res.type {
            case .getEnglishLvReportResult :
                if self.selectedType != .english {return}
                guard let report  = res.data as? KidsReport  else { return self.setupEmptyResult() }
                self.setupKidsReport(report)
            case .getReadingReport:
                if self.selectedType != .infantDevelopment {return}
                guard let report  = res.data as? ReadingReport  else { return self.setupEmptyResult() }
                self.setupReadingReport(report)
            case .getReadingReportResult(_, let area):
                if self.selectedType != .infantDevelopment {return}
                if self.viewModel.readingArea != area {return}
                guard let report  = res.data as? KidsReport  else { return self.setupEmptyResult() }
                self.setupKidsReport(report)
            case .getCreativeReportResult:
                if self.selectedType != .creativeObservation {return}
                guard let report  = res.data as? CreativeReport  else { return self.setupEmptyResult() }
                self.setupCreativeReport(report)
            default: break
            }
        }
        .onReceive(dataProvider.$error) { err in
            guard let err = err else { return }
            switch err.type {
            case .getEnglishLvReportResult :
                if self.selectedType != .english {return}
                self.setupErrorResult()
            case .getReadingReportResult(_, let area):
                if self.selectedType != .infantDevelopment {return}
                if self.viewModel.readingArea != area {return}
                self.setupErrorResult()
            case .getReadingReport:
                if self.selectedType != .infantDevelopment {return}
                self.setupErrorResult()
            case .getCreativeReportResult:
                if self.selectedType != .creativeObservation {return}
                self.setupErrorResult()
            default: break
            }
        }
        .onAppear(){
        }
    }
    @State var cardWidth:CGFloat = Self.cardWidth
    @State var isLoading:Bool = false
    @State var isError:Bool = false
    @State var isEmpty:Bool = true
    @State var isEmptyResult:Bool = false
    @State var selectedType:DiagnosticReportType? = nil
    
    @State var kid:Kid? = nil
    @State var profile:String = AssetKids.image.noProfile
    @State var lvGraphBoxData:LvGraphBoxData? = nil
    @State var creativeGraphBoxData:CreativeGraphBoxData? = nil
    @State var reportContents:KidsReportContents? = nil
    private func selectData(){
        let selectIdx = self.selectedType == nil
            ? -1
            : DiagnosticReportType.allCases.firstIndex(of: self.selectedType!)
        self.appSceneObserver.select =
            .select(
                (self.tag , DiagnosticReportType.allCases.filter{$0.name != nil}.map{$0.name!} ), selectIdx ?? -1){ idx in
                self.selectedData(DiagnosticReportType.allCases[idx])
            }
    }
    
    private func updatedData(){
        self.kid = self.viewModel.kid
        if self.viewModel.kid == nil {
            self.profile = AssetKids.image.noProfile
            self.isEmpty = true
            withAnimation{
                self.selectedType = nil
                self.cardWidth = Self.cardWidth
            }
        } else {
            self.isEmpty = false
            if let kid = self.viewModel.kid {
                self.profile = AssetKids.characterList[ kid.characterIdx ]
            } else {
                self.profile = AssetKids.image.noProfile
            }
            self.selectedData( self.selectedType ?? .english )
        }
    }
    
    private func resetPage(){
        self.isError = false
        self.isEmptyResult = false
        self.lvGraphBoxData = nil
        self.creativeGraphBoxData = nil
        self.reportContents = nil
    }
    
    private func selectedData(_ select:DiagnosticReportType){
        guard let kid = self.kid else { return }
        withAnimation{
            self.selectedType = select
            self.cardWidth = Self.cardWidth
        }
        self.isLoading = true
        self.resetPage()
        switch select {
        case .english:
            self.dataProvider.requestData(q: .init(type: .getEnglishLvReportResult(kid)))
        case .infantDevelopment:
            if self.viewModel.studyData.resultSentence != nil {
                if let area = self.viewModel.readingArea {
                    self.dataProvider.requestData(q: .init(type: .getReadingReportResult(kid, area: area)))
                } else {
                    self.dataProvider.requestData(q: .init(type: .getReadingReport(kid)))
                }
            } else {
                self.setupEmptyResult()
            }
        case .creativeObservation:
            self.dataProvider.requestData(q: .init(type: .getCreativeReportResult(kid)))
        default : break
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
    
    private func setupKidsReport(_ report:KidsReport){
        if report.contents?.test_rslt_yn?.bool == true {
            self.isLoading = false
            self.isEmptyResult = false
            self.reportContents = report.contents
            withAnimation{
                if self.selectedType == .english {
                    self.lvGraphBoxData = LvGraphBoxData().setDataLv(report)
                } else {
                    self.lvGraphBoxData = LvGraphBoxData().setDataGraph(report)
                }
            }
        } else {
            self.setupEmptyResult()
        }
    }
    
    private func setupReadingReport(_ report:ReadingReport){
        guard let kid = self.kid else { return }
        if let resultSentence = self.viewModel.studyData.resultSentence {
            guard let find = report.contents?.areas?.first(where: {$0.hcls_area_nm == resultSentence}) else {
                self.setupEmptyResult()
                return
            }
            guard let area = find.hcls_area_cd else {
                self.setupEmptyResult()
                return
            }
            self.viewModel.readingArea = area
            self.dataProvider.requestData(q: .init(type: .getReadingReportResult(kid, area: area)))
        } else {
            self.setupEmptyResult()
        }
    }
    
    private func setupCreativeReport(_ report: CreativeReport){
        if report.contents?.test_rslt_yn?.bool == true {
            self.isLoading = false
            self.isEmptyResult = false
            self.reportContents = report.contents
            withAnimation{
                self.cardWidth = Self.cardWidthWide
                self.creativeGraphBoxData = CreativeGraphBoxData().setData(report)
            }
        } else {
            self.setupEmptyResult()
        }
    }
    
    private func moveResultPage(){
        if self.kid == nil {
            self.appSceneObserver.alert = .confirm(
                nil ,
                String.kidsText.kidsMyReportNeedProfile,
                confirmText: String.app.regist
                ){ isOk in
                if isOk {
                    if self.pairing.kids.isEmpty {
                        self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.editKid))
                    } else {
                        self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsProfileManagement))
                    }
                }
            }
            return
        }
        self.pagePresenter.openPopup(
            PageKidsProvider
                .getPageObject(.kidsMyDiagnostic)
                .addParam(key: .type, value: self.selectedType)
                .addParam(key: .subType, value: self.viewModel.readingArea)
                .addParam(key: .id, value: self.viewModel.studyData.resultSentence)
                .addParam(key: .data, value: self.reportContents)
        )
    }
}

#if DEBUG
struct DiagnosticReportCard_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            DiagnosticReportCard()
                .environmentObject(PagePresenter())
                .background(Color.app.ivory)
        }
    }
}
#endif
