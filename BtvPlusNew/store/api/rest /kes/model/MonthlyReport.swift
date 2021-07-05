//
//  MonthlyReport.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/05.
//

import Foundation

struct MonthlyReport: Decodable {
    private(set) var infos_cnt: Int? // 월간리포트 정보 리스트 개수
    private(set) var infos: [MonthlyReportItem]? // 월간리포트 정보 리스트
}

struct MonthlyReportItem: Decodable {
    private(set) var total_cn: String? // 총평
    private(set) var svc_prop_cd: String? // 서비스 속성 코드 (공통코드 SVC_PROP_CD 참조)
    private(set) var svc_prop_nm: String? // 서비스 속성 코드 명 (공통코드 SVC_PROP_CD 참조)
    private(set) var learning_mm: Int? // 프로필 학습시간(분)
    private(set) var learning_cnt: Int? // 프로필 학습횟수
    private(set) var avg_mm: Int? // 평균 진도 시간(분) - 월중 현재 일 기준 누적 권장시간
    private(set) var avg_cnt: Int? // 평균 진도 횟수 - 월중 현재 일 기준 누적 권장 횟수
    private(set) var yyyy_mm: String? // 년월
    private(set) var recommend_mm: Int? // 월 권장 시간(분)
    private(set) var recommend_cnt: Int? // 월 권장 횟수
}
