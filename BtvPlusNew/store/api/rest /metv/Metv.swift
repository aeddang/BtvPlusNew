//
//  Metv.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
struct MetvNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.METV2)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request)
    }
}
extension MetvNetwork{
    static let RESPONSE_FORMET = "json"
    static let SVC_CODE = "BTV"
    static let VERSION = "5.0"
    static let PAGE_COUNT = 30

}

class Metv: Rest{
    /**
    * 즐겨찾기 조회(VOD) (IF-ME-011)
    * @param pageNo 요청할 페이지의 번호 (Default: 1)
    * @param entryNo 요청한 페이지에 보여질 개수 (Default: 5)
    */
    func getBookMark(
        page:Int?, pageCnt:Int?,
        completion: @escaping (BookMark) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        var params = [String:String]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["ver"] = MetvNetwork.VERSION
        params["IF"] = "IF-ME-011"
        
        let stbId = "00000000-0000-0000-0000-000000000000"
        params["stb_id"] = stbId  //pairingManager?.getStbId()
        params["group"] = "VOD"
        params["ch_type"] = ""
        params["page_no"] = page?.description ?? "1"
        params["entry_no"] = pageCnt?.description ?? MetvNetwork.PAGE_COUNT.description
        params["hash_id"] = stbId.toSHA256()
        params["svc_code"] = MetvNetwork.SVC_CODE
        
        fetch(route: MetvBookMark(query: params), completion: completion, error:error)
    }
}

struct MetvBookMark:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/metv/v5/bookmark/bookmark/mobilebtv"
   var query: [String : String]? = nil
}
