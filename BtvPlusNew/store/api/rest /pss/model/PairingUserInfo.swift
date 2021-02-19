//
//  PssUserInfo.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/19.
//

import Foundation

struct PairingUserInfo : Decodable {
    private(set) var user:UserInfoItem? = nil                   // 유저 정보
    private(set) var option:OptionInfo? = nil          // 스크램블 값을 갖는 변수
}
struct ScrambleInfo : Decodable {
    private(set) var http_type: String?        // http 타입
    private(set) var scramble_id: String?               // 스크램블 아이디
    private(set) var url: String?              // 스크램블 서버 url
    private(set) var yn_open: String?          // 스크램블 서버 open여부
}

struct OptionInfo : Decodable {
    private(set) var scramble: ScrambleInfo?       // 스크램블 정보
}

struct UserInfoItem : Decodable {
    private(set) var cache: String?
    private(set) var cas_type: String?             // cas 모드 활성화 여부
    private(set) var co_pack: String?
    private(set) var e_time: String?
    private(set) var interval: String?
    private(set) var iptv_pack: String?            // iptv용 패키지 코드
    private(set) var menu_order_version: String?
    private(set) var network_type: String?         // 네트워크 타입
    private(set) var multiview_type: String?       // 멀티뷰 타입
    private(set) var pack: String?                 // 상품팩 코드
    private(set) var pack_desc: String?            // 상품팩 설명
    private(set) var pack_xxxx: String?            // 상품팩 코드2
    private(set) var pd_pack: String?
    private(set) var region_code: String?          // 지역에 따른 지상파 지역코드
    private(set) var s_time: String?
    private(set) var sub_pack: String?             // tv_package 코드
    private(set) var svc: String?                  // 서비스 코드
    private(set) var update_mode: String?
    private(set) var yn_emergency: String?
    private(set) var status_code: String?          // 미가입채널 및 권한없음/요금미납 관련 코드
    private(set) var post_no: String?              // 우편번호
    private(set) var use_infoagr: String?
    private(set) var tvp_use_status: String?       // tv포인트 사용 상태
    private(set) var ukey_prod_id: String?         // NT 아이디
    private(set) var combine_product_list: String? // 월정액 결합상품 리스트
    private(set) var combine_product_use: String?  // 월정액 결합상품 여부
    private(set) var join_prod_name: String?       // 가입 상품명
    private(set) var registered_date: String?      // 가입 날짜
    private(set) var is_new_registered_yn: String?    // 신규 가입 고객 유무
}




