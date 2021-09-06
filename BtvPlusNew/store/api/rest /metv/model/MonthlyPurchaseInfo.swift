//
//  MonthlyPurchaseInfo.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/29.
//

import Foundation


struct MonthlyPurchaseInfo : Decodable {
    private(set) var ver: String? = nil     // 인터페이스 버전
    private(set) var svc_name: String? = nil    // 서비스이름
    private(set) var stb_id: String? = nil  // STB ID
    private(set) var page_tot: String? = nil   // 전체 페이지 개수
    private(set) var page_no: String? = nil    // 현재 페이지 번호
    private(set) var purchase_tot: String? = nil   // 즐겨찾기의 전체 개수
    private(set) var purchase_no: String? = nil    // 현재 페이지의 즐겨찾기 개수
    private(set) var purchase_cancel_svc: String? = nil     // 월정액 해지 서비스를 사용할 것인지 판단 여부 - Y: 해지 서비스 이용, N: 해지 서비스 이용 안함
    private(set) var yn_perd: String? = nil    // N : 기존 월정액 구매내역 정보 제공(약정정보 및 커머스 구매내역 포함) Y : 기간권 구매내역 정보 제공
    private(set) var purchaseList: [PurchaseFixedChargeItem]? = nil   // 즐겨찾기 집합의 이름
}

struct PeriodMonthlyPurchaseInfo : Decodable {
    private(set) var ver: String? = nil     // 인터페이스 버전
    private(set) var svc_name: String? = nil    // 서비스이름
    private(set) var stb_id: String? = nil  // STB ID
    private(set) var page_tot: String? = nil    // 전체 페이지 개수
    private(set) var page_no: String? = nil     // 현재 페이지 번호
    private(set) var purchase_tot: String? = nil    // 즐겨찾기의 전체 개수
    private(set) var purchase_no: String? = nil     // 현재 페이지의 즐겨찾기 개수
    private(set) var purchase_cancel_svc: String? = nil     // 월정액 해지 서비스를 사용할 것인지 판단 여부 - Y: 해지 서비스 이용, N: 해지 서비스 이용 안함
    private(set) var yn_perd: String? = nil     // N : 기존 월정액 구매내역 정보 제공(약정정보 및 커머스 구매내역 포함) Y : 기간권 구매내역 정보 제공
    private(set) var purchaseList: [PurchaseFixedChargePeriodItem]? = nil  // 즐겨찾기 집합의 이름
}



struct PurchaseFixedChargeItem : Decodable {
    private(set) var prod_type: String? // "상품의 구성 종류 - 일반 및 결합 상품 : 일반 월정액 상품 - 월정액 결합 상품 : 월정액+커머스 상품 - 부가서비스 상품 : VAS 월정액 상품 - 채널패키지 상품 : IPTV 월정액 상품"
    private(set) var prod_code: String? // "상품의 구분 코드 - 30 : 일반 및 결합 상품(일반 월정액) - 36 : 월정액+커머스 상품 - 60 : 부가서비스 상품(VAS 월정액) - 80 : 채널패키지 상품(IPTV 월정액)"
    private(set) var prod_id: String? // 상품 식별자
    private(set) var subs_id: String? // "계약 식별자.월정액 해지 시 사용"
    private(set) var calculation: String? // "월정액 정산(현재 매월 1일~7일)이 완료되었는지 여부.T멤버쉽과 B포인트 등의 사용을 판단하여 계산하므로 정산 이전의 계산 내용을 보여줄 수 없다. - Y: 정산 완료, N: 정산 중"
    private(set) var title: String? // 월정액 상품의 이름
    private(set) var adult: String? // "성인물 여부 - Y: 성인물, N: 성인물 아님"
    private(set) var amt_price: String? // "상품 정가.월정액 해지하면 "해지"로 전달 됨"
    private(set) var price: String? // 저장소에 저장된 상품의 판매 가격
    private(set) var selling_price: String? // "사용자가 구매한 월정액 상품의 실질적인 가격(부가세포함)- 약정 미체결 또는 무약정인 경우의 계산식 : price * 1.1(부가세)- 약정 체결인 경우의 계산식(agmt_yn = Y) : agmt_amt_sale *1.1(부가세)- dc_coupon, cd_point, dc_membership, dc_membership_vat 정보는 계산하지 않음.   * dc_coupon, cd_point, dc_membership, dc_membership_vat는 0으로 제공(월정액 중기기반안 적용)"
    private(set) var dc_coupon: String? // 상품 구매 시 쿠폰 이용 가격
    private(set) var cd_coupon_nm: String? // 쿠폰명(쿠폰이용했으나, 쿠폰명 미존재시 "가입 후 지정 개월 할인 적용" 문구 제공, 월정액 중기방안적용)
    private(set) var dc_membership: String? // 상품 구매 시 멤버쉽 포인트 이용 가격
    private(set) var dc_membership_vat: String? // 멤버쉽 포인트 이용 가격의 부가세
    private(set) var dc_membership_text: String? // 맴버쉽 포인트 할인 적용내용 문구, 월정액 중기방안적용
    private(set) var dc_point: String? // 상품 구매 시 B포인트 이용 가격
    private(set) var expired: String? // "서비스 이용 가능 여부 - Y: 만료됨, N: 이용 가능"
    private(set) var reg_date: String? // 상품 구매일 (yyyy.MM.dd)
    private(set) var end_date: String? // 상품 구매 만료일 (yyyy.MM.dd)
    private(set) var cancel_date: String? // 상품 해지일 (yyyy.MM.dd)
    private(set) var period: String? // "상품 이용 기간 [기존 월정액]- 이용중 : 해지 전까지(yyyy.MM.dd ~ 이용중)- 해지시 : 해지완료(yyyy.MM.dd ~ yyyy.MM.dd)[월정액+커머스]- 이용중 : 해지 전까지 매월 자동결제 및 정기배송(yyyy.MM.dd ~ 이용중)- 해지시 : 해지완료(yyyy.MM.dd ~ yyyy.MM.dd)"
    private(set) var period_detail: String? // 상품 이용 기간 상세. (period와 동일)
    private(set) var method_pay_cd: String? // 결재방식 코드값 (null 또는 빈값: 청구서, 10: 핸드폰, 85: 신용카드, , 80: TV 포인트
    private(set) var method_pay_nm: String? // 결재방식 코드명 (null 또는 빈값: 청구서, 10: 핸드폰, 85: 신용카드, , 80: TV 포인트
    private(set) var ppm_poster: String? // 월정액 가입후 포스터
    private(set) var yn_kzone: String? // 키즈 상품구분 (Y : 키즈상품, N:키즈상품 아님)
    private(set) var agmt_yn: String? // "월정액 약정여부 Y/N - 약정 체결된 월정액인 경우 :  Y - 약정 미체결 또는 무약정인 경우 : N - 기본값 : N"
    private(set) var agmt_term: String? // "약정기간 정보(약정 개월/년 정보) - agmt_yn = Y 인 경우 제공"
    private(set) var prd_agmt_id: String? // "상품약정ID - NCMS에서 생성한 상품의 약정ID - agmt_yn = Y 인 경우 제공"
    private(set) var agmt_subs_id: String? // "체결한 약정 정보 확인 식별자 - 약정 해지 및 변경시 활용 - agmt_yn = Y 인 경우 제공"
    private(set) var agmt_amt_sale: String? // "약정 체결된 구매금액(부가세별도) - 판매금액 - 약정할인 받는 금액 - 약정 체결로 할인 받는 금액 아님 - agmt_yn = Y 인 경우 제공"
    private(set) var agmt_rt_dsc: String? // "약정 할인율(%) - 약정체결로 할인받은 할인비율(%) - agmt_yn = Y 인 경우 제공"
    private(set) var agmt_dd_start: String? // "약정시작일 - agmt_yn = Y 인 경우 제공"
    private(set) var agmt_dd_end: String? // "약정종료일 - 약정종료 알림시 활용 - agmt_yn = Y 인 경우 제공"
    private(set) var ppm_rltn_prd_id: String? // "월정액 관련상품(커머스) ID - 관련상품인 경우, 값이 존재 - 기존 상품인 경우, null 또는 빈값으로 제공"
    private(set) var ppm_rltn_prd_poster: String? // "월정액 관련상품(커머스) 포스터 - 관련상품인 경우,  관련상품 포스터 정보 제공- 기존 상품인 경우 null 또는 빈값으로 제공"
}


struct PurchaseFixedChargePeriodItem : Decodable {
    private(set) var prod_type: String?  // "상품의 구성 종류 - 기간 제한 상품 : 월정액기간권 상품"
    private(set) var prod_code: String?  // "상품의 구분 코드 - 32 : 기간 제한 상품(VOD PPM 기간권)"
    private(set) var prod_id: String?    // 상품 식별자
    private(set) var subs_id: String?    // "계약 식별자. - 기간권 해지 시 사용"
    private(set) var title: String?  // 기간권의 이름
    private(set) var title_perd: String? // 기간권 이용기간명(title 추가 표시용)
    private(set) var adult: String?  // "성인물 여부 - Y: 성인물, N: 성인물 아님"
    private(set) var amt_price: String?  // "상품 정가.해지 시, "해지"로 전달 됨"
    private(set) var price: String?  // 저장소에 저장된 기간권의 판매 가격
    private(set) var selling_price: String?  // "사용자가 구매한 기간권의 실질적인 가격(부가세포함)- price * 1.1(부가세)- dc_coupon, cd_point, dc_membership, dc_membership_vat 정보는 계산하지 않음.   * dc_coupon, cd_point, dc_membership, dc_membership_vat는 0으로 제공(월정액 중기기반안 적용)"
    private(set) var dc_coupon: String?  // 기간권 구매 시 쿠폰 이용 가격
    private(set) var cd_coupon_nm: String?   // 쿠폰명(쿠폰이용했으나, 쿠폰명 미존재시 "가입 후 지정 개월 할인 적용" 문구 제공, 월정액 중기방안적용)
    private(set) var dc_membership: String?  // 기간권 구매 시 멤버쉽 포인트 이용 가격
    private(set) var dc_membership_vat: String?  // 멤버쉽 포인트 이용 가격의 부가세
    private(set) var dc_membership_text: String? // 맴버쉽 포인트 할인 적용내용 문구, 월정액 중기방안적용
    private(set) var dc_point: String?   // 기간권 구매 시 B포인트 이용 가격
    private(set) var expired: String?    // "서비스 만료 여부 - Y: 만료됨(이용불가), N: 이용 가능"
    private(set) var reg_date: String?   // 기간권 구매일 (yyyy.MM.dd)
    private(set) var end_date: String?   // 기간권 구매 만료일 (yyyy.MM.dd)
    private(set) var cancel_date: String?    // 기간권 해지/취소일 (yyyy.MM.dd)
    private(set) var period: String? // "기간권 이용 기간- 이용중 (19.04.29~19.04.30) : 기간권 구매 이용 중인 상태 - 예약 (19.04.22~19.04.29) : 기간권 구매한 상태이며, 이용가능 기간이 도래하기 전인 상태 - 이용 전 해지 완료 : 기간권 구매 후,  해지한 상태 - 기간 만료 (19.04.29~19.04.30) : 기간권 구매 이용기간이 지난 상태"
    private(set) var period_detail: String?  // 기간권 이용 기간 상세. (period와 동일)
    private(set) var method_pay_cd: String?  // 결재방식 코드값 (null 또는 빈값: 청구서, 10: 핸드폰, 85: 신용카드, , 80: TV 포인트
    private(set) var method_pay_nm: String?  // 결재방식 코드명 (null 또는 빈값: 청구서, 10: 핸드폰, 85: 신용카드, , 80: TV 포인트
    private(set) var ppm_poster: String? // 월정액 기간권 가입후 포스터
    private(set) var yn_kzone: String?   // 키즈 상품구분 (Y : 키즈상품, N:키즈상품 아님)
    private(set) var mthd_cd_perd: String?   // "기간권 유형구분 - 10 : 구매시청기간(default) - 20 : 구매시청일"
    private(set) var dd_start_perd: String?  // 기간권 시작일 (yyyy.MM.dd HH:mm:ss)
    private(set) var dd_end_perd: String?    // 기간권 종료일 (yyyy.MM.dd HH:mm:ss)
    private(set) var flag_perd: String?  // "예약/취소 여부 - R: 기간권 구매한 상태이며, 이용기간이 도래하지 않은 상태인 경우(예약상품) - C : 기간권 구매 후, 취소한 상태를 의미 - N: 기간권 구매한 상태이며, 이용기간 중이거나, 만료된 상태인 경우(default)"
}
