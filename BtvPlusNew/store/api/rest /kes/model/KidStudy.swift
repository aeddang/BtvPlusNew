//
//  KidStudy.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/06.
//

import Foundation
struct KidStudy: Decodable {
    private(set) var recomm_menus_cnt: Int? = nil // recomm_menus 의 사이즈
    private(set) var recomm_menus: [RecommendMenu]? = nil // Zemkids my home 내의 추천 메뉴 정보들의 List <Object>
    private(set) var epsd_rslu_id: String? = nil// 에피소드 해상도 ID
    private(set) var epsd_ph_poster_url: String? = nil// 추천교육 (영어, 동화, 창의누리, 교과지식, 놀이활동) 에피소드 세로 영상 포스터 URL
    private(set)  var epsd_pw_poster_url: String? = nil// 추천교육 (영어, 동화, 창의누리, 교과지식, 놀이활동) 에피소드 가로 영상 포스터 URL
}



struct RecommendMenu: Decodable {
    private(set) var svc_prop_cd: String? = nil // "서비스 속성 코드
    private(set) var ph_poster_url: String? = nil// (공통코드 SVC_PROP_CD 참조)"
    private(set) var pw_poster_url: String? = nil// 추천교육 (영어, 동화, 창의누리, 교과지식, 놀이활동) 세로 영상 포스터 URL
    private(set) var is_test_result: String? = nil // 추천교육 (영어, 동화, 창의누리, 교과지식, 놀이활동) 가로 영상 포스터 URL
    private(set) var items_cnt: Int? = nil // "테스트 결과 존재 유무
    private(set) var items: [RecommendMenuItem]? = nil // 영어 : 영어 레벨 테스트 검사 유무
    private(set) var epsd_rslu_id: String? = nil // 에피소드 해상도 ID
    private(set) var epsd_ph_poster_url: String? = nil // 추천교육 (영어, 동화, 창의누리, 교과지식, 놀이활동) 에피소드 세로 영상 포스터 URL
    private(set) var epsd_pw_poster_url: String? = nil // 추천교육 (영어, 동화, 창의누리, 교과지식, 놀이활동) 에피소드 가로 영상 포스터 URL
    private(set) var epsd_thumbnail_url: String? = nil // 추천교육 (영어, 동화, 창의누리, 교과지식, 놀이활동) 에피소드 썸네일 URL
}

struct RecommendMenuItem: Decodable {
    private(set) var cw_id: String? = nil
    // "CW ID (확정)
    // KESV50101 선생님이 추천해요(영어)
    // KESV50102 최근에 봤어요(영어)
    // KESV50103 좋아하는 것이에요(영어)
    // KESV50104 친구들이 많이봐요(영어)
    // (공통코드 CW_ID 참조)"
    private(set) var scn_mthd_cd: String? = nil
    // "상영 방식 코드
    // (공통코드 SCN_MTHD_CD 참조)"
    private(set) var menu_title_add_info: String? = nil // 메뉴명 우측에 뒤 따르는 추가정보
    private(set) var recent_test_date: String? = nil // 최근 검사일 (YYYYMMDD)
    private(set) var test_result_sentence: String? = nil // 진단 결과 내용 (문장)
    private(set) var guidance_sentence: String? = nil // 프로필별 개인화 안내 문구
}
