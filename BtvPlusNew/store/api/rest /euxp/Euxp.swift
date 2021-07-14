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
        return ApiGateway.setGatewayheader(request: request)
    }
}

extension EuxpNetwork{
    static let RESPONSE_FORMET = "json"
    static let MENU_STB_SVC_ID = "BTVMOBV440"
   
    static let APP_TYPE_CD = "BTVPLUS"
    static let APP_TYPE_CD_KIDS = "BTVPLUS_KIDS"
    static let VERSION = "0"
    static let PAGE_COUNT = 30
    static let adultCodes:[String?] = ["01", "03"]
    

    enum SortType: String {
        case none = "10" // 기본
        case popularity = "50" // 인기
        case latest = "20" // 최신순
        case title = "30" // 타이틀
        case price = "40" // 가격
        
        
        var name: String {
            switch self {
            case .none : return ""
            case .popularity: return String.sort.popularity
            case .latest: return String.sort.latest
            case .title: return String.sort.title
            case .price: return String.sort.price
            }
        }
    }
    
    enum SearchType: String {
        case sris = "1" // 시리즈
        case prd = "2" // 단품
    }
    
    enum GnbTypeCode: String {
        case GNB_HOME = "BP_01"  // 홈
        case GNB_MONTHLY = "BP_02"  // 월정액
        case GNB_CATEGORY = "BP_03"  // 카테고리
        case GNB_FREE = "BP_04"  // 무료
        case GNB_SCHEDULED = "BP_05"  // 공개 예정
        case GNB_OCEAN = "BP_08"  // 오션 월정액
        case GNB_KIDS = "BP_07"
        static func getType(_ value:String?)->GnbTypeCode?{
            guard let key = value?.subString(start: 0, len: 5) else {return nil}
            switch key {
                case "BP_01": return .GNB_HOME
                case "BP_02": return .GNB_MONTHLY
                case "BP_03": return .GNB_CATEGORY
                case "BP_04": return .GNB_FREE
                case "BP_05": return .GNB_SCHEDULED
                case "BP_08": return .GNB_OCEAN
                case "BP_07": return .GNB_KIDS
                default : return nil
            }
        }
    }
    
    
    
    enum MenuTypeCode: String {
        case MENU_KIDS = "NM2000002471"  // kids
        case MENU_KIDS_HOME = "NM2000031454"
        case MENU_KIDS_HOME_FIRST = "NM2000031456"  // kids
        case MENU_KIDS_MY = "NM2000031458"  // kids
    }
   
    enum SrisTypCd: String {
        case none = "00" // error
        case season = "01"
        case title = "02"
        case contentsPack = "04"
        /*
        var name: String {
            switch self {
            case .season: return "시즌"
            case .title: return "타이틀"
            case .contentsPack: return "패키지"
            default: return "없음\(self)"
            }
        }
        */
    }
    
    enum BannerType: String {
        case page = "10" // error
        case list = "20"
    }
}

class Euxp: Rest{
    /**
     * 빅배너/이벤트 정보 (IF-EUXP-007)
     * @param menuId 블록의 메뉴아이디(배너부모메뉴ID) -> 이벤트배너
     */
    func getEventBanner(
        menuId:String?, bnrTypCd:EuxpNetwork.BannerType = .page , segId:String? = nil,
        completion: @escaping (EventBanner) -> Void, error: ((_ e:Error) -> Void)? = nil){

        var params = [String:String]()
        params["response_format"] = EuxpNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = EuxpNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-EUXP-007"
        params["menu_id"] = menuId ?? ""
        params["seg_id"] = segId
        params["bnr_typ_cd"] = bnrTypCd.rawValue
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
        data:SynopsisData,
        completion: @escaping (Synopsis) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["response_format"] = EuxpNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = EuxpNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-EUXP-010"
        params["sris_id"] = data.srisId ?? ""
        params["epsd_id"] = data.epsdId ?? ""
        params["epsd_rslu_id"] = data.epsdRsluId ?? ""
        if data.epsdId?.isEmpty != false && data.epsdRsluId?.isEmpty == false {
            params["search_type"] = EuxpNetwork.SearchType.prd.rawValue
        } else {
            params["search_type"] = data.searchType ?? ""
        }
       
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
        data:SynopsisData,
        completion: @escaping (GatewaySynopsis) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["response_format"] = EuxpNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = EuxpNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-EUXP-014"
        params["sris_id"] = data.srisId ?? ""
        params["epsd_id"] = data.epsdId ?? ""
        params["prd_prc_id"] = data.prdPrcId ?? ""
        params["search_type"] = data.searchType ?? ""
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
        data:SynopsisRelationData,
        completion: @escaping (RelationContents) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["response_format"] = EuxpNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = EuxpNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-EUXP-012"
        params["menu_id"] = data.menuId
        params["cw_call_id"] = data.cwCallId
        params["epsd_id"] = data.epsdId
        params["epsd_rslu_id"] = data.epsdRsluId
        params["type"] = "all"
        params["app_typ_cd"] = "BTVPLUS"
        fetch(route: EuxpRelationContents(query: params), completion: completion, error:error)
    }
    
    /**
     * Inside 정보 (IF-EUXP-019)
      * @param epsdId 에피소드아이디
     */
    func getInsideInfo(
        data:SynopsisData,
        completion: @escaping (InsideInfo) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["response_format"] = EuxpNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = EuxpNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-EUXP-019"
        params["epsd_id"] = data.epsdId
        fetch(route: EuxpInsideInfo(query: params), completion: completion, error:error)
    }
    
    /**
     * GNB/블록 전체메뉴 (IF-EUXP-030)
     */
    func getGnbBlock(
        isKids:Bool = false,
        completion: @escaping (GnbBlock) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["response_format"] = EuxpNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = EuxpNetwork.MENU_STB_SVC_ID
        params["app_typ_cd"] = isKids ? EuxpNetwork.APP_TYPE_CD_KIDS : EuxpNetwork.APP_TYPE_CD
        params["IF"] = "IF-EUXP-030"
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
        menuId:String?, page:Int?, pageCnt:Int?, version:String?,
        completion: @escaping (GridPreview) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["response_format"] = EuxpNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = EuxpNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-EUXP-031"
        params["menu_id"] = menuId ?? ""
        params["page_no"] = page?.description ?? "1"
        params["page_cnt"] = pageCnt?.description ?? EuxpNetwork.PAGE_COUNT.description
        params["version"] = version ?? EuxpNetwork.VERSION
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
        menuId:String?, sortType:EuxpNetwork.SortType?, page:Int?, pageCnt:Int?, version:String?,
        completion: @escaping (GridEvent) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["response_format"] = EuxpNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = EuxpNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-EUXP-024"
        params["menu_id"] = menuId ?? ""
        params["page_no"] = page?.description ?? "1"
        params["page_cnt"] = pageCnt?.description ?? EuxpNetwork.PAGE_COUNT.description
        params["sort_typ_cd"] = sortType?.rawValue ?? EuxpNetwork.SortType.none.rawValue
        params["version"] = version ?? EuxpNetwork.VERSION
        fetch(route: EuxpGridEvent(query: params), completion: completion, error:error)
    }
    
    /**
    * 이벤트 그리드 정보 (IF-EUXP-009)
    * @param menuId 메뉴 ID
    * @param pageNo 페이지 시작점 (reviews 태그의 list)
    * @param pageCnt 페이지 갯수 (reviews 태그의 list)
    * @param version 버전정보
    */
    func getCWGrid(
        menuId:String?, cwCallId:String?, isKids:Bool = false,
        completion: @escaping (CWGrid) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["response_format"] = EuxpNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = EuxpNetwork.MENU_STB_SVC_ID
        params["app_typ_cd"] = isKids ? EuxpNetwork.APP_TYPE_CD_KIDS : EuxpNetwork.APP_TYPE_CD
        params["IF"] = "IF-EUXP-009"
        
        params["menu_id"] = menuId ?? ""
        params["stb_id"] = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        params["sort_typ_cd"] = ""
        params["rslu_typ_cd"] = "20"
        params["inspect_yn"] = "Y"
        params["cw_call_id"] = cwCallId ?? ""
        params["type"] = "all"
        fetch(route: EuxpCWGrid(query: params), completion: completion, error:error)
    }
    
    /**
    * 키즈 전용 KES CW그리드 정보를 조회하여 그 데이터를 기반으로 CMS의 그리드 정보를 결합하여 제공한다. (IF-EUXP-001)
    */
    
    func getCWGridKids(
        kid:Kid? , cwCallId:String?, sortType:EuxpNetwork.SortType?, type:String? = "all",
        completion: @escaping (CWGridKids) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["response_format"] = EuxpNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = EuxpNetwork.MENU_STB_SVC_ID
        params["app_typ_cd"] = EuxpNetwork.APP_TYPE_CD
        params["IF"] = "IF-EUXP-091"
        
        params["stb_id"] = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        
        params["profile_id"] = kid?.id
        params["sort_typ_cd"] = sortType?.rawValue ?? EuxpNetwork.SortType.none.rawValue
        
        params["inspect_yn"] = "N"
        params["cw_call_id"] = cwCallId ?? ""
        params["type"] = type
        fetch(route: EuxpCWGridKids(query: params), completion: completion, error:error)
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

struct EuxpCWGridKids:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/euxp/v5/inter/kesgrid"
   var query: [String : String]? = nil
}
              







