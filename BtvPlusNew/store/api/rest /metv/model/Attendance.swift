//
//  Atten.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/29.
//

import Foundation

struct Attendance : Decodable { 
    private(set) var IF: String? = nil             // 인터페이스 명
    private(set) var result: String? = nil         // 응답결과
    private(set) var reason: String? = nil         // 메시지
    private(set) var event_month: String? = nil    // 이벤트 해당 월
    private(set) var total_event_cnt: String? = nil// 이벤트 해당 월 동안 출석체크 가능한 총 횟수
    private(set) var check_cnt: String? = nil      // 이벤트 해당 월 동안 출석체크 한 횟수
    private(set) var today_check_yn: String? = nil // 당일 출석체크 여부
}
