//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI


struct PageKidsEnglishLvTestSelect: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var dataProvider:DataProvider
    
    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @ObservedObject var pageDragingModel:PageDragingModel = PageDragingModel()
   
    @State var isPairing:Bool = false
    @State var text:String = ""
    var body: some View {
        GeometryReader { geometry in
            PageDragingBody(
                viewModel:self.pageDragingModel,
                axis:.horizontal
            ) {
                
                VStack (alignment: .center, spacing:0){
                    PageKidsTab(
                        title:String.kidsTitle.kidsEnglishLvTestSelect,
                        isBack: true,
                        style: .kids)
                    
                    if self.isPairing {
                        Text(self.text)
                            .modifier(BoldTextStyleKids(
                                        size: Font.sizeKids.light,
                                        color:  Color.app.brownDeep))
                            .multilineTextAlignment(.center)
                            
                        HStack(spacing:DimenKids.margin.regularExtra){
                            ForEach(self.datas) { data in
                                EnglishLvTestItem( data:data )
                                    .onTapGesture {
                                        self.movePage(data: data)
                                    }
                            }
                        }
                        .padding(.horizontal, DimenKids.margin.regular)
                        .modifier(MatchParent())
                        .modifier(ContentHorizontalEdgesKids())
                        
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
            .onReceive(self.pairing.$kid){ kid in
                self.kid = kid
                self.text = String.kidsText.kidsEnglishLvTestText.replace(kid?.nickName ?? "kid")
                if !self.isInitPage {return}
                self.initPage()
            }
            .onReceive(dataProvider.$result) { res in
                guard let res = res else { return }
                switch res.type {
                case .getEnglishReport :
                    guard let report  = res.data as? EnglishReport  else { return }
                    if let infos = report.contents?.infos {
                        withAnimation{
                            self.datas = infos.map{ EnglishLvTestData().setData($0)}
                        }
                    }
                default: break
                }
            }
            .onReceive(dataProvider.$error) { err in
                guard let err = err else { return }
                switch err.type {
                case .getEnglishReport :break
                default: break
                }
            }
            .onReceive(self.pageObservable.$isAnimationComplete){ ani in
                if ani {
                    self.isInitPage = true
                    self.initPage()
                }
            }
            .onAppear{
                
            }
        }//geo
    }//body
    @State var isInitPage:Bool = false
    @State var kid:Kid? = nil
    @State var datas:[EnglishLvTestData] = []
    private func initPage(){
        guard let kid = self.kid else { return }
        self.dataProvider.requestData(q: .init(type: .getEnglishReport(kid)))
    }
    
    private func movePage(data:EnglishLvTestData){
        self.pagePresenter.openPopup(
            PageKidsProvider.getPageObject(.kidsExam)
                .addParam(key: .type, value: DiagnosticReportType.english)
                .addParam(key: .id, value: data.type.code)
        )
    }
}

enum EnglishLvType{
    case level1_2, level3_4, level5_6, unowned(String?)
    
    static func setType(_ value:String?) ->EnglishLvType{
        switch value {
        case "1" : return .level1_2
        case "2": return .level3_4
        case "3": return .level5_6
        default : return .unowned(value)
        }
    }
    
    var code:String {
        get {
            switch self {
            case .level1_2 : return "1"
            case .level3_4: return "2"
            case .level5_6 : return "3"
            case .unowned(let cd) : return cd ?? ""
            }
        }
    }
    var recommend:String {
        get {
            switch self {
            case .level1_2 : return String.kidsText.kidsEnglishLvTestRecommend1
            case .level3_4: return String.kidsText.kidsEnglishLvTestRecommend2
            case .level5_6 : return String.kidsText.kidsEnglishLvTestRecommend3
            case .unowned : return ""
            }
        }
    }
    
    var image:String {
        get {
            switch self {
            case .level1_2 : return AssetKids.image.testEnglish1
            case .level3_4: return AssetKids.image.testEnglish2
            case .level5_6 : return AssetKids.image.testEnglish3
            case .unowned : return AssetKids.image.resultDiagnostic
            }
        }
    }
}


class EnglishLvTestData:InfinityData{
    private(set) var title:String = ""
   
    private(set) var type:EnglishLvType = .unowned(nil)
   
    func setData(_ data:EnglishReportItem) -> EnglishLvTestData {
        self.type = EnglishLvType.setType(data.tgt_cd)
        self.title = data.tgt_nm ?? ""
        return self
    }
}

extension EnglishLvTestItem {
    static let size:CGSize = SystemEnvironment.isTablet
        ? CGSize(width: 319, height: 342)
        :CGSize(width: 166, height: 178)
}
struct EnglishLvTestItem: PageComponent{
    var data:EnglishLvTestData

    var body: some View {
        ZStack{
            VStack( spacing:0){
                Image(data.type.image)
                    .renderingMode(.original).resizable()
                    .scaledToFit()
                    .frame(height: SystemEnvironment.isTablet ? 184 : 96)
                Text(data.type.recommend)
                    .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.regularExtra,
                                color:  Color.app.brownDeep))
                    .padding(.top, DimenKids.margin.light)
                Text( data.title )
                    .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.thin,
                                color:  Color.app.sepia))
                    .padding(.top, DimenKids.margin.tinyExtra)
            }
        }
        .modifier(MatchHorizontal(height: Self.size.height))
        .background(Color.app.white)
        .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.light))
    }
}


#if DEBUG
struct PageKidsEnglishLvTestSelect_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            PageKidsEnglishLvTestSelect().contentBody
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
