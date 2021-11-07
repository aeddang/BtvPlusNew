//
//  AGToken.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/11/04.
//

import Foundation
struct AGToken : Decodable {
    private(set) var token: String? = nil    // 인터페이스 버전, 요청의 버전과 동일한 값이 전달 된다.
}

