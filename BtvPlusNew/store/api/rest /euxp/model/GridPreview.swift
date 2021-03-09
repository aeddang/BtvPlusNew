//
//  GridPreview.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/10.
//

import Foundation
struct GridPreview : Codable {
    private(set) var total_count:Int? = 0 // 카운트 값과 상관없이 전체 그리드 개수
    private(set) var contents:Array<PreviewContentsItem>? = nil // 메뉴 ID(콘텐츠 블럭을 가진 메뉴ID)
    private(set) var menu_id:String? = nil // 메뉴 ID
}


struct PreviewContentsItem : Codable {
    private(set) var sris_id:String? = nil    // 시리즈 ID
    private(set) var sort_seq:Int? = 0   // 정렬순서
    private(set) var title:String? = nil  // 제목
    private(set) var epsd_id:String? = nil    // 에피소드 ID
    private(set) var wat_lvl_cd:String? = nil // 시청등급코드
    private(set) var adlt_lvl_cd:String? = nil    // 성인등급코드
    private(set) var poster_filename_h:String? = nil  // 가로 포스터
    private(set) var poster_filename_v:String? = nil  // 세로 포스터
    private(set) var meta_typ_cd:String? = nil    // 메타 유형 코드
    private(set) var kids_yn:String? = nil    // 키즈 시놉 여부
    private(set) var release_dt:String? = nil  // 출시일시(본편출시일시)
    private(set) var meta_sub_typ_cd:String? = nil    // 메타 서브 유형 코드 (00501: 일반, 00502 캐릭터 AI)
    private(set) var epsd_rslu_id:String? = nil   // 에피소드 해상도 ID
    private(set) var play_tms_val:String? = nil   // 재생시간
    private(set) var prd_id:String? = nil     // 상품ID (빅배너/이벤트 내 월정액 상품 추가)
    private(set) var ppm_grid_icon_img_path:String? = nil      // PPM아이콘이미지경로(그리드)
    private(set) var prd_typ_cd:String? = nil     // 상품유형코드
    
    private(set) var epsd_snss_cts:String? = nil  // 에피소드 줄거리
    private(set) var sris_dist_aprv_yn:String? = nil  // 본편 배포 승인 여부 (Y=배포승인 + 시작일 경과)
    private(set) var synon_typ_cd:String? = nil  // 진입할 시놉시스 유형(타이틀/단편/시즌/컬렉션/VOD+관련상품)
}
