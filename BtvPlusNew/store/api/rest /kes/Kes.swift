//
//  Metv.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
struct KesNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.KES)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request)
    }
}
extension KesNetwork{
    static let RESPONSE_FORMET = "json"
    static let MENU_STB_SVC_ID = "BTVMOBV440"
    static let PAGE_COUNT = 30
}

class Kes: Rest{
    /**
    * 젬키즈 프로필 목록 조회 (IF-KES-001)
    */
    func getKidsProfiles(
        hostDevice:HostDevice?,
        completion: @escaping (KidsProfiles) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-001"
        params["stb_id"] = stbId
    
        fetch(route: KesKidsProfiles(body: params), completion: completion, error:error)
    }
}

struct KesKidsProfiles:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/profile/item"
    var body: [String : Any]? = nil
}

