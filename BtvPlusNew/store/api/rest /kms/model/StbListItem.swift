//
//  StbInfo.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/15.
//

import Foundation

struct StbListItem : Decodable {
    private(set) var statusCode:String? = nil
    private(set) var statusMessage:String? = nil
    private(set) var data:StbListInfoData? = nil
}

struct StbListInfoData: Decodable {
    private(set) var ver:String? = nil
    private(set) var result:String? = nil
    private(set) var reason:String? = nil
    private(set) var IF:String? = nil
    private(set) var stb_infos:[StbListInfoDataItem]? = nil
}

struct StbListInfoDataItem: Decodable {
    private(set) var stb_id:String? = nil
    private(set) var mac_address:String? = nil
    private(set) var svc_num:String? = nil
    private(set) var status_code:Int? = nil // 상태값(2일 경우 해지)
    private(set) var model_name:String? = nil
    private(set) var svcTermDt:String? = nil // ESS에서 획득한 해지일
}

