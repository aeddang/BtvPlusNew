//
//  EventBanner.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/09.
//

import Foundation

struct EventBanner : Codable {
    private(set) var total_count: Int? = nil
    private(set) var banners: Array<EventBannerItem>? = nil
}

struct EventBannerItem : Codable {
    private(set) var menu_id: String? = nil  // 메뉴 ID
    private(set) var menu_nm: String? = nil   // 메뉴명
    private(set) var gnb_typ_cd: String? = nil // GNB 유형 코드(KIDS, PPM 등)
    private(set) var scn_mthd_cd: String? = nil    // 상영방식 코드
    private(set) var menu_exps_prop_cd: String? = nil  // 메뉴 노출 속성코드
    private(set) var svc_prop_cd: String? = nil    // 서비스 속성 코드
    private(set) var blk_typ_cd: String? = nil // 블록유형코드
    private(set) var lim_lvl_yn: String? = nil // 성인메뉴여부 (제한등급여부)
    private(set) var bnr_on_img_path:String? = nil    // 배너이미지경로(On)
    private(set) var bnr_off_img_path:String? = nil   // 배너이미지경로(Off)
    private(set) var dist_fr_dt:String? = nil // 메뉴배포시작일
    private(set) var dist_to_dt:String? = nil // 메뉴배포종료일
    private(set) var vas_svc_id:String? = nil // VAS 서비스 ID
    private(set) var vas_itm_id:String? = nil // VAS 아이템 ID
    private(set) var vas_id:String? = nil // VAS ID
    private(set) var bnr_det_typ_cd:String? = nil // 배너 상세 유형 코드
    private(set) var bnr_exps_mthd_cd:String? = nil   // 배너노출방식코드 
    private(set) var call_typ_cd:String? = nil    // 호출유형코드
    private(set) var call_url:String? = nil   // 호출URL
    private(set) var cw_call_id_val:String? = nil // CW Call ID
    private(set) var synon_typ_cd:String? = nil   // 진입할 시놉시스 유형(타이틀/단편/시즌/컬렉션/VOD+관련상품)
    private(set) var cnts_typ_cd:String? = nil    // 콘텐츠 유형 코드
    private(set) var shcut_sris_id:String? = nil  // 바로가기 시리즈 ID
    private(set) var shcut_epsd_id:String? = nil  // 바로가기 에피소드 ID
    private(set) var shcut_menu_id:String? = nil  // 바로가기 메뉴 ID
    private(set) var cmpgn_id:String? = nil   // 캠페인 ID(Seg.)
    private(set) var cmpgn_nm:String? = nil   // 캠페인 명
    private(set) var cmpgn_itlk_typ_cd:String? = nil  // 캠페인 연동 유형
    private(set) var cmpgn_fr_dt:String? = nil    // 캠페인 시작일
    private(set) var cmpgn_to_dt:String? = nil    // 캠페인 종료일
    private(set) var cmpgn_apl_fr_dt:String? = nil    // 캠페인 적용 시작일
    private(set) var cmpgn_apl_to_dt:String? = nil    // 캠페인 적용 종료일
    private(set) var bnr_expl:String? = nil   // 배너설명
    private(set) var evt_exps_loc_cd:String? = nil    // 이벤트 노출 위치 코드 10-앞, 20-뒤
    private(set) var page_path:String? = nil  // 메뉴 경로(STB LOG 용)
    private(set) var exps_rslu_cd:String? = nil   // 노출 해상도 코드(이벤트 블록 노출 유형)
    private(set) var bnr_left_img_path:String? = nil  // 배너 왼쪽 이미지 경로
    private(set) var bnr_right_img_path:String? = nil // 배너 오른쪽 이미지 경로
    private(set) var bnr_epsd_rslu_id:String? = nil   // 배너 에피소드 해상도 ID
    private(set) var bnr_typ_cd:String? = nil // 배너 유형 코드(10:빅배너, 20:이벤트)
    private(set) var bbnr_exps_mthd_cd:String? = nil  // "빅배너 노출 방식 코드(M BTV) 01:기본 배너, 02:이용유도배너"
    private(set) var prd_prc_id:String? = nil // 상품ID
    private(set) var prd_typ_cd:String? = nil // 상품유형코드
    private(set) var asis_prd_typ_cd:String? = nil    // ASIS 상품유형코드
    private(set) var sale_prc:Double? = nil   // 판매가격
    private(set) var sale_prc_vat:Double? = nil   // 판매가격 부가세 포함
    private(set) var prd_prc:Double? = nil    // 상품가격(원가격)
    private(set) var prd_prc_vat:Double? = nil    // 상품가격(원가격) 부가세 포함
    private(set) var is_compound_prd:String? = nil    // 복합상품여부
    private(set) var img_dist_yn:String? = nil    // 배너이미지배포여부
    private(set) var mmtf_home_exps_yn:String? = nil  // 월정액 홈 노출여부
    private(set) var uguid_typ_cd:String? = nil   // 이용안내 가이드 유형 코드
    private(set) var uguid_title:String? = nil    // 이용안내 가이드 제목
    private(set) var uguid_expl:String? = nil // 이용안내 가이드 설명
    private(set) var uguid_epsd_rslu_id:String? = nil // 이용안내 가이드 동영상 에피소드 해상도 ID
    private(set) var guide_imgs:Array<ImagePathItem>? = nil // 이용안내 가이드 이미지 목록
    private(set) var bnr_img_expl_typ_cd:String? = nil    // 배너 이미지 설명 유형 코드
    private(set) var bnr_img_btm_expl_typ_cd:String? = nil    // 배너 이미지 하위 설명 유형 코드
    private(set) var bnr_img_expl:String? = nil   // 배너 이미지 설명
    private(set) var bnr_img_btm_expl:String? = nil   // 배너 이미지 하위 설명
    private(set) var img_bagr_color_code:String? = nil    // 이미지 배경 컬러 코드
    private(set) var logo_img_path:String? = nil  // 로고 이미지 경로
    private(set) var width_focus_off_path:String? = nil   // 가로 포커스 OFF 경로: 태블릿 이미지
}

