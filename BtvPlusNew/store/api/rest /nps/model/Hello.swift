//
//  HelloPairing.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/11.
//

import Foundation
import Foundation
struct Hello  : Decodable {
    private(set) var header:NpsCommonHeader? = nil//공통 정보
    private(set) var body:HelloBody? = nil //상세 정보
}

struct HelloBody : Decodable {
    private(set) var guest_deviceid:String? = nil
    private(set) var service_type:String? = nil
    private(set) var sessionid:String? = nil
    private(set) var pairingid:String? = nil
    private(set) var host_deviceid:String? = nil
    private(set) var pairing_device_mac:String? = nil
    private(set) var ip:String? = nil
    private(set) var port:String? = nil
    private(set) var pairing_info:HelloPairingInfo? = nil //페어링 정보
    private(set) var tier_info:HelloTierInfo? = nil //티어 정보
    //private(set) var custom_param:[String:Any]? = nil //임의의 배열
}
    
struct HelloPairingInfo : Decodable {
    private(set) var force_unpairing:String? = nil
    private(set) var count:String? = nil
    private(set) var max_count:String? = nil
}

struct HelloTierInfo : Decodable {
    private(set) var product_name:String? = nil
    private(set) var lastest_update_level:String? = nil
}
