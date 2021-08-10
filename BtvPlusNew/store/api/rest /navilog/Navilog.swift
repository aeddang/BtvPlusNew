//
//  Navilog.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/10.
//

import Foundation

struct NavilogNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.NAVILOG)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setDefaultheader(request: request)
    }
}

struct NavilogNpiNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.NAVILOG_NPI)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setDefaultheader(request: request)
    }
}

class Navilog: Rest{
    func sendLog(
        log:String,
        completion: @escaping (Any) -> Void, error: ((_ e:Error) -> Void)? = nil){
        fetch(route: NavilogSendLog(jsonString: log), completion: completion, error:error)
    }
}

struct NavilogSendLog:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = ""
    var jsonString: String? = nil
}



