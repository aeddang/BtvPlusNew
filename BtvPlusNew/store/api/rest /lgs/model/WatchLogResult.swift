//
//  WatchLogResult.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/29.
//

import Foundation

import Foundation
struct WatchLogResult: Decodable {
    private(set) var result: String? = nil    // 요청 결과.
    private(set) var reason: String? = nil
}
