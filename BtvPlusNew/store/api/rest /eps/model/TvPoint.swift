//
//  TvPoint.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/04/13.
//

import Foundation
struct TvPoint : Decodable {
    private(set) var ui_name: String?     // UI구분자
    private(set) var response_format: String?     // 데이터 형식, "json"만 지원
    private(set) var svc_name: String?    // 서비스 제공 어플리케이션 이름 "EPS"
    private(set) var tvpoint: TvPointItem?    // TV포인트 정보 ※ API 응답 코드가 '0000'(OK)인 경우에만 응답
}

struct  TvPointItem : Decodable {
    private(set) var useTvpoint:Bool? // TV 포인트 사용유무 - true: TV포인트 등록한 사용자 - false: TV포인트 미등록한 사용자
    private(set) var id: String?  // TV포인트 ID
    private(set) var url: String?     // TV포인트 연동 URL ※ ui_name에 설정된 URL이 없는 경우 빈값 또는 생략
    private(set) var balance:Double?   // TV포인트 잔액
}
