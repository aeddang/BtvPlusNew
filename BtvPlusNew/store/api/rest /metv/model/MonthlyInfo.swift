//
//  MonthlyList.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/26.
//

import Foundation
struct MonthlyInfo : Decodable {
    private(set) var ver: String?    // 인터페이스 버전
    private(set) var svc_name: String?   // 서비스이름
    private(set) var stb_id: String? // STB ID
    private(set) var page_tot: String?   // 전체 페이지 개수
    private(set) var page_no: String?    // 현재 페이지 번호
    private(set) var purchase_tot: String?   // 월정액 전체 개수
    private(set)  var purchase_no: String?    // 현재 페이지의 월정액 개수
    private(set) var purchaseList: [MonthlyInfoItem]?   // 집합의 이름
    private(set) var m_pidList: [String]?   // 1. 가입한 월정액 복합상품 ID 리스트 - 월정액 메뉴리스트 제공시 복합VOD 상품인 경우, 개별상품으로 제공하는 시나리오반영으로 월정액 추천시 복합상품을 추천하는 것을 방지하기위해 가입한 월정액의 복합상품ID 리스트를 제공함. 2. 요청파라미터 yn_
}

struct MonthlyInfoItem : Decodable {
    private(set) var prod_code: String?  // "상품의 구분 코드 - 30 : 일반 및 결합 상품(일반 월정액) - 32 : 월정액 기간권 상품 - 36 : 월정액+커머스 상품 - 60 : 부가서비스 상품(VAS 월정액) - 80 : 채널패키지 상품(IPTV 월정액)"
    private(set) var prod_id: String?    // 상품 식별자
    private(set) var subs_id: String?    // "계약 식별자.월정액 해지 시 사용"
    private(set) var title: String?  // 월정액 상품의 이름
    private(set) var adult: String?  // "성인물 여부값 설명 Y : 성인물 N : 성인물 아님"
    private(set) var ppm_rltn_prd_id: String?    // "월정액 관련상품(커머스) ID - 관련상품인 경우, 값이 존재 - 기존 상품인 경우, null 또는 빈값으로 제공"
    private(set) var yn_perd: String?    // "N : 기존 월정액 구매내역 정보 제공(약정정보 및 커머스 구매내역 포함) Y : 기간권 구매내역 정보 제공"
    private(set) var title_perd: String? // 기간권 이용기간명(title 추가 표시용)
    private(set) var dd_start_perd: String?  // "기간권 시작일 (yyyy.MM.dd HH:mm:ss) - yn_ppm_ticket = Y 인 경우 정보 제공 - yn_ppm_ticket = N 인 경우 정보 미제공(빈 값 제공)"
    private(set) var dd_end_perd: String?    // "기간권 종료일 (yyyy.MM.dd HH:mm:ss) - yn_ppm_ticket = Y 인 경우 정보 제공 - yn_ppm_ticket = N 인 경우 정보 미제공(빈 값 제공)"
    private(set) var flag_perd: String?  // "예약/취소 여부 - R: 기간권 구매한 상태이며, 이용기간이 도래하지 않은 상태인 경우(예약상품) - C : 기간권 구매 후, 취소한 상태를 의미- N: 기간권 구매한 상태이며, 이용기간 중이거나, 만료된 상태인 경우(default)"
}
