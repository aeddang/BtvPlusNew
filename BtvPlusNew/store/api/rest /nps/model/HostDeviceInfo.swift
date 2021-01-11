//
//  HostDeviceInfo.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/11.
//

import Foundation

struct HostDeviceInfo : Decodable {
    private(set) var header:NpsCommonHeader? = nil//공통 정보
    private(set) var body:HostDeviceInfoBody? = nil //상세 정보
}

struct HostDeviceInfoBody : Decodable {
    private(set) var if_no:String? = nil // API 일련번호 (IF-NPS-XXX)
    private(set) var guest_deviceid:String? = nil //Guest Device를 구분할 수 있는 ID
    private(set) var host_deviceid:String? = nil //Host Device를 구분할 수 있는 ID
    private(set) var pairingid:String? = nil //페어링 완료 시 할당된 페어링 아이디로 숫자로된 문자열
    private(set) var service_type:String? = nil //Device의 페어링 서비스를 구분할 수 있는 TYPE
    private(set) var host_deviceinfo:HostDeviceData? = nil //배열 형태의 host device
    //private(set) var custom_param:[String:Any]? = nil //임의의 배열
}

struct HostDeviceData : Decodable {
    private(set) var restricted_age:String? = nil // 연령제한 설정 정보
    private(set) var adult_safety_mode:String? = nil //활성화 상태면 1, 그렇지 않으면 0 (성인메뉴19영화, 성인메뉴19플러스 정보 포함)
    private(set) var stb_src_agent_version:String? = nil //agent 버전 정보
    private(set) var stb_patch_version:String? = nil //patch 버전 정보
    private(set) var stb_mac_address:String? = nil //host device의 MacAdress 정보. 암호화하여 입력, 보안 관련 문서는 별도 참조
    private(set) var stb_ui_version:String? = nil //UI 버전 정보
}



