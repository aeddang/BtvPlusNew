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
        authorizationRequest.setValue(
            "Basic MTcyOWQ3M2QxOTcwNGI0NGExZTg2OTdkZjM0NWYzZDI6Zjc5YzMyOTI4MGY5NGE4M2I1MmJiYmUyMDYzYTA0ZGE=",
            forHTTPHeaderField: "Authorization")
        authorizationRequest.setValue( "application/x-www-form-urlencoded; charset=UTF-8",forHTTPHeaderField: "Content-Type")
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
        completion: @escaping (Blank) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let qurryString = "token=" + ApiUtil.string(byUrlEncoding: token).replace(" ", with:"")
        fetch(route: PucrRegisterToken( endpointId: endpointId, jsonString: qurryString ), completion: completion, error:error)
    }
    
    /**
     * 메시지 단말 수신 알림 (IF-PUCR-030)
     */
    func recivePush(
        endpointId:String, messageId:String,
        completion: @escaping (PucrResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let qurryString = "endpoint_id=" + ApiUtil.string(byUrlEncoding: endpointId)
        fetch(route: PucrRecivePush( messageId: messageId, jsonString: qurryString), completion: completion, error:error)
    }
    
    /**
     * 메시지 사용자 확인 알림 (IF-PUCR-040)
     */
    func confirmPush(
        endpointId:String, messageId:String,
        completion: @escaping (PucrResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let qurryString = "endpoint_id=" + ApiUtil.string(byUrlEncoding: endpointId)
        fetch(route: PucrConfirmPush( messageId:messageId, jsonString: qurryString), completion: completion, error:error)
    }
}

struct PucrCreateEndPoint:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/push/v3/endpoints"
    var jsonString: String?
   
}

struct PucrRegisterToken:NetworkRoute{
    var method: HTTPMethod = .post
    var endpointId:String = ""
    var path: String { get{
        return "/push/v3/endpoints/" + endpointId + "/tokens/apns"
    }}
    var jsonString: String?
}

struct PucrRecivePush:NetworkRoute{
    var method: HTTPMethod = .post
    var messageId:String = ""
    var path: String { get{
        return "/push/v3/messages/" + messageId + "/ack"
    }}
    var jsonString: String?
}

struct PucrConfirmPush:NetworkRoute{
    var method: HTTPMethod = .post
    var messageId:String = ""
    var path: String { get{
        return "/push/v3/messages/" + messageId + "/response"
    }}
    var jsonString: String?
}





