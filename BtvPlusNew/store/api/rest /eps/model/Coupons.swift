//
//  Coupons.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/12.
//

import Foundation

struct Coupons : Decodable {
    private(set) var ui_name: String?    // UI구분자
    private(set) var response_format: String?    // 데이터 형식, "json"만 지원
    private(set) var svc_name: String?   // 서비스 제공 어플리케이션 이름 "EPS"
    private(set) var totalCount: Int? // "보유 쿠폰 개수 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    private(set) var page: Int? // 요청 페이지 번호 (요청 파라미터에 page와 count가 있는 경우 응답)
    private(set) var count: Int? // 응답 쿠폰 갯수 (요청 파라미터에 page와 count가 있는 경우 응답)
    private(set) var usableCount: Int?    // "사용 가능한 쿠폰 개수 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    private(set) var expiredCount: Int?   // "만료 예정인 쿠폰 개수 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답"
    private(set) var coupons: CouponsList?

}
struct CouponsList : Decodable {
    private(set) var coupon: [Coupon]?
}

struct Coupon : Decodable {
    private(set) var couponNo: String?   // 쿠폰번호
    private(set) var masterNo: String?   // 쿠폰정책번호
    private(set) var title: String?  // 쿠폰명
    private(set) var couponType: String? // "구분 - 구입 - 무료 - 보낸선물 - 받은선물 - 할인"
    private(set) var expireMessage: String?  // "유효기간 문구 - 기간만료 - 무제한 - ('YYYYMMDD')"
    private(set) var confirmDate: String?   // "승인일시 문구 - ('YYYYMMDD')"
    private(set) var discountType: String?   // "할인 타입- 10:정율할인- 20:정액할인"
    private(set) var discountValue: Double?  // "할인액 - 할인타입이 10('정율')인 경우 % - 할인타입이 20('정액')인 경우 금액"

}





