//
//  CertificationCoupon.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/29.
//

import Foundation
struct CertificationCoupon : Decodable {
    private(set) var result:String? = nil // 성공인 경우 "000", 그외 에러 코드
    private(set) var reason:String? = nil // 성공인 경우 OK, 그외 에러 사유
    private(set) var name: String? = nil    // 발급된 쿠폰명
    private(set) var cpnBpnNo: String? = nil    // 발급된 쿠폰번호
    private(set) var fgCd: String? = nil    // 인증대상코드 - 요청한 인증대상코드와 동일
}


