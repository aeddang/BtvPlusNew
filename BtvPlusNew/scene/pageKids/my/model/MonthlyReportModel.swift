//
//  MonthlyReport.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/11.
//

import Foundation
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
    private(set) var type:KidsPlayType = .unknown("")
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
        self.type = KidsPlayType.getType(data.svc_prop_cd)
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
    
    func copy(data:MonthlyReportData) -> MonthlyReportData{
        self.type = data.type
        self.review = data.review
        self.svcPropCd = data.svcPropCd
        self.title = data.title
        self.learningTime = data.learningTime
        self.learningCount = data.learningCount
        self.averageTime = data.averageTime
        self.averageCount = data.averageCount
        self.recommendTime = data.recommendTime
        self.recommendCount = data.recommendCount
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
    func reset(){
        self.kid = nil
        self.datas = []
        self.isUpdated = true
    }
    func setData(_ data:MonthlyReport, kid:Kid? = nil , date:Date? = nil){
        self.kid = kid
        self.date = date ?? Date()
        if let infos = data.contents?.infos {
            
            if let age = kid?.ageMonth {
                if age <= KidsPlayType.limitedLv1 {
                    self.datas = infos.filter{KidsPlayType.getType($0.svc_prop_cd) != .subject}.map{ MonthlyReportData().setData($0)}
                } else if age <= KidsPlayType.limitedLv2 {
                    self.datas = infos.map{ MonthlyReportData().setData($0) }
                }  else {
                    self.datas = infos.filter{KidsPlayType.getType($0.svc_prop_cd) != .create}.map{ MonthlyReportData().setData($0)}
                }
                
            } else {
                self.datas = infos.map{ MonthlyReportData().setData($0) }
            }
        }
        self.datas.sort{$0.type.sortIdx < $1.type.sortIdx}
        self.isUpdated = true
    }
    func setData(colon:MonthlyReportModel){
        self.datas = colon.datas.map{MonthlyReportData().copy(data: $0)}
    }
    func updatedKid() {
        self.isUpdated = true
    }
    
    private(set) var logTabTitle:String? = nil
    func setupActionLog(tabTitle:String?) {
        self.logTabTitle = tabTitle
    }
}
