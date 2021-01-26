//
//  Metv.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
struct SmdNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.SMD)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setDefaultheader(request: request)
    }
}
extension SmdNetwork{
    static let RESPONSE_FORMET = "json"
}

class Smd: Rest{
    /**
     * BTV 평점 조회  (IF-SMTDV-V5-005)
     * @param seriesId 시리즈 아이디
     */
    func getLike(
        seriesId:String?, hostDevice:HostDevice?, 
        completion: @escaping (Like) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        var params = [String:String]()
        params["response_format"] = SmdNetwork.RESPONSE_FORMET
        params["IF"] = "IF-SMTDV-V5-005"
        params["m"] = "getLikeHate"
        params["stb_id"] = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        params["version_sw"] = hostDevice?.agentVersion ?? ""
        params["total_yn"] = "N"
        params["series_id"] = seriesId ?? ""
        
        fetch(route: SmdLike(query: params), completion: completion, error:error)
    }
    /**
     * BTV 평점 등록 (IF-SMTDV-V5-004)
     * @param seriesId 시리즈 아이디
     * @param likeAction 좋아요정보등록, like_action = 0, 미평가상태, 1 좋아요, 2 별로에요
     */
    func postLike(
        isLike:Bool?, seriesId:String?, hostDevice:HostDevice?,
        completion: @escaping (RegistLike) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        var params = [String:String]()
        params["response_format"] = SmdNetwork.RESPONSE_FORMET
        params["IF"] = "IF-SMTDV-V5-005"
        params["m"] = "registerLikeHate"
        params["stb_id"] = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        params["version_sw"] = hostDevice?.agentVersion ?? ""
        if let like = isLike {
            params["like_action"] = like  ? "1" : "2"
        }else{
            params["like_action"] = "0"
        }
        params["series_id"] = seriesId ?? ""
        fetch(route: SmdLike(query: params), completion: completion, error:error)
    }
}

struct SmdLike:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/delivery/UI5/sd-ui5service"
   var query: [String : String]? = nil
}





