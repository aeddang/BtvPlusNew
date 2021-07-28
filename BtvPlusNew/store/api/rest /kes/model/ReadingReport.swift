//
//  ReadingReport.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/05.
//

import Foundation
struct ReadingReport: Decodable {
    private(set) var contents: ReadingReportContents?  = nil// 월간리포트 정보 리스트
}

struct ReadingReportContents: Decodable {
    private(set) var menu_msg: String? = nil
    private(set) var areas_cnt: Int? = nil
    private(set) var areas: [ReadingReportItem]? = nil
}

struct ReadingReportItem: Decodable {
    private(set) var hcls_area_cd: String? = nil // 진단유형코드(공통코드 HCLS_AREA_CD 참고)
    private(set) var hcls_area_nm: String? = nil // 진단유형명
    private(set) var result_msg: String? = nil // 진단결과
    private(set) var subm_dtm: String? = nil // 진단일
}
