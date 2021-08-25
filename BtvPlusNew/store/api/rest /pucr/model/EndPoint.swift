//
//  EndPoint.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/25.
//

import Foundation

struct EndPoint : Decodable {
    private(set) var endpoint_id: String? = nil // PushPlanet 푸시 시스템에서 부여하는 단말기 앱의 고유 구분 아이디
    private(set) var endpoint_secret: String? = nil  // 부여된 Endpoint ID의 비밀키
}
