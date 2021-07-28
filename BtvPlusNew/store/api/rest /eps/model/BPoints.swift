//
//  BPoints.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/12.
//

import Foundation
struct BPoints : Decodable {
    private(set) var ui_name: String? = nil    // UI구분자
    private(set) var response_format: String? = nil    // 데이터 형식, "json"만 지원
    private(set) var svc_name: String? = nil   // 서비스 제공 어플리케이션 이름 "EPS"
    private(set) var totalCount: Int? = nil // "보유 쿠폰 개수 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    private(set) var page: Int? = nil // 요청 페이지 번호 (요청 파라미터에 page와 count가 있는 경우 응답)
    private(set) var count: Int? = nil // 응답 쿠폰 갯수 (요청 파라미터에 page와 count가 있는 경우 응답)
    private(set) var usableNewBpoint: Double? = nil    // "사용 가능한 쿠폰 개수 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    private(set) var expireNewBpoints: Double? = nil   // "만료 예정인 쿠폰 개수 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    private(set) var newBpoints: BPointList? = nil

}
struct BPointList : Decodable {
    private(set) var newBpoint: [BPoint]? = nil
}

struct BPoint : Decodable {
    private(set) var newBpointNo: String? = nil   // B포인트 번호
    private(set) var title: String? = nil  // B포인트 정책명
    private(set) var masterNo: String? = nil   // B포인트 정책번호
    private(set) var balance: Double? = nil  // B포인트 잔액
    private(set) var useRate: Double? = nil    // 사용율
    private(set) var expireMessage: String? = nil  // "유효기간 문구 - 기간만료 - 무제한 - ('YYYYMMDD')"
    private(set) var confirmDate: String? = nil    // "승인일시 - ('YYYYMMDD')"
    private(set) var saleAmount: Double? = nil // 구매금액
}
