//
//  HostNicknameList.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/09/02.
//

import Foundation
struct HostNickName : Decodable {

    private(set) var ver: String? = nil    // 인터페이스 버전
    private(set) var svc_name: String? = nil   // 서비스이름
    private(set) var stb_id: String? = nil // STB ID
    private(set) var user_num: String? = nil // 명의자의 사용자번호
    private(set) var stbList:[HostNickNameItem]? = nil  // 가입한 STB 집합의 이름
}



struct HostNickNameItem : Decodable {

    private(set) var joined_user_service_num: String? = nil    // 가입한 STB 의 서비스 번호
    private(set) var joined_stb_id: String? = nil   // 가입한 STB ID
    private(set) var joined_nickname: String? = nil     // 가입한 STB의 닉네임
}


