//
//  RecommandBenefit.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/28.
//

import Foundation

struct RecommandBenefit: Decodable {
    private(set) var bpoint: String? = nil    // 리워드 Bpoint 금액
    private(set) var coupon_cd: String? = nil   // 사용하는 쿠폰 정책 구분코드(정율/정액) - 01: 정율 쿠폰 - 02: 정액 쿠폰
    private(set) var coupon_val: String? = nil  // 할인쿠폰 값; 쿠폰 정책에 따라 의미가 달라짐 - 구분코드 01: 15% (할인율) - 구분코드 02: 15000 (정액 금액)
}


struct RecommandId: Decodable {

    private(set) var mgm_id:String? = nil // 추천 고유ID(AES암호화)
}

