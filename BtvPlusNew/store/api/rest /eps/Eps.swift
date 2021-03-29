//
//  Metv.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
struct EpsNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.EPS2)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request)
    }
}
extension EpsNetwork{
    static let RESPONSE_FORMET = "json"
    static let SVC_CODE = "BTV"
    static let VERSION = "5.0"
    
    static let PAGE_COUNT = 30
    static let CLIENT_NAME = "BtvPlus"
    static let UI_NAME = "BTVUH2V500"

}

class Eps: Rest{
    /**
     * STB의 보유 통합 포인트 조회 (IF-EPS-010)
     */
    func getTotalPointInfo(
        hostDevice:HostDevice?,
        completion: @escaping (TotalPointInfo) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let macAdress = hostDevice?.convertMacAdress ?? ApiConst.defaultMacAdress
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["response_format"] = EpsNetwork.RESPONSE_FORMET
        params["ver"] = EpsNetwork.VERSION
        params["client_name"] = EpsNetwork.CLIENT_NAME
        params["ui_name"] = EpsNetwork.UI_NAME
        params["IF"] = "IF-EPS-010"
        params["stb_id"] = stbId
        params["mac"] = macAdress
        fetch(route: EpsTotalPointInfo(query: params), completion: completion, error:error)
    }
    
    /**
     * STB의 보유 통합 포인트 조회 (IF-EPS-300)
     * @param isSimple "간소화 모드 여부 - Y: 간소화 모드 (하위 목록을 응답하지 않음) - N: 상세 모드 (Default, 하위 목록 응답 함.) ※ 성능 개선을 위해 추가되었으며 신규 개발 또는 변경 되는 STB와 Mobile은 ynSimple을 무조건 'Y'로 설정해야 하고 요청해야 한다."
     */
    func getTotalPoint(
        hostDevice:HostDevice?, isSimple:Bool = true,
        completion: @escaping (TotalPoint) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let macAdress = hostDevice?.convertMacAdress ?? ApiConst.defaultMacAdress
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["response_format"] = EpsNetwork.RESPONSE_FORMET
        params["ver"] = EpsNetwork.VERSION
        params["client_name"] = EpsNetwork.CLIENT_NAME
        params["ui_name"] = EpsNetwork.UI_NAME
        params["IF"] = "IF-EPS-300"
        params["stb_id"] = stbId
        params["mac"] = macAdress
        params["ynSimple"] = isSimple ? "Y" : "N"
        fetch(route: EpsTotalPoint(query: params), completion: completion, error:error)
    }
   
}

struct EpsTotalPointInfo:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "/eps/v5/points/total"
    var query: [String : String]? = nil
}

struct EpsTotalPoint:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "/eps/v5/settopbox/points/mobilebtv"
    var query: [String : String]? = nil
}


