//
//  SearchVod.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/22.
//

import Foundation
struct SearchPopularityVod : Decodable {
    private(set) var statusCode: String?    // 요청 결과.
    private(set) var statusMessage: String?
    private(set) var data:SearchPopularityVodResult?
}


struct SearchPopularityVodResult : Decodable {
    private(set) var result: String?    // 요청 결과.
    private(set) var results_vod: [SearchPopularityVodItem]?
}

struct SearchPopularityVodItem : Decodable {
    private(set) var epsd_id: String?
    private(set) var epsd_rslu_id: String?
    private(set) var level: String?
    private(set) var poster: String?
    private(set) var synon_typ_cd: String?
    private(set) var title: String?
}
