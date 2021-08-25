//
//  PucrResult.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/25.
//

import Foundation

struct PucrResult : Codable {
    private(set) var result:String? = nil // 성공인 경우 0000, 그외 에러 코드
    private(set) var reason:String? = nil // 성공인 경우 OK, 그외 에러 사유
    
}
