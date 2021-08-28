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
        var authorizationRequest = request
        authorizationRequest.addValue(
            "Basic MTcyOWQ3M2QxOTcwNGI0NGExZTg2OTdkZjM0NWYzZDI6Zjc5YzMyOTI4MGY5NGE4M2I1MmJiYmUyMDYzYTA0ZGE=",
            forHTTPHeaderField: "Authorization")
        return authorizationRequest
    }
}
extension PucrNetwork{
    static let DEVICE_TYPE = "iOS"
    static let SDK_VS = "iOS:4.0"
    static let MANYFACTURER = "Apple"
    static let CONTENT_TYPE = "application/x-www-form-urlencoded; charset=UTF-8"
}

class Pucr: Rest{
    /**
     * 유저 Endpoint 생성 (IF-PUCR-010)
     */
    func createEndpoint(
        completion: @escaping (EndPoint) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let plmn = SystemEnvironment.getPlmn()
        var params = [String:Any]()
        params["device_type"] = PucrNetwork.DEVICE_TYPE
        params["device_token"] = SystemEnvironment.deviceId
        params["sdk_version"] = "sdk_type:" + PucrNetwork.SDK_VS
        params["os_version"] = SystemEnvironment.systemVersion
        params["manufacturer"] = PucrNetwork.MANYFACTURER
        params["model"] = SystemEnvironment.model
        params["product"] = SystemEnvironment.model
        params["plmn"] = plmn
        params["sim_plmn"] = plmn
        fetch(route: PucrCreateEndPoint(body: params), completion: completion, error:error)
    }
    
    /**
     * 푸시 토큰 등록 (IF-PUCR-020)
     */
    func registerToken(
        endpointId:String, token:String,
        completion: @escaping (PucrResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:Any]()
        params["token"] = token
        fetch(route: PucrRegisterToken( endpointId: endpointId, body: params), completion: completion, error:error)
    }
    
    /**
     * 메시지 단말 수신 알림 (IF-PUCR-030)
     */
    func recivePush(
        endpointId:String, messageId:String,
        completion: @escaping (PucrResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
    
        var params = [String:Any]()
        params["endpoint_id"] = endpointId
        fetch(route: PucrRecivePush( messageId: messageId, body: params), completion: completion, error:error)
    }
    
    /**
     * 메시지 사용자 확인 알림 (IF-PUCR-040)
     */
    func confirmPush(
        endpointId:String, messageId:String,
        completion: @escaping (PucrResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
    
        var params = [String:Any]()
        params["endpoint_id"] = endpointId
        fetch(route: PucrConfirmPush( messageId:messageId, body: params), completion: completion, error:error)
    }
}

struct PucrCreateEndPoint:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/push/v3/endpoints"
    var body: [String : Any]? = nil
}

struct PucrRegisterToken:NetworkRoute{
    var method: HTTPMethod = .post
    var endpointId:String = ""
    var path: String { get{
        return "/push/v3/endpoints/" + endpointId + "/tokens/apns"
    }}
    var body: [String : Any]? = nil
}

struct PucrRecivePush:NetworkRoute{
    var method: HTTPMethod = .post
    var messageId:String = ""
    var path: String { get{
        return "/push/v3/messages/" + messageId + "/ack"
    }}
    var body: [String : Any]? = nil
    var contentType: String? = PucrNetwork.CONTENT_TYPE
}

struct PucrConfirmPush:NetworkRoute{
    var method: HTTPMethod = .post
    var messageId:String = ""
    var path: String { get{
        return "/push/v3/messages/" + messageId + "/response"
    }}
    var body: [String : Any]? = nil
    var contentType: String? = PucrNetwork.CONTENT_TYPE
}





