//
//  SearchKeyword.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/22.
//

import Foundation

struct SearchKeyword : Decodable {
    private(set) var statusCode: String?    // 요청 결과.
    private(set) var statusMessage: String?
    private(set) var data:SearchKeywordResult?
}


struct SearchKeywordResult : Decodable {
    private(set) var result: String?    // 요청 결과.
    private(set) var reason: String?
    private(set) var results_keyword: [SearchKeywordItem]?
}

struct SearchKeywordItem : Decodable {
    private(set) var idx: Int?    // 컨텐츠 시리즈아이디
    private(set) var keyword: String?    // 컨텐츠 에피소드아이디
}
