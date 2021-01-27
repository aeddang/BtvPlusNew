//
//  Watch.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/27.
//

import Foundation

struct Watch : Decodable {

    private(set) var ver: String?    // 인터페이스 버전
    private(set) var svc_name: String?   // 서비스이름
    private(set) var stb_id: String? // STB ID
    private(set) var page_tot: String?   // 전체 페이지 개수
    private(set) var page_no: String?    // 현재 페이지 번호
    private(set) var watch_tot: String?  // 즐겨찾기의 전체 개수
    private(set) var watch_no: String?   // 현재 페이지의 즐겨찾기 개수
    private(set) var yn_ppm: String? // "최근시청VOD조회시 MyBtv/월정액 구분 필수 Y : 월정액 N : My Btv "
    private(set) var watchList: Array<WatchItem>? // 시청 집합의 이름
}


struct WatchItem : Decodable {
    private(set) var ver: String?    // 인터페이스 버전
    private(set) var sris_id: String?    // VOD 컨텐츠의 시즌ID
    private(set) var epsd_id: String?    // VOD 컨텐트의 식별자
    private(set) var epsd_rslu_id: String?   // VOD 컨텐트의 해상도ID
    private(set) var yn_series: String?  // 시즌 / 단편(타이틀) 구분, Y(시즌), N(단편)
    private(set) var series_no: String?  // VOD 컨텐트의 시리즈 회차
    private(set) var title: String?  // 컨텐트의 이름
    private(set) var level: String?  // 사용자 등급
    private(set) var adult: String?  // 성인물 여부  - Y: 성인물, N: 성인물 아님
    private(set) var thumbnail: String?  // 포스터 주소(URL)의 패스 (example=/menu/cate/poster.jpg)
    private(set) var catchup: String?    // VOD 컨텐츠의 신규 회차 배포 Y/N, group=VOD일 때 필수
    private(set) var trans_type: String? // 컨텐트 전송 방식 - 1: D&P, 2: RTSP, 3: HLS
    private(set) var watch_rt: String?   // 시청비율 %
    private(set) var watch_time: String? // 컨텐트 최종 시청 타임. 단위 second
    private(set) var reg_date: String?   // 시청일 (yy.MM.dd)
    private(set) var material_cd: String?    // 시즌ID별 최근 시청한 컨텐츠의 소재상태코드(65:배포승인, 80:배포만료 등)
    private(set) var prod_id: String?    // 시청한 상품ID (상품ID가 없는 경우, "" 로 제공, 구매한 상품ID 아님)
    private(set) var running_time: String?    // 시청한 컨텐츠의 총 러닝타임(/second)

}
