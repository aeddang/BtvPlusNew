//
//  WebModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/22.
//

import Foundation

struct CompleteKeyword : Decodable {
    private(set) var statusCode: String? = nil   // 요청 결과.
    private(set) var statusMessage: String? = nil
    private(set) var data:CompleteKeywordResult? = nil
}

struct CompleteKeywordResult : Decodable {
    private(set) var results: [CompleteKeywordItem]? = nil
}

struct CompleteKeywordItem : Decodable {
    private(set) var idx: Int? = nil   // 컨텐츠 시리즈아이디
    private(set) var title: String? = nil    // 컨텐츠 에피소드아이디
}
