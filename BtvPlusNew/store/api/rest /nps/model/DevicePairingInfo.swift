//
//  DevicePairingInfo.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/08.
//

import Foundation
struct DevicePairingInfo  : Decodable {
    private(set) var header:NpsCommonHeader? = nil//공통 정보
    private(set) var body:DevicePairingInfoBody? = nil //상세 정보
}

struct DevicePairingInfoBody : Decodable {
    private(set) var if_no:String? = nil // API 일련번호 (IF-NPS-XXX)
    private(set) var guest_deviceid:String? = nil //Guest Device를 구분할 수 있는 ID
    private(set) var service_type:String? = nil //Device의 페어링 서비스를 구분할 수 있는 TYPE
    private(set) var host_deviceid:String? = nil //Host Device를 구분할 수 있는 ID
    private(set) var pairing_info:PairingInfo? = nil //페어링 정보
    private(set) var tier_info:TierInfo? = nil //티어 정보
    //private(set) var custom_param:[String:Any]? = nil //임의의 배열
}
    
struct PairingInfo : Decodable {
    private(set) var count:String? = nil
    private(set) var max_count:String? = nil
}

struct TierInfo : Decodable {
    private(set) var product_name:String? = nil
    private(set) var level:String? = nil
}
