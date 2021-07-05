//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI

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

class MonthlyReportData:ObservableObject, PageProtocol{
    @Published private(set) var isUpdated:Bool = false
    var kid:Kid? = nil
    
    func setData(_ data:MonthlyReport){
        
    }
}

struct MonthlyReportCard: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel:MonthlyReportData = MonthlyReportData()
    
    @State var isEmpty:Bool = true
    @State var selectedType:MonthlyReportType? = nil
    @State var date:String = "2020년 6월"
    var body: some View {
        ZStack{
            ZStack(alignment: .bottom){
                ForEach(MonthlyReportType.allCases, id:\.rawValue) { type in
                    ReportPage(name: type.name)
                        .padding(.top, selectedType == type ? 0 : DimenKids.margin.heavy)
                }
            }
            .padding(.all, DimenKids.margin.tiny)
            Image( AssetKids.shape.cardFolderWide)
                .renderingMode(.original)
                .resizable()
                .scaledToFill()
                .modifier(MatchParent())
            VStack(alignment: .center ,spacing:0){
                HStack{
                    Text(String.kidsText.kidsMyMonthlyReport)
                        .modifier(BoldTextStyleKids(
                                    size: Font.sizeKids.light,
                                    color:  Color.app.brownDeep))
                        .padding(.all, DimenKids.margin.thin)
                        .fixedSize()
                    if self.isEmpty {
                        Spacer().modifier(MatchHorizontal(height: 1))
                    } else {
                        Text("|")
                            .modifier(BoldTextStyleKids(
                                        size: Font.sizeKids.light,
                                        color:  Color.app.sepia))
                            .padding(.vertical, DimenKids.margin.thin)
                            .fixedSize()
                        Text(self.date)
                            .modifier(BoldTextStyleKids(
                                        size: Font.sizeKids.light,
                                        color:  Color.app.sepia))
                            .padding(.all, DimenKids.margin.thin)
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
                if self.isEmpty {
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
                } else {
                    
                }
                Spacer()
            }
        }
        .frame(
            width: SystemEnvironment.isTablet ? 574 : 302,
            height: SystemEnvironment.isTablet ? 359 : 187)
        .onReceive(self.viewModel.$isUpdated){ isUpdated in
            if !isUpdated {return}
        }
        .onAppear(){
        }
    }
    
    func selectData(){
        let selectIdx = self.selectedType == nil
            ? -1
            : MonthlyReportType.allCases.firstIndex(of: self.selectedType!)
        self.appSceneObserver.select =
            .select(
                (self.tag , MonthlyReportType.allCases.map{$0.name} ), selectIdx ?? -1){ idx in
                withAnimation{
                    self.selectedType = MonthlyReportType.allCases[idx]
                }
            }
    }
    
    func updatedData(){
        self.isEmpty = self.viewModel.kid == nil
        if self.isEmpty {
            self.selectedType = nil
        } else {
            
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
