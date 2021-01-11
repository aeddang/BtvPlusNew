//
//  DevicePairing.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/01/08.
//

import Foundation


struct DevicePairing : Decodable {
    private(set) var header:NpsCommonHeader? = nil//공통 정보
    private(set) var body:DevicePairingBody? = nil //상세 정보
}

struct DevicePairingBody : Decodable {
    private(set) var if_no:String? = nil // API 일련번호 (IF-NPS-XXX)
    private(set) var guest_deviceid:String? = nil //Guest Device를 구분할 수 있는 ID
    private(set) var host_deviceid:String? = nil //Host Device를 구분할 수 있는 ID
    private(set) var pairingid:String? = nil //페어링 완료 시 할당된 페어링 아이디로 숫자로된 문자열
    //private(set) var custom_param:[String:Any]? = nil //임의의 배열
}
