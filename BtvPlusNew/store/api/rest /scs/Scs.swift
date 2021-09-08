//
//  Metv.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
struct ScsNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.SCS2)
    
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request)
    }
}
extension ScsNetwork{
    static let RESPONSE_FORMET = "json"
    static let VERSION = "1.0"
    static let TARGET = "BTVPLUS"
    static let DEVICETYPE = ApiPrefix.os
    static func getUserAgentParameter() -> String{
        return SystemEnvironment.model + ";"
            + ApiPrefix.os + "/" + SystemEnvironment.systemVersion + ";"
            + ApiPrefix.service + "/" + SystemEnvironment.bundleVersion
    }
    static func getPlainText(stbId:String,macAdress:String, epsdRsluId:String?) -> String{
        return stbId + "^" + macAdress + "^" + (epsdRsluId ?? "")
    }
    static func getPlainText(stbId:String, epsdRsluId:String?) -> String{
        return stbId + "^" + (epsdRsluId ?? "")
    }
    
    static func getReqData(date:Date) -> String{
        return date.toDateFormatter(dateFormat: "yyyy-MM-dd_HH:mm:ss", local: "en_US_POSIX")
    }
    
    enum ConfirmType: String {
        case adult = "adult"
        case purchase = "purchase"
    }
    
    enum ConnectType: String {
        case regist = "reg"
        case delete = "del"
        case info = "info"
    }
}

class Scs: Rest{
    /**
     * 미리보기 3분 기능 (IF-SCS-PRODUCT-UI520-013)
     * @param epsdRsluId 에피소드 해상도 ID
     */
    func getPreview(
        epsdRsluId:String?, hostDevice:HostDevice?,
        completion: @escaping (Preview) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let date = Date()
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        let macAdress = hostDevice?.apiMacAdress ?? ApiConst.defaultMacAdress
        let plainText = ScsNetwork.getPlainText(stbId: stbId , macAdress: macAdress, epsdRsluId: epsdRsluId)
        var params = [String:String]()
        params["if"] = "IF-SCS-PRODUCT-UI520-013"
        params["ver"] = ScsNetwork.VERSION
        params["stb_id"] = stbId
        params["mac_address"] = macAdress
        params["cid"] = epsdRsluId
        params["eag_protocol"] = "NONE"
        params["userAgent"] = "NONE"
        params["swVersion"] = "NONE"
        params["devicetype"] = ScsNetwork.DEVICETYPE
        params["target_system"] = ScsNetwork.TARGET
        params["m_useragent"] = ScsNetwork.getUserAgentParameter()
        params["verf_req_data"] = ApiUtil.getSCSVerfReqData(stbId, plainText: plainText, date: date)
        params["req_date"] = ScsNetwork.getReqData(date:date)
        params["method"] = "get"
        fetch(route: ScsPreview(query: params), completion: completion, error:error)
    }
    
    /**
     * Btv Plus 예고편 재생 (IF-SCS-PRODUCT-UI520-015)
     * @param epsdRsluId 에피소드 해상도 ID
     * @param preFlag 예고편인 경우 false, 본편시 true
     */
    func getPreplay(
        epsdRsluId:String?, isPreview:Bool?,
        completion: @escaping (Preview) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let date = Date()
        let stbId = ApiConst.defaultStbId
        let macAdress = ApiConst.defaultMacAdress
        let plainText = ScsNetwork.getPlainText(stbId: stbId , macAdress: macAdress, epsdRsluId: epsdRsluId)
        var params = [String:String]()
        params["if"] = "IF-SCS-PRODUCT-UI520-015"
        params["ver"] = ScsNetwork.VERSION
        params["stb_id"] = stbId
        params["cid"] = epsdRsluId
        params["pre_flag"] = isPreview == true ? "N" : "Y"
        params["devicetype"] = ScsNetwork.DEVICETYPE
        params["m_useragent"] = ScsNetwork.getUserAgentParameter()
        params["verf_req_data"] = ApiUtil.getSCSVerfReqData(stbId, plainText: plainText, date: date)
        params["req_date"] = ScsNetwork.getReqData(date:date)
        params["method"] = "get"
        
        fetch(route: ScsPreplay(query: params), completion: completion, error:error)
    }
    
    /**
     * 상품정보 조회(Btv Plus) (IF-SCS-PRODUCT-UI512-007)
     * @param epsdRsluId 에피소드 해상도 ID
     */
    func getPlay(
        epsdRsluId:String?, hostDevice:HostDevice?,
        completion: @escaping (Play) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let date = Date()
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        //let macAdress = hostDevice?.apiMacAdress ?? ApiConst.defaultMacAdress
        let plainText = ScsNetwork.getPlainText(stbId: stbId , epsdRsluId: epsdRsluId)
        var params = [String:String]()
        params["if"] = "IF-SCS-PRODUCT-UI512-007"
        params["ver"] = ScsNetwork.VERSION
        params["stb_id"] = stbId
        params["cid"] = epsdRsluId
        params["devicetype"] = ScsNetwork.DEVICETYPE
        params["useragent"] = ScsNetwork.getUserAgentParameter()
        params["verf_req_data"] = ApiUtil.getSCSVerfReqData(stbId, plainText: plainText, date: date)
        params["req_date"] = ScsNetwork.getReqData(date:date)
        params["method"] = "get"
        
        DataLog.d("epsdRsluId : " + (epsdRsluId ?? ""), tag: "상품정보 조회")
        fetch(route: ScsPlay(query: params), completion: completion, error:error)
    }
    
    /**
     * 비밀번호 확인 요청 (IF-SCS-004)
     */
    func confirmPassword(
        pw:String?, hostDevice:HostDevice?, type:ScsNetwork.ConfirmType?,
        completion: @escaping (ConfirmPassword) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        let macAdress = hostDevice?.apiMacAdress ?? ApiConst.defaultMacAdress
        
        var params = [String:String]()
        params["if"] = "IF-SCS-GWSVC-UI5-002"
        params["ver"] = ScsNetwork.VERSION
        params["stb_id"] = stbId
        params["mac_address"] = macAdress
        params["passwd"] = pw;
        params["passwd_type"] = type?.rawValue ?? ScsNetwork.ConfirmType.adult.rawValue;
        params["method"] = "get"
        
        fetch(route: ScsConfirmPassword(query: params), completion: completion, error:error)
    }
    
    /**
     * 모바일 해지 셋탑 연결 정보 등록 (IF-SCS-STB-UI522-004)
     * @param stbId 연결할 해지된 셋탑 * mode 파라메터 값이 info 일 경우는 noStbId 로 값을 넣는다.
     */
    func connectTerminateStb(
        type:ScsNetwork.ConnectType, stbId:String?,
        completion: @escaping (ConnectTerminateStb) -> Void, error: ((_ e:Error) -> Void)? = nil){
          
        var params = [String:Any]()
        params["if"] = "IF-SCS-STB-UI522-004"
        params["ver"] = ScsNetwork.VERSION
        params["stb_id"] = stbId ?? "noStbId"
        params["mode"] = type.rawValue
        params["mbtv_key"] = type == .info ? "noMbtvKey" : SystemEnvironment.deviceId
        params["method"] = "post"
        fetch(route: ScsConnectTerminateStb(body: params), completion: completion, error:error)
    }
    
    /**
     * STB 정보 확인 (IF-SCS-STBINFO-UI5-001)
     */
    func getStbInfo(
        hostDevice:HostDevice?,
        completion: @escaping (StbInfo) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        let macAdress = hostDevice?.apiMacAdress ?? ApiConst.defaultMacAdress
        
        var params = [String:Any]()
        params["if"] = "IF-SCS-STB-UI5-001"
        params["ver"] = ScsNetwork.VERSION
        params["stb_id"] = stbId
        params["mac_address"] = macAdress
      
        params["method"] = "post"
        
        fetch(route: ScsStbInfo(body: params), completion: completion, error:error)
    }
}

struct ScsPreview:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/scs/v520/preview/mobilebtv"
   var query: [String : String]? = nil
}
struct ScsPreplay:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/scs/v520/preplay/mobilebtv"
   var query: [String : String]? = nil
}

struct ScsPlay:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/scs/v512/product/btvplus/mobilebtv"
   var query: [String : String]? = nil
}

struct ScsConfirmPassword:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/scs/v5/password/confirm/mobilebtv"
   var query: [String : String]? = nil
 
}

struct ScsConnectTerminateStb:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/scs/v522/mcancelstblink/mobilebtv"
   var body: [String : Any]? = nil
}

struct ScsStbInfo:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/scs/v5/stbmapping"
   var body: [String : Any]? = nil
}


