//
//  Rps.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/28.
//

import Foundation

struct PucrNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.PUCR)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request)
    }
}
extension PucrNetwork{
    static let DEVICE_TYPE = "iOS"
    static let SDK_VS = "iOS:4.0"
    static let MANYFACTURER = "Apple"
}

class Pucr: Rest{
    /**
     * 유저 Endpoint 생성 (IF-PUCR-010)
     */
    func createEndpoint(
        token:String,
        completion: @escaping (EndPoint) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        var params = [String:Any]()
        params["device_type"] = PucrNetwork.DEVICE_TYPE
        params["device_token"] = token
        params["sdk_version"] = PucrNetwork.SDK_VS
        
        params["os_version"] = SystemEnvironment.systemVersion
        params["manufacturer"] = PucrNetwork.MANYFACTURER
        params["model"] = SystemEnvironment.model
        params["product"] = SystemEnvironment.model
      
        fetch(route: PucrCreateEndPoint(body: params), completion: completion, error:error)
    }
}

struct PucrCreateEndPoint:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/push/v3/endpoints"
    var body: [String : Any]? = nil
}




