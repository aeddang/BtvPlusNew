//
//  CWGrid.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/10.
//

import Foundation
struct CWGrid : Codable {
    private(set) var total_count:Int? = 0 // 카운트 값과 상관없이 전체 그리드 개수
    private(set) var grid:Array<GridsItem>? = nil // 빅배너 목록
    private(set) var result:String? = nil
}

struct GridsItem : Codable {
    private(set) var block_cnt:Double? = 0 // 메타 서브 유형 코드 (00501: 일반, 00502 캐릭터 AI) (null일경우 일반으로 처리)
    private(set) var sub_title:String? = nil // 동화 그리기 노출 여부
    private(set) var cw_call_id:String? = nil // 동화 역할놀이 노출 여부
    private(set) var session_id:String? = nil // 동화 가족 역할 노출 여부
    private(set) var sectionId:String? = nil // 동화 가족 역할 노출 여부
    private(set) var block:Array<ContentItem>? = nil  // 메뉴 ID(콘텐츠 // jdy_todo : 009 와 024가 배너를 제외한 데이타가 동일하여 임시로 변경
}
