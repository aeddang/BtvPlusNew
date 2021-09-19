//
//  Metv.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
struct KesNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.KES)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request)
    }
}
extension KesNetwork{
    static let RESPONSE_FORMET = "json"
    static let MENU_STB_SVC_ID = "BTVMOBV440" //+ SystemEnvironment.bundleVersionKey
    static let PAGE_COUNT = 30
    
    enum UpdateType {
        case post, put, del
        var code:String {
            get {
                switch self {
                case .post: return "I"
                case .put: return "U"
                case .del: return "D"
                }
            }
        }
    }
    
  

    enum ScnMethodCode: String {
        case last = "514" // 최근에봤어요  513:UI5.0-KES_LAST
        case new = "515" // 새로왔어요  513:UI5.0-KES_NEW
        case favorite = "516" // 좋아하는것이에요  513:UI5.0-KES_FAV
        case friends = "517" // 친구들이많이봐요  513:UI5.0-KES_FRN
        case teacher = "518" // 선생님이추천해요  513:UI5.0-KES_TCR
    }
}

class Kes: Rest{
    /**
    * 젬키즈 프로필 목록 조회 (IF-KES-001)
    */
    func getKidsProfiles(
        completion: @escaping (KidsProfiles) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-001"
        params["stb_id"] = stbId
    
        fetch(route: KesKidsProfiles(body: params), completion: completion, error:error)
    }
    
    
    /**
    * 프로필 등록/수정/삭제 (IF-KES-002)
    */
    func updateKidsProfiles(
        profiles:[Kid],
        completion: @escaping (KidsProfiles) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-002"
        params["stb_id"] = stbId
        let profileDatas:[[String:Any]] = profiles.map { kid in
            var profile = [String:Any]()
            if kid.updateType != .post {
                profile[ "profile_id" ] =  kid.id
            }
            profile[ "profile_nm" ] = kid.getNickname()
            profile[ "birth_ym" ] = kid.getBirth()
            profile[ "gender" ] = kid.getGenderKey()
            profile[ "chrter_img_id" ] = kid.getCharacterId()
            profile[ "prof_loc_val" ] = kid.locVal
            profile[ "event_typ" ] = kid.updateType?.code ?? ""
            return profile
        }
        params["profiles"] = profileDatas
        fetch(route: KesRegistKidsProfile(body: params), completion: completion, error:error)
    }
    
    func getKidStudy(
        profile:Kid?,
        completion: @escaping (KidStudy) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-003"
        params["stb_id"] = stbId
        
        params["profile_id"] = profile?.id ?? "0"
        fetch(route: KesKidStudy(body: params), completion: completion, error:error)
    }
    
    /**
    * 수준 진단평가 정보 조회 / 영어
    */
    func getEnglishLvReportExam(
        profile:Kid, target:String?,
        completion: @escaping (KidsExams) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-101"
        params["stb_id"] = stbId
        params["profile_id"] = profile.id
        params["tgt_cd"] = target
        fetch(route: KesEnglishLvReportExam(body: params), completion: completion, error:error)
    }
    /**
    * 수준 진단평가 정보 저장
    */
    func getEnglishLvReportQuestion(
        profile:Kid, epNo: String? , epTpNo: Int?, questions: [QuestionData],
        completion: @escaping (KidsExamQuestionResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-102"
        params["stb_id"] = stbId
        params["profile_id"] = profile.id
       
        params["ep_no"] = epNo
        params["ep_tp_no"] = epTpNo
        let questionDatas:[[String:Any]] = questions.map { $0.getSaveData() }
        params["q_items"] = questionDatas
        fetch(route: KesEnglishLvReportExamQuestion(body: params), completion: completion, error:error)
    }
    // i: 영어 진단리포트 결과 호출
    func getEnglishLvReportResult(
        profile:Kid,
        completion: @escaping (KidsReport) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-103"
        params["stb_id"] = stbId
        params["profile_id"] = profile.id
        fetch(route: KesEnglishLvReportResult(body: params), completion: completion, error:error)
    }
    
    
    
    /**
    * 독서 유형별 진단 정보 (IF-KES-104)
    */
    func getReadingReport(
        profile:Kid,
        completion: @escaping (ReadingReport) -> Void, error: ((_ e:Error) -> Void)? = nil){ 
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-104"
        params["stb_id"] = stbId
        params["profile_id"] = profile.id
        fetch(route: KesReadingReport(body: params), completion: completion, error:error)
    }
    /**
    * 독서 유형별 진단결과 정보 (IF-KES-105)
    */
    func getReadingReportExam(
        profile:Kid, area:String?,
        completion: @escaping (KidsExams) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-105"
        params["stb_id"] = stbId
        params["profile_id"] = profile.id
        params["hcls_area_cd"] = area
        
        fetch(route: KesReadingReportExam(body: params), completion: completion, error:error)
    }
    /**
    * 성향 진단평가 정보 저장 / 독서 (IF-KES-106)
    */
    func getReadingReportQuestion(
        profile:Kid, epNo: String? , epTpNo: Int?, questions: [QuestionData],
        completion: @escaping (KidsExamQuestionResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-106"
        params["stb_id"] = stbId
        params["profile_id"] = profile.id
         
        params["ep_no"] = epNo
        params["ep_tp_no"] = epTpNo
        let questionDatas:[[String:Any]] = questions.map { $0.getSaveData() }
        params["q_items"] = questionDatas
        
        fetch(route: KesReadingReportExamQuestion(body: params), completion: completion, error:error)
    }
    
    /**
    * 성향 진단평가 정보 결과 / 독서 결과 (IF-KES-107)
    */
    func getReadingReportResult(
        profile:Kid, area:String?,
        completion: @escaping (KidsReport) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-107"
        params["stb_id"] = stbId
        params["profile_id"] = profile.id
        params["hcls_area_cd"] = area
        
        fetch(route: KesReadingReportResult(body: params), completion: completion, error:error)
    }
    
    /**
    * 성향 진단평가 정보 조회 / 창의 (IF-KES-108)
    */
    func getCreativeReportExam(
        profile:Kid,
        completion: @escaping (KidsExams) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-108"
        params["stb_id"] = stbId
        params["profile_id"] = profile.id
         
        fetch(route: KesCreativeReportExam(body: params), completion: completion, error:error)
    }
    
    /**
    * 성향 진단평가 정보 저장 / 창의 (IF-KES-109)
    */
    func getCreativeReportQuestion(
        profile:Kid, epNo: String? , epTpNo: Int?, questions: [QuestionData],
        completion: @escaping (KidsExamQuestionResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-109"
        params["stb_id"] = stbId
        params["profile_id"] = profile.id
        params["ep_no"] = epNo
        params["ep_tp_no"] = epTpNo
        let questionDatas:[[String:Any]] = questions.map { $0.getSaveData() }
        params["q_items"] = questionDatas
         
        fetch(route: KesCreativeReportExamQuestion(body: params), completion: completion, error:error)
    }
    /**
    * 성향 진단평가 정보 결과 / 창의 (IF-KES-110)
    */
    func getCreativeReportResult(
        profile:Kid,
        completion: @escaping (CreativeReport) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-110"
        params["stb_id"] = stbId
        params["profile_id"] = profile.id
        
        fetch(route: KesCreativeReportResult(body: params), completion: completion, error:error)
    }
    
    
    /**
    * 차시 평가(퀴즈) 정보 조회 / 영어, 창의, 교과 (IF-KES-111)
    */
    func getEvaluationReportExam(
        profile:Kid, srisId:String?,
        completion: @escaping (KidsExams) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-111"
        params["stb_id"] = stbId
        params["profile_id"] = profile.id
        params["sris_id"] = srisId
        fetch(route: KesEvaluationReportExam(body: params), completion: completion, error:error)
    }
    
    /**
    * 차시 평가(퀴즈) 정보 저장 (IF-KES-112)
    */
    func getEvaluationReportQuestion(
        profile:Kid, epNo: String? , epTpNo: Int?, questions: [QuestionData],
        completion: @escaping (KidsExamQuestionResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-112"
        params["stb_id"] = stbId
        params["profile_id"] = profile.id
        params["ep_no"] = epNo
        params["ep_tp_no"] = epTpNo
        let questionDatas:[[String:Any]] = questions.map { $0.getSaveData() }
        params["q_items"] = questionDatas
         
        fetch(route: KesEvaluationReportExamQuestion(body: params), completion: completion, error:error)
    }
    
    
    /**
    * 월간리포트 (IF-KES-113)
    */
    func getMonthlyReport(
        profile:Kid, date:Date? = nil,
        completion: @escaping (MonthlyReport) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-113"
        params["stb_id"] = stbId
        params["profile_id"] = profile.id
        params["yyyy_mm"] = ( date ??  Date() ).toDateFormatter(dateFormat:"yyyyMM")
        fetch(route: KesMonthlyReport(body: params), completion: completion, error:error)
    }
    
    /**
    * 영어 진단레벨 목록 조회 (IF-KES-114)
    */
    func getEnglishReport(
        profile:Kid,
        completion: @escaping (EnglishReport) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-114"
        params["stb_id"] = stbId
        params["profile_id"] = profile.id
        
        fetch(route: KesEnglishReport(body: params), completion: completion, error:error)
    }
}

struct KesKidsProfiles:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/profile/item"
    var body: [String : Any]? = nil
}

struct KesRegistKidsProfile:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/profile"
    var body: [String : Any]? = nil
}

struct KesKidStudy:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/mystudy/item"
    var body: [String : Any]? = nil
}


struct KesEnglishLvReportExam:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/level/english/item"
    var body: [String : Any]? = nil
}
struct KesEnglishLvReportExamQuestion:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/level/english"
    var body: [String : Any]? = nil
}
struct KesEnglishLvReportResult:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/level/english/report"
    var body: [String : Any]? = nil
}


struct KesReadingReport:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/reading/report"
    var body: [String : Any]? = nil
}
struct KesReadingReportExam:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/tendency/reading/item"
    var body: [String : Any]? = nil
}
struct KesReadingReportExamQuestion:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/tendency/reading"
    var body: [String : Any]? = nil
}
struct KesReadingReportResult:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/tendency/reading/report"
    var body: [String : Any]? = nil
}


struct KesCreativeReportExam:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/tendency/idea/item"
    var body: [String : Any]? = nil
}
struct KesCreativeReportExamQuestion:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/tendency/idea"
    var body: [String : Any]? = nil
}
struct KesCreativeReportResult:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/tendency/idea/report"
    var body: [String : Any]? = nil
}

struct KesEvaluationReportExam:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/evaluation/item"
    var body: [String : Any]? = nil
}
struct KesEvaluationReportExamQuestion:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/evaluation"
    var body: [String : Any]? = nil
}



struct KesMonthlyReport:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/monthly/report"
    var body: [String : Any]? = nil
}

struct KesEnglishReport:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/kes/v1/english/item"
    var body: [String : Any]? = nil
}
