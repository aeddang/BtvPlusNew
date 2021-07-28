//
//  KidsReport.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/05.
//

import Foundation

struct KidsExams: Decodable {
    private(set) var result: String? = nil   // 요청 결과.
    private(set) var reason: String? = nil
    private(set) var contents: KidsExam? = nil
}

struct KidsExam: Decodable {
    private(set) var ep_no: DynamicValue? = nil // 시험지번호
    private(set) var ep_tit_nm: String? = nil // 시험지제목명
    private(set) var ep_tp_no: DynamicValue? = nil // 시험지유형번호
    private(set) var q_items_cnt: Int? = nil // 문항 개수
    private(set) var q_items: [ KidsExamQuestion]? = nil // 문항 정보 리스트
}

struct KidsExamQuestion: Decodable {
    private(set) var q_id: String? = nil // 문항ID
    private(set) var q_sort_or: Int? = nil // 문항 정렬순서
    private(set) var q_bdlt_tp_cd: String? = nil // 문항본문유형코드(공통코드 Q_BDLT_TP_CD 참조)
    private(set) var q_cans_cn: String? = nil // 문항정답
    private(set) var q_img_url: String? = nil // 문항 이미지 full url
    private(set) var q_aud_url: String? = nil // 문항 음성 full url
    private(set) var q_ex_cnt: Int? = nil // 보기수
    private(set) var subm_ansr_cn: String? = nil // 제출답안내용
    private(set) var tgt_per_cd: String? = nil // 대상자구분코드(공통코드 TGT_PER_CD 참조)
}

struct KidsExamAnswerResult: Decodable {
    var q_cnt: Int? = nil //문항 개수
    var cans_cnt: Int? = nil // 맞은 개수
}

struct KidsReport: Decodable {
    private(set) var contents: KidsReportContents? = nil
}

struct KidsReportContents: Decodable {
    private(set) var parents: [Int]? = nil //creative
    private(set) var childs: [Int]? = nil
    private(set) var labels: [String]? = nil
    
    private(set) var graphs: [Int]? = nil // 5점척도 그래프 reading
    
    private(set) var level_cd: String? = nil // 레벨코드(공통코드 LEVEL_CD 참고)
    private(set) var level_avgs: [Int]? = nil // 레벨 평균 분포
    private(set) var level_labels: [String]? = nil // 레벨 이름
    private(set) var peer_avgs: [Int]? = nil // 또래 평균
    private(set) var my_levels: [Int]? = nil // 나의 레벨
    private(set) var max_val: Int? = nil // 그래프의 max값
    
    private(set) var test_rslt_yn: DynamicValue? = nil // 시험결과여부
    private(set) var subm_dtm: String? = nil // 검사일
    private(set) var retry_cnt: Int? = nil // 재응시 횟수

    private(set) var total_cn: String? = nil// 총평
    private(set) var cn_items_cnt: Int? = nil // 진단결과 리스트 개수
    private(set) var cn_items: [KidsReportResult]? = nil// 진단결과 리스트
    private(set) var ep_no: String? = nil // 시험지번호
    private(set) var ep_tit_nm: String? = nil// 시험지제목명
    private(set) var ep_tp_no: Int? = nil // 시험지유형번호
    private(set) var q_items_cnt: Int? = nil // 문항 개수
    private(set) var q_items: [KidsExamQuestion]? = nil// 문항 정보 리스트
    private(set) var call_url: String? = nil// 추천메뉴 url
}

struct KidsReportResult: Decodable {
    private(set) var title: String? = nil // 제목
    private(set) var cn: String? = nil // 컨텐츠
}
