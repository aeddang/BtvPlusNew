//
//  InsideInfo.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/10.
//

import Foundation
struct InsideInfo : Decodable {
    private(set) var inside_info: InsideInfoData? = nil
}

struct InsideInfoData : Decodable {
    private(set) var epsd_id:String? = nil         // 에피소드 아이디
    private(set) var meta_id:String? = nil         // 메타 아이디
    private(set) var people_scenes:Array<InsidePeopleSceneItem>? = nil // 인물 등장 정보
    private(set) var scenes:Array<InsideSceneItem>? = nil              // 장면 정보
    private(set) var music_info:Array<InsideMusicInfoItem>? = nil      // 배경 음악 정보

}

struct InsidePeopleSceneItem : Decodable {
    private(set) var prs_id:String? = nil     // 아이디
    private(set) var img_path:String? = nil   // 이미지 경로
    private(set) var img_file_nm:String? = nil    // 이미지 파일명
    private(set) var person_scenes:Array<InsidePersonSceneItem>? = nil  // 장면 정보
}


struct InsidePersonSceneItem : Decodable {
    private(set) var scene_id:String? = nil   // 장면ID
    private(set) var prs_scne_dts_seq:String? = nil   // 장면순번
    private(set) var tmtag_fr_tmsc:String? = nil  // 장면시작시간
    private(set) var tmtag_to_tmsc:String? = nil  // 장면종료시간
    private(set) var img_path:String? = nil   // 이미지 경로
    private(set) var img_file_nm:String? = nil    // 이미지 경로명
}


struct InsideSceneItem : Decodable {
    private(set) var scene_id:String? = nil       // 장면ID
    private(set) var tmtag_to_tmsc:String? = nil  // 장면순번
    private(set) var scne_dts_seq:String? = nil   // 장면시작시간
    private(set) var tmtag_fr_tmsc:String? = nil  // 장면종료시간
    private(set) var scne_typ_code:String? = nil  // 10:오프닝 20:본편 30:엔딩 50:쿠키(50번 쿠키영상만 사용 해야 함)
    private(set) var img_path:String? = nil       // 쿠키영상 이미지경로
    private(set) var img_file_nm:String? = nil    // 쿠키영상 이미지 명
}

struct InsideMusicInfoItem : Decodable {

    private(set) var music_id:String? = nil       // 음원 아이디
    private(set) var music_title:String? = nil    // 음원 제목
    private(set) var album_nm:String? = nil   // 앨범 명
    private(set) var manuf_yr:String? = nil   // 제작년도
    private(set) var artist_nm:String? = nil  // 아티스트명
    private(set) var album_img_path:String? = nil // 앨범 이미지 경로
    private(set) var album_img_file_nm:String? = nil  // 앨범 이미지 파일명
    private(set) var scenes:Array<InsideMusicSceneItem>? = nil  // 장면 정보

}

struct InsideMusicSceneItem : Decodable {
    private(set) var scene_id:String? = nil   // 장면ID
    private(set) var music_scne_dts_seq:String? = nil // 장면 순번
    private(set) var tmtag_fr_tmsc:String? = nil  // 장면시작시간
    private(set) var tmtag_to_tmsc:String? = nil  // 장면종료시간
    private(set) var img_path:String? = nil   // 이미지 경로
    private(set) var img_file_nm:String? = nil    // 이미지 파일명
}
