//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI

/*
enum MonthlyReportType:String, CaseIterable{
    case english ,fairytale, creativity, elementarySchool
    
    var name: String {
        switch self {
        case .english: return String.sort.english
        case .fairytale: return String.sort.fairytale
        case .creativity: return String.sort.creativity
        case .elementarySchool: return String.sort.elementarySchool
        
        }
    }
}
 */
class MonthlyReportData:Identifiable, Equatable{
    let id:String = UUID().uuidString
    private(set) var review:String? = nil
    private(set) var svcPropCd:String? = nil
    private(set) var title:String = ""
    private(set) var learningTime:Int = 0
    private(set) var learningCount:Int = 0
   
    private(set) var averageTime:Int = 0
    private(set) var averageCount:Int = 0
    private(set) var recommendTime:Int = 0
    private(set) var recommendCount:Int = 0
    
    func setData(_ data:MonthlyReportItem) -> MonthlyReportData{
        self.review = data.total_cn
        self.svcPropCd = data.svc_prop_cd
        self.title = data.svc_prop_nm ?? ""
        self.learningTime = data.learning_mm ?? 0
        self.learningCount = data.learning_cnt ?? 0
        self.averageTime = data.avg_mm ?? 0
        self.averageCount = data.avg_cnt ?? 0
        self.recommendTime = data.recommend_mm ?? 0
        self.recommendCount = data.recommend_cnt ?? 0
        return self
    }
    
    var averageTimePct:Float {
        get{ return min(1.0, (Float(self.averageTime) / Float(self.recommendTime))) }
    }
    var learningTimePct:Float {
        get{ return min(1.0, (Float(self.learningTime) / Float(self.recommendTime))) }
    }
    var averageCountPct:Float {
        get{ return min(1.0, (Float(self.averageCount) / Float(self.recommendCount))) }
    }
    var learningCountPct:Float {
        get{ return min(1.0, (Float(self.learningCount) / Float(self.recommendCount))) }
    }
    
    public static func == (l:MonthlyReportData, r:MonthlyReportData)-> Bool {
        return l.svcPropCd == r.svcPropCd
    }
}

class MonthlyReportModel:ObservableObject, PageProtocol{
    @Published private(set) var isUpdated:Bool = false {didSet{ if isUpdated { isUpdated = false} }}
    private(set) var kid:Kid? = nil
    private(set) var date:Date = Date()
    private(set) var datas:[MonthlyReportData] = []
    
    func setData(_ data:MonthlyReport, kid:Kid?, date:Date?){
        self.kid = kid
        self.date = date ?? Date()
        if let infos = data.contents?.infos {
            self.datas = infos.map{ MonthlyReportData().setData($0) }
        }
        self.isUpdated = true
    }
}

struct MonthlyReportCard: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel:MonthlyReportModel = MonthlyReportModel()
    
   
    
    var body: some View {
        ZStack{
            ZStack(alignment: .bottom){
                ForEach(self.reports) { report in
                    ReportPage(name: report.title)
                        .padding(.top, self.currentReport?.svcPropCd == report.svcPropCd ? 0 : DimenKids.margin.heavy)
                }
            }
            .padding(.all, DimenKids.margin.tiny)
            Image( AssetKids.shape.cardFolderWide)
                .renderingMode(.original)
                .resizable()
                .scaledToFill()
                .modifier(MatchParent())
            VStack(alignment: .center ,spacing:0){
                HStack(spacing:0){
                    Text(String.kidsText.kidsMyMonthlyReport)
                        .modifier(BoldTextStyleKids(
                                    size: Font.sizeKids.light,
                                    color:  Color.app.brownDeep))
                        .padding(.leading, DimenKids.margin.light)
                        .padding(.vertical, DimenKids.margin.thin)
                        .fixedSize()
                    if self.isEmpty {
                        Spacer().modifier(MatchHorizontal(height: 1))
                    } else {
                        Text("|")
                            .modifier(BoldTextStyleKids(
                                        size: Font.sizeKids.light,
                                        color:  Color.app.sepia))
                            .padding(.all, DimenKids.margin.thin)
                            .fixedSize()
                        Text(self.date)
                            .modifier(BoldTextStyleKids(
                                        size: Font.sizeKids.light,
                                        color:  Color.app.sepia))
                            .padding(.vertical, DimenKids.margin.thin)
                            .fixedSize()
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
                if let currentReport = self.currentReport {
                    HStack(spacing:DimenKids.margin.mediumExtra){
                        MonthlyGraphBox(
                            title:String.app.watchTime,
                            value:currentReport.learningTime.description + String.app.min,
                            subTitle:self.dateMonth + String.app.recommend + " " + currentReport.recommendTime.description + String.app.min,
                            thumbImg:self.profile,
                            valurPct:self.watchTimePct,
                            guideImg:AssetKids.shape.graphGuideTime,
                            guidePct:currentReport.averageTimePct,
                            color:Color.app.yellow
                        )
                        
                        Spacer().modifier(
                            LineVertical(width: DimenKids.line.light,
                                         margin: DimenKids.margin.thin,
                                         color: Color.app.ivoryLight,
                                         opacity: 1.0))
                        
                        MonthlyGraphBox(
                            title:String.app.watchCount,
                            value:currentReport.learningCount.description + String.app.watchCountUnit,
                            subTitle:self.dateMonth + String.app.recommend + " " + currentReport.recommendCount.description + String.app.watchCountUnit,
                            thumbImg:self.profile,
                            valurPct:self.watchCountPct,
                            guideImg:AssetKids.shape.graphGuideNum,
                            guidePct:currentReport.averageCountPct,
                            color:Color.app.green
                        )
                        
                    }
                } else {
                    
                    Button(action: {
                        self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.registKid))
                        
                    }) {
                        Image( AssetKids.image.reportImg)
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: SystemEnvironment.isTablet ? 175 : 91,
                                   height: SystemEnvironment.isTablet ? 106 : 55)
                    }
                    
                    Text(String.kidsText.kidsMyMonthlyReportText)
                        .multilineTextAlignment(.center)
                        .modifier(BoldTextStyleKids(
                                    size: Font.sizeKids.tiny,
                                    color:  Color.app.sepiaDeep))
                        .padding(.top, DimenKids.margin.light)
                    Text(String.kidsText.kidsMyMonthlyReportStart)
                        .multilineTextAlignment(.center)
                        .modifier(BoldTextStyleKids(
                                    size: Font.sizeKids.thin,
                                    color:  Color.app.brownDeep))
                        .padding(.top, DimenKids.margin.tinyExtra)
                }
                Spacer()
            }
        }
        .frame(
            width: SystemEnvironment.isTablet ? 574 : 302,
            height: SystemEnvironment.isTablet ? 359 : 187)
        .onReceive(self.viewModel.$isUpdated){ isUpdated in
            if !isUpdated {return}
            self.updatedData()
        }
        .onAppear(){
        }
    }
    @State var isEmpty:Bool = true
   
    @State var date:String = ""
    @State var dateMonth:String = ""
    @State var profile:String = AssetKids.image.noProfile
    @State var reports:[MonthlyReportData] = []
    @State var currentReport:MonthlyReportData? = nil
   
    @State var watchTimePct:Float = 0
    @State var watchCountPct:Float = 0
      
    private func selectData(){
        let selectIdx = self.currentReport == nil
            ? -1
            : self.reports.firstIndex(of: self.currentReport!)
        self.appSceneObserver.select =
            .select(
                (self.tag , self.reports.map{$0.title} ), selectIdx ?? -1){ idx in
                
                self.selectedData(self.reports[idx])
            }
    }
    
    private func updatedData(){
        self.isEmpty = self.viewModel.kid == nil
        if self.isEmpty {
            self.currentReport = nil
            self.reports = []
            self.profile = AssetKids.image.noProfile
        } else {
            self.reports = self.viewModel.datas
            self.date = self.viewModel.date.toDateFormatter(dateFormat: "yyyy" + String.app.year + " MM" + String.app.month)
            self.dateMonth = self.viewModel.date.toDateFormatter(dateFormat: "MM" + String.app.month) + " "
            if let kid = self.viewModel.kid {
                self.profile = AssetKids.characterList[ kid.characterIdx ]
            } else {
                self.profile = AssetKids.image.noProfile
            }
            if let currentReport = self.currentReport {
                if let find =  self.reports.first(where: {currentReport.svcPropCd == $0.svcPropCd }){
                    self.selectedData(find)
                    return
                }
            }
            if let select = self.reports.first {
                self.selectedData(select)
            }
        }
    }
    private func selectedData(_ select:MonthlyReportData){
        withAnimation{
            self.currentReport = select
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 ) {
            withAnimation{
                watchTimePct = select.learningTimePct
                watchCountPct = select.learningCountPct
            }
        }
    }
    
}

#if DEBUG
struct MonthlyReportCard_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            MonthlyReportCard()
                .environmentObject(PagePresenter())
                .background(Color.app.ivory)
        }
    }
}
#endif
