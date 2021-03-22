//
//  SearchCategory.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/22.
//

import Foundation
struct SearchCategory : Decodable {
    private(set) var statusCode: String?    // 요청 결과.
    private(set) var statusMessage: String?
    private(set) var data:SearchCategoryResult?
}


struct SearchCategoryResult : Decodable {
    private(set) var result: String?    // 요청 결과.
    private(set) var category: [CategoryItem]?
    private(set) var results_vod: [CategoryVodItem]?
    private(set) var results_vod_tseq: [CategorySrisItem]?
    private(set) var results_corner: [CategoryCornerItem]?
    private(set) var results_people: [CategoryPeopleItem]?
}

struct CategoryItem : Decodable {
    private(set) var count: Int?
    private(set) var code: String?
    private(set) var title: String?
}

struct CategoryVodItem : Decodable {
    private(set) var duplicate_id: String?
    private(set) var epsd_id: String?
    private(set) var code: String?
    private(set) var sris_cmpt_yn: String?
    private(set) var meta_typ_cdd: String?
    private(set) var level: String?
    private(set) var poster: String?
    private(set) var price: String?
    private(set) var title: String?
    private(set) var price_use_yn: String?
    private(set) var synon_typ_cd: String?
    private(set) var epsd_rslu_id: String?
    private(set) var poster_tseq: String?
    private(set) var svc_fr_dt: String?
    private(set) var badge_img: String?
    private(set) var price_sris: String?
    private(set) var poster_flag: String?
    private(set) var svc_yn: String?
    private(set) var hd_flag: String?
}

struct CategorySrisItem : Decodable {
    private(set) var badge_img: String?
    private(set) var code: String?
    private(set) var duplicate_id: String?
    private(set) var epsd_id: String?
    private(set) var epsd_rslu_id: String?
    private(set) var level: String?
    private(set) var meta_typ_cd: String?
    private(set) var poster: String?
    private(set) var poster_flag: String?
    private(set) var poster_tseq: String?
    private(set) var price: String?
    private(set) var price_use_yn: String?
    private(set) var synon_typ_cd: String?
    private(set) var title: String?
    private(set) var title_sub: String?
}

struct CategoryCornerItem : Decodable {
    private(set) var cnr_id: String?
    private(set) var code: String?
    private(set) var group_id: String?
    private(set) var epsd_id: String?
    private(set) var epsd_rslu_id: String?
    private(set) var level: String?
    private(set) var hd_flag: String?
    private(set) var main_title: String?
    private(set) var ocr_title: String?
    private(set) var section_flag: String?
    private(set) var start_time: String?
    private(set) var thumb: String?
    private(set) var title: String?
}

struct CategoryPeopleItem : Decodable {
    private(set) var birth: String?
    private(set) var code: String?
    private(set) var job: String?
    private(set) var prs_id: String?
    private(set) var title: String?
}


