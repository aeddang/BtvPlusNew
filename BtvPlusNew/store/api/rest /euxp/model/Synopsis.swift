//
//  Synopsis.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/09.
//

import Foundation

struct Synopsis : Codable {
    private(set) var contents: SynopsisContentsItem? = nil
    private(set) var purchares: Array<PurchasItem>? = nil
    private(set) var series: Array<SeriesItem>? = nil
}

struct SynopsisContentsItem : Codable {
    private(set) var title_img_path:String? = nil   // 타이틀 이미지 경로(대표 하나만)
    private(set) var next_sris_id:String? = nil // 다음 시즌 시리즈 ID
    private(set) var sris_sales_vas_svc_id:String? = nil    // 세일즈 VAS 서비스 ID
    private(set) var sson_choic_nm:String? = nil   // 시즌명
    private(set) var brcast_chnl_nm:String? = nil   // 방송채널명
    private(set) var epsd_id:String? = nil  // 에피소드ID
    private(set) var sris_poster_filename_v:String? = nil   // 시즌 세로 포스터(히어로 이미지 없을 경우 노출용)
    private(set) var epsd_rslu_info:Array<EpsdRsluInfo>? = nil  // 에피소드 해상도 정보 (대상: 본편, 예고편/스페셜 제외)
    private(set) var epsd_snss_cts:String? = nil  // 줄거리
    private(set) var sris_sales_comt_cts:String? = nil  // 세일즈 코멘트 내용
    private(set) var aprc_pt_cts:String? = nil  // 감상 포인트
    private(set) var wat_lvl_cd:String? = nil  // 시청등급코드
    private(set) var sris_sales_comt_call_url:String? = nil  // 세일즈 코멘트 호출 URL
    private(set) var peoples:Array<PeoplesItem>? = nil    // 인물목록
    private(set) var open_yr:String? = nil  // 개봉연도
    private(set) var epsd_evt_comt_call_url:String? = nil  // 이벤트 코멘트 호출 URL
    private(set) var sris_poster_filename_h:String? = nil  // 시즌 가로 포스터(히어로 이미지 없을 경우 노출용)
    private(set) var brcast_tseq_nm:String? = nil  // 방송회차
    private(set) var epsd_sales_vas_svc_id:String? = nil  // 세일즈 VAS 서비스 ID
    private(set) var sris_id:String? = nil  // 시리즈ID
    private(set) var sris_typ_cd:String? = nil  // 시리즈 유형 코드
    private(set) var epsd_sales_comt_cts:String? = nil  // 세일즈 코멘트 내용
    private(set) var director:String? = nil  // 감독(최대 2명)
    private(set) var epsd_sales_comt_call_typ_cd:String? = nil  // 세일즈 코멘트 호출 유형 코드
    private(set) var epsd_evt_vas_itm_id:String? = nil  // 이벤트 VAS 아이템 ID
    private(set) var aprc_pt_cts_colr_val:String? = nil  // 감상 포인트 글자색
    private(set) var sris_sales_comt_call_typ_cd:String? = nil  // 세일즈 코멘트 호출 유형 코드
    private(set) var sris_evt_comt_call_objt_id:String? = nil  // 이벤트 코멘트 호출 오브젝트 ID
    private(set) var sris_sales_comt_call_objt_id:String? = nil  // 세일즈 코멘트 호출 오브젝트 ID
    private(set) var cacbro_cts:String? = nil  // 결방 코멘트
    private(set) var sris_evt_comt_cts:String? = nil  // 이벤트 코멘트 내용
    private(set) var stillCut:Array<ImagePathItem>? = nil  // 스틸컷 목록
    private(set) var snd_typ_cd:String? = nil  // 음질
    private(set) var epsd_sales_comt_exps_mthd_cd:String? = nil  // 세일즈 코멘트 노출 방식
    private(set) var next_epsd_id:String? = nil  // 다음 시즌 에피소드 ID
    private(set) var play_tms_val:String? = nil  // 러닝타임
    private(set) var sris_sales_comt_exps_mthd_cd:String? = nil  // 세일즈 코멘트 노출 방식
    private(set) var sris_sales_comt_title:String? = nil  // 세일즈 코멘트 제목
    private(set) var rslu_typ_cd:String? = nil  // 해상도 유형 코드
    private(set) var epsd_evt_comt_cts:String? = nil  // 이벤트 코멘트 내용
    private(set) var site_review:SiteReviewItem? = nil  //
    private(set) var kids_yn:String? = nil  // 키즈 시놉 여부
    private(set) var guest:String? = nil  // 게스트
    private(set) var sris_evt_comt_call_typ_cd:String? = nil  // 이벤트 코멘트 호출 유형 코드
    private(set) var mtx_capt_yn:String? = nil  // 다중 자막 여부
    private(set) var epsd_sales_comt_img_path:String? = nil  // 세일즈 코멘트 이미지 경로
    private(set) var cacbro_yn:String? = nil  // 결방여부
    private(set) var cacbro_cd:String? = nil  // 결방코드(방송중단코드)
    private(set) var preview:Array<PreviewItem>? = nil  // 예고편 목록
    private(set) var sris_evt_comt_exps_mthd_cd:String? = nil  // 이벤트 코멘트 노출 방식
    private(set) var sris_evt_comt_title:String? = nil  // 이벤트 코멘트 제목
    private(set) var sris_sales_comt_img_path:String? = nil  // 세일즈 코멘트 이미지 경로
    private(set) var bg_img_path:String? = nil  // 배경이미지(정보영역 BG에 추가됨.)
    private(set) var title:String? = nil  // 타이틀
    private(set) var epsd_evt_comt_img_path:String? = nil  // 이벤트 코멘트 이미지 경로
    private(set) var sris_evt_vas_svc_id:String? = nil  // 이벤트 VAS 서비스 ID
    private(set) var chrtr:String? = nil  // 등장 캐릭터
    private(set) var tpcc_comt:String? = nil  // 화제성 코멘트
    private(set) var sris_evt_comt_scn_mthd_cd:String? = nil  // 이벤트 코멘트 상영 방식 코드
    private(set) var sris_sales_comt_scn_mthd_cd:String? = nil  // 세일즈 코멘트 상영 방식 코드
    private(set) var epsd_evt_comt_scn_mthd_cd:String? = nil  // 이벤트 코멘트 상영 방식 코드
    private(set) var epsd_sales_comt_scn_mthd_cd:String? = nil  // 세일즈 코멘트 상영 방식 코드
    private(set) var lag_capt_typ_exps_yn:String? = nil  // 언어 자막 유형 노출 여부
    private(set) var brcast_avl_perd_yn:String? = nil  // 방송 유효 기간 여부
    private(set) var products:Array<ProductItem>? = nil  // 상품정보
    private(set) var epsd_sales_comt_call_objt_id:String? = nil  // 세일즈 코멘트 호출 오브젝트 ID
    private(set) var corners:Array<CornersItem>? = nil  // 코너 목록
    private(set) var prev_sris_id:String? = nil  // 이전 시즌 시리즈 ID
    private(set) var epsd_sales_comt_title:String? = nil  // 세일즈 코멘트 제목
    private(set) var epsd_evt_comt_title:String? = nil  // 이벤트 코멘트 제목
    private(set) var epsd_sales_comt_call_url:String? = nil  // 세일즈 코멘트 호출 URL
    private(set) var meta_title_colr_val:String? = nil  // 타이틀 색상(WORD ART 글자색)
    private(set) var brcast_dy:String? = nil  // 방송일자
    private(set) var adlt_lvl_cd:String? = nil  // 성인등급코드
    private(set) var epsd_poster_filename_h:String? = nil  // 회차 가로 포스터
    private(set) var sris_evt_comt_call_url:String? = nil  // 이벤트 코멘트 호출 URL
    private(set) var epsd_evt_comt_call_typ_cd:String? = nil  // 이벤트 코멘트 호출 유형 코드
    private(set) var epsd_evt_vas_svc_id:String? = nil  // 이벤트 VAS 서비스 ID
    private(set) var epsd_evt_comt_call_objt_id:String? = nil  // 이벤트 코멘트 호출 오브젝트 ID
    private(set) var meta_typ_cd:String? = nil  // 메타 유형 코드(콘텐츠 유형)
    private(set) var sub_title:String? = nil  // 부제목
    private(set) var brcast_exps_dy:String? = nil  // 방송노출일자
    private(set) var sris_evt_vas_itm_id:String? = nil  // 이벤트 VAS 아이템 ID
    private(set) var epsd_poster_filename_v:String? = nil  // 회차 세로 포스터
    private(set) var sris_sales_vas_itm_id:String? = nil  // 세일즈 VAS 아이템 ID
    private(set) var nscrn_yn:String? = nil  // Nscreen 여부
    private(set) var prev_epsd_id:String? = nil  // 다음 시즌 에피소드 ID
    private(set) var sris_snss_cts:String? = nil  // 줄거리
    private(set) var actor:String? = nil  // 출연(최대 5명)
    private(set) var epsd_evt_comt_exps_mthd_cd:String? = nil  // 이벤트 코멘트 노출 방식
    private(set) var sris_evt_comt_img_path:String? = nil  // 이벤트 코멘트 이미지 경로
    private(set) var series_info:Array<SeriesInfoItem>? = nil  // 시리즈 정보
    //private(set) var poss_bg_img:String? = nil  // 소장용 배경이미지
    //private(set) var poss_bg_img:Array<ImagePathItem>? = nil  // 소장용 배경이미지
    private(set) var dark_img_yn:String? = nil  // 배경이미지 명암여부(어두운지 안어두운지)
    private(set) var combine_product_yn:String? = nil  // 결합상품 사용여부(방송중단코드가 공급중단(SS)인 경우
    private(set) var session_id:String? = nil  // 세션아이디 (추천결과 수집용)
    private(set) var cw_call_id:String? = nil  // 페이지아이디(추천결과 수집용)
    private(set) var track_id:String? = nil  // 트랙아이디 (추천결과 수집용)
    private(set) var cw_call_id_val:String? = nil  // CW 콜 아이디
    private(set) var pcim_dimn_cd:String? = nil  // 영상 차원 코드(Null :2D, 20 : 3D, 30 : 360VR)
    private(set) var svc_fr_dt:String? = nil  // 서비스 시작일
    private(set) var svc_to_dt:String? = nil  // 서비스 종료일
    private(set) var gstn_yn:String? = nil  // 맛보기여부
    private(set) var dist_sts_cd:String? = nil  // 배포상태코드
    private(set) var has_inside_meta:String? = nil  // 00 or null 미존재, 10 존재
    private(set) var menu_id:String? = nil  // 메뉴ID
    private(set) var ending_cw_call_id_val:String? = nil  // 엔딩시놉시스 CW CALL ID
    private(set) var sris_cmpt_yn:String? = nil  // 시리즈 완료 여부
    private(set) var meta_sub_typ_cd:String? = nil  // 메타 서브 유형 코드 (00501: 일반, 00502 캐릭터 AI) (null일 경우 일반으로 처리)
    private(set) var chrtr_ai_typ_cd:String? = nil  // 캐릭터 AI 유형 코드 (10:분기형, 20:퀴즈형, 30:선택형, 40: 추리형)
    private(set) var first_sris_id:String? = nil  // 첫번째 시리즈 ID
    private(set) var last_sris_id:String? = nil  // 마지막 시리즈 ID
    private(set) var has_scene_meta:String? = nil  // 00 or null 미존재, 10 존재
    private(set) var pre_exam_yn:String? = nil  // 미리보기여부
    private(set) var smtn_wat_abl_yn:String? = nil  // 동시시청 가능 여부 Y/N
    private(set) var contrp_id:String? = nil  // CP 계약 코드
    private(set) var vc_bg_img_path:String? = nil
    private(set) var vc_dark_img_yn:String? = nil
    private(set) var epsd_sales_vas_itm_id:String? = nil //
    private(set) var orgn_epsd_id: String? = nil // 클립 영상의 본편 에피소드 id
    private(set) var manufco_nm: String? = nil // 제작사명
    private(set) var pcim_lvl_cls_no: String? = nil   // 영상등급분류번호
    private(set) var pcim_lvl_cls_dy: String? = nil   // 영상등급분류일자
    private(set) var pcim_lvl1_exps_yn: String? = nil   // 영상등급1노출여부
    private(set) var pcim_lvl2_exps_yn: String? = nil   // 영상등급2노출여부
    private(set) var pcim_lvl3_exps_yn: String? = nil   // 영상등급3노출여부
    private(set) var pcim_lvl4_exps_yn: String? = nil   // 영상등급4노출여부
    private(set) var pcim_lvl5_exps_yn: String? = nil   // 영상등급5노출여부
    private(set) var pcim_lvl6_exps_yn: String? = nil   // 영상등급6노출여부
    private(set) var pcim_lvl7_exps_yn: String? = nil   // 영상등급7노출여부
    private(set) var pcim_lvl1_wat_age_cd: String? = nil   // 영상등급1시청연령코드(0:낮음, 12:보통, 15:다소높음, 19:높음)
    private(set) var pcim_lvl2_wat_age_cd: String? = nil   // 영상등급2시청연령코드(0:낮음, 12:보통, 15:다소높음, 19:높음)
    private(set) var pcim_lvl3_wat_age_cd: String? = nil   // 영상등급3시청연령코드(0:낮음, 12:보통, 15:다소높음, 19:높음)
    private(set) var pcim_lvl4_wat_age_cd: String? = nil   // 영상등급4시청연령코드(0:낮음, 12:보통, 15:다소높음, 19:높음)
    private(set) var pcim_lvl5_wat_age_cd: String? = nil   // 영상등급5시청연령코드(0:낮음, 12:보통, 15:다소높음, 19:높음)
    private(set) var pcim_lvl6_wat_age_cd: String? = nil   // 영상등급6시청연령코드(0:낮음, 12:보통, 15:다소높음, 19:높음)
    private(set) var pcim_lvl7_wat_age_cd: String? = nil   // 영상등급7시청연령코드(0:낮음, 12:보통, 15:다소높음, 19:높음)
    private(set) var wat_lvl_phrs: String? = nil   // 시청등급문구
    
    
}

struct EpsdRsluInfo: Codable {
    private(set) var epsd_rslu_id:String? = nil   // 에피소드 해상도 ID
    private(set) var rslu_typ_cd:String? = nil   // 해상도 유형 코드
    private(set) var lag_capt_typ_cd:String? = nil   // 언어자막유형코드
    private(set) var possn_yn:String? = nil   // 소장여부
    private(set) var openg_tmtag_tmsc:DynamicValue? = nil   // 오프닝 타임태그 시간초
    private(set) var endg_tmtag_tmsc:DynamicValue? = nil   // 엔딩 타임태그 시간초
    private(set) var capt_yn:String? = nil   // 자막사용여부
    private(set) var capt_svc_file_path:String? = nil   // 자막 파일 경로
    private(set) var mtx_capt_yn:String? = nil   // 다중자막여부
    private(set) var mtx_capt_svc_file_path:String? = nil   // 다중자막 파일 경로
    private(set) var prd_prc_fr_dt:String? = nil   // 상품 가격 시작일
    private(set) var prd_prc_to_dt:String? = nil   // 상품 가격 종료일
    private(set) var matl_sts_cd:String? = nil   // 해상도 소재 상태 코드
    //private(set) var capt_lans:Array<Any>? = nil   // 다중자막 언어 목록
}

struct PeoplesItem : Codable{
    private(set) var prs_id:String? = nil   // 인물ID
    private(set) var img_path:String? = nil   // 인물 사진 이미지 경로
    private(set) var prs_nm:String? = nil   // 인물명
    private(set) var prs_role_nm:String? = nil   // 역할명
    private(set) var prs_plrl_nm:String? = nil   // 배역명
    private(set) var brth_ymd:String? = nil   // 생년월일
    private(set) var sort_seq:Int? = nil   // 정렬순서
    private(set) var prs_role_cd:String? = nil   // 인물역할코드
}

struct SiteReviewItem : Codable{
    private(set) var sris_id:String? = nil   // 시리즈ID
    private(set) var sites:Array<SiteReviewSitesItem>? = nil  // 평점사이트 목록
    private(set) var btv_pnt_info:Array<SiteReviewBtvPntInfoItem>? = nil
    private(set) var prize_history:Array<SiteReviewPrizeHistoryItem>? = nil    // 수상정보
}

struct SiteReviewSitesReviewsItem : Codable{
    private(set) var prs_nm:String? = nil   // 인물명
    private(set) var pnt:Double? = nil   // 평점
    private(set) var review_ctsc:String? = nil  // 리뷰 내용
}

struct SiteReviewSitesDistInfoItem : Codable{
    private(set) var pnt:Double? = nil   // 평점
    private(set) var dist_rate:Double? = nil   // 분포율
}

struct SiteReviewSitesItem : Codable{
    private(set) var bas_pnt:Double? = nil   // 기준평점
    private(set) var site_cd:String? = nil   // 평점사이트 코드
    private(set) var review_cnt:Double? = nil   // 평가자 수
    private(set) var reviewsArray:Array<SiteReviewSitesReviewsItem>? = nil   // 리뷰 정보
    private(set) var dist_infoArray:Array<SiteReviewSitesDistInfoItem>? = nil   // 평점 분포 정보
    private(set) var avg_pnt:Double? = nil  // 평균 평점
    private(set) var site_nm:String? = nil   // 평점사이트 명
}

struct SiteReviewBtvPntInfoItem : Codable{
    private(set) var btv_like_ncnt:Double? = nil   // 좋아요 카운트
    private(set) var btv_like_rate:Double? = nil   // 좋아요 비율
    private(set) var btv_ngood_ncnt:Double? = nil   // 별로에요 카운트
    private(set) var btv_ngood_rate:Double? = nil   // 별로에요 비율
    private(set) var btv_pnt:Double? = nil   // Btv 포인트
}

struct SiteReviewPrizeHistoryItem : Codable{
    private(set) var awrdc_nm:String? = nil    // 시상식명(시상식 회차 포함)
    private(set) var prize_yr:String? = nil    // 시상년도
    private(set) var prize_dts_cts:String? = nil    // 수상내역
    private(set) var rep_yn:String? = nil    // 대표여부
}

struct PreviewItem : Codable{
    private(set) var prd_prc_id:String? = nil   // 상품가격ID
    private(set) var pcim_addn_typ_nm:String? = nil   // 예고편 분류명
    private(set) var epsd_rslu_id:String? = nil   // 에피소드 해상도 ID
    private(set) var img_path:String? = nil   // 포스터 이미지 경로
    private(set) var title:String? = nil   // 제목
    private(set) var play_tms_val:String? = nil   // 재생시간
}


struct ProductItem : Codable{
    private(set) var epsd_id:String? = nil   // 에피소드ID
    private(set) var epsd_rslu_id:String? = nil   // 에피소드 해상도 ID
    private(set) var rslu_typ_cd:String? = nil   // 해상도 유형 코드
    private(set) var prd_typ_cd:String? = nil   // 상품유형코드
    private(set) var asis_prd_typ_cd:String? = nil   // AS-IS 상품 유형 코드
    private(set) var prd_prc_id:String? = nil   // 상품가격 ID
    private(set) var prd_prc:Double? = nil   // 상품가격(원가격)
    private(set) var prd_prc_vat:Double? = nil   // 상품가격(원가격) 부가세 포함
    private(set) var sale_prc:Double? = nil   // 판매가격
    private(set) var sale_prc_vat:Double? = nil   // 판매가격 부가세 포함
    private(set) var ppm_orgnz_fr_dt:String? = nil   // 프리미어편성예정일
    private(set) var ppm_orgnz_to_dt:String? = nil   // 프리미어편성종료일
    private(set) var svc_to_dt:String? = nil   // 서비스 종료일
    private(set) var prd_prc_fr_dt:String? = nil   // 상품 가격 시작일
    private(set) var prd_prc_to_dt:String? = nil   // 상품 가격 종료일
    private(set) var expire_prd_prc_dt:String? = nil   // 콘텐츠 종료일
    private(set) var purc_wat_to_dt:String? = nil   // 상품 시청 종료일
    private(set) var next_prd_prc_fr_dt:String? = nil   // 가격변경일
    private(set) var nscrn_yn:String? = nil   // Nscreen 여부
    private(set) var possn_yn:String? = nil   // 소장여부
    private(set) var purc_pref_rank:String? = nil   // 구매우선순위
    private(set) var use_yn:String? = nil   // 사용여부
    private(set) var brcast_avl_perd_yn:String? = nil   // 방송 유효 기간 여부
    private(set) var purc_wat_dd_fg_cd:String? = nil   // 구매시청일구분코드(10:일,20:주,30:년,40:월)
    private(set) var purc_wat_dd_cnt:Int? = nil   // 구매실청일수
    private(set) var poc_det_typ_cd_list:Array<String>? = nil // POC 상세 유형 코드 리스트 코드값 추가 ( 101 - Btv, 102-MBtv )
    private(set) var sale_tgt_fg_yn:String? = nil //판매대상구분여부
}


struct CornersItem : Codable{
    private(set) var cnr_id:String? = nil   // 코너 ID
    private(set) var cnr_nm:String? = nil   // 코너 명
    private(set) var epsd_rslu_id:String? = nil   // 에피소드 해상도 ID
    private(set) var img_path:String? = nil   // 시작 서비스 이미지 파일
    private(set) var wat_fr_byte_val:String? = nil   // 시청 시작 바이트 값
    private(set) var tmtag_fr_tmsc:Double? = nil   // 타임 태그 시작 시각
    private(set) var sort_seq:Int? = nil   // 정렬순서
    private(set) var cnr_grp_id:String? = nil   // 코너 그룹 ID
    private(set) var cnr_btm_nm:String? = nil     // 코너 하위 명
    private(set) var cnr_typ_cd:String? = nil     // 코너 유형 코드(1.코너, 3.OCR코드)
}

struct SeriesInfoItem : Codable{

    private(set) var poster_filename_h:String? = nil    // 가로 포스터
    private(set) var poster_filename_v:String? = nil    // 세로 포스터
    private(set) var epsd_id:String? = nil    // 에피소드ID
    private(set) var brcast_tseq_nm:String? = nil    // 방송회차
    private(set) var cacbro_yn:String? = nil    // 결방여부
    private(set) var svc_fr_dt:String? = nil    // 서비스 시작일
    private(set) var svc_to_dt:String? = nil    // 서비스 종료일
    private(set) var dist_sts_cd:String? = nil    // 배포상태코드
    private(set) var sort_seq:Int? = nil        // 178
    private(set) var play_tms_val:String? = nil    // "94"
    private(set) var sub_title:String? = nil       // "아이즈원"
    private(set) var brcast_exps_dy:String? = nil  // "19.05.04 (토)"
    private(set) var sale_prc_vat:Double? = nil  // 판매가격 부가세 포함

}

struct PurchasItem : Codable{
    private(set) var prd_prc_id:String? = nil  // 상품ID
    private(set) var prd_typ_cd:String? = nil  // 상품 유형 코드
    private(set) var asis_prd_typ_cd:String? = nil  // AS-IS 상품유형코드
    private(set) var sale_prc:Double? = nil  // 판매가격
    private(set) var use_yn:String? = nil  // 사용여부
    private(set) var epsd_id:String? = nil  // 에피소드ID
    private(set) var ppm_orgnz_fr_dt:String? = nil  // 프리미어편성예정일
    private(set) var purc_wat_to_dt:String? = nil  // 상품 시청 종료일
    private(set) var nscrn_yn:String? = nil  // Nscreen 여부
    private(set) var prd_prc_to_dt:String? = nil  // 상품 가격 종료일
    private(set) var expire_prd_prc_dt:String? = nil  // 콘텐츠 종료일
    private(set) var sale_prc_vat:Double? = nil  // 판매가격 부가세 포함
    private(set) var prd_prc:Double? = nil  // 상품가격(원가격)
    private(set) var epsd_rslu_id:String? = nil  // 해상도 아이디
    private(set) var rslu_typ_cd:String? = nil  // 화질
    private(set) var possn_yn:String? = nil  // 소장여부
    private(set) var prd_prc_fr_dt:String? = nil  // 상품 가격 시작일
    private(set) var ppm_orgnz_to_dt:String? = nil  // 프리미어편성종료일
    private(set) var purc_pref_rank:String? = nil  // 구매우선순위
    private(set) var next_prd_prc_fr_dt:String? = nil  // 가격변경일
    private(set) var lag_capt_typ_cd:String? = nil  // 언어자막유형코드
    private(set) var prd_prc_vat:Double? = nil  // 상품가격(원가격) 부가세 포함
    private(set) var sris_id:String? = nil  // 시리즈ID
    private(set) var lag_capt_typ_exps_yn:String? = nil  // 언어 자막 유형 노출 여부
    private(set) var brcast_avl_perd_yn:String? = nil  // 방송 유효 기간 여부
    private(set) var purc_wat_dd_fg_cd:String? = nil  // 구매시청일구분코드(10:일,20:주,30:년,40:월)
    private(set) var purc_wat_dd_cnt:Int? = nil  //구매실청일수
    private(set) var ppm_synop_icon_img_path:String? = nil    // PPM아이콘이미지경로(시놉)
    private(set) var ppm_prd_nm:String? = nil // PPM상품명
    private(set) var ppm_prd_typ_cd:String? = nil // PPM상품유형코드
    private(set) var poc_det_typ_cd_list:[String]? = nil // POC 상세 유형 코드 리스트 코드값 추가 ( 101 - Btv, 102-MBtv )
    private(set) var sale_tgt_fg_yn:String? = nil //판매대상구분여부
}

struct SeriesItem : Codable{
    private(set) var sris_id:String? = nil  // 시리즈ID
    private(set) var sson_choic_nm:String? = nil  // 시즌선택명
    private(set) var epsd_id:String? = nil  // 에피소드ID(첫번째 에피소드 ID)
    private(set) var sort_seq:Int? = nil  // 정렬순번(시즌 번호)

}
