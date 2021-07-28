//
//  AllChannels.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/05/17.
//

import Foundation

struct AllChannels : Decodable {
    private(set) var ui_name: String? = nil    // UI구분자
    private(set) var result: String? = nil       // 성공:OK, 실패:별도 에러코드 테이블 참조
    private(set) var reason: String? = nil      // 성공 또는 실패 이유
    private(set) var IF: String? = nil           // 인터페이스 아이디
    private(set) var ver: String? = nil         // 인터페이스 버전
    private(set) var poc_name: String? = nil     // poc구분 값    STB : Legacy (default)    UHDTV : UHD TV    UHDSTB : UHD STB    BTVMOBILE : Btv Mobile
    private(set) var version: String? = nil      // 응답 데이터의 버전 정보
    private(set) var ServiceInfoArray:[ChannelInfo]? = nil
}

struct ChannelInfo : Decodable {
    private(set) var RANK: String? = nil          // 성인채널 여부   : 19 이상의 값이 들어 있는경우 성인채널
    private(set) var ID_SVC: String? = nil           // 서비스 번호
    private(set) var SVCPOC: String? = nil           // 서비스 POC 코드(01:전체(nscreen) 02:STB 전용 03:모바일 전용)
    private(set) var CD_HDSD: String? = nil          // 채널이 HD/SD 여부 (0 : SD, 1 : HD, 2 : UHD 4K, 3 : UHD 8K)
    private(set) var CD_GENRE: String? = nil         // 장르
    private(set) var ID_ISUPKG: String? = nil        // ISU패키지ID
    private(set) var ID_CAS: String? = nil           // CAS시스템ID
    private(set) var CD_AREA: String? = nil          // 지역코드
    private(set) var NM_MCIP: String? = nil          // 멀티캐스트IP
    private(set) var CNT_PORT: String? = nil         // 멀티캐스트PORT
    private(set) var CD_PROC: String? = nil          // 작동상태
    private(set) var PAY: String? = nil              // 유료채널 여부   :  0 (무료채널), 1( 유료채널 )
    private(set) var NO_CH: String? = nil           // 채널번호
    private(set) var TP_SVC: String? = nil           // 서비스 타입
    private(set) var NM_CH: String? = nil          // 채널명
    private(set) var EVENT_INFO:[ProgramEventInfo]? = nil      // 현재 프로그램 정보
}


