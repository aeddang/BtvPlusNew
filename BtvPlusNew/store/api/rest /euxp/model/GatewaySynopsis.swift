//
//  GatewaySynopsis.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/10.
//

import Foundation
struct GatewaySynopsis : Codable {
    private(set) var package: PackageInfo? = nil
}

struct PackageInfo : Codable {
    private(set) var sale_prc_vat:DynamicValue? = nil   // 판매가격 부가세 포함
    private(set) var prd_prc_id:String? = nil     // 상품ID
    private(set) var sale_prc:DynamicValue? = nil   // 판매가격
    private(set) var meta_typ_cd:String? = nil    // 메타 유형 코드
    private(set) var prd_typ_cd:String? = nil // 상품유형코드
    private(set) var asis_prd_typ_cd:String? = nil    // AS-IS 상품 유형 코드
    private(set) var svc_fr_dt:String? = nil  // 서비스 시작일
    private(set) var svc_to_dt:String? = nil  // 서비스 종료일
    private(set) var sris_id:String? = nil    // 시리즈ID
    private(set) var prd_prc:DynamicValue? = nil    // 상품가격(원가격)
    private(set) var poster_filename_h:String? = nil  // (패키지)가로 포스터
    private(set) var poster_filename_v:String? = nil  // (패키지)세로 포스터
    private(set) var contents:[PackageContentsItem]? = nil    // 메뉴 ID(콘텐츠 블럭을 가진 메뉴ID)
    private(set) var bg_img_path:String? = nil    // 배경이미지(정보영역 BG에 추가됨.)
    private(set) var kids_yn:String? = nil    // 키즈 시놉 여부
    private(set) var title:String? = nil  // 제목
    private(set) var prd_prc_vat:DynamicValue? = nil    // 상품가격(원가격) 부가세 포함
    private(set) var sris_typ_cd:String? = nil    // 시리즈 유형 코드 04:콘텐츠팩, 08:전시용팩
    private(set) var dist_sts_cd:String? = nil    // 배포상태
    private(set) var prvw_left_img_path:String? = nil // 프리뷰 왼쪽 이미지 경로
    private(set) var prvw_right_img_path:String? = nil    // 프리뷰 오른쪽 이미지 경로
    private(set) var mbtv_bg_img_path:String? = nil    // 모바일 BTV 배경 이미지
    private(set) var mbtv_bg_img_path_h:String? = nil     // 모바일 BTV 가로 배경 이미지
}

struct PackageContentsItem : Codable {
    private(set) var sris_id:String? = nil   // 시리즈ID
    private(set) var poster_filename_v:String? = nil // 포스터이미지경로(세로)
    private(set) var wat_lvl_cd:String? = nil// 시청등급코드
    private(set) var PKG_SRIS_ID:String? = nil   // 패키지 시리즈 아이디
    private(set) var epsd_id:String? = nil   // 에피소드ID
    private(set) var adlt_lvl_cd:String? = nil   // 성인등급코드
    private(set) var title:String? = nil // 제목
    private(set) var synon_typ_cd:String? = nil  // 진입할 시놉시스 유형(타이틀/단편/시즌/컬렉션/VOD+관련상품)
    private(set) var lag_capt_typ_cd:String? = nil   // 언어자막유형코드
}
