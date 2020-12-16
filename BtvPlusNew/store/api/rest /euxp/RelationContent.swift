//
//  RelationContent.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/10.
//

import Foundation
struct RelationContents : Codable {
    private(set) var status_code: String? = nil
    private(set) var banners: Array<RelatedInfo>? = nil
    private(set) var menu_stb_svc_id: String? = nil
}
struct RelatedInfo : Codable {
    private(set) var t_cnt: String? = nil  // 그리드 전체 배열 개수
    private(set) var sub_title: String? = nil  // 부제목
    private(set) var cw_call_id: String? = nil  // CW Call ID (IF-EUXP-010 호출 시 요청 파라미터로 넘겨준다.)
    private(set) var session_id: String? = nil  // 세션아이디 (IF-EUXP-010 호출 시 요청 파라미터로 넘겨준다.)
    private(set) var block: Array<CWBlockItem>? = nil  // 블록
    private(set) var sectionId: String? = nil  // 섹션아이디
    private(set) var btrack_id: String? = nil  // 트랙아이디(CW 관리정보)
}

struct CWBlockItem : Codable {
    private(set) var titleString: String? = nil  // 제목
    private(set) var poster_filename_hString: String? = nil  // 포스터파일명(가로)
    private(set) var sris_idString: String? = nil  // 시리즈ID
    private(set) var poster_filename_vString: String? = nil  // 포스터파일명(세로)
    private(set) var track_idString: String? = nil  // 콘텐츠 트랙 아이디 (IF-EUXP-010 호출 시 요청 파라미터로 넘겨준다.)
    private(set) var epsd_idString: String? = nil  // 에피소드ID
    private(set) var adlt_lvl_cdString: String? = nil  // 성인등급코드
    private(set) var sale_prcString: String? = nil  // 판매가격
    private(set) var sale_prc_vatString: String? = nil   // 판매가격 부가세 포함
    private(set) var prd_prcString: String? = nil    // 상품가격(원가격)
    private(set) var prd_prc_vatString: String? = nil    // 상품가격(원가격) 부가세 포함
    private(set) var prd_prc_idString: String? = nil // 상품가격ID(현재콘텐츠가 속한 월정액 PID[우선순위 정해서 하나만])
    private(set) var ppm_grid_icon_img_pathString: String? = nil  // PPM아이콘이미지경로(그리드)
    private(set) var user_badge_img_pathString: String? = nil  // 사용자 등록 뱃지 이미지(하단 노출 이벤트 이미지)
    private(set) var svc_fr_dtString: String? = nil  // 진입할 시놉시스 유형(타이틀/단편/시즌/컬렉션/VOD+관련상품)
    private(set) var synon_typ_cdString: String? = nil  // 진입할 시놉시스 유형(타이틀/단편/시즌/컬렉션/VOD+관련상품)
    private(set) var icon_exps_fr_dtString: String? = nil  // 뱃지(이벤트) 노출 시작 일자
    private(set) var wat_lvl_cdString: String? = nil  // 시청등급코드
    private(set) var bas_badge_img_pathString: String? = nil  // 기본 뱃지 이미지 경로(상단 노출 뱃지)
    private(set) var brcast_tseq_nmString: String? = nil  // 방송회차
    private(set) var meta_typ_cdString: String? = nil  // 메타 유형 코드
    private(set) var icon_exps_to_dtString: String? = nil  // 뱃지(이벤트) 노출 종료 일자
    private(set) var sort_seqString: String? = nil  // 정렬순서
    private(set) var svc_to_dtString: String? = nil  // 서비스 종료일
    private(set) var epsd_dist_fir_svc_dtString: String? = nil  // 에피소드 동기화승인일
    private(set) var sris_dist_fir_svc_dtString: String? = nil  // 시리즈 동기화승인일
    private(set) var badge_typ_nmString: String? = nil  // 뱃지 유형명
    private(set) var rslu_typ_cdString: String? = nil  // 상품해상도
    private(set) var kids_ynString: String? = nil  // 키즈 시놉 여부
    private(set) var cacbro_ynString: String? = nil  // 결방여부
    private(set) var epsd_rslu_idString: String? = nil  // CW에서 제공하는 콘텐츠 아이디 (IF-EUXP-010 호출시 요청 파라미터로 넘겨준다.)

}
