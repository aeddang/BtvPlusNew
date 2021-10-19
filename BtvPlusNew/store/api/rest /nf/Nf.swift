//
//  Metv.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
struct NfNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.NF)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request)
    }
}
extension NfNetwork{
    static let VERSION = "1.0"
    static let RESPONSE_FORMET = "json"
    static let CFG_TYPE = "contents_update"
    
    enum NotiType:String{
        case movie, season, product
    }
}

struct NotificationData{
    var srisId:String? = nil
    var epsdId:String? = nil
    var type:String? = nil
    var epsdRsluId:String? = nil
    var prdId:String? = nil
    var contentsNm:String? = nil
}

class Nf: Rest{
    /**
     * 알림 조회 하기 (IF-NF-001)
     * @param srisId 컨텐츠 시리즈아이디 (string array)
     * @param epsdId 컨텐츠 에피소드아이디 (string array)
     * @param notiType 알림타입
     */
    func getNotificationVod(
        srisId:[String]?, epsdId:[String]?, type:NfNetwork.NotiType?,
        completion: @escaping (NotificationVod) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["if"] = "IF-NF-001"
        params["ver"] = NfNetwork.VERSION
        params["response_format"] = NfNetwork.RESPONSE_FORMET
        params["dvc_id"] = stbId
        if let ids = srisId , !ids.isEmpty {
            params["sris_id"] = ids.dropFirst().reduce(ids.first!){ a, b in a + "," + b }
        }
        if let ids = epsdId , !ids.isEmpty {
            params["epsd_id"] = ids.dropFirst().reduce(ids.first!){ a, b in a + "," + b }
        }
        params["cfg_type"] = NfNetwork.CFG_TYPE
        fetch(route: NfNotificationVod(query: params), completion: completion, error:error)
    }
    /**
     * 알림 설정 하기 (IF-NF-002)
     * @param prdId 상품 아이디
     * @param srisId 컨텐츠 시리즈아이디
     * @param epsdId 컨텐츠 에피소드아이디
     * @param epsdRsluId 컨텐츠 에피소드해상도아이디
     * @param contentsNm 컨텐츠 이름(100자미만)
     * @param notiType 알림타입
     */
    func postNotificationVod(
        data:NotificationData?,
        completion: @escaping (RegistNotificationVod) -> Void, error: ((_ e:Error) -> Void)? = nil){
        //let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var query = [String:String]()
        query["if"] = "IF-NF-002"
        query["ver"] = NfNetwork.VERSION
        
        var params = [String:String]()
        params["dvc_id"] =  SystemEnvironment.originDeviceId
        params["sris_id"] = data?.srisId ?? ""
        params["epsd_id"] = data?.epsdId ?? ""
        params["prd_id"] = data?.prdId ?? ""
        params["epsd_rslu_id"] = data?.epsdRsluId ?? ""
        params["contents_nm"] = data?.contentsNm ?? ""
        params["noti_type"] = data?.type ?? NfNetwork.NotiType.movie.rawValue
        params["cfg_type"] = NfNetwork.CFG_TYPE
        fetch(route: NfRegisterNotificationVod( query: query, body:params), completion: completion, error:error)
    }
    
    /**
     * 알림 삭제 하기 (IF-NF-003)
     * @param srisId 컨텐츠 시리즈아이디
     */
    func deleteNotificationVod(
        srisId:String?,
        completion: @escaping (RegistNotificationVod) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var query = [String:String]()
        query["if"] = "IF-NF-003"
        query["ver"] = NfNetwork.VERSION
        
        var params = [String:String]()
        params["dvc_id"] = stbId
        params["sris_id"] = srisId
        
        var headers = [String : String]()
        headers["method"] = "delete"
        fetch(route: NfUnregisterNotificationVod(headers: headers, query:query, body: params), completion: completion, error:error)
    }
}

struct NfNotificationVod:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "/nfapi/notification/vod"
    var query: [String : String]? = nil
}

struct NfRegisterNotificationVod:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/nfapi/notification/vod/register"
    var query: [String : String]? = nil
    var body: [String : Any]? = nil
}

struct NfUnregisterNotificationVod:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/nfapi/notification/vod/unregister"
    var headers:[String : String]? = nil
    var query: [String : String]? = nil
    var body: [String : Any]? = nil
}








