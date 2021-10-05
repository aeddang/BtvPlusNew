//
//  Metv.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
import SwiftUI
struct CbsNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.CBS)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        var authorizationRequest = request
        authorizationRequest.setValue( "application/x-www-form-urlencoded; charset=UTF-8",forHTTPHeaderField: "Content-Type")
        authorizationRequest.setValue( "application/json;charset=utf-8",forHTTPHeaderField: "Accept")
        
        return authorizationRequest
    }
    
}
extension CbsNetwork{
    static let KEY_STBID_SVCNUM = "BtvcmoneyissueWithSKBroadband120"
    static let KEY_DATA = "BtvcmoneyissueWithSKBroadband123"
    
    static func getClientTimeHeader()->String {
        return Date().toDateFormatter(dateFormat: "YYYY-MM-DD hh:mm:ss", local: "en_US_POSIX")
    }
    
    static func getClientTime()->String {
        return Date().toDateFormatter(dateFormat: "yyyyMMddHHmmss", local: "en_US_POSIX")
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
        headers["User-Service-Num"] = ApiUtil.getCBSEncrypted(stbInfo.svc_num ?? "", uuid: uuid)
        headers["Client-ID"] = "Mobile-POC"
        headers["Client-Name"] = "pocwrk1stg"
        headers["Client-Time"] = CbsNetwork.getClientTimeHeader()
        headers["API-ID"] = "CBS-POC-011"
        headers["User-Agent"] = "BtvPlus/4.4.5 (iPhone; iOS 15.0; Scale/3.00)"
        
        let encryptedCouponNum = ApiUtil.getCBSEncrypted(couponNum?.replace("-", with: ""), uuid: uuid)
        let encryptedFgCd = ApiUtil.getCBSEncrypted("10", uuid: uuid)
        let encryptedReqId = ApiUtil.getCBSEncrypted("MobileBtv", uuid: uuid)
        let qurryString =
            "noConfirm=" + ApiUtil.string(byUrlEncoding:encryptedCouponNum) +
            "&fgCd=" + ApiUtil.string(byUrlEncoding:encryptedFgCd) +
            "&reqId=" + ApiUtil.string(byUrlEncoding:encryptedReqId)
        
        /*
        var params = [String:Any]()
        params["noConfirm"] = ApiUtil.string(byUrlEncoding:ApiUtil.getCBSEncrypted(couponNum, uuid: uuid))
        params["fgCd"] =  ApiUtil.string(byUrlEncoding:ApiUtil.getCBSEncrypted("10", uuid: uuid))
        params["reqId"] = ApiUtil.string(byUrlEncoding:ApiUtil.getCBSEncrypted("MobileBtv", uuid: uuid))
         */
         //let postData = qurryString.formUrlencoded().data(using: String.Encoding.utf8, allowLossyConversion: false)
        fetch(route: CbsCertificationCoupon(overrideHeaders:headers, jsonString: qurryString ), completion: completion, error:error)
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
        params["AMT_CMONEY"] = 0
        params["AMT_BPOINT"] = pointAmount
        params["IF_GUBUN"] = "SKBIFC003"
        params["OP_TIME"] = CbsNetwork.getClientTime()
        let jsonString = AppUtil.getJsonString(dic: params)
            
        let encryptedStbId = ApiUtil.getCBSBPointEncrypted(stbId, key: CbsNetwork.KEY_STBID_SVCNUM) ?? ""
        let encryptedData = ApiUtil.getCBSBPointEncrypted(jsonString, key: CbsNetwork.KEY_DATA) ?? ""
        let qurryString = "STB_ID=" + ApiUtil.string(byUrlEncoding: encryptedStbId)
            + "&SERVICE_NUM=&DATA=" + ApiUtil.string(byUrlEncoding: encryptedData)
        /*
        var body = [String:Any]()
        body["STB_ID"] = ApiUtil.string(byUrlEncoding: encryptedStbId)
        body["SERVICE_NUM"] = ""
        body["DATA"] = ApiUtil.string(byUrlEncoding: encryptedData)
        */
        fetch(route: CbsRequestBPointIssuance( jsonString:qurryString), completion: completion, error:error)
    }
    
}

struct CbsCertificationCoupon:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/mpoc/v1/confirmCoupon"
    var overrideHeaders: [String : String]? = nil
    //var body: [String : Any]?
    //var bodys: [Any]?
    //var postData: Data?
    var jsonString: String?
}

struct CbsRequestBPointIssuance:NetworkRoute{
    var method: HTTPMethod = .post
    //var body: [String : Any]?
    var path: String = "/CPAS/issue"
    var jsonString: String?

}



//
