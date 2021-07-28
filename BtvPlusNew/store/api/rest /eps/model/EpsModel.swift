//
//  EpsModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/12.
//

import Foundation

struct RegistEps : Decodable {
    private(set) var result: String? = nil    // 요청 결과.
    private(set) var reason: String? = nil
    private(set) var ui_name: String? = nil    // UI구분자
    private(set) var response_format: String? = nil   // 데이터 형식, "json"만 지원
    private(set) var svc_name: String? = nil  // 서비스 제공 어플리케이션 이름 "EPS"
}

struct BalanceItem : Decodable {
    private(set) var supplyBalance: Double? = nil    // B캐쉬 공급가
    private(set) var totalBalance: Double? = nil   // B캐쉬 총액
}
