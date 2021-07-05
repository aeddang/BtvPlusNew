//
//  KidsReport.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/05.
//

import Foundation

struct KidsExams: Decodable {
    private(set) var contents: KidsExam?
}

struct KidsExam: Decodable {
    private(set) var ep_no: DynamicValue? // 시험지번호
    private(set) var ep_tit_nm: String? // 시험지제목명
    private(set) var ep_tp_no: Int? // 시험지유형번호
    private(set) var q_items_cnt: Int? // 문항 개수
    private(set) var q_items: [ KidsExamQuestion]? // 문항 정보 리스트
}

struct KidsExamQuestion: Decodable {
    private(set) var q_id: String? // 문항ID
    private(set) var q_sort_or: Int? // 문항 정렬순서
    private(set) var q_bdlt_tp_cd: String? // 문항본문유형코드(공통코드 Q_BDLT_TP_CD 참조)
    private(set) var q_cans_cn: String? // 문항정답
    private(set) var q_img_url: String? // 문항 이미지 full url
    private(set) var q_aud_url: String? // 문항 음성 full url
    private(set) var q_ex_cnt: Int? // 보기수
    private(set) var subm_ansr_cn: String? // 제출답안내용
    private(set) var tgt_per_cd: String? // 대상자구분코드(공통코드 TGT_PER_CD 참조)
}

struct KidsExamAnswerResult: Decodable {
    var q_cnt: Int? //문항 개수
    var cans_cnt: Int? // 맞은 개수
}

struct KidsReport: Decodable {
    private(set) var contents: KidsReportContents?
}

struct KidsReportContents: Decodable {
    private(set) var test_rslt_yn: String? // 시험결과여부
    private(set) var subm_dtm: String? // 검사일
    private(set) var retry_cnt: Int? // 재응시 횟수
    private(set) var graphs: [Int]? // 5점척도 그래프
    private(set) var level_cd: String? // 레벨코드(공통코드 LEVEL_CD 참고)
    private(set) var level_avgs: [Int]? // 레벨 평균 분포
    private(set) var level_labels: [String]? // 레벨 이름
    private(set) var peer_avgs: [Int]? // 또래 평균
    private(set) var my_levels: [Int]? // 나의 레벨
    private(set) var max_val: Int? // 그래프의 max값
    private(set) var total_cn: String? // 총평
    private(set) var cn_items_cnt: Int? // 진단결과 리스트 개수
    private(set) var cn_items: [KidsReportResult]? // 진단결과 리스트
    private(set) var ep_no: String? // 시험지번호
    private(set) var ep_tit_nm: String? // 시험지제목명
    private(set) var ep_tp_no: Int? // 시험지유형번호
    private(set) var q_items_cnt: Int? // 문항 개수
    private(set) var q_items: [KidsExamQuestion]? // 문항 정보 리스트
    private(set) var call_url: String? // 추천메뉴 url
}

struct KidsReportResult: Decodable {
    private(set) var title: String? // 제목
    private(set) var cn: String? // 컨텐츠
}
