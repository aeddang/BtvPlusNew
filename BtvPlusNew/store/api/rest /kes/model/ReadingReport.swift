//
//  ReadingReport.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/05.
//

import Foundation
struct ReadingReport: Decodable {
    private(set) var contents: ReadingReportContents? // 월간리포트 정보 리스트
}

struct ReadingReportContents: Decodable {
    private(set) var menu_msg: String?
    private(set) var areas_cnt: Int?
    private(set) var areas: [ReadingReportItem]?
}

struct ReadingReportItem: Decodable {
    private(set) var hcls_area_cd: String? // 진단유형코드(공통코드 HCLS_AREA_CD 참고)
    private(set) var hcls_area_nm: String? // 진단유형명
    private(set) var result_msg: String? // 진단결과
    private(set) var subm_dtm: String? // 진단일
}
