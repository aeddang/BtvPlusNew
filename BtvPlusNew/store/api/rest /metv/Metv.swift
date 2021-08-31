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
    static let VERSION = "5.3.0"
    static let GROUP_VOD = "VOD"
    static let PAGE_COUNT = 30

    enum SynopsisType{
        case none, title, seriesChange , seasonFirst
        var code:String {
            get {
                switch self {
                case .none: return "0"
                case .title: return "1"
                case .seriesChange: return "2" //지워
                case .seasonFirst: return "3"
                }
            }
        }
    }
    
    static func isWatchCardRateIn(data:WatchItem) -> Bool {
        /* [러닝 타임별 기준]
            •    러닝 타임 5분 미만 : 러닝 타임의 15% 이상 시청 시 시청 내역 표시
            •    러닝 타임 5-30분 미만 : 러닝 타임의 10% 이상 시청 시 시청 내역 표시
            •    러닝 타임 30분 이상 : 러닝 타임의 5% 이상 시청 시 시청 내역 표시
               [장르별 기준]
            •    단편 : 90% 이상 시청 시에는 시청 내역에서 제외
            •    시즌 : 공통 기준만 고려하며, 100% 시청 시에도 시청 내역에서 제외하지 않음 */
        let watch: Int = Int(data.watch_rt ?? "0") ?? 0
        let runTime: Int = (Int(data.running_time ?? "0") ?? 0) / 60
        let runningTimeCheck: Bool = (runTime < 5 && watch >= 15) ||
                ((5...29).contains(runTime) && watch >= 10) ||
                (runTime >= 30 && watch >= 5)
        let genreCheck: Bool = ("N" == data.yn_series && watch < 90) || "Y" == data.yn_series

        return runningTimeCheck && genreCheck
    }
}

class Metv: Rest{
    /**
    * 일반 구매내역 조회 (IF-ME-031)
    * @param pageNo 요청할 페이지의 번호 (Default: 1)
    * @param entryNo 요청한 페이지에 보여질 개수 (Default: 10)
    */
    func getPurchase(
        page:Int?, pageCnt:Int?,
        completion: @escaping (Purchase) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["ver"] = MetvNetwork.VERSION
        params["IF"] = "IF-ME-031"
        params["stb_id"] = stbId
        params["page_no"] = page?.description ?? "1"
        params["entry_no"] = pageCnt?.description ?? "999"
        params["hash_id"] = ApiUtil.getHashId(stbId)
        params["svc_code"] = MetvNetwork.SVC_CODE
        fetch(route: MetvPurchase(query: params), completion: completion, error:error)
    }
    
    /**
    * 365/소장용 구매내역 조회 (IF-ME-032)
    * @param pageNo 요청할 페이지의 번호 (Default: 1)
    * @param entryNo 요청한 페이지에 보여질 개수 (Default: 10)
    */
    func getCollectiblePurchase(
        page:Int?, pageCnt:Int?,
        completion: @escaping (Purchase) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["ver"] = MetvNetwork.VERSION
        params["IF"] = "IF-ME-032"
        params["stb_id"] = stbId
        params["page_no"] = page?.description ?? "1"
        params["entry_no"] = pageCnt?.description ?? "999"
        params["hash_id"] = ApiUtil.getHashId(stbId)
        params["svc_code"] = MetvNetwork.SVC_CODE
        fetch(route: MetvCollectiblePurchase(query: params), completion: completion, error:error)
    }
    
    /**
    * 구매내역 미노출 상태 등록 (IF-ME-037)
    * @param purchaseList 노출/미노출 대상 구매 인덱스 리스트 + 단건, 복수건 노출 미노출 요청시 List 형식으로 필수
    */
    func deletePurchase(
        deleteList:[String]? = nil,
        completion: @escaping (PurchaseDeleted) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["ver"] = MetvNetwork.VERSION
        params["IF"] = "IF-ME-037" 
        params["stb_id"] = stbId
    
        params["disp_sts_cd"] = "1"
        params["hash_id"] = ApiUtil.getHashId(stbId)
        params["svc_code"] = MetvNetwork.SVC_CODE
        params["purchaseList"] = deleteList ?? []
        
        var headers = [String : String]()
        headers["method"] = "delete"
        fetch(route: MetvDeletePurchase(headers:headers, body: params), completion: completion, error:error)
    }
    
    /**
    * 월정액 구매내역 조회 (IF-ME-033)
    * @param pageNo 요청할 페이지의 번호 (Default: 1)
    * @param entryNo 요청한 페이지에 보여질 개수 (Default: 10)
    * @param isPeriod 기간권 구매내역 정보 요청 여부 Y : 월정액 기간권 구매내역 조회 요청 N : 기존 월정액 구매내역 정보 제공
    */
    func getPurchaseMonthly(
        page:Int?, pageCnt:Int?,
        completion: @escaping (MonthlyPurchaseInfo) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["ver"] = MetvNetwork.VERSION
        params["IF"] = "IF-ME-033"
        
        params["stb_id"] = stbId
        params["page_no"] = page?.description ?? "1"
        params["entry_no"] = pageCnt?.description ?? "999"
        params["hash_id"] = ApiUtil.getHashId(stbId)
        params["svc_code"] = MetvNetwork.SVC_CODE
        params["req_perd"] = "Y"
        fetch(route: MetvPurchaseMonthly(query: params), completion: completion, error:error)
    }
    
    func getPeriodPurchaseMonthly(
        page:Int?, pageCnt:Int?,
        completion: @escaping (PeriodMonthlyPurchaseInfo) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["ver"] = MetvNetwork.VERSION
        params["IF"] = "IF-ME-033"
        
        params["stb_id"] = stbId
        params["page_no"] = page?.description ?? "1"
        params["entry_no"] = pageCnt?.description ?? "999"
        params["hash_id"] = ApiUtil.getHashId(stbId)
        params["svc_code"] = MetvNetwork.SVC_CODE
        params["req_perd"] = "Y"
        fetch(route: MetvPurchaseMonthly(query: params), completion: completion, error:error)
    }
    /**
    * 월정액 메뉴 리스트 (IF-ME-036)
    * @param pageNo 요청할 페이지의 번호 (Default: 1)
    * @param entryNo 요청한 페이지에 보여질 개수 (Default: 10)
    * @param isLowlevelPPM 가입한 월정액의 하위상품ID 리스트 제공여부 값이 없는경우, N로 간주(기본값)
    */
    func getMonthly(
        lowLevelPpm:Bool = false , page:Int?, pageCnt:Int?,
        completion: @escaping (MonthlyInfo) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["ver"] = MetvNetwork.VERSION
        params["IF"] = "IF-ME-036"
        
        params["stb_id"] = stbId
        params["page_no"] = page?.description ?? "1"
        params["entry_no"] = pageCnt?.description ?? "999"
        params["hash_id"] = ApiUtil.getHashId(stbId)
        params["svc_code"] = MetvNetwork.SVC_CODE
        params["yn_lowlevel_ppm"] = lowLevelPpm ? "Y" : "N"
        params["yn_lowlevel_perd"] = "Y" //??
        fetch(route: MetvMonthly(query: params), completion: completion, error:error)
    }
    
    /**
     * 월정액 가입여부 확인 (IF-ME-039)
     * @param prd_prc_id 월정액 상품 가격 아이디
     * @param sel_typ normal : 일반 조회 방식 (default) detail : 상세 조회 방식
     */
    func getMonthlyData(
        prdPrcId:String?, isDetail:Bool = false,
        completion: @escaping (MonthlyInfoData) -> Void, error: ((_ e:Error) -> Void)? = nil){

        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["ver"] = MetvNetwork.VERSION
        params["IF"] = "IF-ME-039"
        
        params["stb_id"] = stbId
        params["hash_id"] = ApiUtil.getHashId(stbId)
        params["svc_code"] = MetvNetwork.SVC_CODE
        params["prd_prc_id"] = prdPrcId
        params["sel_typ"] = isDetail ? "detail" : "normal"
        fetch(route: MetvMonthlyData(body: params), completion: completion, error:error)
    }
    
    /**
    * 모바일 최근시청 VOD 조회 (IF-ME-121)
    * @param pageNo 요청할 페이지의 번호 (Default: 1)
    * @param entryNo 요청한 페이지에 보여질 개수 (Default: 5)
    * @param isPPM 최근시청VOD조회시 MyBtv/월정액 구분 필수 Y : 월정액 N : My Btv
    */
    func getWatch(
        isPpm:Bool = false , page:Int?, pageCnt:Int?,
        completion: @escaping (Watch) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["ver"] = MetvNetwork.VERSION
        params["IF"] = "IF-ME-021" //"IF-ME-121"
        
        params["stb_id"] = stbId
       // params["mobile_id"] = SystemEnvironment.getGuestDeviceId()
        params["page_no"] = page?.description ?? "1"
        params["entry_no"] = pageCnt?.description ?? "9999"
        params["hash_id"] = ApiUtil.getHashId(stbId)
        params["svc_code"] = MetvNetwork.SVC_CODE
        params["yn_ppm"] = isPpm ? "Y" : "N"
        fetch(route: MetvWatch(query: params), completion: completion, error:error)
    }
    /**
    * 모바일 최근시청 VOD 삭제 (IF-ME-122)
    * @param isAll 전체 삭제 여부
    * @param deleteList 시청한 VOD 컨텐트의 sris_id(시즌 ID)
    */
    func deleteWatch(
        deleteList:[String]? = nil, isAll:Bool = false ,
        completion: @escaping (UpdateMetv) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["ver"] = MetvNetwork.VERSION
        params["IF"] = "IF-ME-022" //"IF-ME-122"
        params["stb_id"] = stbId
        // params["mobile_id"] = SystemEnvironment.getGuestDeviceId()
        params["isAll"] = isAll ? "Y" : "N"
        params["hash_id"] = ApiUtil.getHashId(stbId)
        params["svc_code"] = MetvNetwork.SVC_CODE
        params["deleteList"] = deleteList ?? []
        
        var headers = [String : String]()
        headers["method"] = "delete"
        fetch(route: MetvDelWatch(headers:headers, body: params), completion: completion, error:error)
    }
    
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
        completion: @escaping (UpdateMetv) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
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
        completion: @escaping (UpdateMetv) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
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
    
    /** 0804 -> SCS -002 synopsisType 2번 사용 안함 빼기
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
    
    /** 0804 -> SCS -002
    * 게이트웨이시놉 바로보기 (IF-ME-062)
    * @param reqPidList 바로보기 확인용 상품ID 리스트 집합
    * @param isPPM 월정액 전용 게이트웨이 시놉 바로보기 확인여부 체크(Y/N)
    */
    func getPackageDirectView(
        data:SynopsisPackageModel? = nil, isPpm:Bool = false , pidList:[String]? = nil,
        completion: @escaping (DirectPackageView) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        
        var params = [String:Any]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["ver"] = MetvNetwork.VERSION
        params["IF"] = "IF-ME-062"
        
        params["stb_id"] = stbId
        params["hash_id"] = ApiUtil.getHashId(stbId)
        params["req_pidList"] = pidList ?? [ data?.prdPrcId ?? "" ]
        params["yn_ppm"] = isPpm ? "Y": "N"
        fetch(route: MetvPackageDirectview( body: params), completion: completion, error:error)
    }
    
    /**
    * 해지고객 소장용 구매내역 조회 (IF-ME-932)
    * @param stbId STB ID
    * @param pageNo 요청할 페이지의 번호 (Default: 1)
    * @param entryNo 요청한 페이지에 보여질 개수 (Default: 10)
    */
    func getPossessionPurchase(
        stbId:String , page:Int?, pageCnt:Int?,
        completion: @escaping (Purchase) -> Void, error: ((_ e:Error) -> Void)? = nil){

        var params = [String:String]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["ver"] = MetvNetwork.VERSION
        params["IF"] = "IF-ME-932"
        params["stb_id"] = stbId
        params["page_no"] = page?.description ?? "1"
        params["entry_no"] = pageCnt?.description ?? "999"
        params["hash_id"] = ApiUtil.getHashId(stbId)
        
        fetch(route: MetvPossessionPurchase(query: params), completion: completion, error:error)
    }
    
    /**
    * 출석체크 저장 (IF-EVENT-001)
    */
    func postAttendance(
        pcId:String,
        completion: @escaping (UpdateMetv) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = MetvNetwork.RESPONSE_FORMET
        params["IF"] = "IF-EVENT-001"
        params["stb_id"] = stbId
        params["pcid"] = pcId
        params["dvc_id"] = SystemEnvironment.deviceId
        params["method"] = "post"
        fetch(route: MetvPostAttendance(body: params), completion: completion, error:error)
    }
    /**
    * 출석체크 조회 (IF-EVENT-002)
    */
    func getAttendance(
        pcId:String,
        completion: @escaping (Attendance) -> Void, error: ((_ e:Error) -> Void)? = nil){
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["IF"] = "IF-EVENT-002"
        params["stb_id"] = stbId
        params["pcid"] = pcId
        params["dvc_id"] = SystemEnvironment.deviceId
       
        fetch(route: MetvGetAttendance(body: params), completion: completion, error:error)
    }
}

struct MetvPurchase:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "/metv/v5/purchase/general/mobilebtv"
    var query: [String : String]? = nil
}

struct MetvDeletePurchase:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/metv/v5/purchase/dispctrl"
    var headers:[String : String]? = nil
    var body: [String : Any]? = nil
}

struct MetvCollectiblePurchase:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "/metv/v5/purchase/unlimited/mobilebtv"
    var query: [String : String]? = nil
}

struct MetvPurchaseMonthly:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "/metv/v5/purchase/fixedcharge/mobilebtv"
    var query: [String : String]? = nil
}

struct MetvMonthly:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "/metv/v5/setting/fixedchargelist/mobilebtv"
    var query: [String : String]? = nil
}

struct MetvMonthlyData:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/metv/v5/setting/chargeconfirm/mobilebtv"
    var body: [String : Any]? = nil
}

struct MetvWatch:NetworkRoute{
   var method: HTTPMethod = .get
   //var path: String = "/metv/v5/watch/mbtv-season"
   var path: String = "/metv/v5/watch/season/mobilebtv"
   var query: [String : String]? = nil
}

struct MetvDelWatch:NetworkRoute{
   var method: HTTPMethod = .post
   //var path: String = "/metv/v5/watch/mbtv-season/del"
   var path: String = "/metv/v5/watch/season/del/mobilebtv"
   var headers:[String : String]? = nil
   var body: [String : Any]? = nil
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

struct MetvPackageDirectview:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/metv/v5/datamart/directviewgateway/mobilebtv"
   var body: [String : Any]? = nil
}

struct MetvPossessionPurchase:NetworkRoute{
   var method: HTTPMethod = .get
   var path: String = "/metv/v5/purchase/closeduser-unlimited"
   var query: [String : String]? = nil
}

struct MetvPostAttendance:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/metv/v5/vodcomments/setevent/mobilebtv"
   var body:[String: Any]? = nil
   
}

struct MetvGetAttendance:NetworkRoute{
   var method: HTTPMethod = .post
   var path: String = "/metv/v5/vodcomments/getevent/mobilebtv"
   var body:[String: Any]? = nil
    
}



