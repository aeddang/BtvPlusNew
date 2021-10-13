//
//  Rps.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/28.
//

import Foundation

struct UoRpsNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.UORPS)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request)
    }
}
extension UoRpsNetwork{
    static let RESPONSE_FORMET = "json"
}

class UoRps: Rest{
    /**
     * NUGU PAIRING 여부 조회 (IF-UORPS-005)
     */
    func checkNuguPairing(
        macAddress:String?,
        completion: @escaping (NuguPairing) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["response_format"] = RpsNetwork.RESPONSE_FORMET
        params["IF"] = "IF-UORPS-005"
        params["m"] = "chkPairing"
        params["stb_id"] = stbId
        params["device_id"] = SystemEnvironment.deviceId
        params["mac_addr"] = macAddress
        //params["mode"] = "null"
        params["add_pair"] = "senior"
            
        fetch(route: UoRpsCheckNuguPairing(query: params), completion: completion, error:error)
    }
}

struct UoRpsCheckNuguPairing:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "chkPairing"
    var query: [String : String]? = nil
}

