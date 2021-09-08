//
//  Rps.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/28.
//

import Foundation

struct RpsNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.RPS)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request)
    }
}
extension RpsNetwork{
    static let RESPONSE_FORMET = "json"
}

class Rps: Rest{
    /**
    * 추천 목록 조회 (IIIF-MGMRPS-004)
    */
    func getRecommendHistory(
        completion: @escaping (RecommandHistory) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["response_format"] = RpsNetwork.RESPONSE_FORMET
        params["IF"] = "IF-MGMRPS-004"
        params["stb_id"] = stbId
        params["m"] = "recommendHistory"
        params["device_id"] = SystemEnvironment.deviceId
        params["page_no"] = "1"
        params["page_cnt"] = "999"
        fetch(route: RpsRecommendHistory(query: params), completion: completion, error:error)
    }
}

struct RpsRecommendHistory:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "/rps/mgmrps-service/recommendHistory"
    var query: [String : String]? = nil
}

