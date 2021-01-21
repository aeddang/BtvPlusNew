//
//  DirectView.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/21.
//

import Foundation

struct DirectView : Decodable {
    private(set) var ver: String?   // 인터페이스 버전
    private(set) var svc_name: String?    // 서비스이름
    private(set) var stb_id: String?  // STB ID
    private(set) var is_bookmark: String?     // vod 즐겨찾기 여부
    private(set) var ppv_products:[PPVProductItem]?
    private(set) var yn_season_watch_all: String?    // 시즌시놉인 경우 필수 - 시즌 전체를 시청가능한지여부 (Y/N) 제공
    private(set) var pps_products:[PPSProductItem]?
    private(set) var last_watch_info:LastWatchInfo?  // 시즌별 마지막 시청 정보
}


struct PPVProductItem : Decodable {
    private(set) var epsd_id: String?     // 에피소드ID
    private(set) var prd_prc_id: String?  // 상품ID
    private(set) var yn_directview: String?   // 시청가능여부(Y/N)
    private(set) var yn_purchase: String?     // 구매여부(Y/N), PPP 인 경우는 구매여부(Y/N)를 무조건 제공(구매버튼관련)
    private(set) var end_date: String?
    private(set) var period: String?
    private(set) var period_hour: String?
    private(set) var period_min: String?
}



struct PPSProductItem : Decodable {
    private(set) var prd_prc_id: String?  // 상품ID
    private(set) var yn_directview: String?   // 시청가능여부(Y/N)
    private(set) var yn_purchase: String?     // 구매여부(Y/N), PPP 인 경우는 구매여부(Y/N)를 무조건 제공(구매버튼관련)
    private(set) var end_date: String?
    private(set) var period: String?
    private(set) var period_hour: String?
    private(set) var period_min: String?
}

struct LastWatchInfo : Decodable {
    private(set) var sris_id: String?     // 마지막 시청한 컨텐츠의 시리즈ID
    private(set) var epsd_id: String?     // 마지막 시청한 컨텐츠의 에피소드ID
    private(set) var epsd_rslu_id: String?    // 마지막 시청한 컨텐츠의 에피소드 해상도 ID
    private(set) var trans_type: String?  // "컨텐트 전송 방식 - 1: D&P, 2: RTSP, 3: HLS"
    private(set) var watch_rt: String?    // 시청 비율 (%)
    private(set) var watch_time: String?  // 시청시간 초(sec)
}

