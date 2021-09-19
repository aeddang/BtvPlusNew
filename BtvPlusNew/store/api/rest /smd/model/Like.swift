//
//  Like.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/21.
//

import Foundation

struct Like : Decodable {
    private(set) var like: String? = nil    // 사용자 평가 상태( 0, 미평가상태, 1 좋아요 선택상태 )
    private(set) var dislike: String? = nil   // 사용자 평가 상태( 0, 미평가상태, 1 별루예요 선택상태 )
    private(set) var updateDate: String? = nil // 최근 좋아요,별루예요 평가 시간정보
    private(set) var like_total: String?   // 콘텐츠 평가 좋아요 총점
    private(set) var dislike_total: String?    // 콘텐츠 평가 별로에요 총점
    private(set) var updateDate_total: String?   // 콘텐츠 평점 총합 업데이트 날짜
}

struct RegistLike : Decodable {
    private(set) var result: String? = nil
    private(set) var like_action: String? = nil    //  0, 미평가상태, 1 좋아요, 2 별로에요
    private(set) var series_id: String? = nil
}
