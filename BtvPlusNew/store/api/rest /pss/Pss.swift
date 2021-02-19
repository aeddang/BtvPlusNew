//
//  Metv.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
struct PssNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.PSS)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request)
    }
}
extension PssNetwork{
    static let XML_CONTENT_TYPE  = "application/vnd.skb.sts+xml"
    static let RESPONSE_FORMET = "json"
}

class Pss: Rest{
    /**
     * 셋톱박스 정보 요청(페어링 상태 일 경우)
     * @param stbId : (필수) 셋톱박스 ID
     * @param charId : (필수) char ID
     */
    func getPairingUserInfoByPackageID(
        charId:String?,
        completion: @escaping (Blank) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["m"] = "getEpgUserStatus_s1"
        params["stb_id"] = stbId
        params["char_id"] = charId
        fetch(route: PssPairingUserInfo(contentType:PssNetwork.XML_CONTENT_TYPE, query: params), completion: completion, error:error)
    }
    
    /**
     * 사용자 정보 조회(페어링 상태 일 경우)
     * @param stbId : (필수) 셋톱박스 ID
     * @param macAddr : (필수) 맥 주소
     * @param uiName : UI name
     */
    func getPairingUserInfo(
        macAddress:String?, uiName:String?,
        completion: @escaping (PairingUserInfo) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["m"] = "getPSSUserStatus_v1"
        params["stb_id"] = stbId
        params["ui_name"] = (uiName == nil || uiName?.isEmpty == true) ? "BTVLGYV512" : uiName
        params["stb_model"] = "BTVPLUS"
        params["mac_addr"] = macAddress
        params["response_type"] = PssNetwork.RESPONSE_FORMET
        fetch(route: PssPairingUserInfo(query: params), completion: completion, error:error)
    }
}

struct PssPairingUserInfo:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "/epg/serviceAction.hm"
    var contentType: String? = nil
    var query: [String : String]? = nil
}






