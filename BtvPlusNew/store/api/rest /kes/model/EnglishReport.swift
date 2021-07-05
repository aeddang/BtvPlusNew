//
//  EnglishReport.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/05.
//

import Foundation
struct EnglishReport: Decodable {
    private(set) var contents: Diagnose? // 월간리포트 정보 리스트
}
struct Diagnose: Decodable {
    private(set) var infos: [DiagnoseInfo]?
}

struct DiagnoseInfo: Decodable {
    private(set) var tgt_cd: String? // 대상코드(공통코드 TGT_CD 참조)
    private(set) var tgt_nm: String? // 진단레벨 라벨
}
