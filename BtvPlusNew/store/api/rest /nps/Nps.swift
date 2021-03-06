//
//  Metv.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
struct NpsNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.NPS_V5)
    /*
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        var authorizationRequest = request
        authorizationRequest.addValue("ver", forHTTPHeaderField: Self.VERSION)
        authorizationRequest.addValue("sender_name", forHTTPHeaderField: Self.getSenderName())
        authorizationRequest.addValue("response_format", forHTTPHeaderField: Self.RESPONSE_FORMET)
        authorizationRequest.addValue("sender", forHTTPHeaderField: Self.SENDER)
        authorizationRequest.addValue("receiver", forHTTPHeaderField: Self.RECEIVER)
        return authorizationRequest
    }
    */
}
extension NpsNetwork{
    static let RESPONSE_FORMET = "json"
    static let VERSION = "5.0"
    static let SERVICE_TYPE = "B"
    static let SERVICE_NAME = "com.skb.btvplus"
    static let SENDER = "Mobile"
    static let RECEIVER = "NPS"
    static let APP_NAME = "btv plus"
    static let TEST_APP_NAME = "b tv plus"
    static let TEST_APP_VERSION = "4.0.0"
    
    static let USER_ID = ""
    static let DEVICE_TYPE = "G"
    
    static let AES_KEY = "R3WoPEtbkEIhPQqrKl37fQEsfZAYpPMk"
    static let AES_IV = "8C7BFE4A1116E5E5"
    static let AES_PW  = "sFJ4y3uJ8Pcz2BCp82Ds6VPByNX2vG8u"
    static private(set) var isHelloInit = true
    static private(set) var isTest = false
    static private(set) var sessionId = ""
    static private(set) var pairingId = ""
    static private(set) var pairingStatus = ""
    static private(set) var hostDeviceId:String? = nil
    
    static func goodbye() {
        Self.sessionId = ""
    }
    
    static func hello(res:ApiResultResponds) -> String? {
        guard let resData = res.data as? Hello else { return nil }
        if resData.header?.result != NpsNetwork.resultCode.success.code { return nil}
        guard let sessionId = resData.body?.sessionid else { return nil }
        Self.sessionId = sessionId
        Self.pairingId = resData.body?.pairingid ?? ""
        Self.hostDeviceId = resData.body?.host_deviceid
        if Self.hostDeviceId == "" { Self.hostDeviceId = nil }
        guard let body = resData.body else { return nil }
        guard let ip = body.ip else { return nil }
        guard let port = body.port else { return nil }
        let path = "http://" +  ip + ":" + port
        Self.isHelloInit = false
        return path
    }
    
    static func resetPairing() {
        Self.pairingId = ""
        Self.hostDeviceId = nil
        Self.pairingStatus = ""
    }
    static func pairing(res:ApiResultResponds) {
        guard let resData = res.data as? DevicePairing  else { return }
        guard let resultCode = resData.header?.result else { return }
        if resultCode != NpsNetwork.resultCode.success.code { return }
        guard let pairingid = resData.body?.pairingid else { return }
        Self.pairingId = pairingid
        Self.hostDeviceId = resData.body?.host_deviceid
    }
    
    static func unpairing(res:ApiResultResponds) {
        guard let resData = res.data as? NpsResult  else { return }
        if resData.header?.result != NpsNetwork.resultCode.success.code { return }
        Self.pairingId = ""
        Self.hostDeviceId = nil
        Self.pairingStatus = ""
    }
    static func checkPairing(res:ApiResultResponds) {
        guard let resData = res.data as? DevicePairingStatus  else { return }
        if resData.header?.result != NpsNetwork.resultCode.success.code { return }
        guard let pairingStatus = resData.body?.pairing_status else { return }
        Self.pairingStatus = pairingStatus
        if pairingStatus == "0" {
            Self.pairingId = ""
            Self.hostDeviceId = nil
            Self.pairingStatus = ""
        }
    }
    
    
    static var isPairing:Bool{
        get{
            return Self.pairingId != ""
        }
    }
    
    static func getSenderName() -> String{
        let osName = ApiPrefix.os + " " + SystemEnvironment.systemVersion
        if isTest {
            return Self.TEST_APP_NAME + "," + osName + "," + Self.TEST_APP_VERSION
        }else{
            return Self.APP_NAME + "," + osName + "," + SystemEnvironment.bundleVersion
        }
    }

    static func getNpsUsername(userName:String?) -> String{
        guard let name = userName else { return "0000" }
        if name.count < 4 {
            let diff = 4 - name.count
            return name + ( 0...diff).reduce(""){ str, _ in str + " " }
        }else {
            return name
        }
    }
    
    static func getHeader(ifNo:String)->[String:String]{
        var headers = [String:String]()
        headers["if_no"] = ifNo
        headers["ver"] =  NpsNetwork.VERSION
        headers["sender_name"] =  NpsNetwork.getSenderName()
        headers["response_format"] =  NpsNetwork.RESPONSE_FORMET
        headers["sender"] =  NpsNetwork.SENDER
        headers["receiver"] =  NpsNetwork.RECEIVER
        return headers
    }
    
    enum resultCode:String{
        case success, pairingRetry, pairingLimited,
             authcodeInvalid, authcodeWrong, authcodeTimeout, existPairing
        
        var code:String {
            get {
                switch self {
                case .success: return ApiCode.success
                case .pairingRetry: return "1029"
                case .pairingLimited: return "1028"
                case .authcodeInvalid: return "1005"
                case .authcodeWrong: return "1011"
                case .authcodeTimeout: return "1012"
                case .existPairing: return  "1019"
                //default: return ""
                }
            }
        }
    }
}



class Nps: Rest{
    
    /**
     * @brief hello nps
    */
    func postHello(
        customParam:[String: Any] = [String: Any](),
        completion: @escaping (Hello) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let headers = NpsNetwork.getHeader(ifNo: "IF-NPS-511")
        var params = [String: Any]()
        params["service_type"] = NpsNetwork.SERVICE_TYPE
        params["guest_deviceid"] = SystemEnvironment.getGuestDeviceId()
        params["include_tier"] = "0"
        params["initial_flag"] = NpsNetwork.isHelloInit ? "1" : "0"
        params["custom_param"] = customParam
        var body = [String: Any]()
        body["header"] = headers
        body["body"] = params
        fetch(route: NpsHello(body: body), completion: completion, error:error)
    }
    
    /**
     * @brief 페어링 대상 HostDevice의 요금제 및 페어링 수 조회
     * @param authcode host_device에서 보여지는 인증 코드로 입력받은 6자리 숫자
     * @param hostDeviceId Host Device를 구분할 수 있는 ID
     * @param completion 페어링 대상 HostDevice의 요금제 및 페어링 수 조회 API response
    */
    func getDevicePairingInfo(
        authcode:String?, hostDeviceid:String?, customParam:[String: Any] = [String: Any](),
        completion: @escaping (DevicePairingInfo) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let headers = NpsNetwork.getHeader(ifNo: "IF-NPS-546")
        var params = [String: Any]()
        params["service_type"] = NpsNetwork.SERVICE_TYPE
        params["guest_deviceid"] = SystemEnvironment.getGuestDeviceId()
        params["authcode"] = authcode
        params["host_deviceid"] = hostDeviceid
        params["custom_param"] = customParam
        
        var body = [String: Any]()
        body["header"] = headers
        body["body"] = params
        
        fetch(route: NpsDevicePairingInfo(body: body), completion: completion, error:error)
    }
    
    func getDevicePairingStatus(
        customParam:[String: Any] = [String: Any](),
        completion: @escaping (DevicePairingStatus) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let headers = NpsNetwork.getHeader(ifNo: "IF-NPS-533")
        var params = [String: Any]()
        params["service_type"] = NpsNetwork.SERVICE_TYPE
        params["pairing_deviceid"] = SystemEnvironment.getGuestDeviceId()
        params["pairing_device_type"] =  NpsNetwork.DEVICE_TYPE
        params["pairingid"] = NpsNetwork.pairingId
        params["userId"] = NpsNetwork.USER_ID
        params["custom_param"] = customParam
        
        var body = [String: Any]()
        body["header"] = headers
        body["body"] = params
        
        fetch(route: NpsPairingStatus(body: body), completion: completion, error:error)
    }
    
    func postDevicePairing(
        user:User?, device:StbData?, customParam:[String: Any] = [String: Any](),
        completion: @escaping (DevicePairing) -> Void, error: ((_ e:Error) -> Void)? = nil){
    
        NpsNetwork.resetPairing()
        let headers = NpsNetwork.getHeader(ifNo: "IF-NPS-531")
        var deviceinfo = [String: String]()
        if let device = device {
            deviceinfo["restricted_age"] = device.restrictedAge
            deviceinfo["adult_safety_mode"] = device.isAdultSafetyMode == true ? "1" : "0"
            deviceinfo["stb_src_agent_version"] = device.agentVer
            deviceinfo["stb_mac_address"] = ApiUtil.getEncyptedData(
                forNps: device.macAddress, npsKey: NpsNetwork.AES_KEY, npsIv: NpsNetwork.AES_IV)
                
            deviceinfo["stb_patch_version"] = device.patchVer
            deviceinfo["stb_ui_version"] = device.uiAppVer
        }
        var params = [String: Any]()
        params["service_type"] = NpsNetwork.SERVICE_TYPE
        params["guest_deviceid"] = SystemEnvironment.getGuestDeviceId()
        params["user_name"] = NpsNetwork.getNpsUsername(userName: user?.nickName)
        params["muser_num"] = ""
        params["userid"] =  NpsNetwork.USER_ID
        params["host_deviceinfo"] = deviceinfo
        params["host_deviceid"] = device?.stbid
        params["custom_param"] = customParam
        
        var body = [String: Any]()
        body["header"] = headers
        body["body"] = params
        fetch(route: NpsDevicePairing(body: body), completion: completion, error:error)
    }
    
    func postAuthPairing(
        user:User?, authcode:String?, customParam:[String: Any] = [String: Any](),
        completion: @escaping (DevicePairing) -> Void, error: ((_ e:Error) -> Void)? = nil){
    
        NpsNetwork.resetPairing()
        let headers = NpsNetwork.getHeader(ifNo: "IF-NPS-512")
        var params = [String: Any]()
        params["service_type"] = NpsNetwork.SERVICE_TYPE
        params["guest_deviceid"] = SystemEnvironment.getGuestDeviceId()
        params["user_name"] = NpsNetwork.getNpsUsername(userName: user?.nickName)
        params["sessionid"] = NpsNetwork.sessionId
        params["authcode"] = authcode
        params["muser_num"] = ""
        params["userid"] =  NpsNetwork.USER_ID
        params["custom_param"] = customParam
        
        var body = [String: Any]()
        body["header"] = headers
        body["body"] = params
        fetch(route: NpsAuthPairing(body: body), completion: completion, error:error)
    }
    
    func getHostDeviceInfo(
        customParam:[String: Any] = [String: Any](),
        completion: @escaping (HostDeviceInfo) -> Void, error: ((_ e:Error) -> Void)? = nil){
    
        let headers = NpsNetwork.getHeader(ifNo: "IF-NPS-513")
        var params = [String: Any]()
        params["service_type"] = NpsNetwork.SERVICE_TYPE
        params["guest_deviceid"] = SystemEnvironment.getGuestDeviceId()
        params["sessionid"] = NpsNetwork.sessionId
        params["pairingid"] = NpsNetwork.pairingId
        params["muser_num"] = ""
        params["custom_param"] = customParam
        
        var body = [String: Any]()
        body["header"] = headers
        body["body"] = params
        fetch(route: NpsHostDeviceInfo(body: body), completion: completion, error:error)
    }
    
    func postGuestInfo(
        user:User?, customParam:[String: Any] = [String: Any](),
        completion: @escaping (NpsResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        var userInfo = [String: String]()
        if let user = user {
            userInfo["gender"] = user.gender.apiValue()
            userInfo["birth_year"] = user.birth.onlyNumric()
        }
        let headers = NpsNetwork.getHeader(ifNo: "IF-NPS-544")
        var params = [String: Any]()
        params["service_type"] = NpsNetwork.SERVICE_TYPE
        params["guest_deviceid"] = SystemEnvironment.getGuestDeviceId()
        params["sessionid"] = NpsNetwork.sessionId
        params["pairingid"] = NpsNetwork.pairingId
        params["guest_deviceinfo"] = userInfo
        params["custom_param"] = customParam
        
        var body = [String: Any]()
        body["header"] = headers
        body["body"] = params
        fetch(route: NpsGuestDeviceInfo(body: body), completion: completion, error:error)
    }
    
    func postGuestNickname(
        user:User?, customParam:[String: Any] = [String: Any](),
        completion: @escaping (NpsResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        
        let headers = NpsNetwork.getHeader(ifNo: "IF-NPS-542")
        var params = [String: Any]()
        params["service_type"] = NpsNetwork.SERVICE_TYPE
        params["guest_deviceid"] = SystemEnvironment.getGuestDeviceId()
        params["sessionid"] = NpsNetwork.sessionId
        params["pairingid"] = NpsNetwork.pairingId
        params["user_name"] = NpsNetwork.getNpsUsername(userName: user?.nickName)
        params["custom_param"] = customParam
        
        var body = [String: Any]()
        body["header"] = headers
        body["body"] = params
        fetch(route: NpsGuestDeviceInfo(body: body), completion: completion, error:error)
    }
    
    func getGuestAgreement(
        customParam:[String: Any] = [String: Any](),
        completion: @escaping (GuestAgreementInfo) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let headers = NpsNetwork.getHeader(ifNo: "IF-NPS-536")
        var params = [String: Any]()
        params["service_type"] = NpsNetwork.SERVICE_TYPE
        params["pairing_deviceid"] = SystemEnvironment.getGuestDeviceId()
        params["pairing_device_type"] = NpsNetwork.DEVICE_TYPE
        params["pairingid"] = NpsNetwork.pairingId
        params["custom_param"] = customParam
    
        var body = [String: Any]()
        body["header"] = headers
        body["body"] = params
        fetch(route: NpsGuestAgreementInfo(body: body), completion: completion, error:error)
    }
    func postGuestAgreement(
        user:User?, customParam:[String: Any] = [String: Any](),
        completion: @escaping (NpsResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var agreement = [String: String]()
        if let user = user {
            agreement["market"] = user.isAgree1 ? "1" : "0"
            agreement["personal"] = user.isAgree2 ? "1" : "0"
            agreement["push"] = user.isAgree3 ? "1" : "0"
        }
        let headers = NpsNetwork.getHeader(ifNo: "IF-NPS-535")
        var params = [String: Any]()
        params["service_type"] = NpsNetwork.SERVICE_TYPE
        params["pairing_deviceid"] = SystemEnvironment.getGuestDeviceId()
        params["pairing_device_type"] = NpsNetwork.DEVICE_TYPE
        params["pairingid"] = NpsNetwork.pairingId
        params["agreement"] = agreement
        params["custom_param"] = customParam
        
        var body = [String: Any]()
        body["header"] = headers
        body["body"] = params
        fetch(route: NpsGuestAgreement(body: body), completion: completion, error:error)
    }
    
    func postUnPairing(
        customParam:[String: Any] = [String: Any](),
        completion: @escaping (NpsResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let headers = NpsNetwork.getHeader(ifNo: "IF-NPS-534")
        var params = [String: Any]()
        params["service_type"] = NpsNetwork.SERVICE_TYPE
        params["pairing_deviceid"] = SystemEnvironment.getGuestDeviceId()
        params["pairing_device_type"] = NpsNetwork.DEVICE_TYPE
        params["pairingid"] = NpsNetwork.pairingId
        params["custom_param"] = customParam

        var body = [String: Any]()
        body["header"] = headers
        body["body"] = params
        fetch(route: NpsUnPairing(body: body), completion: completion, error:error)
    }
}


struct NpsHello:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/nps/v5/reqHello"
   var body: [String : Any]? = nil
}

struct NpsPairingStatus:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/nps/v5/reqPairingStatus"
   var body: [String : Any]? = nil
}

struct NpsDevicePairingInfo:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/nps/v5/reqTierInfo/PairingCount"
   var body: [String : Any]? = nil
}

struct NpsDevicePairing:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/nps/v5/reqPairingInfoRegist"
   var body: [String : Any]? = nil
}

struct NpsAuthPairing:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/nps/v5/reqAuth"
   var body: [String : Any]? = nil
}

struct NpsHostDeviceInfo:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/nps/v5/reqHostDeviceInfo"
   var body: [String : Any]? = nil
}

struct NpsGuestDeviceInfo:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/nps/v5/reqUpdateGuestDeviceInfo"
   var body: [String : Any]? = nil
}

struct NpsGuestAgreement:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/nps/v5/reqUpdateAgreement"
   var body: [String : Any]? = nil
}

struct NpsGuestAgreementInfo:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/nps/v5/reqAgreement"
   var body: [String : Any]? = nil
}

struct NpsUnPairing:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/nps/v5/reqUnPairing"
   var body: [String : Any]? = nil
}





