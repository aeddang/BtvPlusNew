//
//  CurrentChannels.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/05/17.
//

import Foundation
struct CurrentChannels : Decodable {
    private(set) var ui_name: String?    // UI구분자
    private(set) var result: String?       // 성공:OK, 실패:별도 에러코드 테이블 참조
    private(set) var reason: String?       // 성공 또는 실패 이유
    private(set) var IF: String?           // 인터페이스 아이디
    private(set) var ver: String?          // 인터페이스 버전
    private(set) var poc_name: String?     // poc구분 값    STB : Legacy (default)    UHDTV : UHD TV    UHDSTB : UHD STB    BTVMOBILE : Btv Mobile
    private(set) var version: String?      // 응답 데이터의 버전 정보
    private(set) var ServiceInfoArray:[CurrentChannelInfo]?
}

struct CurrentChannelInfo : Decodable {
    private(set) var ID_SVC: String?        // 서비스 번호
    private(set) var EventInfoArray:[ProgramEventInfo]?
}
