//
//  SearchKeyword.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/22.
//

import Foundation

struct SearchKeyword : Decodable {
    private(set) var statusCode: String? = nil    // 요청 결과.
    private(set) var statusMessage: String? = nil
    private(set) var data:SearchKeywordResult? = nil
}


struct SearchKeywordResult : Decodable {
    private(set) var result: String? = nil    // 요청 결과.
    private(set) var reason: String? = nil
    private(set) var results_keyword: [SearchKeywordItem]? = nil
}

struct SearchKeywordItem : Decodable {
    private(set) var idx: Int? = nil    // 컨텐츠 시리즈아이디
    private(set) var keyword: String? = nil    // 컨텐츠 에피소드아이디
}
