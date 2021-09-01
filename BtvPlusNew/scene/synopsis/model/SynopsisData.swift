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
        default : return ""
        }
    }
    var logResult: String {
        switch self {
        case .title: return "단편"
        case .season: return "시즌"
        case .package: return "패키지"
        default : return ""
        }
    }

}

struct SynopsisData{
    var srisId:String? = nil
    var searchType:String? = nil
    var epsdId:String? = nil
    var epsdRsluId:String? = nil
    var prdPrcId:String? = nil
    var kidZone:String? = nil
    //watchLog
    var pId:String? = nil
    var cpId:String? = nil
    var contentId:String? = nil
    var ppmIds:String? = nil
    var isLimitedWatch:Bool = false
    var progress:Float? = nil
    var progressTime:Double? = nil
    //naviLog
    var synopType:SynopsisType = SynopsisType.none
   
}

struct SynopsisPlayData{
    let eventTime:String = AppUtil.getTime(fromInt:AppUtil.networkTime())
    var start:String? = nil
    var end:String? = nil
    var position:String? = nil
    var rate:String? = nil
}
