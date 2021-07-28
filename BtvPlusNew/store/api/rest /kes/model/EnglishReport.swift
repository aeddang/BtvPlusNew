//
//  EnglishReport.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/05.
//

import Foundation
struct EnglishReport: Decodable {
    private(set) var contents: EnglishReportContents? = nil // 월간리포트 정보 리스트
}
struct EnglishReportContents: Decodable {
    private(set) var infos: [EnglishReportItem]? = nil
}

struct EnglishReportItem: Decodable {
    private(set) var tgt_cd: String? = nil// 대상코드(공통코드 TGT_CD 참조)
    private(set) var tgt_nm: String? = nil // 진단레벨 라벨
}
