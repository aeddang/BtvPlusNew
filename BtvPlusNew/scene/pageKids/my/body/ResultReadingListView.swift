//
//  MonthlyGraphBox.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/06.
//

import Foundation
import SwiftUI

enum ReadingHclsAreaType{
    case athletic , language ,cognitive ,social, selfhelf, unowned(String?)
    
    static func setType(_ value:String?) -> ReadingHclsAreaType {
        switch value {
        case "21" : return .athletic
        case "22": return .language
        case "23": return .cognitive
        case "24" : return .social
        case "25" : return .selfhelf
        default : return .unowned(value)
        }
    }
    
    var code:String {
        get {
            switch self {
            case .athletic : return "21"
            case .language: return "22"
            case .cognitive : return "23"
            case .social : return "24"
            case .selfhelf : return "25"
            case .unowned(let cd): return cd ?? ""
            }
        }
    }
    
    var desc:String {
        get {
            switch self {
            case .athletic : return String.kidsText.kidsMyInfantDevelopmentDescription1
            case .language: return String.kidsText.kidsMyInfantDevelopmentDescription2
            case .cognitive : return String.kidsText.kidsMyInfantDevelopmentDescription3
            case .social : return String.kidsText.kidsMyInfantDevelopmentDescription4
            case .selfhelf : return String.kidsText.kidsMyInfantDevelopmentDescription5
            case .unowned : return ""
            }
        }
    }
    
    var image:String {
        get {
            switch self {
            case .athletic : return AssetKids.image.resultReading1
            case .language: return AssetKids.image.resultReading2
            case .cognitive : return AssetKids.image.resultReading3
            case .social : return AssetKids.image.resultReading4
            case .selfhelf : return AssetKids.image.resultReading5
            case .unowned : return AssetKids.image.resultDiagnostic
            }
        }
    }
    
    var logName:String {
        get {
            switch self {
            case .athletic : return "운동발달"
            case .language: return "언어발달"
            case .cognitive : return "인지발달"
            case .social : return "사회정서발달"
            case .selfhelf : return "자조행동발달"
            case .unowned(let cd): return cd ?? ""
            }
        }
    }
}

class ReadingListData:InfinityData{
    private(set) var title:String = ""
    private(set) var area:String = ""
    private(set) var result:String? = nil
    private(set) var date:String? = nil
    private(set) var type:ReadingHclsAreaType = .unowned(nil)
    private(set) var isComplete:Bool = false
    func setData(_ data:ReadingReportItem) -> ReadingListData {
        self.type = ReadingHclsAreaType.setType(data.hcls_area_cd)
        self.title = data.hcls_area_nm ?? ""
        self.area = data.hcls_area_cd ?? ""
        self.result = data.result_msg
        self.date = data.subm_dtm?.replace("-", with: ".") ?? nil
        self.isComplete = self.date?.isEmpty == false
        return self
    }
}

struct ResultReadingListView: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    var infinityScrollModel: InfinityScrollModel = InfinityScrollModel()
    var kid:Kid
    var action: ((ReadingListData) -> Void)? = nil
    @State var datas:[ReadingListData] = []
    
    var body: some View {
        VStack( spacing:DimenKids.margin.thin){
            InfinityScrollView(
                viewModel: self.infinityScrollModel,
                axes:.horizontal,
                marginHorizontal: DimenKids.margin.regular + self.sceneObserver.safeAreaEnd,
                isAlignCenter:true,
                spacing:DimenKids.margin.thin,
                isRecycle:false,
                useTracking: true
                ){
                
                ForEach(self.datas) { data in
                    ReadingListItem( data:data )
                        .onTapGesture {
                            self.naviLogManager.actionLog(
                                .clickOptionMenu,
                                actionBody: .init(
                                    menu_name:DiagnosticReportType.infantDevelopment.logName,
                                    config:data.type.logName))
                            self.action?(data)
                        }
                        .frame(
                            width: ReadingListItem.size.width,
                            height: ReadingListItem.size.height
                        )
                }
               
            }
            .modifier(MatchParent())
            HStack{
                Spacer()
                RectButtonKids(
                    text: String.kidsText.kidsMyInfantDevelopmentDescription,
                    isSelected: false,
                    size: CGSize(width: 0, height: DimenKids.button.regular),
                    isFixSize: false){_ in
                    
                    let descs:[TabInfoData] = self.datas.map{
                        TabInfoData(title: $0.title, text: $0.type.desc)
                    }
                    self.pagePresenter.openPopup(
                        PageKidsProvider
                            .getPageObject(.tabInfo)
                            .addParam(key: .datas, value: descs)
                            .addParam(key: .selected, value: 1)
                    )
                    
                }
            }
            .modifier(ContentHorizontalEdgesKids())
        }
        .padding(.top, DimenKids.margin.thin)
        .padding(.bottom, DimenKids.margin.thin + self.sceneObserver.safeAreaIgnoreKeyboardBottom)
        .modifier(MatchParent())
        .onReceive(dataProvider.$result) { res in
            guard let res = res else { return }
            switch res.type {
            
            case .getReadingReport:
                guard let report  = res.data as? ReadingReport  else { return  }
                guard let areas = report.contents?.areas else { return  }
                withAnimation{
                    self.datas = areas.map{ReadingListData().setData($0)}
                }
            default: break
            }
        }
        .onReceive(dataProvider.$error) { err in
            guard let err = err else { return }
            switch err.type {
            case .getEnglishLvReportResult :
                break
            default: break
            }
        }
        
        .onAppear(){
            self.dataProvider.requestData(q: .init(type: .getReadingReport(kid)))
        }
    }
}

extension ReadingListItem {
    static let size:CGSize = SystemEnvironment.isTablet
        ? CGSize(width: 269, height: 295)
        :CGSize(width: 140, height: 154)
}
struct ReadingListItem: PageComponent{
    var data:ReadingListData

    var body: some View {
        ZStack{
            VStack( spacing:DimenKids.margin.light){
                Text(data.title)
                    .modifier(BoldTextStyleKids(
                                size: Font.sizeKids.lightExtra,
                                color:  Color.app.brownDeep))
                ZStack(alignment: .bottom){
                    Image(data.type.image)
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: SystemEnvironment.isTablet ? 230 : 120)
                    if self.data.isComplete {
                        Text(String.kidsText.kidsMyReportCompleted + " " + (self.data.date ?? ""))
                            .modifier(BoldTextStyleKids(
                                        size: Font.sizeKids.tinyExtra,
                                        color:  Color.app.white))
                            .padding(.vertical, DimenKids.margin.tinyExtra)
                            .padding(.horizontal, DimenKids.margin.thin)
                            .background(Color.app.red)
                            .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.regular))
                    }
                }
            }
        }
        .frame(
            width: Self.size.width,
            height: Self.size.height)
        .background(Color.app.white)
        .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.light))
    }
}
