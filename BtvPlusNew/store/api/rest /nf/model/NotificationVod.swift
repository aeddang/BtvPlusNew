//
//  NotificationVod.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/09.
//

import Foundation


struct NotificationVod : Decodable {
    private(set) var NotiVodList:[NotificationVodItem]? = nil                   // 유저 정보
}

struct NotificationVodItem : Decodable {
    private(set) var sris_id: String? = nil    // 컨텐츠 시리즈아이디
    private(set) var epsd_id: String? = nil   // 컨텐츠 에피소드아이디
    private(set) var epsd_rslu_id: String? = nil   // 컨텐츠 에피소드해상도아이디
    private(set) var contents_nm: String? = nil     // 컨텐츠 이름(100자미만)
    private(set) var dvc_id: String? = nil  // BtvPlus단말일련번호
    private(set) var dt_insert_str: String? = nil   // 알림 설정 일시
    private(set) var dt_update_str: String? = nil   //
    private(set) var noti_type: String? = nil   // 알림 타입(movie:영화)
    private(set) var dt_noti_str: String? = nil     //
}

struct RegistNotificationVod : Decodable {
    private(set) var result: String? = nil
    private(set) var reason: String? = nil
}
