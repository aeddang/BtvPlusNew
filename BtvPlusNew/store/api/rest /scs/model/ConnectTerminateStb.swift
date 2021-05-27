//
//  ConnectTerminateStb.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/05/27.
//

import Foundation
struct ConnectTerminateStb : Decodable {
    private(set) var IF: String?   // 인터페이스 아이디
    private(set) var ver: String?  // 인터페이스 버전
    private(set) var ui_name: String?    // UI 구분자
    private(set) var svc_name: String?   // 서비스 명
    private(set) var result: String? // 성공여부 0000:성공, xxxx:오류
    private(set) var reason: String? // 메시지, 오류코드 명세 참조
    private(set) var stb_id: String? // Mobile Btv 연결된 해지된 셋탑 ID
    private(set) var mbtv_key: String? // Mobile Btv 연결된 해지된 셋탑 ID
}
