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
    private(set) var http_type: String? = nil        // http 타입
    private(set) var scramble_id: String? = nil               // 스크램블 아이디
    private(set) var url: String? = nil              // 스크램블 서버 url
    private(set) var yn_open: String? = nil         // 스크램블 서버 open여부
}

struct OptionInfo : Decodable {
    private(set) var scramble: ScrambleInfo? = nil       // 스크램블 정보
}

struct UserInfoItem : Decodable {
    private(set) var cache: String? = nil
    private(set) var cas_type: String? = nil             // cas 모드 활성화 여부
    private(set) var co_pack: String? = nil
    private(set) var e_time: String? = nil
    private(set) var interval: String? = nil
    private(set) var iptv_pack: String? = nil           // iptv용 패키지 코드
    private(set) var menu_order_version: String? = nil
    private(set) var network_type: String? = nil         // 네트워크 타입
    private(set) var multiview_type: String? = nil       // 멀티뷰 타입
    private(set) var pack: String? = nil                 // 상품팩 코드
    private(set) var pack_desc: String? = nil            // 상품팩 설명
    private(set) var pack_xxxx: String? = nil           // 상품팩 코드2
    private(set) var pd_pack: String? = nil
    private(set) var region_code: String? = nil          // 지역에 따른 지상파 지역코드
    private(set) var s_time: String? = nil
    private(set) var sub_pack: String? = nil            // tv_package 코드
    private(set) var svc: String? = nil                  // 서비스 코드
    private(set) var update_mode: String? = nil
    private(set) var yn_emergency: String? = nil
    private(set) var status_code: String? = nil          // 미가입채널 및 권한없음/요금미납 관련 코드
    private(set) var post_no: String? = nil              // 우편번호
    private(set) var use_infoagr: String? = nil
    private(set) var tvp_use_status: String? = nil       // tv포인트 사용 상태
    private(set) var ukey_prod_id: String? = nil         // NT 아이디
    private(set) var combine_product_list: String? = nil // 월정액 결합상품 리스트
    private(set) var combine_product_use: String? = nil  // 월정액 결합상품 여부
    private(set) var join_prod_name: String? = nil      // 가입 상품명
    private(set) var registered_date: String? = nil      // 가입 날짜
    private(set) var is_new_registered_yn: String? = nil    // 신규 가입 고객 유무
}




