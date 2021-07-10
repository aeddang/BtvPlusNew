//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI



struct MonthlyReportCard: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pairing:Pairing
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
                if self.isLoading {
                    Spacer()
                    
                }else if let currentReport = self.currentReport {
                    HStack(spacing:DimenKids.margin.mediumExtra){
                        MonthlyGraph(
                            title:String.app.watchTime,
                            value:currentReport.learningTime.description + String.app.min,
                            subTitle:self.dateMonth + String.app.recommend + " " + currentReport.recommendTime.description + String.app.min,
                            thumbImg:self.profile,
                            valuePct:self.watchTimePct,
                            color:Color.app.yellow
                        )
                        
                        Spacer().modifier(
                            LineVertical(width: DimenKids.line.light,
                                         margin: DimenKids.margin.thin,
                                         color: Color.app.ivoryLight,
                                         opacity: 1.0))
                        
                        MonthlyGraph(
                            title:String.app.watchCount,
                            value:currentReport.learningCount.description + String.app.watchCountUnit,
                            subTitle:self.dateMonth + String.app.recommend + " " + currentReport.recommendCount.description + String.app.watchCountUnit,
                            thumbImg:self.profile,
                            valuePct:self.watchCountPct,
                            color:Color.app.green
                        )
                        
                    }
                    .onTapGesture {
                        self.moveResultPage()
                    }
                } else {
                    
                    Button(action: {
                        self.moveResultPage()
                        
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
    @State var isLoading:Bool = true
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
            withAnimation{
                self.isLoading = false
            }
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
            self.isLoading = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 ) {
            withAnimation{
                watchTimePct = select.learningTimePct
                watchCountPct = select.learningCountPct
            }
        }
    }
    
    private func moveResultPage(){
        if self.viewModel.kid == nil {
            self.appSceneObserver.alert = .confirm(
                nil ,
                String.kidsText.kidsMyReportNeedProfile
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
                .getPageObject(.kidsMyMonthly)
                .addParam(key: .data, value: self.viewModel)
        )
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
