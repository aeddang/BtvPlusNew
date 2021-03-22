//
//  WebModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/22.
//

import Foundation

struct CompleteKeyword : Decodable {
    private(set) var statusCode: String?    // 요청 결과.
    private(set) var statusMessage: String?
    private(set) var data:CompleteKeywordResult?
}

struct CompleteKeywordResult : Decodable {
    private(set) var results: [CompleteKeywordItem]?
}

struct CompleteKeywordItem : Decodable {
    private(set) var idx: Int?    // 컨텐츠 시리즈아이디
    private(set) var title: String?    // 컨텐츠 에피소드아이디
}
