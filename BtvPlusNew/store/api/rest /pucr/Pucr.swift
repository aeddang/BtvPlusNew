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
        authorizationRequest.addValue( "application/x-www-form-urlencoded; charset=UTF-8",forHTTPHeaderField: "Content-Type")
        return authorizationRequest
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
        completion: @escaping (EndPoint) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let qurryString =
            "device_type=" + ApiUtil.string(byUrlEncoding: PucrNetwork.DEVICE_TYPE) +
            "&device_token=" + ApiUtil.string(byUrlEncoding:SystemEnvironment.deviceId) +
            "&sdk_version=" + ApiUtil.string(byUrlEncoding:PucrNetwork.SDK_VS) +
            "&os_version=" + ApiUtil.string(byUrlEncoding:SystemEnvironment.systemVersion) +
            "&manufacturer=" + ApiUtil.string(byUrlEncoding:PucrNetwork.MANYFACTURER) +
            "&model=" + ApiUtil.string(byUrlEncoding:SystemEnvironment.model) +
            "&product=" + ApiUtil.string(byUrlEncoding:SystemEnvironment.model)
        
        fetch(route: PucrCreateEndPoint(jsonString: qurryString), completion: completion, error:error)
    }
    
    /**
     * 푸시 토큰 등록 (IF-PUCR-020)
     */
    func registerToken(
        endpointId:String, token:String,
        completion: @escaping (PucrResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:Any]()
        params["token"] = token
        params["method"] = "post"
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
        params["method"] = "post"
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
        params["method"] = "post"
        fetch(route: PucrConfirmPush( messageId:messageId, body: params), completion: completion, error:error)
    }
}

struct PucrCreateEndPoint:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/push/v3/endpoints"
    var jsonString: String?
    //var body: [String : Any]? = nil
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
}

struct PucrConfirmPush:NetworkRoute{
    var method: HTTPMethod = .post
    var messageId:String = ""
    var path: String { get{
        return "/push/v3/messages/" + messageId + "/response"
    }}
    var body: [String : Any]? = nil
}





