//
//  EpisodeViewerData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/11.
//

import Foundation
import SwiftUI
class EpisodeViewerData {
    private(set) var image: String = Asset.noImg16_9
    private(set) var seasonTitle: String? = nil
    private(set) var title: String = ""
    private(set) var subTitle: String = ""
    private(set) var info: String = ""
    private(set) var count: String? = nil
    private(set) var ratingPct: Double? = nil
    private(set) var ratingPoint: Double? = nil
    private(set) var ratingMax: Double? = nil
    private(set) var date: String? = nil
    private(set) var serviceYear: String? = nil
    private(set) var restrictAgeIcon: String? = nil
    private(set) var restrictAgeIconKids: String? = nil
    private(set) var isAdult: Bool = false
    private(set) var duration: String? = nil
    private(set) var provider: String? = nil
    private(set) var award: String? = nil
    private(set) var awardDetail: String? = nil
    private(set) var onAir: String? = nil
    var episodeTitle:String {
        guard let count = self.count else { return self.title }
        if count.isEmpty { return self.title }
        return self.title + " " + count + String.app.broCount 
    }
    
    var episodeSubTitle:String {
        guard let count = self.count else { return self.subTitle }
        if count.isEmpty { return self.subTitle }
        return self.subTitle + " " + count + String.app.broCount
    }
    
    var episodeTitleKids:String {
        guard let count = self.count else { return self.title }
        if count.isEmpty { return self.title }
        return count + String.app.broCount + " " + self.title
    }
    
    func setData(data:SynopsisContentsItem) -> EpisodeViewerData {
        self.title = data.title ?? ""
        self.subTitle = data.epsd_snss_cts ?? data.title ?? ""
        self.seasonTitle = data.sson_choic_nm
        self.date = data.brcast_exps_dy?.isEmpty == false ? data.brcast_exps_dy : nil
        self.serviceYear = data.svc_fr_dt?.isEmpty == false ? data.svc_fr_dt?.subString(start: 0, len: 4) : nil
        self.provider = data.brcast_chnl_nm?.isEmpty == false ? data.brcast_chnl_nm : nil
        if data.sris_typ_cd == SrisTypCd.season.rawValue {
            self.count = data.brcast_tseq_nm
            self.onAir = (data.sris_cmpt_yn?.toBool() ?? false) ? Asset.icon.onAirOff : Asset.icon.onAir
        }
        if let age = data.wat_lvl_cd {
            self.isAdult = age.toInt() >= 19
            self.restrictAgeIcon = Asset.age.getIcon(age: age)
            self.restrictAgeIconKids = AssetKids.age.getIcon(age: age)
            self.info = age.description + String.app.ageCount
        }
        if let min = data.play_tms_val {
            let d =  min + String.app.min
            self.duration = d
            self.info = self.info.isEmpty ? d : self.info + " | " + d
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
                    let detail:String = prizeHistory.reduce("", {
                        let leading = $1.awrdc_nm ?? ""
                        let trailing = $1.prize_dts_cts ?? ""
                        return $0 + leading + "\n" + trailing
                    })
                    self.awardDetail = detail
                }
            }
        }
        return self
    }
}
