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
    /** 0804 -> SCS -002 synopsisType 2번 사용 안함 빼기
    * 바로보기 (IF-ME-061)
    * @param srisId 최근본회차 시청정보, 즐겨찾기 확인  + 컨텐츠의 sris_id + 필수
    * @param synopsisType 시놉시스 확인 식별자 값 설명 - 1 : 단편시놉 진입시  - 2 : 시즌시놉 회차이동시 - 3. : 시즌시놉 최초진입 또는 시즌변경시
    * @param ppvProducts 단편 또는 시즌 회차별 바로보기 여부 확인시의 요청 상품리스트
    * @param ppsProducts 시즌시놉의 바로보기 여부 확인 요청 상품리스트
    */
    func getDirectView(
        data:SynopsisModel,anotherStbId:String? = nil,
        completion: @escaping (DirectView) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let stbId = anotherStbId ?? ( NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId )
        var params = [String:Any]()
        params["response_format"] = ScsNetwork.RESPONSE_FORMET
        params["ver"] = ScsNetwork.VERSION
        params["IF"] = "IF-ME-061"
        params["stb_id"] = stbId
        params["hash_id"] = ApiUtil.getHashId(stbId)
        params["sris_id"] = data.srisId ?? ""
        params["synopsis_type"] = data.synopsisType.code
        params["omni_ppm_info_flag"] = data.hasOmnipack ? "Y" : "N"
        //params["muser_num"] = ""
        //params["version"] = ""
        if !data.ppsProducts.isEmpty {
            params["pps_products"] = data.ppsProducts
        }
        params["ppv_products"] = data.ppvProducts
        
        var overrideHeaders:[String : String]? = nil
        if let another = anotherStbId {
            overrideHeaders = [String:String]()
            overrideHeaders?["Client_ID"] = another
        }
        fetch(route: ScsDirectview( body: params, overrideHeaders:overrideHeaders), completion: completion, error:error)
    }
    
    /** 0804 -> SCS -002
    * 게이트웨이시놉 바로보기 (IF-ME-062)
    * @param reqPidList 바로보기 확인용 상품ID 리스트 집합
    * @param isPPM 월정액 전용 게이트웨이 시놉 바로보기 확인여부 체크(Y/N)
    */
    func getPackageDirectView(
        data:SynopsisPackageModel? = nil, isPpm:Bool = false , pidList:[String]? = nil, anotherStbId:String? = nil,
        completion: @escaping (DirectPackageView) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = anotherStbId ?? ( NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId )
        
        var params = [String:Any]()
        params["response_format"] = ScsNetwork.RESPONSE_FORMET
        params["ver"] = ScsNetwork.VERSION
        params["IF"] = "IF-ME-062"
        
        params["stb_id"] = stbId
        params["hash_id"] = ApiUtil.getHashId(stbId)
        params["req_pidList"] = pidList ?? [ data?.prdPrcId ?? "" ]
        params["yn_ppm"] = isPpm ? "Y": "N"
        var overrideHeaders:[String : String]? = nil
        if let another = anotherStbId {
            overrideHeaders = [String:String]()
            overrideHeaders?["Client_ID"] = another
        }
        fetch(route: ScsPackageDirectview( body: params,
                                            overrideHeaders:overrideHeaders), completion: completion, error:error)
    }
    /**
     * 미리보기 3분 기능 (IF-SCS-PRODUCT-UI520-013)
     * @param epsdRsluId 에피소드 해상도 ID
     */
    func getPreview(
        epsdRsluId:String?, hostDevice:HostDevice?,
        completion: @escaping (Preview) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let date = Date()
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        let macAdress = hostDevice?.playMacAdress ?? ""
        let plainText = ScsNetwork.getPlainText(stbId: stbId , macAdress: macAdress, epsdRsluId: epsdRsluId)
        var params = [String:String]()
        params["if"] = "IF-SCS-PRODUCT-UI520-013"
        params["ver"] = ScsNetwork.VERSION
        params["stb_id"] = stbId
       
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
        params["m_drm"] = "fairplay"
        params["use_subtitle_yn"] = "n"
        params["mac_address"] = macAdress
        params["mac_exclude_check_yn"] = macAdress.isEmpty == false ? "N" : "Y"
        fetch(route: ScsPreview(query: params), completion: completion, error:error)
    }
    
    /**
     * Btv Plus 예고편 재생 (IF-SCS-PRODUCT-UI520-015)
     * @param epsdRsluId 에피소드 해상도 ID
     * @param preFlag 예고편인 경우 false, 본편시 true
     */
    func getPreplay(
        epsdRsluId:String?, isPreview:Bool?, hostDevice:HostDevice?,
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
        params["m_drm"] = "fairplay"
        params["use_subtitle_yn"] = "n"
        
        params["mac_address"] = ""
        params["mac_exclude_check_yn"] = "Y"
            
        //params["mac_address"] = macAdress
        //params["mac_exclude_check_yn"] = macAdress.isEmpty == false ? "N" : "Y"
        fetch(route: ScsPreplay(query: params), completion: completion, error:error)
    }
    
    /**
     * 상품정보 조회(Btv Plus) (IF-SCS-PRODUCT-UI512-007)
     * @param epsdRsluId 에피소드 해상도 ID
     */
    func getPlay(
        epsdRsluId:String?, anotherStbId:String? = nil, hostDevice:HostDevice?,
        completion: @escaping (Play) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let date = Date()
        var params = [String:String]()
        let macAdress = hostDevice?.playMacAdress ?? ""
        var stbId = ""
        var path = ""
        var overrideHeaders:[String : String]? = nil
        if let anotherStbId = anotherStbId {
            stbId = anotherStbId
            params["if"] = "IF-SCS-PRODUCT-UI512-018"
            params["mbtv_key"] = SystemEnvironment.deviceId
            overrideHeaders = [String:String]()
            overrideHeaders?["Client_ID"] = anotherStbId
            path = "/scs/v522/playcancelstb/mobilebtv"
        } else {
            params["if"] = "IF-SCS-PRODUCT-UI512-007"
            stbId =  NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
            path = "/scs/v512/product/btvplus/mobilebtv"
        }
        let plainText = ScsNetwork.getPlainText(stbId: stbId , epsdRsluId: epsdRsluId)
       
        params["ver"] = ScsNetwork.VERSION
        params["stb_id"] = stbId
        params["cid"] = epsdRsluId
        params["devicetype"] = ScsNetwork.DEVICETYPE
        params["useragent"] = ScsNetwork.getUserAgentParameter()
        params["verf_req_data"] = ApiUtil.getSCSVerfReqData(stbId, plainText: plainText, date: date)
        params["req_date"] = ScsNetwork.getReqData(date:date)
        params["method"] = "get"
        params["m_drm"] = "fairplay" //SystemEnvironment.isStage ? "fairplay" : ""
        params["use_subtitle_yn"] = "n"
        params["mac_address"] = macAdress
        params["mac_exclude_check_yn"] = macAdress.isEmpty == false ? "N" : "Y"
        fetch(route: ScsPlay(path:path, query: params, overrideHeaders: overrideHeaders), completion: completion, error:error)

    }
    
    /**
     * 비밀번호 확인 요청 (IF-SCS-004)
     */
    func confirmPassword(
        pw:String?, hostDevice:HostDevice?, type:ScsNetwork.ConfirmType?,
        completion: @escaping (ConfirmPassword) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var macAdress = hostDevice?.playMacAdress ?? ""
        if !macAdress.isEmpty {
            macAdress = hostDevice?.apiMacAdress ?? ""
        }
        var params = [String:String]()
        params["if"] = "IF-SCS-GWSVC-UI5-002"
        params["ver"] = ScsNetwork.VERSION
        params["stb_id"] = stbId
        params["mac_address"] = macAdress
        params["passwd"] = pw;
        params["passwd_type"] = type?.rawValue ?? ScsNetwork.ConfirmType.adult.rawValue;
        params["method"] = "get"
            
        params["mac_exclude_check_yn"] = macAdress.isEmpty == false ? "N" : "Y"
        fetch(route: ScsConfirmPassword(query: params), completion: completion, error:error)
    }
    
    
    /**
     * STB 정보 확인 (IF-SCS-STBINFO-UI5-001)
     */
    func getStbInfo(
        hostDevice:HostDevice?,
        completion: @escaping (StbInfo) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        let macAdress = hostDevice?.playMacAdress ?? ""
        
        var params = [String:Any]()
        params["if"] = "IF-SCS-STB-UI5-001"
        params["ver"] = ScsNetwork.VERSION
        params["stb_id"] = stbId
        params["mac_address"] = macAdress
        params["method"] = "post"
        params["mac_exclude_check_yn"] = macAdress.isEmpty == false ? "N" : "Y"
        fetch(route: ScsStbInfo(body: params), completion: completion, error:error)
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
    
    
}

struct ScsDirectview:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/scs/v523/directview/mobilebtv"
   var body: [String : Any]? = nil
   var overrideHeaders: [String : String]? = nil
}

struct ScsPackageDirectview:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/scs/v523/directviewgateway/mobilebtv"
   var body: [String : Any]? = nil
   var overrideHeaders: [String : String]? = nil
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
    var overrideHeaders: [String : String]? = nil
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


