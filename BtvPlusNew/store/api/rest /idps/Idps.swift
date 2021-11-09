//
//  Metv.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
struct IdpsNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.IDPS)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request)
    }
}
extension IdpsNetwork{
    static let RESPONSE_FORMET = "json"
    static let VERSION = "1.0"
    static let TARGET = "BTVPLUS"
    static let DEVICETYPE = ApiPrefix.os
    
}

class Idps: Rest{
    /**
    * 옥수수 인증 여부 체크 API (IF-IDPS-OKSUSU-003)
    */
    func checkOksusu(
        completion: @escaping (OksusuStatus) -> Void, error: ((_ e:Error) -> Void)? = nil){

        var params = [String:String]()
        params["did"] = SystemEnvironment.deviceId
        var overrideHeaders = [String:String]()
        overrideHeaders["Trace"] = ""
        overrideHeaders["Token"] = SystemEnvironment.agToken
        overrideHeaders["Authorization"] = "Bearer"
        fetch(route: IdpsCheckOksusu( query: params, overrideHeaders:overrideHeaders), completion: completion, error:error)
    }
}

struct IdpsCheckOksusu:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/api/idps/auth/oksusu/check/mobilebtv"
   var query: [String : String]? = nil
   var overrideHeaders: [String : String]? = nil
}



