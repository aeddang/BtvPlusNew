//
//  SearchCategory.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/22.
//

import Foundation
struct SearchCategory : Decodable {
    private(set) var statusCode: String? = nil    // 요청 결과.
    private(set) var statusMessage: String? = nil
    private(set) var data:SearchCategoryResult? = nil
}


struct SearchCategoryResult : Decodable {
    private(set) var result: String? = nil    // 요청 결과.
    private(set) var category: [CategoryItem]? = nil
    private(set) var results_vod: [CategoryVodItem]? = nil
    private(set) var results_vod_tseq: [CategorySrisItem]? = nil
    private(set) var results_corner: [CategoryCornerItem]? = nil
    private(set) var results_people: [CategoryPeopleItem]? = nil
    private(set) var results_clip: [CategoryClipItem]? = nil
    private(set) var results_tv: [CategoryTvItem]? = nil
}

struct CategoryItem : Decodable {
    private(set) var count: Int? = nil
    private(set) var code: String? = nil
    private(set) var title: String? = nil
}

struct CategoryVodItem : Decodable {
    private(set) var duplicate_id: String? = nil
    private(set) var epsd_id: String? = nil
    private(set) var code: String? = nil
    private(set) var sris_cmpt_yn: String? = nil
    private(set) var meta_typ_cd: String? = nil
    private(set) var level: String? = nil
    private(set) var poster: String? = nil
    private(set) var price: String? = nil
    private(set) var title: String? = nil
    private(set) var price_use_yn: String? = nil
    private(set) var synon_typ_cd: String? = nil
    private(set) var epsd_rslu_id: String? = nil
    private(set) var poster_tseq: String? = nil
    private(set) var svc_fr_dt: String? = nil
    private(set) var badge_img: String? = nil
    private(set) var price_sris: String? = nil
    private(set) var poster_flag: String? = nil
    private(set) var svc_yn: String? = nil
    private(set) var hd_flag: String? = nil
}

struct CategorySrisItem : Decodable {
    private(set) var badge_img: String? = nil
    private(set) var code: String? = nil
    private(set) var duplicate_id: String? = nil
    private(set) var epsd_id: String? = nil
    private(set) var epsd_rslu_id: String? = nil
    private(set) var level: String? = nil
    private(set) var meta_typ_cd: String? = nil
    private(set) var poster: String?
    private(set) var poster_flag: String? = nil
    private(set) var poster_tseq: String? = nil
    private(set) var price: String? = nil
    private(set) var price_use_yn: String? = nil
    private(set) var synon_typ_cd: String? = nil
    private(set) var title: String? = nil
    private(set) var title_sub: String? = nil
}

struct CategoryCornerItem : Decodable {
    private(set) var cnr_id: String? = nil
    private(set) var code: String? = nil
    private(set) var group_id: String? = nil
    private(set) var epsd_id: String? = nil
    private(set) var epsd_rslu_id: String? = nil
    private(set) var level: String? = nil
    private(set) var hd_flag: String? = nil
    private(set) var main_title: String? = nil
    private(set) var ocr_title: String? = nil
    private(set) var section_flag: String? = nil
    private(set) var start_time: String? = nil
    private(set) var thumb: String? = nil
    private(set) var title: String? = nil
}

struct CategoryClipItem : Decodable {
    private(set) var synon_typ_cd: String? = nil
    private(set) var code: String? = nil
    private(set) var epsd_id: String? = nil
    private(set) var epsd_rslu_id: String? = nil
    private(set) var level: String? = nil
    private(set) var hd_flag: String? = nil
    private(set) var no_epsd: String? = nil
    private(set) var running_time: String? = nil
    private(set) var sris_cmpt_yn: String? = nil
    private(set) var title_sris: String? = nil
    private(set) var thumb: String? = nil
    private(set) var title: String? = nil
}

struct CategoryPeopleItem : Decodable {
    private(set) var birth: String? = nil
    private(set) var code: String? = nil
    private(set) var job: String? = nil
    private(set) var prs_id: String? = nil
    private(set) var title: String? = nil
}

struct CategoryTvItem : Decodable {
    private(set) var code: String? = nil
    private(set) var idx: Int? = nil
    private(set) var level: String? = nil
    private(set) var start_time: String? = nil
    private(set) var end_time: String? = nil
    private(set) var thumb: String? = nil
    private(set) var thumb_live: String? = nil
    private(set) var channel_name: String? = nil
    private(set) var title: String? = nil
    private(set) var con_id: String? = nil
    private(set) var hd_flag: String? = nil
    private(set) var channel_code: String? = nil
}


