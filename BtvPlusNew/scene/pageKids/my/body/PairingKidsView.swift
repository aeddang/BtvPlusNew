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
    
    var pageObservable:PageObservable = PageObservable()
    var pageDragingModel:PageDragingModel = PageDragingModel()
    var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var diagnosticReportModel:DiagnosticReportModel = DiagnosticReportModel()
    var monthlyReportModel:MonthlyReportModel = MonthlyReportModel()
    
    @ObservedObject var tabNavigationModel:NavigationModel = NavigationModel()
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
                        textModifier: BoldTextStyleKids(
                            size: Font.sizeKids.tiny,
                            color: Color.app.sepia).textModifier,
                        bgColor: Color.app.ivoryLight,
                        size: CGSize(
                            width:DimenKids.item.profileBox.width ,
                            height: DimenKids.button.lightUltra),
                        cornerRadius:  DimenKids.radius.medium,
                        isMore: true
                    ) { _ in
                        
                        self.pagePresenter.openPopup(PageKidsProvider.getPageObject(.kidsProfileManagement))
                    }
                }
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
                    MenuNavi(viewModel: self.tabNavigationModel, buttons: self.tabs, selectedIdx: self.tabIdx, isDivision: false)
                        .padding(.leading, DimenKids.margin.thin)
                }
                InfinityScrollView(
                    viewModel: self.infinityScrollModel,
                    axes:.horizontal,
                    isAlignCenter:true,
                    isRecycle:false,
                    useTracking: true
                    ){
                    HStack(spacing:DimenKids.margin.thin){
                        DiagnosticReportCard(viewModel:self.diagnosticReportModel)
                        MonthlyReportCard(viewModel:self.monthlyReportModel)
                    }
                    .padding(.leading, DimenKids.margin.thin)
                    .padding(.trailing, DimenKids.margin.thin + self.sceneObserver.safeAreaEnd)
                    
                }
                .modifier(MatchParent())

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
                self.monthlyReportModel.setData(monthlyReport, kid: self.kid, date: self.currentDate)
                
            case .getKidStudy :
                guard let study  = res.data as? KidStudy  else { return }
                self.diagnosticReportModel.setData(study, kid: self.kid) 
            
            default: break
            }
        }
        .onReceive(dataProvider.$error) { err in
            guard let err = err else { return }
            
            switch err.type {
            default: break
            }
        }
        .onReceive(self.pairing.$kid){ kid in
            self.kid = kid
            self.setupInitData()
        }
        .onReceive(self.pairing.$event){ evt in
            guard let evt = evt else { return }
            
            switch evt {
            case .editedKids :
                self.monthlyReportModel.updatedKid()
                self.diagnosticReportModel.updatedKid()
            default: break
            }
        }
        .onReceive(self.tabNavigationModel.$index){ idx in
            if self.tabs.isEmpty {return}
            
            if idx >= self.tabs.count {return}
            withAnimation{
                self.tabIdx = idx
            }
        }
        .onAppear{
            self.tabDatas = self.dataProvider.bands.kidsGnbModel
                .getMyDatas()?
                .filter{$0.menu_nm != nil} ?? []
            
            self.tabs = self.tabDatas.map{$0.menu_nm ?? ""}
        }
    }//body
    @State var tabIdx:Int = 0
    @State var tabDatas:[BlockItem] = []
    @State var tabs:[String] = []
    @State var currentDate:Date = Date()
    
    private func setupInitData (){
        guard let kid = self.kid else {
            self.monthlyReportModel.reset()
            self.diagnosticReportModel.reset()
            return
        }
        self.dataProvider.requestData(q: .init(type: .getKidStudy(kid), isOptional: false))
        self.dataProvider.requestData(q: .init(type: .getMonthlyReport(kid, self.currentDate), isOptional: false))
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
