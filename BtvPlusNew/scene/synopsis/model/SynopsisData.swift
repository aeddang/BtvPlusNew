//
//  SynopsisData.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/17.
//

import Foundation
enum SynopsisType {
    case package, title
    public init(value: String?) {
        switch value {
        case "03": self = .package
        case "41": self = .package
        default: self = .title
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
   
}

struct SynopsisPlayData{
    let eventTime:String = AppUtil.getTime(fromInt:AppUtil.networkTime())
    var start:String? = nil
    var end:String? = nil
    var position:String? = nil
    var rate:String? = nil
}
