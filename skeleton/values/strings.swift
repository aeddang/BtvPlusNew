//
//  strings.swift
//  ironright
//
//  Created by JeongCheol Kim on 2020/02/04.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

extension String {
    public static let appName = "BtvPlus"
    public static let corfirm = "확인"
    public static let cancel = "취소"
    public static let retry = "다시시도"
    
    struct alert {
        public static var apns = "알림"
        public static var api = "알림"
        public static var apiErrorServer = "접속이 지연되고 있습니다. 잠시 후 다시 이용해 주세요."
        public static var apiErrorClient = "네트워크 연결 상태를 확인하시고 다시 시도해 주세요."
    }
    
    struct button {
        public static var next = "다음"
        public static var complete = "완료"
        public static var share = "공유하기"
        public static var more = "더 보기"
        public static var delete = "지우기"
    }
    
    struct pageTitle {
        public static var home = "홈"
        public static var ocean  = "OCEAN"
        public static var payment = "월정액"
        public static var category = "카테고리"
        public static var free = "무료"
    }
}
