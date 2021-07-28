//
//  OKCash.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/13.
//

import Foundation
struct OkCashPoint : Decodable {
    private(set) var result: String? = nil    // 요청 결과.
    private(set) var reason: String? = nil
    private(set) var ui_name: String? = nil    // UI구분자
    private(set) var response_format: String? = nil    // 데이터 형식, "json"만 지원
    private(set) var svc_name: String? = nil  // 서비스 제공 어플리케이션 이름 "EPS"
    private(set) var ocb: OkCashPointItem? = nil  // OK캐쉬백 정보 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답
}

struct OkCashPointItem : Decodable {

    private(set) var sequence: Int? = nil   // OK캐쉬백 카드 순번
    private(set) var cardNo: String? = nil      // OK캐쉬백 카드 번호 (앞 8자리만 응답)
    private(set) var balance: Double? = nil     // 잔액
}
