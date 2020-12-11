//
//  Euxp.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/09.
//

import Foundation
struct EuxpNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.EUXP)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        var authorizationRequest = request
        authorizationRequest.addValue(
            "application/json;charset=utf-8", forHTTPHeaderField: "Accept")

        #if DEBUG
        authorizationRequest.addValue(
            "l7xx159a8ca72966400b886a93895ec9e2e3", forHTTPHeaderField: "Api_Key")
        #else
        authorizationRequest.addValue(
            "l7xx851d12cc66dc4d2e86a461fb5a530f4a", forHTTPHeaderField: "Api_Key")
        #endif
        
        let timestamp = Date().toTimestamp(dateFormat: "yyyyMMddHHmmss.SSS", local: "en_US_POSIX")
        authorizationRequest.addValue( timestamp, forHTTPHeaderField: "TimeStamp")
        authorizationRequest.addValue( timestamp.toSHA256(), forHTTPHeaderField: "Auth_Val")
        authorizationRequest.addValue(
            "{00000000-0000-0000-0000-000000000000}", forHTTPHeaderField: "Client_ID")
       
        /*
        authorizationRequest.addValue(
            SystemEnvironment.model+"/"+SystemEnvironment.systemVersion, forHTTPHeaderField: "x-device-info")
        
        authorizationRequest.addValue(
            ApiPrefix.iphone+"/"+SystemEnvironment.systemVersion, forHTTPHeaderField: "x-os-info")
        
        authorizationRequest.addValue(
            ApiPrefix.service+"/"+SystemEnvironment.systemVersion, forHTTPHeaderField: "x-service-info")
        
        authorizationRequest.addValue(
            SystemEnvironment.deviceId, forHTTPHeaderField: "x-did-info")
        
        authorizationRequest.addValue(
            "", forHTTPHeaderField: "x-auth-info")
        */
        DataLog.d("authorizationRequest : " + authorizationRequest.debugDescription, tag: self.tag)
        return authorizationRequest
    }
}

class Euxp: Rest{
    /**
     * 빅배너/이벤트 정보 (IF-EUXP-007)
     * @param menuId 블록의 메뉴아이디(배너부모메뉴ID) -> 이벤트배너
     */
    func getEventBanners(
        menuId:String, bnrTypCd:String = "10", segId:String? = nil,
        completion: @escaping (EventBanners) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        var params = [String:String]()
        params["response_format"] = "json"
        params["IF"] = "IF-EUXP-007"
        params["menu_stb_svc_id"] = "BTVMOBV521"
        params["menu_id"] = menuId
        params["seg_id"] = segId
        params["bnr_typ_cd"] = bnrTypCd
        fetch(route: EuxpEventBanners(query: params), completion: completion, error:error)
    }
    /**
     * 시놉시스 (IF-EUXP-010)
     * @param srisId 시리즈아이디
     * @param epsdId 에피소드아이디 (search_type 1 경우 필수)
     * @param epsdRsluId 해상도아이디(CID) (search_type 2 경우 필수)
     * @param searchType 1 : epsd_id 기준 조회, 2 : epsd_rslu_id 기준 조회(con_id)
     */
    func getSynopsis(
        srisId:String, searchType:String, epsdId:String, epsdRsluId:String,
        completion: @escaping (Synopsis) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        var params = [String:String]()
        params["response_format"] = "json"
        params["IF"] = "IF-EUXP-010"
        params["menu_stb_svc_id"] = "BTVMOBV521"
        params["sris_id"] = srisId
        params["epsd_id"] = epsdId
        params["epsd_rslu_id"] = epsdRsluId
        params["search_type"] = searchType
        params["app_typ_cd"] = "BTVPLUS"
        fetch(route: EuxpSynopsis(query: params), completion: completion, error:error)
        
    }
    
    /**
     * 게이트웨이 시놉시스 (IF-EUXP-014)
     * @param srisId 시리즈아이디 (search_type 1 경우 필수)
     * @param epsdId 에피소드아이디
     * @param prdPrcId 상품가격아이디 (search_type: 2 인 경우 필수)
     * @param searchType 검색조건 1 : sris_id 조회, 2 : prd_prc_id 조회 (상품가격아이디)
     */
    func getGatewaySynopsis(
        srisId:String, searchType:String, epsdId:String, prdPrcId:String,
        completion: @escaping (GatewaySynopsis) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        var params = [String:String]()
        params["response_format"] = "json"
        params["IF"] = "IF-EUXP-014"
        params["menu_stb_svc_id"] = "BTVMOBV521"
        params["sris_id"] = srisId
        params["epsd_id"] = epsdId
        params["prd_prc_id"] = prdPrcId
        params["search_type"] = searchType
        fetch(route: EuxpGatewaySynopsis(query: params), completion: completion, error:error)
        
    }
    
    /**
     * CW 연관 컨텐츠 (IF-EUXP-012)
     * @param menuId 메뉴 아이디
     * @param cwCallId 페이지 아이디
     * @param epsdId 에피소드아이디
     * @param epsdRsluId 해상도아이디(CID)
     */
    func getRelationContents(
        menuId:String, cwCallId:String, epsdId:String, epsdRsluId:String,
        completion: @escaping (RelationContents) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        var params = [String:String]()
        params["response_format"] = "json"
        params["IF"] = "IF-EUXP-012"
        params["menu_stb_svc_id"] = "BTVMOBV521"
        params["menu_id"] = menuId
        params["cw_call_id"] = cwCallId
        params["epsd_id"] = epsdId
        params["epsd_rslu_id"] = epsdRsluId
        params["type"] = "all"
        params["app_typ_cd"] = "BTVPLUS"
        fetch(route: EuxpRelationContents(query: params), completion: completion, error:error)
    }
    
    /**
     * Inside 정보 (IF-EUXP-019)
      * @param epsdId 에피소드아이디
     */
    func getInsideInfo(
        epsdId:String,
        completion: @escaping (InsideInfo) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        var params = [String:String]()
        params["response_format"] = "json"
        params["IF"] = "IF-EUXP-019"
        params["menu_stb_svc_id"] = "BTVMOBV521"
        params["epsd_id"] = epsdId
        fetch(route: EuxpInsideInfo(query: params), completion: completion, error:error)
    }
    
    /**
     * GNB/블록 전체메뉴 (IF-EUXP-030)
     */
    func getGnbBlock(
        completion: @escaping (GnbBlock) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["response_format"] = "json"
        params["IF"] = "IF-EUXP-030"
        params["menu_stb_svc_id"] = "BTVMOBV521"
        params["app_typ_cd"] = "BTVPLUS"
        fetch(route: EuxpGnbBlock(query: params), completion: completion, error:error)
    }
    
    /**
     * 예고편 그리드 정보 (IF-EUXP-031)
     * @param menuId 메뉴 ID
     * @param pageNo 페이지 시작점 (reviews 태그의 list)
     * @param pageCnt 페이지 갯수 (reviews 태그의 list) -> HD STB 페이징 처리 이슈로 500건 이상인 경우 500건으로 한정
     * @param version 버전정보
     */
    func getGridPreview(
        menuId:String, page:Int, pageCnt:Int, version:String,
        completion: @escaping (GridPreview) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["response_format"] = "json"
        params["IF"] = "IF-EUXP-031"
        params["menu_stb_svc_id"] = "BTVMOBV521"
        params["menu_id"] = menuId
        params["page_no"] = page.description
        params["page_cnt"] = pageCnt.description
        params["version"] = version
        fetch(route: EuxpGridPreview(query: params), completion: completion, error:error)
    }
    

    /**
    * 이벤트 그리드 정보 (IF-EUXP-024)
    * @param menuId 메뉴 ID
    * @param pageNo 페이지 시작점 (reviews 태그의 list)
    * @param pageCnt 페이지 갯수 (reviews 태그의 list)
    * @param version 버전정보
    */
    func getGridEvent(
        menuId:String, sortType:String, page:Int, pageCnt:Int, version:String,
        completion: @escaping (GridEvent) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["response_format"] = "json"
        params["IF"] = "IF-EUXP-024"
        params["menu_stb_svc_id"] = "BTVMOBV521"
        params["menu_id"] = menuId
        params["page_no"] = page.description
        params["page_cnt"] = pageCnt.description
        params["sort_typ_cd"] = sortType
        params["version"] = version
        fetch(route: EuxpGridEvent(query: params), completion: completion, error:error)
    }
    
    
    func getCWGrid(
        menuId:String, cwCallId:String, stbId:String,
        completion: @escaping (CWGrid) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["response_format"] = "json"
        params["IF"] = "IF-EUXP-009"
        params["menu_stb_svc_id"] = "BTVMOBV521"
        params["app_typ_cd"] = "BTVPLUS"
        params["menu_id"] = menuId
        params["stb_id"] = stbId
        params["sort_typ_cd"] = ""
        params["rslu_typ_cd"] = "20"
        params["inspect_yn"] = "Y"
        params["cw_call_id"] = cwCallId
        params["type"] = "all"
        fetch(route: EuxpCWGrid(query: params), completion: completion, error:error)
    }
}


struct EuxpEventBanners:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/euxp/v5/grid/event/mobilebtv"
   var query: [String : String]? = nil
}

struct EuxpSynopsis:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/euxp/v5/contents/synopsis/mobilebtv"
   var query: [String : String]? = nil
}

struct EuxpRelationContents:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/euxp/v5/inter/cwrelation/mobilebtv"
   var query: [String : String]? = nil
}

struct EuxpGatewaySynopsis:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/euxp/v5/contents/gwsynop/mobilebtv"
   var query: [String : String]? = nil
}

struct EuxpInsideInfo:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/euxp/v5/inside/info/mobilebtv"
   var query: [String : String]? = nil
}

struct EuxpGnbBlock:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/euxp/v5/menu/gnbBlock/mobilebtv"
   var query: [String : String]? = nil
}

struct EuxpGridPreview:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/euxp/v5/grid/gridPreview/mobilebtv"
   var query: [String : String]? = nil
}

struct EuxpGridEvent:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/euxp/v5/grid/gridEvent/mobilebtv"
   var query: [String : String]? = nil
}

struct EuxpCWGrid:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/euxp/v5/inter/cwgrid/mobilebtv"
   var query: [String : String]? = nil
}







