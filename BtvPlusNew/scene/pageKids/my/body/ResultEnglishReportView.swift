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
    private(set) var lvGraphs:[LvGraphData] = []
    private(set) var avgLv:Int = 0
    private(set) var meLv:Int = 0
    private(set) var avgPct:Float = 0
    private(set) var mePct:Float = 0
    
    private(set) var kid:Kid? = nil
    private(set) var profile:String = ""
    private(set) var lvDescription:String? = nil
    private(set) var lvCode:String? = nil
    private(set) var date:String = ""
    private(set) var retryCount:Int = 0
    private(set) var retryCountStr:String = ""
    private(set) var title:String? = nil
    
    func setData(_ content:KidsReportContents, kid:Kid?) -> ResultEnglishReportViewData{
        self.kid = kid
        if let kid = kid {
            self.profile = AssetKids.characterList[ kid.characterIdx ]
        } else {
            self.profile = AssetKids.image.noProfile
        }
        
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
        self.title = content.ep_tit_nm
        self.avgLv = content.peer_avgs?.firstIndex(of: 1) ?? 0
        self.meLv = content.my_levels?.firstIndex(of: 1) ?? 0
        self.lvDescription = content.level_cd
        self.lvCode = self.lvs[self.meLv]
        self.date = content.subm_dtm?.replace("-", with: ".") ?? ""
        self.retryCount = content.retry_cnt ?? 0
        self.retryCountStr =  self.retryCount == 0
            ? String.app.empty
            : self.retryCount.description + String.app.broCount
        
        var idx:Int = 0
        self.lvGraphs = zip(self.lvTitles,zip(self.lvAvgs, self.lvAvgTitles)).map{ lb, data in
            let me = idx == self.meLv
            let avg = idx == self.avgLv
            
            var thumb:String? = nil
            if me , let kid = kid {
                thumb = AssetKids.characterList[kid.characterIdx]
            }
            idx = idx + 1
            return LvGraphData(
                thumb: thumb,
                thumbText: avg ? String.app.peerAverage : nil,
                valueText: data.1,
                value: data.0,
                color:
                    me
                    ? Color.app.yellow
                    : avg
                        ? Color.app.green : Color.app.grey,
                title: lb,
                titleColor: me ? Color.app.brownDeep :  Color.app.sepiaLight,
                delay: Double(idx) * 0.2)
        }
        
        return self
    }
    
    
}

struct ResultEnglishReportView: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var data:ResultEnglishReportViewData
    var action: (() -> Void)? = nil
   
    var body: some View {
        VStack(spacing:DimenKids.margin.thin){
            HStack(spacing:0){
                VStack(spacing:DimenKids.margin.thin){
                    HStack(spacing:0){
                        TrophyBox(
                            trophyText: self.data.lvCode,
                            title: String.kidsText.kidsMyEnglishResultLv,
                            subTitle: self.data.lvDescription)
                        Spacer()
                        LvGraphList(datas: self.data.lvGraphs)
                        
                    }
                    Spacer().modifier(
                        LineHorizontal(height: DimenKids.line.light,
                                     color: Color.app.ivoryDeep,
                                     opacity: 0.5))
                    HStack(spacing:DimenKids.margin.thin){
                        RectButtonKids(
                            text: String.kidsText.kidsMyEnglishResultRetry,
                            textModifier: BoldTextStyleKids(
                                size: Font.sizeKids.tiny,
                                color: Color.app.sepia).textModifier,
                            bgColor: Color.app.ivoryLight,
                            size: DimenKids.button.lightRectExtra,
                            cornerRadius:  DimenKids.radius.medium
                        ) { _ in
                            self.action?()
                           
                        }
                        RectButtonKids(
                            text: String.kidsText.kidsMyEnglishResultAnswerView,
                            textModifier: BoldTextStyleKids(
                                size: Font.sizeKids.tiny,
                                color: Color.app.sepia).textModifier,
                            bgColor: Color.app.ivoryLight,
                            size: DimenKids.button.lightRectExtra,
                            cornerRadius:  DimenKids.radius.medium
                        ) { _ in
                            var move = PageKidsProvider.getPageObject(.kidsExamViewer)
                                .addParam(key: .type, value: DiagnosticReportType.english)
                                .addParam(key: .datas, value: self.data.questions)
                            if let title = self.data.title {
                                move = move.addParam(key: .title, value: title )
                            }
                            
                            self.pagePresenter.openPopup(
                                move
                            )
                        }
                    }
                }
                .padding(.horizontal, DimenKids.margin.regular)
                .padding(.vertical, DimenKids.margin.thin)
                .modifier(MatchParent())
                Spacer().modifier(
                    LineVertical(width: DimenKids.line.light,
                                 color: Color.app.ivoryDeep,
                                 opacity: 0.5))
                    .padding(.vertical, DimenKids.margin.regular)
                CommentBox(
                    icon: AssetKids.image.resultEnglish,
                    text: String.kidsText.kidsMyEnglishResultCommentText,
                    comments: self.data.comments)
                    .modifier(MatchVertical(width: SystemEnvironment.isTablet ? 320 : 178))
                    .background(Color.app.whiteExtra)
            }
            .modifier(MatchParent())
            .background(Color.app.white)
            .clipShape(RoundedRectangle(cornerRadius: DimenKids.radius.light))
            
            ResultReportBottom(
                date:self.data.date,
                retryCount:self.data.retryCountStr
            )
            .modifier(MatchHorizontal(height: DimenKids.button.regular))
        }
        .padding(.top, DimenKids.margin.thin)
        .padding(.bottom, DimenKids.margin.thin + self.sceneObserver.safeAreaBottom)
        .modifier(ContentHorizontalEdgesKids())
        .onAppear(){
          
        }
    }
}
