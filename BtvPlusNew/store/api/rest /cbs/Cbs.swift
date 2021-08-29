//
//  Metv.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
struct CbsNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.CBS)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        var authorizationRequest = request
        authorizationRequest.addValue( "application/x-www-form-urlencoded; charset=UTF-8",forHTTPHeaderField: "Content-Type")
        authorizationRequest.addValue( "application/json;charset=utf-8",forHTTPHeaderField: "Accept")
        
        return authorizationRequest
    }
    
}
extension CbsNetwork{
    static let KEY_STBID_SVCNUM = "BtvcmoneyissueWithSKBroadband120"
    static let KEY_DATA = "BtvcmoneyissueWithSKBroadband123"
    
    static func getClientTime()->String {
        return Date().toDateFormatter(dateFormat: "YYYY-MM-DD hh:mm:ss", local: "en_US_POSIX")
    }
    
    static func getCertificationErrorMeassage(_ result:String?, reason:String?)->String {
        guard let result = result else { return String.alert.couponRegistFail }
        guard let reason = reason else { return String.alert.couponRegistFail }
        if result == "712"
            || result == "713"
            || result == "721"
            || result == "722"
            || result == "723"
            || result == "724" {
            
            return reason.replace("+", with: "")
        } else {
            return String.alert.couponRegistFail
        }
       
    }
}

class Cbs: Rest{
    /**
     * 쿠폰 인증 (CBS-POC-011)
     */
    func certificationCoupon(
        couponNum:String?, stbInfo:StbInfo,
        completion: @escaping (CertificationCoupon) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let uuid = UUID().uuidString.lowercased()
       
        var headers = [String:String]()
        headers["UUID"] = uuid
        headers["User-Service-Num"] = stbInfo.svc_num
        headers["Client-ID"] = "Mobile-POC"
        headers["Client-Name"] = "pocwrk1stg"
        headers["Client-Time"] = CbsNetwork.getClientTime()
        headers["API-ID"] = "CBS-POC-011"
        
        
        var params = [String:Any]()
        params["noConfirm"] = ApiUtil.getCBSEncrypted(couponNum, uuid: uuid)
        params["fgCd"] =  ApiUtil.getCBSEncrypted("10", uuid: uuid)
        params["reqId"] = ApiUtil.getCBSEncrypted("MobileBtv", uuid: uuid)
       // params["method"] = "post"
        fetch(route: CbsCertificationCoupon(headers:headers, body: params), completion: completion, error:error)
    }
    
    /**
     * B포인트 발급
     */
    func requestBPointIssuance(
        pointPolicyNum:String, pointAmount:Int,
        completion: @escaping (BPointIssuance) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
    
        var params = [String:Any]()
        params["ENCRYPT_YN"] = "Y"
        params["CPN_BPNT_POCY_NO"] = pointPolicyNum
        params["OP_ORG"] = "0000"
        params["AMT_BPOINT"] = pointAmount
        params["IF_GUBUN"] = "SKBIFC003"
        params["OP_ORG"] = CbsNetwork.getClientTime()
         
        let encryptedStbId = ApiUtil.getCBSEncrypted(stbId, uuid: CbsNetwork.KEY_STBID_SVCNUM) ?? ""
        let encryptedData = ApiUtil.getCBSEncrypted(AppUtil.getJsonString(dic: params), uuid: CbsNetwork.KEY_DATA) ?? ""
        
       // params["method"] = "post"
        fetch(route: CbsRequestBPointIssuance(
                encryptedStbId:encryptedStbId,
                encryptedData:encryptedData), completion: completion, error:error)
    }
    
}

struct CbsCertificationCoupon:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/mpoc/v1/confirmCoupon"
    var headers: [String: String]?
    var body: [String : Any]?
}

struct CbsRequestBPointIssuance:NetworkRoute{
    var method: HTTPMethod = .post
    var encryptedStbId : String = ""
    var encryptedData : String = ""
    
    var path: String { get{
        return "/CPAS/issue?STB_ID=" + encryptedStbId + "$SERVICE_NUM=&DATA=" + encryptedData
    }}
}



//
