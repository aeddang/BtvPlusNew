//
//  NpsModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/08.
//

import Foundation

struct NpsCommonHeader : Codable {
    private(set) var if_no:String? = nil // API 일련번호 (IF-NPS-XXX)
    private(set) var ver:String? = nil //API 버전 (5.0)
    private(set) var response_format:String? = nil //응답 형식 (json)
    private(set) var result:String? = nil // 성공인 경우 0000, 그외 에러 코드
    private(set) var reason:String? = nil // 성공인 경우 OK, 그외 에러 사유
    private(set) var sender:String? = nil // NPS
    private(set) var receiver:String? = nil //응답받을 디바이스 타입 (Mobile)
}

struct NpsResult : Decodable {
    private(set) var header:NpsCommonHeader? = nil//공통 정보
}


