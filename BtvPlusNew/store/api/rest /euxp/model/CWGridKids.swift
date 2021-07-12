//
//  CWGrid.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/10.
//

import Foundation
struct CWGridKids : Codable {
    private(set) var status_code: String? // Kes 연동코드
    private(set) var status_reason: String? // Kes 연동메세지
    private(set) var total_count: Int? // 그리드 개수
    private(set) var menu_stb_svc_id: String? // 서비스코드
    private(set) var grid: [GridsItemKids]?
    init(json: [String:Any]) throws {}
}

struct GridsItemKids : Codable {
    private(set) var block_cnt:Double? = 0 //
    private(set) var sub_title:String? = nil //
    private(set) var cw_call_id:String? = nil // 페이지 아이디 (IF-EUXP-010 호출 시 요청 파라미터로 넘겨준다.)
    private(set) var session_id:String? = nil // 세션 아이디 (IF-EUXP-010 호출 시 요청 파라미터로 넘겨준다.)
    private(set) var sectionId:String? = nil //  섹션 아이디
    private(set) var block:Array<ContentItem>? = nil  // 메뉴 ID(콘텐츠 // jdy_todo : 009 와 024가 배너를 제외한 데이타가 동일하여 임시로 변경
    private(set) var btrack_id: String? // 블록 트랙 아이디
    init(json: [String:Any]) throws {}
}
