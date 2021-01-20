//
//  DevicePairingStatus.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/20.
//

import Foundation

struct DevicePairingStatus : Decodable {
    private(set) var header:NpsCommonHeader? = nil//공통 정보
    private(set) var body:DevicePairingStatusBody? = nil //상세 정보
}

struct DevicePairingStatusBody : Decodable {
    private(set) var pairing_deviceid:String? = nil
    private(set) var pairing_device_type:String? = nil
    private(set) var pairingid:String? = nil
    private(set) var service_type:String? = nil
    private(set) var pairing_status:String? = nil /*! 페어링 상태를 표시하는 값 */
    //private(set) var custom_param:[String:Any]? = nil //임의의 배열
}

