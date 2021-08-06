//
//  PairingToken.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/06.
//

import Foundation

struct PairingToken : Decodable {
    private(set) var header:NpsCommonHeader? = nil//공통 정보
    private(set) var body:PairingTokenBody? = nil //상세 정보
}

struct PairingTokenBody : Decodable {
    /*! Guest Device를 구분할 수 있는 ID */
    private(set) var guest_deviceid:String? = nil
    /*! Device의 페어링 서비스를 구분할 수 있는 TYPE */
    private(set) var service_type:String? = nil
    /*! Host Device를 구분할 수 있는 ID */
    private(set) var host_deviceid:String? = nil
    /*! 토큰을 이용한 페어링에 사용 되는 토큰 값 ex) 암호화된 특정 문자열 */
    private(set) var pairing_token:String? = nil
    /*! 토큰의 유효 시간 ex) 2020-08-23T19:20:30 */
    private(set) var valid_time:String? = nil
   
}

