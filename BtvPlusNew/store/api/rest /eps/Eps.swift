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
    
    /**
     * 보유 쿠폰 목록 조회 (IF-EPS-401)
     * @param page 요청할 페이지 번호 (page와 count 중 하나라도 생략시 모든 목록 응답, Default = null)
     * @param count 한 페이지에 노출할 쿠폰 개수 (page와 count 중 하나라도 생략시 모든 목록 응답, Default = null)
     */
    func getCoupons(
        hostDevice:HostDevice?, page:Int?, pageCnt:Int?,
        completion: @escaping (Coupons) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let macAdress = hostDevice?.convertMacAdress ?? ApiConst.defaultMacAdress
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["response_format"] = EpsNetwork.RESPONSE_FORMET
        params["ver"] = EpsNetwork.VERSION
        params["client_name"] = EpsNetwork.CLIENT_NAME
        params["ui_name"] = EpsNetwork.UI_NAME
        params["IF"] = "IF-EPS-401"
        params["stb_id"] = stbId
        params["mac"] = macAdress
        params["page"] = page?.description ?? "1"
        params["count"] = pageCnt?.description ?? EpsNetwork.PAGE_COUNT.description
        fetch(route: EpsCoupons(query: params), completion: completion, error:error)
    }
    
    /**
     * 쿠폰 등록 요청 (IF-EPS-410)
     * @param couponNum 쿠폰인증번호, 숫자만 허용 (상담원 또는 이벤트를 통하여 전달 받은 쿠폰 인증 번호 16자리)
     */
    func postCoupon(
        hostDevice:HostDevice?, couponNum:String?,
        completion: @escaping (RegistEps) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let macAdress = hostDevice?.convertMacAdress ?? ApiConst.defaultMacAdress
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = EpsNetwork.RESPONSE_FORMET
        params["ver"] = EpsNetwork.VERSION
        params["client_name"] = EpsNetwork.CLIENT_NAME
        params["ui_name"] = EpsNetwork.UI_NAME
        params["IF"] = "IF-EPS-410"
        params["stb_id"] = stbId
        params["mac"] = macAdress
        fetch(route: EpsPostCoupon( couponId: couponNum ?? "", body: params), completion: completion, error:error)
    }
    
    /**
     * STB의 보유 B포인트 목록 조회 (IF-EPS-751)
     * @param page 요청할 페이지 번호 (page와 count 중 하나라도 생략시 모든 목록 응답, Default = null)
     * @param count 한 페이지에 노출할 쿠폰 개수 (page와 count 중 하나라도 생략시 모든 목록 응답, Default = null)
     */
    func getBPoints(
        hostDevice:HostDevice?, page:Int?, pageCnt:Int?,
        completion: @escaping (BPoints) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let macAdress = hostDevice?.convertMacAdress ?? ApiConst.defaultMacAdress
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["response_format"] = EpsNetwork.RESPONSE_FORMET
        params["ver"] = EpsNetwork.VERSION
        params["client_name"] = EpsNetwork.CLIENT_NAME
        params["ui_name"] = EpsNetwork.UI_NAME
        params["IF"] = "IF-EPS-751"
        params["stb_id"] = stbId
        params["mac"] = macAdress
        params["page"] = page?.description ?? "1"
        params["count"] = pageCnt?.description ?? EpsNetwork.PAGE_COUNT.description
        fetch(route: EpsBPoint(query: params), completion: completion, error:error)
    }
    
    /**
     * B포인트 이용권 등록 요청 (IF-EPS-760)
     * @param pointId B포인트인증번호, 숫자만 허용 (상담원 또는 이벤트를 통하여 전달 받은 B포인트 인증 번호 16자리)
     */
    func postBPoint(
        hostDevice:HostDevice?, pointId:String?,
        completion: @escaping (RegistEps) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let macAdress = hostDevice?.convertMacAdress ?? ApiConst.defaultMacAdress
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = EpsNetwork.RESPONSE_FORMET
        params["ver"] = EpsNetwork.VERSION
        params["client_name"] = EpsNetwork.CLIENT_NAME
        params["ui_name"] = EpsNetwork.UI_NAME
        params["IF"] = "IF-EPS-760"
        params["stb_id"] = stbId
        params["mac"] = macAdress
        fetch(route: EpsPostBPoint( pointId: pointId ?? "", body: params), completion: completion, error:error)
    }
    
    /**
     * STB의 보유 B캐쉬 금액 및 목록 조회 (IF-EPS-701)
     * @param page 요청할 페이지 번호 (page와 count 중 하나라도 생략시 모든 목록 응답, Default = null)
     * @param count 한 페이지에 노출할 B캐쉬 개수 (page와 count 중 하나라도 생략시 모든 목록 응답, Default = null)
     */
    func getBCashes(
        hostDevice:HostDevice?, page:Int?, pageCnt:Int?,
        completion: @escaping (BCashes) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let macAdress = hostDevice?.convertMacAdress ?? ApiConst.defaultMacAdress
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["response_format"] = EpsNetwork.RESPONSE_FORMET
        params["ver"] = EpsNetwork.VERSION
        params["client_name"] = EpsNetwork.CLIENT_NAME
        params["ui_name"] = EpsNetwork.UI_NAME
        params["IF"] = "IF-EPS-701"
        params["stb_id"] = stbId
        params["mac"] = macAdress
        params["page"] = page?.description ?? "1"
        params["count"] = pageCnt?.description ?? EpsNetwork.PAGE_COUNT.description
        fetch(route: EpsBCash(query: params), completion: completion, error:error)
    }
    /**
     * B캐쉬 이용권 등록 요청 (IF-EPS-710)
     * @param cashId B캐쉬인증번호, 숫자만 허용 (상담원 또는 이벤트를 통하여 전달 받은 B캐쉬 인증 번호 16자리)
     */
    func postBCash(
        hostDevice:HostDevice?, cashId:String?,
        completion: @escaping (RegistEps) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let macAdress = hostDevice?.convertMacAdress ?? ApiConst.defaultMacAdress
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = EpsNetwork.RESPONSE_FORMET
        params["ver"] = EpsNetwork.VERSION
        params["client_name"] = EpsNetwork.CLIENT_NAME
        params["ui_name"] = EpsNetwork.UI_NAME
        params["IF"] = "IF-EPS-710"
        params["stb_id"] = stbId
        params["mac"] = macAdress
        fetch(route: EpsPostBCash( cashId: cashId ?? "", body: params), completion: completion, error:error)
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

struct EpsCoupons:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "/eps/v5/coupons/mobilebtv"
    var query: [String : String]? = nil
}
struct EpsPostCoupon:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String { get{
        return "/eps/v5/coupons/" + couponId + "?method=POST"
    }}
    var couponId:String = ""
    var body: [String : Any]? = nil
}

struct EpsBPoint:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "/eps/v5/newBpoints"
    var query: [String : String]? = nil
}
struct EpsPostBPoint:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String { get{
        return "/eps/v5/newBpoints" + pointId + "?method=POST"
    }}
    var pointId:String = ""
    var body: [String : Any]? = nil
}

struct EpsBCash:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "/eps/v5/bcash"
    var query: [String : String]? = nil
}
struct EpsPostBCash:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String { get{
        return "/eps/v5/bcash" + cashId + "?method=POST"
    }}
    var cashId:String = ""
    var body: [String : Any]? = nil
}
