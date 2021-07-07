//
//  MonthlyGraphBox.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/06.
//

import Foundation
import SwiftUI



class ResultEnglishReportViewData{
    private(set) var lvs:[String] = []
    private(set) var lvTitles:[String] = []
    private(set) var lvAvgs:[Float] = []
    private(set) var lvAvgTitles:[String] = []
    private(set) var comments:[CommentData] = []
    private(set) var questions:[QuestionData] = []
    private(set) var avgLv:Int = 0
    private(set) var meLv:Int = 0
    private(set) var avgPct:Float = 0
    private(set) var mePct:Float = 0
    
    private(set) var lvDescription:String? = nil
    private(set) var lvCode:String? = nil
    private(set) var date:String = ""
    private(set) var retryCount:Int = 0
    
    func setData(_ content:KidsReportContents) -> ResultEnglishReportViewData{
        if let labels = content.level_labels {
            self.lvs = labels.map{$0}
            self.lvTitles = labels.map{ lb in
                var ldStr = lb.description
                ldStr = ldStr.isNumric() ? "Lv." + ldStr : ldStr
                return ldStr
            }
        }
        
        
        let max = Float(content.max_val ?? 100)
        if let avgs = content.level_avgs {
            self.lvAvgs = avgs.map{ avg in
                Float(avg) / max
            }
            self.lvAvgTitles = avgs.map{ avg in
                avg.description + "%"
            }
        }
        
        if let cns = content.cn_items {
            self.comments = cns.map{ cn in
                CommentData(title: cn.title ?? "", text: cn.cn ?? "")
            }
        }
        if let qs = content.q_items {
            self.questions = qs.map{ q in
                QuestionData().setData(q)
            }
        }
        
        self.avgLv = content.peer_avgs?.firstIndex(of: 1) ?? 0
        self.meLv = content.my_levels?.firstIndex(of: 1) ?? 0
        self.lvDescription = content.level_cd
        self.lvCode = self.lvs[self.meLv]
        self.date = content.subm_dtm?.replace("-", with: ".") ?? ""
        self.retryCount = content.retry_cnt ?? 0
        
        return self
    }
    
    
}



struct ResultEnglishReportView: PageComponent{
    var thumb:String
    var data:KidsReportContents
    
    @State var mePct:Float = 0
    @State var avgPct:Float = 0
    @State var meTitle:String = ""
    @State var avgTitle:String = ""
    var body: some View {
        VStack(spacing:0){
            
        }
        .onAppear(){
          
        }
    }
}
