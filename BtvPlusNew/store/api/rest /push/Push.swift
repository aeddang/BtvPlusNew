//
//  Rps.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/28.
//

import Foundation

struct PushNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.PUSH)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setDefaultheader(request: request)
    }
}
extension PushNetwork{
    static let VERSION = "1.0"
    static let DEVICE_TYPE = "APNS"
    static let APP_ID = "3100001"
    static let MANYFACTURER = "Apple"
}

class Push: Rest{
    /**
     * 유저 Endpoint 등록 (IF-PUSH-101)
     */
    func registEndpoint(
        endpointId:String, isAgree:Bool,
        completion: @escaping (PushResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:Any]()
        params["if_id"] = "IF-PUSH-101"
        params["ver"] = PushNetwork.VERSION
        params["endpoint"] = endpointId
        params["agr_yn_mkt_info"] = isAgree ? "Y" : "N"
        params["agr_yn_push"] = isAgree ? "Y" : "N"
        params["device_type"] = PushNetwork.DEVICE_TYPE
        params["app_id"] = PushNetwork.APP_ID
        params["sender_name"] = "btv plus,ios " + SystemEnvironment.systemVersion + "," + SystemEnvironment.bundleVersion
        params["cuid"] = PushManager.currentCuid
        fetch(route: PushRegistEndpoint(body: params), completion: completion, error:error)
    }
    
    /**
     * 마케팅 및 알림 수신 동의 여부 변경 (IF-PUSH-102)
     */
    func updatePushUserAgreement(
        isAgree:Bool,
        completion: @escaping (PushResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        var params = [String:Any]()
        params["if_id"] = "IF-PUSH-102"
        params["ver"] = PushNetwork.VERSION
        params["agr_yn_mkt_info"] = isAgree ? "Y" : "N"
        params["agr_yn_push"] = isAgree ? "Y" : "N"
        params["device_type"] = PushNetwork.DEVICE_TYPE
        params["app_id"] = PushNetwork.APP_ID
        params["cuid"] = PushManager.currentCuid
        fetch(route: PushUpdatePushUserAgreement(body: params), completion: completion, error:error)
    }
}

struct PushRegistEndpoint:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/endpoint/register"
    var body: [String : Any]? = nil
}

struct PushUpdatePushUserAgreement:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/endpoint/marketing"
    var body: [String : Any]? = nil
}

