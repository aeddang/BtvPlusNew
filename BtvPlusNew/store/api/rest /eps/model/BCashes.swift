//
//  BCash.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/12.
//
import Foundation
struct BCashes : Decodable {
    private(set) var ui_name: String?    // UI구분자
    private(set) var response_format: String?    // 데이터 형식, "json"만 지원
    private(set) var svc_name: String?   // 서비스 제공 어플리케이션 이름 "EPS"
    private(set) var totalCount: Int? // "보유 쿠폰 개수 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    private(set) var page: Int? // 요청 페이지 번호 (요청 파라미터에 page와 count가 있는 경우 응답)
    private(set) var count: Int? // 응답 쿠폰 갯수 (요청 파라미터에 page와 count가 있는 경우 응답)
    private(set) var usableBcash: BalanceItem?    // "사용 가능한 쿠폰 개수 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    private(set) var expireBcash: BalanceItem?   // "만료 예정인 쿠폰 개수 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    private(set) var bcashList: BCashList?

}
struct BCashList : Decodable {
    private(set) var bcash: [BCash]?
}


struct BCash : Decodable {
    private(set) var bcashNo: String?    // B캐쉬 번호
    private(set) var title: String?  // B캐쉬 정책명
    private(set) var masterNo: String?   // B캐쉬 정책번호
    private(set) var supplyBalance: Double?  // B캐쉬 공급가
    private(set) var totalBalance: Double?   // B캐쉬 총액
    private(set) var useRate: Double?    // 사용율
    private(set) var expireMessage: String?  // "유효기간 문구 - 기간만료 - 무제한 - ('YYYYMMDD')"
    private(set) var confirmDate: String?    // "승인일시 - ('YYYYMMDD')"
    private(set) var supplyAmount: Double?   // 구매금액 공급가
    private(set) var totalAmount: Double?    // 구매금액 총액
}
