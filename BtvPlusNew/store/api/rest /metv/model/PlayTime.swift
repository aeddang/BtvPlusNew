//
//  PlayTime.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/19.
//

import Foundation
struct PlayTime : Decodable {
    private(set) var ver: String? = nil    // 인터페이스 버전, 요청의 버전과 동일한 값이 전달 된다.
    private(set) var svc_name: String? = nil   // 서비스 이름
    private(set) var stb_id: String? = nil // STB ID
    private(set) var epsd_id: String? = nil    // VOD 컨텐트의 에피소드ID
    private(set) var trans_type: String? = nil // 컨텐트 전송 방식  - 1: D&P, 2: RTSP, 3: HLS
    private(set) var watch_rt: String? = nil   // 시청비율 %
    private(set) var watch_time: String? = nil // 컨텐트 최종 시청 타임. 단위 second
}

