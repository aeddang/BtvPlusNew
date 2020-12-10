//
//  Vms.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/08.
//

import Foundation

struct VmsNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.VMS)
}

class Vms: Rest{
    func versionCheck(completion: @escaping (Version) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:Any]()
        params["response_format"] = "json"
        params["IF"] = "IF-BVMS-001"
        params["ver"] = "1.0"
        params["x-os-info"] = ApiPrefix.iphone+"/"+SystemEnvironment.systemVersion
        params["x-svc-info"] = ApiPrefix.service+"/"+SystemEnvironment.systemVersion
        params["x-virgin-flag"] = SystemEnvironment.firstLaunch ? "yes" : "no"
        fetch(route: VmsVersionCheck(body: params), completion: completion, error:error)
    }
}

struct VmsVersionCheck:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/login/versionCheck.jsp"
   var body: [String : Any]? = nil
}

struct Version : Decodable {
    private(set) var result: String? = nil
    private(set) var reason: String? = nil
    private(set) var releaseNote: String? = nil
    private(set) var tstore: String? = nil
    private(set) var updateUrl: String? = nil
    private(set) var eUpdateFlag: String? = nil
    private(set) var server_conf:Array<[String : String]>? = nil
}



