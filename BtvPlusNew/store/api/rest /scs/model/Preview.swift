//
//  Preview.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/27.
//

struct Preview : Decodable {
    private(set) var IF: String? = nil    // 인터페이스 아이디
    private(set) var ver: String? = nil   // 인터페이스 버전
    private(set) var ui_name: String? = nil     // UI 구분자
    private(set) var svc_name: String? = nil    // 서비스 명
    private(set) var result: String? = nil  // 성공여부 0000:성공, xxxx:오류
    private(set) var reason: String? = nil  // 메시지, 오류코드 명세 참조
    private(set) var epsd_id: String? = nil     // 에피소드 ID
    private(set) var sris_id: String? = nil     // 시리즈 ID
    private(set) var STB_ID: String? = nil  // STB ID
    private(set) var CUR_TIME: String? = nil    // H/E DB 서버 시간
    private(set) var CTS_INFO:PlayInfo? = nil   // 컨텐츠 정보
    private(set) var verf_res_data: String? = nil     // @end
}




