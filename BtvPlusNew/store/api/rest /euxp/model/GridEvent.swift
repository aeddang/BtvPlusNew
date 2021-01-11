//
//  GridEvent.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/10.
//

import Foundation
struct GridEvent : Codable {
    private(set) var total_content_count:Int? = 0 // 카운트 값과 상관없이 전체 그리드 개수
    private(set) var total_banner_count:Int? = 0
    private(set) var banners:Array<EventBanner>? = nil // 빅배너 목록
    private(set) var contents:Array<ContentItem>? = nil // 메뉴 ID(콘텐츠 블럭을 가진 메뉴ID)
    private(set) var result:String? = nil
}


