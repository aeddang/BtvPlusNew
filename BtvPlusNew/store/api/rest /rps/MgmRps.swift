//
//  Rps.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/28.
//

import Foundation

struct MgmRpsNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.MGMRPS)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request)
    }
}
extension MgmRpsNetwork{
    static let RESPONSE_FORMET = "json"
    
    enum MgmError: String {
        case expiredURL = "MP-8001"
        case aleadyPurchased = "MP-8004"
        case aleadyHasCoupon = "MP-8005"
        case euqalSTB = "MP-8006"
        case noResult = "MP-9998"
        case cbsFailed = "MP-8888"
        case etc = "MP-9999"
        
        var msg: String {
            switch self {
            case .expiredURL : return  String.share.synopsisRecommandReceiveErrorExpired
            case .aleadyPurchased: return  String.share.synopsisRecommandReceiveErrorPurchased
            case .aleadyHasCoupon: return  String.share.synopsisRecommandReceiveErrorHasCoupon
            case .euqalSTB: return  String.share.synopsisRecommandReceiveErrorEqualSTB
            default : return String.share.synopsisRecommandReceiveErrorFail
            }
        }
        
        var tip: String? {
            switch self {
            case .expiredURL : return  String.share.synopsisRecommandReceiveErrorExpiredTip
            case .aleadyPurchased: return  String.share.synopsisRecommandReceiveErrorPurchasedTip
            case .aleadyHasCoupon: return  String.share.synopsisRecommandReceiveErrorHasCouponTip
            default : return nil
            }
        }
        
        static func getType(_ value:String?)->MgmError{
            switch value {
            case "MP-8001": return .expiredURL
            case "MP-8004": return .aleadyPurchased
            case "MP-8005": return .aleadyHasCoupon
            case "MP-8006": return .euqalSTB
            case "MP-9998": return .noResult
            case "MP-8888": return .cbsFailed
            case "MP-9999": return .etc
            default : return .etc
            }
        }
    }
}

class MgmRps: Rest{
    /**
     * 추천 혜택정보 제공 (IF-MGMRPS-001)
     */
    func getRecommendBenefit(
        completion: @escaping (RecommandBenefit) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["response_format"] = MgmRpsNetwork.RESPONSE_FORMET
        params["IF"] = "IF-MGMRPS-001"
        params["m"] = "benefitInfo"
       
        fetch(route: MgmRpsRecommendBenefit(query: params), completion: completion, error:error)
    }
    
    /**
     * 추천정보 저장 및 추천 고유ID 생성 (IF-MGMRPS-002)
     */
    func registRecommend(
        user:User, data:SynopsisData,
        completion: @escaping (RecommandId) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["response_format"] = MgmRpsNetwork.RESPONSE_FORMET
        params["IF"] = "IF-MGMRPS-002"
        params["m"] = "recommendUrl"
        params["stb_id"] = stbId
        params["device_id"] = SystemEnvironment.getGuestDeviceId()
        
        params["epsd_id"] = data.epsdId
        params["sris_id"] = data.srisId
        params["nick_nm"] = user.nickName
       
        fetch(route: MgmRpsRecommend(query: params), completion: completion, error:error)
    }
    
    /**
     * 쿠폰발급 (IF-MGMRPS-003)
     */
    func getRecommendCoupon(
        mgmId:String, srisTypeCd:String?,
        completion: @escaping (RecommandCoupon) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:String]()
        params["response_format"] = MgmRpsNetwork.RESPONSE_FORMET
        params["IF"] = "IF-MGMRPS-003"
        params["m"] = "couponPayment"
        params["tgt_stb_id"] = stbId
        params["tgt_device_id"] = SystemEnvironment.getGuestDeviceId()
        params["mgm_id"] = mgmId
        params["sris_typ_cd"] = srisTypeCd ?? ""
       
        fetch(route: MgmRpsRecommendCoupon(query: params), completion: completion, error:error)
    }
}

struct MgmRpsRecommendBenefit:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "benefitInfo/mobilebtv"
    var query: [String : String]? = nil
}

struct MgmRpsRecommend:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "recommendUrl/mobilebtv"
    var query: [String : String]? = nil
}
struct MgmRpsRecommendCoupon:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "couponPayment/mobilebtv"
    var query: [String : String]? = nil
}


