//
//  Preview.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/27.
//

struct Preview : Decodable {
    private(set) var IF: String?    // 인터페이스 아이디
    private(set) var ver: String?   // 인터페이스 버전
    private(set) var ui_name: String?     // UI 구분자
    private(set) var svc_name: String?    // 서비스 명
    private(set) var result: String?  // 성공여부 0000:성공, xxxx:오류
    private(set) var reason: String?  // 메시지, 오류코드 명세 참조
    private(set) var epsd_id: String?     // 에피소드 ID
    private(set) var sris_id: String?     // 시리즈 ID
    private(set) var STB_ID: String?  // STB ID
    private(set) var CUR_TIME: String?    // H/E DB 서버 시간
    private(set) var CTS_INFO:PlayInfo?   // 컨텐츠 정보
    private(set) var verf_res_data: String?     // @end
}




