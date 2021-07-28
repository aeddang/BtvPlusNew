//
//  KidsProfiles.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/06/28.
//

import Foundation

struct KidsProfiles : Decodable {
    private(set) var profiles_cnt: Int? = nil   // 프로필 전체 갯수
    private(set) var profiles:[KidsProfileItem]? = nil     //  프로필 목록
}

struct KidsProfileItem : Decodable {
    private(set) var profile_id: String? = nil // 프로필아이디   | request에서 수정, 삭제 시 필수 값
    private(set) var profile_nm: String? = nil // 프로필명      | (등록,수정 시 필수 값)
    private(set) var gender: String? = nil// 성별(M/F)        | (등록,수정 시 필수 값)
    private(set) var birth_ym: String? = nil   // 생년월(YYYYMM) | (등록,수정 시 필수 값)
    private(set) var age_y: Int? = nil // 나이 (단위 년)
    private(set) var age_m: Int? = nil // 나이 (단위 개월 수)
    private(set) var chrter_img_id: String? = nil  // 셋탑 캐릭터 이미지 아이디 | (등록,수정 시 필수 값)
    private(set) var prof_loc_val: DynamicValue? = nil // 프로필 위치 값 | (등록,수정 시 필수 값)
    private(set) var event_typ: String? = nil //- 작업구분 ( I: 등록, U:수정, D:삭제 ) - event_typ = 'U' or 'D' 일경우 profile_id 값 필수
}
