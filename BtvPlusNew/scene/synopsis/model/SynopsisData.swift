//
//  SynopsisData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/17.
//

import Foundation
enum SynopsisType {
    case none, package, title, season
    public init(value: String?) {
        switch value {
        case "01", "10": self = .title
        case "02": self = .season
        case "03": self = .package
        case "41": self = .package
        default: self = .none
        }
    }
    
    var logCategory: String {
        switch self {
        case .title: return "ppv"
        case .season: return "pps"
        case .package: return "ppp"
        default : return "ppv"
        }
    }
    var logResult: String {
        switch self {
        case .title: return "단편"
        case .season: return "시즌"
        case .package: return "패키지"
        default : return "단편"
        }
    }

}

struct SynopsisData{
    var srisId:String? = nil
    var searchType:EuxpNetwork.SearchType = .prd
    var epsdId:String? = nil
    var epsdRsluId:String? = nil
    var prdPrcId:String? = nil
    var kidZone:String? = nil
    var isRecent:Bool? = nil
    var isPosson:Bool = false
    var anotherStbId:String? = nil
    var pId:String? = nil
    var cpId:String? = nil
    var contentId:String? = nil
    var ppmIds:String? = nil
    var metaTypCd:String? = nil
    var isLimitedWatch:Bool = false
    var progress:Float? = nil
    var progressTime:Double? = nil
    var isFullScreenProgressTime:Bool = true // progressTimed 있을때 true 이면 풀스크린s
    var synopType:SynopsisType
    var isPreview:Bool = false
    var isDemand:Bool = false
    /*
    SynopSvcTypCdNone = 0,
    SynopSvcTypCdVod = 30, //일반 VOD 시놉
    SynopSvcTypCdClip = 38, //클립 시놉
    SynopSvcTypCdVR360 = 31, //360VR
    SynopSvcTypCdFairyTale = 32, //동화
    SynopSvcTypCdUseGuide = 33,  //이용가이드
    SynopSvcTypCdDemand = 12, //디멘드
    SynopSvcTypCdMcn = 34, //MCN
    SynopSvcTypCdOriginal = 45,  //오리지날
    SynopSvcTypCdCharAI = 36, //캐릭터 AI
    SynopSvcTypCdKes = 37,  // KES
    //contents.kids_yn. 외부진입용 키즈존.
    SynopSvcTypCdKids = 9999
    */
    var isContinuous:Bool {
        if progress != nil {return true}
        if progressTime != nil {return true}
        return false
    }
    
}

struct SynopsisPlayData{
    let eventTime:String = AppUtil.getTime(fromInt:AppUtil.networkTime())
    var start:String? = nil
    var end:String? = nil
    var position:String? = nil
    var rate:String? = nil
}
