//
//  KidProfile.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/03.
//

import Foundation
import SwiftUI

enum DiagnosticReportType:String, CaseIterable{
    case english ,infantDevelopment, creativeObservation
    
    var name: String {
        switch self {
        case .english: return String.sort.english
        case .infantDevelopment: return String.sort.infantDevelopment
        case .creativeObservation: return String.sort.creativeObservation
        
        }
    }
    
}

class DiagnosticReportData:ObservableObject, PageProtocol{
    @Published private(set) var isUpdated:Bool = false
    var kid:Kid? = nil
    
    func setData(_ data:EnglishReport){
        
    }
}

struct DiagnosticReportCard: PageComponent{
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @ObservedObject var viewModel:DiagnosticReportData = DiagnosticReportData()
    
    @State var isEmpty:Bool = true
    @State var selectedType:DiagnosticReportType? = nil
    var body: some View {
        ZStack{
            ZStack(alignment: .bottom){
                ForEach(DiagnosticReportType.allCases, id:\.rawValue) { type in
                    ReportPage(name: type.name)
                        .padding(.top, selectedType == type ? 0 : DimenKids.margin.heavy)
                }
            }
            .padding(.all, DimenKids.margin.tiny)
            Image( AssetKids.shape.cardFolder)
                .renderingMode(.original)
                .resizable()
                .scaledToFill()
                .modifier(MatchParent())
            VStack(alignment: .center ,spacing:0){
                HStack{
                    Text(String.kidsText.kidsMyDiagnosticReport)
                        .modifier(BoldTextStyleKids(
                                    size: Font.sizeKids.light,
                                    color:  Color.app.brownDeep))
                        .padding(.all, DimenKids.margin.thin)
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
                if self.isEmpty {
                    Button(action: {
                        self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.registKid))
                        
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
                    
                }
                Spacer()
            }
        }
        .frame(
            width: SystemEnvironment.isTablet ? 344 : 179,
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
            : DiagnosticReportType.allCases.firstIndex(of: self.selectedType!)
        self.appSceneObserver.select =
            .select(
                (self.tag , DiagnosticReportType.allCases.map{$0.name} ), selectIdx ?? -1){ idx in
                withAnimation{
                    self.selectedType = DiagnosticReportType.allCases[idx]
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
