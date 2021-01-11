//
//  BookMark.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation

struct BookMark : Codable {
    private(set) var ver: String?    // 인터페이스 버전
    private(set) var svc_name: String?   // 서비스이름
    private(set) var stb_id: String? // STB ID
    private(set) var page_tot: String?   // 전체 페이지 개수
    private(set) var page_no: String?    // 현재 페이지 번호
    private(set) var bookmark_tot: String?   // 즐겨찾기의 전체 개수
    private(set) var bookmark_no: String?    // 현재 페이지의 즐겨찾기 개수
    private(set) var group: String?  // 즐겨찾기 유형, VOD: VOD 컨텐츠, IPTV: 실시간 채널, VAS: 부가서비스
    private(set) var ch_type: String?    // group = iptv 인 경우, 필수
    private(set) var bookmarkList: [BookMarkItem]?   // 즐겨찾기 집합의 이름
    init(json: [String:Any]) throws {}
}

struct BookMarkItem : Codable {
    private(set) var sris_id: String?    // VOD의 sris 식별자
    private(set) var epsd_id: String?    // 에피소드ID
    private(set) var epsd_rslu_id: String?   // VOD 컨텐트의 해상도ID (group=VOD 필수)
    private(set) var title: String?  // VOD: 컨텐츠명, IPTV: 채널명, VAS: 부가서비스명
    private(set) var level: String?  // 사용자 등급
    private(set) var adult: String?  // 성인물 여부(Y/N)
    private(set) var catchup: String?    // VOD 컨텐츠의 신규 회차 배포 Y/N, group=VOD일 때 필수
    private(set) var poster: String? // 포스터 주소(URL)의 패스 (group=VOD일 때 필수)
    private(set) var material_cd: String?    // 즐겨찾기한 컨텐츠의 소재상태코드(65:배포승인, 80:배포만료 등) - group=VOD일 때 필수
    private(set) var yn_kzone: String?   // 키즈존 여부
    private(set) var reg_date: String?   // 즐겨찾기 등록일 (형식: yy.MM.dd)
    init(json: [String:Any]) throws {}
}
