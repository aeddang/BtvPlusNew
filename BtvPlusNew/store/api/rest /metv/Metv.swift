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
    static let GROUP_VOD = "VOD"
    static let PAGE_COUNT = 30

    enum SynopsisType{
        case none, title, seriesChange , seasonFirst
        var code:String {
            get {
                switch self {
                case .none: return "0"
                case .title: return "1"
                case .seriesChange: return "2"
                case .seasonFirst: return "3"
                }
            }
        }
    }
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
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["ver"] = MetvNetwork.VERSION
        params["IF"] = "IF-ME-011"
        
        params["stb_id"] = stbId
        params["group"] = MetvNetwork.GROUP_VOD
        params["ch_type"] = ""
        params["page_no"] = page?.description ?? "1"
        params["entry_no"] = pageCnt?.description ?? MetvNetwork.PAGE_COUNT.description
        params["hash_id"] = ApiUtil.getHashId(stbId)
        params["svc_code"] = MetvNetwork.SVC_CODE
        
        fetch(route: MetvBookMark(query: params), completion: completion, error:error)
    }
    /**
    * 즐겨찾기 등록 (VOD) (IF-ME-012)
    * @param srisId VOD 컨텐트의 식별자
    * @param epsdId 에피소드ID
    * @param epsdRsluId VOD 컨텐트의 해상도ID
    * @param isKidsZone 키즈존 여부
    */
    func postBookMark(
        data:SynopsisData,
        completion: @escaping (UpdateBookMark) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["ver"] = MetvNetwork.VERSION
        params["IF"] = "IF-ME-012"
        
        params["stb_id"] = stbId
        params["group"] = MetvNetwork.GROUP_VOD
        params["hash_id"] = ApiUtil.getHashId(stbId)
        params["sris_id"] = data.srisId ?? ""
        params["epsd_id"] = data.epsdId ?? ""
        params["epsd_rslu_id"] = data.epsdRsluId ?? ""
        params["yn_kzone"] = data.kidZone ?? "N"
        params["svc_code"] = MetvNetwork.SVC_CODE
        
        fetch(route: MetvPostBookMark(body: params), completion: completion, error:error)
    }
    /**
    * 즐겨찾기 삭제 (VOD) (IF-ME-013)
    * @param isAllType 0 : 단건 또는 복수건 삭제(deleteList는 반드시 설정하여야 함), 1 : 그룹별 전체삭제
    * @param deleteList 즐겨찾기 삭제할 unique key 집합 - group=VOD 일 때, sris_id를 의미
    */
    func deleteBookMark(
        data:SynopsisData,
        completion: @escaping (UpdateBookMark) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["ver"] = MetvNetwork.VERSION
        params["IF"] = "IF-ME-013"
        
        params["stb_id"] = stbId
        params["group"] = MetvNetwork.GROUP_VOD
        params["hash_id"] = ApiUtil.getHashId(stbId)
        
        params["isAll_type"] = "0"
        if let deleteID = data.srisId {
            params["deleteList"] = [deleteID]
        }
        
        var headers = [String : String]()
        headers["method"] = "delete"
        fetch(route: MetvDelBookMark(headers: headers, body: params), completion: completion, error:error)
    }
    
    /**
    * 바로보기 (IF-ME-061)
    * @param srisId 최근본회차 시청정보, 즐겨찾기 확인  + 컨텐츠의 sris_id + 필수
    * @param synopsisType 시놉시스 확인 식별자 값 설명 - 1 : 단편시놉 진입시  - 2 : 시즌시놉 회차이동시 - 3. : 시즌시놉 최초진입 또는 시즌변경시
    * @param ppvProducts 단편 또는 시즌 회차별 바로보기 여부 확인시의 요청 상품리스트
    * @param ppsProducts 시즌시놉의 바로보기 여부 확인 요청 상품리스트
    */
    func getDirectView(
        data:SynopsisModel,
        completion: @escaping (DirectView) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        
        var params = [String:Any]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["ver"] = MetvNetwork.VERSION
        params["IF"] = "IF-ME-061"
        
        params["stb_id"] = stbId
        params["hash_id"] = ApiUtil.getHashId(stbId)
        
        params["sris_id"] = data.srisId ?? ""
        params["synopsis_type"] = data.synopsisType.code
        //params["muser_num"] = ""
        //params["version"] = ""
        if !data.ppsProducts.isEmpty {
            params["pps_products"] = data.ppsProducts
        }
        params["ppv_products"] = data.ppvProducts
        fetch(route: MetvDirectview( body: params), completion: completion, error:error)
    }
}

struct MetvBookMark:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/metv/v5/bookmark/bookmark/mobilebtv"
   var query: [String : String]? = nil
}

struct MetvPostBookMark:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/metv/v5/bookmark/bookmark/add/mobilebtv"
   var body: [String : Any]? = nil
}

struct MetvDelBookMark:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/metv/v5/bookmark/bookmark/del/mobilebtv"
   var headers:[String : String]? = nil
   var body: [String : Any]? = nil
}

struct MetvDirectview:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/metv/v5/datamart/directview/mobilebtv"
   var body: [String : Any]? = nil
}





