//
//  OksusuStatus.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/11/04.
//

import Foundation


struct OksusuStatus : Decodable {
    private(set) var result: String? = nil
    private(set) var code: String? = nil
    private(set) var message: String? = nil
    private(set) var body:OksusuStatusItem? = nil
    
}

struct OksusuStatusItem : Decodable {
    private(set) var authYn: String? = nil //인증여부
    private(set) var closeYn: String? = nil //해지/이관 여부 -> 인증여부가 N인경우에는 null을 응답함.
}


