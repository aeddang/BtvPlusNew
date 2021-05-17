//
//  WepgModel.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/05/17.
//

import Foundation

struct ProgramEventInfo: Decodable {
    private(set) var DT_EVNT_START: String?    // Event 시작시간
    private(set) var ID_EVENT: String?         // Event를 구분하는 ID_EVENT
    private(set) var NM_TITLE: String?         // Event의 프로그램 이름
    private(set) var NM_SYNOP: String?         // 프로그램의 시놉시스
    private(set) var CD_GENRE: String?         // 프로그램의 장르코드
    private(set) var DT_EVNT_END: String?      // Event 종료시간
    private(set) var CD_CATEGORY: String?      // 프로그램의 카테고리
    private(set) var CD_RATING: String?        // 프로그램의 시청등급
    private(set) var ID_MASTER: String?        // 마스터 ID
    private(set) var ID_VOD: String?           // VOD ID
    private(set) var AdditionalInfoArray:[AdditionalInfo]?
}


struct AdditionalInfo: Decodable {
    private(set) var FG_STEREO: String?        // FG_STEREO 정보(0:MONO, 1:stereo, 2: AC-3)
    private(set) var FG_RESOLU: String?        // FG_RESOLU 정보(0:SD, 1:HD, 2: UHD 4K, 3: UHD 8K)
    private(set) var NM_DIRECTOR: String?      // 연출자
    private(set) var NM_ACT: String?           // 출연자
}
