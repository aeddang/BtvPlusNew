//
//  StbInfo.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/29.
//

import Foundation
struct StbInfo : Decodable{
    private(set) var IF:String? = nil   // 인터페이스 아이디
    private(set) var ver:String? = nil  // 인터페이스 버전
    private(set) var result:String? = nil // 성공여부 0000:성공, xxxx:오류
    private(set) var reason:String? = nil // 메시지, 오류코드 명세 참조
    private(set) var ui_name:String? = nil    // UI 구분자
    private(set) var stb_id:String? = nil // Mobile Btv 연결된 해지된 셋탑 ID
    private(set) var mac_address:String? = nil
    private(set) var svc_num:String? = nil
   //private(set) var status_code:String? = nil
}


