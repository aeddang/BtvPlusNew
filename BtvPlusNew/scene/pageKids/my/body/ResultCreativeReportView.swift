//
//  MonthlyGraphBox.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/06.
//

import Foundation
import SwiftUI



class ResultCreativeReportViewData{
   
    private(set) var lvTitles:[String] = []
    private(set) var comment:String? = nil
    private(set) var comments:[CommentData] = []
    private(set) var questions:[QuestionData] = []
    private(set) var creativeGraphBoxData:CreativeGraphBoxData = CreativeGraphBoxData()
   
    
    private(set) var kid:Kid? = nil
    private(set) var profile:String = ""
    private(set) var date:String = ""
    private(set) var retryCount:Int = 0
    private(set) var retryCountStr:String = ""

    
    func setData(_ content:KidsReportContents, kid:Kid?) -> ResultCreativeReportViewData{
        self.kid = kid
        if let kid = kid {
            self.profile = AssetKids.characterList[ kid.characterIdx ]
        } else {
            self.profile = AssetKids.image.noProfile
        }
        
        self.lvTitles = [
            String.kidsText.kidsMyInfantDevelopmentLv1,
            String.kidsText.kidsMyInfantDevelopmentLv2,
            String.kidsText.kidsMyInfantDevelopmentLv3,
            String.kidsText.kidsMyInfantDevelopmentLv4,
            String.kidsText.kidsMyInfantDevelopmentLv5
        ]
        self.comment = content.total_cn
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
        self.creativeGraphBoxData.setData(content:content)
    
        self.date = content.subm_dtm?.replace("-", with: ".") ?? ""
        self.retryCount = content.retry_cnt ?? 0
        self.retryCountStr =  self.retryCount == 0
            ? String.app.empty
            : self.retryCount.description + String.app.broCount
        
        return self
    }
    
    
}

struct ResultCreativeReportView: PageComponent{
    @EnvironmentObject var sceneObserver:PageSceneObserver
    var data:ResultCreativeReportViewData
    
    
    var body: some View {
        VStack(spacing:DimenKids.margin.thin){
            HStack(spacing:0){
                VStack(spacing:DimenKids.margin.thin){
                    CreativeGraphBox(
                        data: self.data.creativeGraphBoxData,
                        sortSize: SystemEnvironment.isTablet ? CGSize(width: 28, height: 16) : CGSize(width: 17, height: 10),
                        colorKid: Color.app.yellow,
                        colorParent: Color.app.green
                    )
                    .padding(.horizontal, DimenKids.margin.regular)
                    .modifier(MatchParent())
                    Spacer().modifier(
                        LineHorizontal(height: DimenKids.line.light,
                                     color: Color.app.ivoryDeep,
                                     opacity: 0.5))
                    RectButtonKids(
                        text: String.kidsText.kidsMyResultRetryStart,
                        textModifier: BoldTextStyleKids(
                            size: Font.sizeKids.tiny,
                            color: Color.app.sepia).textModifier,
                        bgColor: Color.app.ivoryLight,
                        size: DimenKids.button.lightRectExtra,
                        cornerRadius:  DimenKids.radius.medium
                    ) { _ in
                        
                       
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
                    comment: self.data.comment,
                    comments: self.data.comments
                )
                .modifier(MatchVertical(width: SystemEnvironment.isTablet ? 289 : 178))
                .background(Color.app.whiteExtra)
                .modifier(MatchVertical(width: SystemEnvironment.isTablet ? 436 : 269))
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
