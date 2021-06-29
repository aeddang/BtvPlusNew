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
    static let MENU_STB_SVC_ID = "BTVMOBV440"
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
}

class Kes: Rest{
    /**
    * 젬키즈 프로필 목록 조회 (IF-KES-001)
    */
    func getKidsProfiles(
        hostDevice:HostDevice?,
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
        hostDevice:HostDevice?, profiles:[Kid],
        completion: @escaping (KidsProfiles) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = KesNetwork.RESPONSE_FORMET
        params["menu_stb_svc_id"] = KesNetwork.MENU_STB_SVC_ID
        params["IF"] = "IF-KES-002"
        params["stb_id"] = stbId
        params["profiles"] = profiles.map{ kid in
            var profile = [String:Any]()
            if kid.updateType != .post {
                profile[ "profile_id" ] = kid.id
            }
            profile[ "profile_nm" ] = kid.nickName
            profile[ "gender" ] = kid.gender
            profile[ "birth_ym" ] = kid.birth
            profile[ "chrter_img_id" ] = kid.getCharacterId()
            profile[ "prof_loc_val" ] = ""
            profile[ "event_typ" ] = kid.updateType?.code ?? ""
        }
        fetch(route: KesRegistKidsProfile(body: params), completion: completion, error:error)
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
