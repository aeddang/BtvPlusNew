//
//  TotalPoint.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/29.
//

import Foundation

struct TotalPointInfo : Decodable {
    private(set) var ui_name: String? = nil    // UI구분자
    private(set) var response_format: String? = nil   // 데이터 형식, "json"만 지원
    private(set) var svc_name: String? = nil   // 서비스 제공 어플리케이션 이름 "EPS"
    private(set) var coupon:CouponInfo? = nil    // "쿠폰 정보 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    private(set) var bcash:BCashInfo? = nil  // B캐쉬 정보 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답
    private(set) var newBpoint:BPointInfo? = nil    // 보유한 신규 B포인트정보 객체 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답
    private(set) var tmembership:TMembershipInfo? = nil    // T멤버십 정보 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답 등록된 T멤버십카드가 없을 경우 null 또는 빈값 응답
    private(set) var ocbMasterSequence:Int? = nil  // 대표 OK캐쉬백 카드 순번 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답
    private(set) var ocbList:OcbInfo? = nil// B포인트 정보 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답
    private(set) var tvpoint:TvPointInfo? = nil    // TV포인트 정보 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답
    private(set) var tvpay:TvPay? = nil    // TV페이 정보 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답
}


struct TotalPoint : Decodable {
    private(set) var ui_name: String? = nil    // UI구분자
    private(set) var response_format: String? = nil    // 데이터 형식, "json"만 지원
    private(set) var svc_name: String? = nil   // 서비스 제공 어플리케이션 이름 "EPS"
    private(set) var totalCount:Int? = nil // "보유 쿠폰 개수 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    private(set) var usableCount:Int? = nil    // "사용 가능한 쿠폰 개수 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    private(set) var expiredCount:Int? = nil  // "만료 예정인 쿠폰 개수 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    //private(set) var coupons:[BPointItem]?   // "쿠폰 정보 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    private(set) var useBpointRun:Bool? = nil   // "월정액 B포인트 자동 차감 여부 - true: 자동 차감 사용 - false: 자동 차감 미사용 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    private(set) var usableBpoints:Double? = nil  // "사용가능 B포인트 총액 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    private(set) var expireBpoints:Double? = nil  // "만료예정 B포인트 총액 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    //private(set) var bpoints:[BPointItem]?    // B포인트 정보 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답
    private(set) var tmembership:TMembershipInfo? = nil   // T멤버십 정보 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답 등록된 T멤버십카드가 없을 경우 null 또는 빈값 응답
    private(set) var ocbMasterSequence:Int? = nil  // 대표 OK캐쉬백 카드 순번 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답
    private(set) var ocbList:OcbList? = nil    // B포인트 정보 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답
    private(set) var tvpoint:TvPointInfo? = nil    // TV포인트 정보 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답
    private(set) var tvpay:TvPay? = nil    // TV페이 정보 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답
}

struct OcbList : Decodable {
    private(set) var ocb: [OcbItem]? = nil
}

struct CouponInfo : Decodable {
    private(set) var totalCount:Int? = nil   // 보유 쿠폰 개수
    private(set) var usableCount:Int? = nil     // 사용 가능한 쿠폰 개수
    private(set) var expiredCount:Int? = nil     // 만료 예정인 쿠폰 개수
}

struct BCashInfo : Decodable {
    private(set) var usableBcash:BalanceItem? = nil    // 보유한 B캐쉬 정보 객체
    private(set) var expireBcash:BalanceItem? = nil    // 만료 예정 B캐쉬 정보 객체
}

struct BPointInfo : Decodable {
    private(set) var usableNewBpoint:Double? = nil    // 보유한 신규B포인트 정보 객체
    private(set) var expireNewBpoint:Double? = nil    // 만료 예정 신규B포인트 정보 객체
}

struct TMembershipInfo : Decodable {
    private(set) var cardNo: String? = nil      // T멤버십 카드 번호 (앞 8자리만 응답)
}

struct TvPointInfo : Decodable {
    private(set) var useTvpoint:Bool? = nil   // TV 포인트 사용유무 - true: TV포인트 등록한 사용자 - false: TV포인트 미등록한 사용자
    private(set) var id: String? = nil   // TV포인트 ID
    private(set) var url: String? = nil    // TV포인트 연동 URL
}

struct TvPay : Decodable {
    private(set) var id: String? = nil    // TV페이 ID
    private(set) var url: String? = nil   // TV페이 연동 URL
}

struct OcbInfo : Decodable {
    private(set) var ocb:[OcbItem]? = nil
}
struct OcbItem : Decodable {
    private(set) var sequence: Int? = nil  // OK캐쉬백 카드 순번
    private(set) var cardNo: String? = nil   // OK캐쉬백 카드 번호 (앞 8자리만 응답)
    private(set) var balance: Double? = nil   // 잔액
}


struct BPointItem : Decodable {
    private(set) var bpointNo: String? = nil   // B포인트 번호
    private(set) var title: String? = nil  // B포인트 정책명
    private(set) var masterNo: String? = nil   // B포인트 정책번호
    private(set) var balance:Double? = nil     // B포인트 잔액
    private(set) var useRate:Double? = nil    // 사용율
    private(set) var expireMessage: String? = nil  // "유효기간 문구 - 기간만료 - 무제한 - ('YYYYMMDD')"
    private(set) var confirmDate: String? = nil    // "승인일시 - ('YYYYMMDD')"
    private(set) var saleAmountDouble:Double? = nil   // 구매금액
}


