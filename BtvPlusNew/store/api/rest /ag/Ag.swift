//
//  Metv.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
struct AgNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.AG)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request)
    }
}

extension AgNetwork{
    
}

class Ag: Rest{
    /**
    * Token (IF-GW-001)
    * @param epsdId 에피소드ID
    */
    func getAGToken(
        completion: @escaping (AGToken) -> Void, error: ((_ e:Error) -> Void)? = nil){
        //let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        //var params = [String:String]()
        //params["stb_id"] = stbId
        //var overrideHeaders = [String:String]()
        //overrideHeaders["Client_ID"] = SystemEnvironment.deviceId
        //overrideHeaders["UUID"] = stbId.replace("{", with: "").replace("}", with: "")
        fetch(route: AgToken(overrideHeaders:nil), completion: completion, error:error)
    }
}


struct AgToken:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "/api/v1/auth/getToken"
    var overrideHeaders: [String : String]? = nil
}
