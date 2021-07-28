//
//  SearchVod.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/22.
//

import Foundation
struct SearchPopularityVod : Decodable {
    private(set) var statusCode: String? = nil    // 요청 결과.
    private(set) var statusMessage: String? = nil
    private(set) var data:SearchPopularityVodResult? = nil
}


struct SearchPopularityVodResult : Decodable {
    private(set) var result: String? = nil   // 요청 결과.
    private(set) var results_vod: [SearchPopularityVodItem]? = nil
}

struct SearchPopularityVodItem : Decodable {
    private(set) var epsd_id: String? = nil
    private(set) var epsd_rslu_id: String? = nil
    private(set) var level: String? = nil
    private(set) var poster: String? = nil
    private(set) var synon_typ_cd: String? = nil
    private(set) var title: String? = nil
}
