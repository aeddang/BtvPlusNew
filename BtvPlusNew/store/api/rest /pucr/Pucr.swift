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
        return ApiGateway.setDefaultheader(request: request)
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
}

struct PucrConfirmPush:NetworkRoute{
    var method: HTTPMethod = .post
    var messageId:String = ""
    var path: String { get{
        return "/push/v3/messages/" + messageId + "/response"
    }}
    var body: [String : Any]? = nil
}





