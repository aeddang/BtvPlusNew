//
//  GuestAgreementInfo.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/12.
//

import Foundation

import Foundation
struct GuestAgreementInfo  : Decodable {
    private(set) var header:NpsCommonHeader? = nil//공통 정보
    private(set) var body:GuestAgreementInfoBody? = nil //상세 정보
}

struct GuestAgreementInfoBody : Decodable {
    private(set) var update_date:String? = nil
    private(set) var agreement:GuestAgreement? = nil //티어 정보
    //private(set) var custom_param:[String:Any]? = nil //임의의 배열
}

struct GuestAgreement : Decodable {
    private(set) var market:String? = nil
    private(set) var personal:String? = nil
    private(set) var push:String? = nil
}


