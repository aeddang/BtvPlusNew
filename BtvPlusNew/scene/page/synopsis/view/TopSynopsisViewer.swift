//
//  PosterType01.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/18.
//

import Foundation
import SwiftUI


class TopSynopsisViewerData {
    private(set) var image: String = Asset.noImg16_9
    private(set) var title: String = ""
    private(set) var count: String? = nil
    private(set) var ratingPct: Double? = nil
    private(set) var ratingPoint: Double? = nil
    private(set) var ratingMax: Double? = nil
    private(set) var date: String? = nil
    private(set) var restrictAgeIcon: String? = nil
    private(set) var duration: String? = nil
    private(set) var provider: String? = nil
    private(set) var award: String? = nil
    private(set) var awardDetail: String? = nil
    private(set) var isHeart:Bool? = nil
    func setData(data:SynopsisContentsItem) -> TopSynopsisViewerData {
        self.title = data.title ?? ""
        self.count = data.brcast_tseq_nm
        self.date = data.brcast_exps_dy
        self.provider = data.brcast_chnl_nm
        if let age = data.wat_lvl_cd {
            switch age {
            case "7": self.restrictAgeIcon = Asset.icon.age7
            case "12": self.restrictAgeIcon = Asset.icon.age12
            case "15": self.restrictAgeIcon = Asset.icon.age15
            case "19": self.restrictAgeIcon = Asset.icon.age19
            default: self.restrictAgeIcon = Asset.icon.ageAll
            }
        }
        if let min = data.play_tms_val {
            self.duration = min + String.app.min
        }
        if let review = data.site_review {
            if let pnt = review.btv_pnt_info?.first {
                self.ratingPct = pnt.btv_like_rate ?? 0
            }
            if let site = review.sites?.first(where: {$0.site_cd == "20"}) {
                self.ratingPoint = site.avg_pnt ?? 0
                self.ratingMax = site.bas_pnt ?? 5
            }
            if let prizeHistory = review.prize_history {
                let count = prizeHistory.count
                if count > 0 {
                    let prize = prizeHistory.first
                    let leading = prize!.awrdc_nm ?? ""
                    if count == 1 {
                        self.award = leading + " " + String.app.award
                    } else {
                        self.award = leading + " " + String.app.another
                            + " " + (count-1).description + String.app.count +  String.app.award
                    }
                    let detail = prizeHistory.reduce("", {
                        $0 + ($1.awrdc_nm ?? "") + "\n" + ($1.prize_dts_cts ?? "")
                    })
                    self.awardDetail = detail
                }
                
            }
        
        }

        return self
    }
}


struct TopSynopsisViewer: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    var data:TopSynopsisViewerData
    var synopsisData:SynopsisData? = nil
   
    var body: some View {
        VStack(alignment:.leading , spacing:0) {
            Text(self.data.title)
                .modifier(BoldTextStyle( size: Font.size.boldExtra ))
                .lineLimit(2)
                .padding(.top, Dimen.margin.regularExtra)
            HStack(alignment: .center, spacing:Dimen.margin.tiny){
                if self.data.ratingPct != nil {
                    RatingInfo(
                        rating: self.data.ratingPct!
                    )
                    .fixedSize(horizontal: true, vertical: false)
                }
                if self.data.ratingPoint != nil {
                    RatingPoint(
                        rating: self.data.ratingPoint!, ratingMax: self.data.ratingMax!
                    )
                }
                
                if self.data.date != nil {
                    Text(self.data.date!)
                        .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                    }
                if self.data.restrictAgeIcon != nil {
                    Image( self.data.restrictAgeIcon! )
                        .renderingMode(.original).resizable()
                        .scaledToFit()
                        .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                    }
                if self.data.duration != nil {
                    Text(self.data.duration!)
                        .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                    }
                if self.data.provider != nil {
                    Text(self.data.provider!)
                        .modifier(BoldTextStyle(size: Font.size.thinExtra, color: Color.app.white))
                    }
            }
            .padding(.top, Dimen.margin.lightExtra)
            
            if self.data.award != nil {
                Button(action: {
                    self.pageSceneObserver.alert = .alert(nil, self.data.awardDetail)
                }) {
                    HStack(spacing:Dimen.margin.tinyExtra){
                        Image( Asset.icon.trophy )
                            .renderingMode(.original).resizable()
                            .scaledToFit()
                            .frame(width: Dimen.icon.thin, height: Dimen.icon.thin)
                        Text(self.data.award!)
                            .modifier(MediumTextStyle(size: Font.size.thinExtra, color: Color.app.greyDeep))
                        
                    }
                    .padding(.top, Dimen.margin.lightExtra)
                }
            }
            
            HStack(spacing:Dimen.margin.regular){
                if self.synopsisData != nil{
                    BookMarkButton(
                        data:self.synopsisData!
                    ){ ac in
                       
                    }
                }
                if self.synopsisData != nil{
                    LikeButton(
                        data:self.synopsisData!
                    ){ ac in
                       
                    }
                }
                BtvButton(
                    id:""
                )
                ShareButton(
                    id:""
                )
            }
            .padding(.vertical, Dimen.margin.regular)
            Spacer().modifier(LineHorizontal())
            
        }
        .modifier(ContentHorizontalEdges())
        .onAppear{
            
        }
    }//body
}



#if DEBUG
struct TopSynopsisViewer_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack{
            TopSynopsisViewer(
                data:TopSynopsisViewerData()
            )
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
           
        }.background(Color.blue)
    }
}
#endif

