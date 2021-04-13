//
//  TMembership.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/13.
//

import Foundation
struct TMembership : Decodable {
    private(set) var ui_name: String?    // UI구분자
    private(set) var response_format: String?    // 데이터 형식, "json"만 지원
    private(set) var svc_name: String?   // 서비스 제공 어플리케이션 이름 "EPS"
    private(set) var tmembership: TMembershipItem?    // T멤버십 정보 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답
    private(set) var discountRate: Double?   // 상품에 대한 할인율 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답 요청 시 productId가 포함하여 호출 하였을 경우에만 응답
}

struct TMembershipItem  : Decodable {
    private(set) var cardNo: String?   // T멤버십 카드 번호 (앞 8자리만 응답)
    private(set) var grade: String?      // T멤버십 등급- V: VIP- G: Gold- S: Silver- A: 일반
    private(set) var balance: Double?    // 잔여 T멤버십 포인트
}
