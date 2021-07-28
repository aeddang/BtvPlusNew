//
//  RecommandCoupon.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/28.
//

import Foundation

struct RecommandCoupon: Decodable {
    private(set) var result:String? = nil
    private(set) var reason:String? = nil
    private(set) var nick_nm:String? = nil // 발신자 닉네임
    private(set) var title:String? = nil // 추천 상품 타이틀
}
