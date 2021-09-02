//
//  MonthlyList.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/26.
//

import Foundation
struct MonthlyInfo : Decodable {
    private(set) var ver: String? = nil    // 인터페이스 버전
    private(set) var svc_name: String? = nil   // 서비스이름
    private(set) var stb_id: String? = nil // STB ID
    private(set) var page_tot: String? = nil   // 전체 페이지 개수
    private(set) var page_no: String? = nil    // 현재 페이지 번호
    private(set) var purchase_tot: String? = nil   // 월정액 전체 개수
    private(set) var purchase_no: String? = nil    // 현재 페이지의 월정액 개수
    private(set) var purchaseList: [MonthlyInfoItem]? = nil  // 집합의 이름
    private(set) var m_pidList: [String]? = nil  // 1. 가입한 월정액 복합상품 ID 리스트 - 월정액 메뉴리스트 제공시 복합VOD 상품인 경우, 개별상품으로 제공하는 시나리오반영으로 월정액 추천시 복합상품을 추천하는 것을 방지하기위해 가입한 월정액의 복합상품ID 리스트를 제공함. 2. 요청파라미터 yn_
}

struct MonthlyInfoItem : Decodable {
    private(set) var prod_code: String? = nil  // "상품의 구분 코드 - 30 : 일반 및 결합 상품(일반 월정액) - 32 : 월정액 기간권 상품 - 36 : 월정액+커머스 상품 - 60 : 부가서비스 상품(VAS 월정액) - 80 : 채널패키지 상품(IPTV 월정액)"
    private(set) var kzone_yn: String? = nil
    private(set) var prod_id: String? = nil    // 상품 식별자
    private(set) var subs_id: String? = nil   // "계약 식별자.월정액 해지 시 사용"
    private(set) var title: String? = nil  // 월정액 상품의 이름
    private(set) var adult: String? = nil // "성인물 여부값 설명 Y : 성인물 N : 성인물 아님"
    private(set) var ppm_rltn_prd_id: String? = nil    // "월정액 관련상품(커머스) ID - 관련상품인 경우, 값이 존재 - 기존 상품인 경우, null 또는 빈값으로 제공"
    private(set) var yn_perd: String? = nil    // "N : 기존 월정액 구매내역 정보 제공(약정정보 및 커머스 구매내역 포함) Y : 기간권 구매내역 정보 제공"
    private(set) var title_perd: String? = nil // 기간권 이용기간명(title 추가 표시용)
    private(set) var dd_start_perd: String? = nil  // "기간권 시작일 (yyyy.MM.dd HH:mm:ss) - yn_ppm_ticket = Y 인 경우 정보 제공 - yn_ppm_ticket = N 인 경우 정보 미제공(빈 값 제공)"
    private(set) var dd_end_perd: String? = nil   // "기간권 종료일 (yyyy.MM.dd HH:mm:ss) - yn_ppm_ticket = Y 인 경우 정보 제공 - yn_ppm_ticket = N 인 경우 정보 미제공(빈 값 제공)"
    private(set) var flag_perd: String? = nil  // "예약/취소 여부 - R: 기간권 구매한 상태이며, 이용기간이 도래하지 않은 상태인 경우(예약상품) - C : 기간권 구매 후, 취소한 상태를 의미- N: 기간권 구매한 상태이며, 이용기간 중이거나, 만료된 상태인 경우(default)"
}

struct MonthlyInfoData : Decodable {
    private(set) var reqPPMInfo: [MonthlyInfoDataPpm]? = nil    // Request로 요청한 월정액 상품 정보(1건)
    private(set) var purchaseList: [MonthlyInfoDataPurchase]? = nil   // reqPPMInfo를 가지고 월정액 구매내역 전체를 확인한 결과 리스트(여러건), 조회 결과 없을 시 null 리턴
}

struct MonthlyInfoDataPpm : Decodable {
    private(set) var req_prd_prc_id: String? = nil // 요청한 월정액 상품 가격 아이디
    private(set) var req_prd_nm: String? = nil // 요청한 월정액 상품명
    private(set) var req_prd_typ_cd: String? = nil// 요청한 월정액 상품의 NCMS 상품 구분 코드 - 30 : VOD PPM - 32 : VOD PPM 기간권 - 34 : 복합 VOD PPM - 35 : 복합 PPM - 36 : VOD PPM 관련상품 - 37 : 복합 VOD PPM 기간권 - 60 : VAS PPM - 80 : 채널 PPM
    private(set)  var req_asis_prd_typ_cd: String? = nil    // 요청한 월정액 상품의 상품 구분 코드 - 30 : 일반 및 결합 상품(일반 월정액) - 60 : 부가서비스 상품(VAS 월정액) - 80 : 채널패키지 상품(IPTV 월정액)
}

struct MonthlyInfoDataPurchase : Decodable {
    private(set) var owned_prd_prc_id: String? = nil   // "구매내역에 있는 월정액 상품 가격 아이디 구매하지 않았을 때는 공백("""")으로 리턴"
    private(set) var owned_prd_nm: String? = nil  // "구매내역에 있는 월정액 상품명 구매하지 않았을 때는 공백("""")으로 리턴"
    private(set) var owned_prd_typ_cd: String? = nil   // "NCMS 상품의 구분 코드 - 30 : VOD PPM - 32 : VOD PPM 기간권 - 34 : 복합 VOD PPM - 35 : 복합 PPM - 36 : VOD PPM 관련상품 - 37 : 복합 VOD PPM 기간권 - 60 : VAS PPM - 80 : 채널 PPM"
    private(set) var owned_asis_prd_typ_cd: String? = nil  // "상품의 구분 코드 - 30 : 일반 및 결합 상품(일반 월정액) - 60 : 부가서비스 상품(VAS 월정액) - 80 : 채널패키지 상품(IPTV 월정액)"
    private(set) var purchase_yn: String? = nil   // "월정액/기간권 가입 여부 Y : 가입중 N : 가입안함"
    private(set) var free_ppm_use_yn: String? = nil    // "무료 월정액 가입할 수 있는지 확인하는 필드 Y: 무료 월정액 가입 가능 대상 N: 무료 무료 월정액 가입 불가 대상 - free_ppm_use_yn=N 으로 조회되는 이유 - 무료 월정액 혜택을 이미 받았을 때 - 상위 월정액을 이미 이용 중 이거나 이용했던 적이 있일 때 - 상위 월정액 구매 시 무료 월정액 혜택을 받는 중 이거나 이미 받았을 때 - 구매한 월정액의 파생상품(기간권 등)을 이미 이용 중 이거나 이용했던 적이 있을 때"
    private(set) var ppm_free_join_yn: String? = nil   // "월정액 상품 정보(NCMS)에 설정되어 있는 무료 가입 여부 - free_ppm_use_yn=N 이라도 ppm_free_join_yn=Y 일 수 있다."
    private(set) var ppm_free_join_perd_cd: String? = nil  // "월정액 상품 정보(NCMS)에 설정되어 있는 무료 월정액 이용 가능 개월 수 - 1이면 1개월, 2면 2개월, 3이면 3개월… - ppm_free_join_yn=N 이면 ppm_free_join_perd_cd=""""(공백) 임"
    private(set) var kzone_yn: String? = nil  // "키즈 월정액 여부 Y : 키즈 월정액 N : 키즈 월정액 아님"
    private(set) var dt_insert: String? = nil  // 월정액 가입일자
    private(set) var dt_update: String? = nil // 월정액 정보 수정일자
}
