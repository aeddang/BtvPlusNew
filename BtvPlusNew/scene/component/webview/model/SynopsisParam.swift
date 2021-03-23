//
//  SynopsisJson.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/16.
//

import Foundation
struct SynopsisJson :Codable{
    var synopType:String? = nil
    var srisId:String? = nil
    var epsdId:String? = nil
    var episodeResolutionId:String? = nil
    var entryMenu:String? = nil
    var pid:String? = nil
    var cwCallIdVal:String? = nil
    var gGubun:DynamicValue? = nil
    var sessionId:String? = nil
    init(json: [String:Any]) throws {}
}

struct SynopsisQurry :Codable{
    var srisId:String? = nil
    var epsdId:String? = nil
}
