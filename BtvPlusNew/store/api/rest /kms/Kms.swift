//
//  Metv.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
struct KmsNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.KMS)
    
}
extension KmsNetwork{
    static let RESPONSE_FORMET = "json"
    static let SVC_CODE = "BTV"
    static let VERSION = "5.0"
    static let PAGE_COUNT = 30
}

class Kms: Rest{
    /**
     * STB ID 목록 조회(페어링 시 사용)
     */
    func getStbList(
        ci:String?,
        completion: @escaping (StbInfo) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        if let ci = ci {
            params["ci"] = ApiUtil.string(byUrlEncoding: ci)
        }
        
        //params["mode"] = "test"
        fetch(route: KmsStbList(query: params), completion: completion, error:error)
    }
    
    func getTerminateStbList(
        ci:String?,
        completion: @escaping (StbInfo) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        if let ci = ci {
            params["ci"] = ApiUtil.string(byUrlEncoding: ci)
        }
        fetch(route: KmsTerminateStbList(query: params), completion: completion, error:error)
    }
}

struct KmsStbList:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/api/v3.0/userstb/list"
   var query: [String : String]? = nil
   var withAllowedCharacters:CharacterSet? = nil
}

struct KmsTerminateStbList:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/api/v3.0/terminatestb/list"
   var query: [String : String]? = nil
   var withAllowedCharacters:CharacterSet? = nil
    
}

