//
//  Purchase.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/06.
//

import Foundation

struct Purchase : Decodable {
    private(set) var ver: String?    // 인터페이스 버전
    private(set) var svc_name: String?   // 서비스이름
    private(set) var stb_id: String? // STB ID
    private(set) var page_tot: String?   // 전체 페이지 개수
    private(set) var page_no: String?    // 현재 페이지 번호
    private(set) var purchase_tot: String?   // 즐겨찾기의 전체 개수
    private(set) var purchase_no: String?    // 현재 페이지의 즐겨찾기 개수
    private(set) var purchaseList:[PurchaseListItem]?   // 즐겨찾기 집합의 이름
}

struct PurchaseListItem : Decodable {
    private(set) var purchase_idx: String? // 구매내역의 구매인덱스
    private(set) var sris_id: String? // VOD 컨텐츠의 시즌ID
    private(set) var epsd_id: String? // VOD 컨텐트의 식별자
    private(set) var prod_type_nm: String? // "일반/소장용구분, 상품타입, 언어구분여부 정보 제공 - 상품타입종류 : 단편, 시즌 전편, 시즌 회차, 패키지, VOD 관련상품 - 단편 : yn_series = N & prod_type_cd = 10 - 시즌 회차 : yn_series = Y & prod_type_cd = 10 - 시즌 전편 : prod_type_cd = 20 - 패키지 : 41 - VOD 관련상품 : VOD 관련상품으로 구매시(id_mchdse 가 존재시)"
    private(set) var prod_type_cd: String? // "상품의 구분 코드  - 10: 단편, 20: 시즌, 41: 패키지"
    private(set) var yn_mchdse: String? // "관련상품 여부 Y : 관련상품, N : 일반상품(10/20/41)"
    private(set) var prod_id: String? // 상품 식별자
    private(set) var epsd_rslu_id: String? // 구매한 VOD 컨텐트의 해상도ID
    private(set) var title: String? // "컨텐트 또는 부가서비스의 이름 *패키지 상품인 경우, 상품 title 표시"
    private(set) var yn_series: String? // 시즌 / 단편(타이틀) 구분, Y(시즌), N(단편)
    private(set) var series_no: String? // VOD 컨텐트의 회차
    private(set) var level: String? // 사용자 등급
    private(set) var adult: String? // "성인물 여부  - Y: 성인물, N: 성인물 아님"
    private(set) var poster: String? // 포스터 주소(URL)의 패스 (example=/menu/cate/poster.jpg)
    private(set) var nscreen: String? // "N-Screen 상품 유무 - Y: N-Screen, N: N-Screen 아님"
    private(set) var quality: String? // 미디어 화질 구분
    private(set) var lang_caption_type: String? // 언어, 자막구분코드
    private(set) var amt_price: String? // 상품 정가
    private(set) var price: String? // 저장소에 저장된 상품의 판매 가격
    private(set) var selling_price: String? // "사용자가 구매한 상품의 실질적인 가격 (계산식: amt_price - dc_coupon - dc_membership - dc_ocb - dc_point)"
    private(set) var dc_coupon: String? // 상품 구매 시 쿠폰 이용 가격
    private(set) var dc_coupon_value: String? // 쿠폰 금액 또는 할인율
    private(set) var dc_coupon_type: String? // 정율/정액 구분
    private(set) var dc_membership: String? // 상품 구매 시 멤버쉽 포인트 이용 가격
    private(set) var dc_membership_vat: String? // 멤버쉽 포인트 이용 가격의 부가세
    private(set) var dc_membership_tot: String? // 맴버쉽 total 이용가격
    private(set) var dc_point: String? // 상품 구매 시 B포인트 이용 가격
    private(set) var dc_ocb: String? // 상품 구매 시 OK Cashbag 이용 가격
    private(set) var dc_ocb_vat: String? // OK Cashbag 이용 가격의 부가세
    private(set) var dc_ocb_tot: String? // OK Cashbag Total 이용가격
    private(set) var tvpoint: String? // TV 포인트로 구매한 경우, 구매가격
    private(set) var dc_tvpoint: String? // TV 포인트로 할인 받은 경우, 이용가격
    private(set) var dc_tvpoint_vat: String? // TV 포인트로 할인 받은 경우, 이용가격의 부가세
    private(set) var dc_tvpoint_tot: String? // TV 포인트 Total 이용가격
    private(set) var expired: String? // "서비스 이용 가능 여부 - Y: 만료됨, N: 이용 가능"
    private(set) var reg_date: String? // 상품 구매일 (yyyy.MM.dd)
    private(set) var end_date: String? // 상품 구매 만료일 (yyyy.MM.dd)
    private(set) var period: String? // "남은일수(만료시간 - 현재시간) -  8일 이상이면 빈값 -  7일 이하 이면 n ~ -1 (0이면 만료임박, -1이면 만료) - 보낸선물인경우, n = -1"
    private(set) var period_detail: String? // "이용기간 - 8일 이상이면 : 이용가능(yyyy.mm.dd HH:MM 까지) - 7일이하 ~ 2일이상 : 만료n일 전(yyyy.mm.dd HH:MM 까지) - 1일이하 ~ 만료전 : 만료임박(yyyy.mm.dd HH:MM 까지) - 만료 : 기간만료(yyyy.mm.dd HH:MM 까지) - 보낸선물 : 기간만료(보낸선물)"
    private(set) var material_cd: String? // "구매한 컨텐츠의 소재상태코드(65:배포승인, 80:배포만료 등) - 구매한 시점의 컨텐츠ID 기준"
    private(set) var method_pay_cd: String? // 결재방식 코드값 (null 또는 빈값: 청구서, 10: 핸드폰, 85: 신용카드, , 80: TV포인트
    private(set) var method_pay_nm: String? // 결재방식 코드명 (null 또는 빈값: 청구서, 10: 핸드폰, 85: 신용카드, , 80: TV포인트
}

