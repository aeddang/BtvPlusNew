//
//  GnbBlock.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/10.
//

import Foundation
struct GnbBlock : Decodable {
    private(set) var total_count:Int? = 0 // 전체 개수
    private(set) var gnbs:Array<GnbItem>? = nil // GNB 목록
}

struct GnbItem : Decodable {

    private(set) var scn_mthd_cd:String? = nil    // 상영방식 코드
    private(set) var menu_exps_prop_cd:String? = nil  // 메뉴 노출 속성코드
    private(set) var svc_prop_cd:String? = nil    // 서비스 속성 코드
    private(set) var dist_fr_dt:String? = nil // 메뉴배포시작일
    private(set) var dist_to_dt:String? = nil // 메뉴배포종료일
    private(set) var menu_nm:String? = nil    // 메뉴명
    private(set) var lim_lvl_yn:String? = nil // 성인메뉴여부 (제한등급여부)
    private(set) var menu_id:String? = nil    // 메뉴 ID
    private(set) var gnb_typ_cd:String? = nil // GNB 유형 코드(KIDS, PPM 등)
    private(set) var kidsz_gnb_cd:String? = nil   // 키즈존 GNB 코드
    private(set) var gnb_sub_typ_cd:String? = nil // GNB 서브 유형 코드(시니어GNB코드)
    private(set) var page_path:String? = nil  // 메뉴 경로(STB LOG용)
    private(set) var menu_on_img_path:String? = nil   // 메뉴이미지경로(on) GNB 아이콘
    private(set) var menu_off_img_path:String? = nil  // 메뉴이미지경로(off)
    private(set) var menu_selected_img_path:String? = nil // 메뉴이미지경로(선택)
    private(set) var menu_on_img_path2:String? = nil   // 메뉴 아이콘/뱃지2(Over)
    private(set) var menu_off_img_path2:String? = nil  // 메뉴 아이콘/뱃지2(Normal)
    private(set) var menu_selected_img_path2:String? = nil // 메뉴 아이콘/뱃지2(Selected)
    private(set) var bg_imgs:Array<ImagePathItem>? = nil// "배경 이미지 목록- 시니어 배경이미지 5개 등록 - 키즈 배경이미지에서 사용 가능"
    private(set) var bnr_exps_mthd_cd:String? = nil   // "배너노출방식코드(10:텍스트, 20:이미지) 메뉴명 이미지 처리 가능"
    private(set) var bnr_on_img_path:String? = nil    // 배너이미지경로(On)
    private(set) var bnr_off_img_path:String? = nil   // 배너이미지경로(Off)
    private(set) var bnr_selected_img_path:String? = nil  // 배너이미지경로(선택)
    private(set) var btm_menu_tree_exps_yn:String? = nil  // 하위 메뉴 tree 노출 여부
    private(set) var call_typ_cd:String? = nil    // 호출유형코드(TV앱(VAS)만 사용). 키즈/시니어 APP 호출용
    private(set) var call_url:String? = nil   // 호출URL
    private(set) var vas_id:String? = nil // VAS ID
    private(set) var vas_svc_id:String? = nil // VAS 서비스 ID
    private(set) var vas_itm_id:String? = nil // VAS 아이템 ID
    private(set) var bnr_use_yn:String? = nil // 빅배너 호출 여부
    private(set) var last_bnr_dist_to_dt:String? = nil    // 마지막빅배너배포종료일
    private(set) var evt_use_yn:String? = nil // 이벤트호출여부
    private(set) var last_evt_dist_to_dt:String? = nil    // 마지막이벤트배포종료일
    private(set) var blocks:Array<BlockItem>? = nil // 블록배열

}

struct BlockItem  : Decodable {
    private(set) var menu_id:String? = nil    // 메뉴 ID(콘텐츠 블럭을 가진 메뉴ID)
    private(set) var menu_nm:String? = nil    // 메뉴명
    private(set) var menu_expl:String? = nil  // "메뉴설명(월정액에서 사용)M BTV에서 부가설명에서도 사용"
    private(set) var call_typ_cd:String? = nil    // 호출유형코드
    private(set) var call_url:String? = nil   // 호출URL
    private(set) var cw_call_id_val:String? = nil // CW Call ID
    private(set) var menu_exps_prop_cd:String? = nil  // "메뉴 노출 속성코드 509: UI5.2-KIDS하위메뉴2단노출 510: UI5.2-KIDS하위메뉴1단노출 511: UI5.2-구분메뉴"
    private(set) var scn_mthd_cd:String? = nil    // 상영 방식 코드
    private(set) var svc_prop_cd:String? = nil    // 서비스 속성 코드
    private(set) var lim_lvl_yn:String? = nil // 성인메뉴여부 (제한등급여부)
    private(set) var exps_rslu_cd:String? = nil   // 노출 해상도 코드
    private(set) var blk_typ_cd:String? = nil // 블럭유형코드
    private(set) var menu_nm_exps_yn:String? = nil    // 메뉴명 노출 여부
    private(set) var exps_mthd_cd:String? = nil   // 노출방식코드
    private(set) var pst_exps_typ_cd:String? = nil    // "포스터 노출 유형 10 가로 20 세로 30 가로 썸네일(MobileBTV) 40 세로 BIG(MobileBTV)"
    private(set) var chrtr_menu_cat_cd:String? = nil  // 캐릭터 메뉴 카테고리 코드
    private(set) var gnb_typ_cd:String? = nil // GNB 유형 코드(KIDS, PPM 등)
    private(set) var cmpgn_id:String? = nil   // 캠페인 ID(Seg.)
    private(set) var dist_fr_dt:String? = nil // 메뉴배포시작일
    private(set) var dist_to_dt:String? = nil // 메뉴배포종료일
    private(set) var bnr_use_yn:String? = nil // 빅배너 호출 여부
    private(set) var last_bnr_dist_to_dt:String? = nil    // 마지막빅배너배포종료일
    private(set) var evt_use_yn:String? = nil // 이벤트호출여부
    private(set) var last_evt_dist_to_dt:String? = nil    // 마지막이벤트배포종료일
    private(set) var bnr_exps_mthd_cd:String? = nil   // "배너노출방식코드(10:텍스트, 20:이미지) 메뉴명 이미지 처리 시니어 내 카드이미지"
    private(set) var bnr_on_img_path:String? = nil    // 배너이미지경로(On)
    private(set) var bnr_off_img_path:String? = nil   // 배너이미지경로(Off)
    private(set) var bnr_selected_img_path:String? = nil  // 배너이미지경로(선택)
    private(set) var page_path:String? = nil  // 메뉴경로(STB LOG용)
    private(set) var asis_prd_typ_cd:String? = nil    // ASIS 상품유형코드
    private(set) var is_compound_prd:String? = nil    // 복합상품여부
    private(set) var prd_prc_id:String? = nil // 상품가격ID(VAS ID에 저장되어 있던 값)
    private(set) var prd_prc:String? = nil    // 상품가격(원가격)
    private(set) var prd_prc_vat:String? = nil    // 상품가격(원가격) 부가세 포함
    private(set) var prd_typ_cd:String? = nil // 상품유형코드
    private(set) var sale_prc:String? = nil   // 판매가격
    private(set) var sale_prc_vat:String? = nil   // 판매가격 부가세 포함
    private(set) var cnts_typ_cd:String? = nil    // 콘텐츠 유형 코드
    private(set) var shcut_epsd_id:String? = nil  // 바로가기 에피소드 ID
    private(set) var shcut_sris_id:String? = nil  // 바로가기 시리즈 ID
    private(set) var shcut_menu_id:String? = nil  // 바로가기 메뉴 ID
    private(set) var synon_typ_cd:String? = nil   // 진입할 시놉시스 유형(타이틀/단편/시즌/컬렉션/VOD+관련상품)
    private(set) var vas_id:String? = nil // VAS ID
    private(set) var vas_svc_id:String? = nil // VAS 서비스 ID
    private(set) var vas_itm_id:String? = nil // VAS 아이템 ID
    private(set) var uguid_typ_cd:String? = nil   // 이용안내 가이드 유형 코드
    private(set) var uguid_title:String? = nil    // 이용안내 가이드 제목
    private(set) var uguid_expl:String? = nil // 이용안내 가이드 설명
    private(set) var uguid_epsd_rslu_id:String? = nil // 이용안내 가이드 동영상 에피소드 해상도 ID
    private(set) var evt_exps_loc_cd:String? = nil    // 이벤트노출위치코드 10-앞, 20-뒤
    private(set) var guide_imgs:Array<ImagePathItem>? = nil // 이용안내 가이드 이미지 목록
    private(set) var spbub_nm:String? = nil   // 말풍선명(M BTV)
    private(set) var btm_menu_tree_exps_yn:String? = nil  // 하위 메뉴 tree 노출 여부
    private(set) var prvw_orgnz_yn:String? = nil  // 미리보기 편성 여부(M BTV) 콘텐츠블록일때 공개예정 여부
    private(set) var btm_bnr_blk_exps_cd:String? = nil    // 하위 배너 블록 노출 코드(M BTV) 01: 기본(사각형), 02: 동그라미(대), 03: 동그라미(중), 04: 동그라미(소)
    private(set) var gnb_sub_typ_cd:String? = nil   // GNB 서브 유형 코드(모바일 BTV GNB 코드)
    private(set) var ppm_join_on_img_path:String? = nil   // 월정액가입이미지경로(On)
    private(set) var ppm_join_off_img_path:String? = nil   // 월정액가입이미지경로(Off)
    private(set) var menu_on_img_path:String? = nil   // 메뉴 아이콘/뱃지(Over)
    private(set) var menu_off_img_path:String? = nil  // 메뉴 아이콘/뱃지(Normal)
    private(set) var menu_selected_img_path:String? = nil // 메뉴 아이콘/뱃지(Selected)
    private(set) var menu_on_img_path2:String? = nil   // 메뉴 아이콘/뱃지2(Over)
    private(set) var menu_off_img_path2:String? = nil  // 메뉴 아이콘/뱃지2(Normal)
    private(set) var menu_selected_img_path2:String? = nil // 메뉴 아이콘/뱃지2(Selected)
    private(set) var blocks:Array<BlockItem>? = nil // 블록 목록
}
