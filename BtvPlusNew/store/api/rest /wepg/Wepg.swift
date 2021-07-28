//
//  Metv.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
struct WepgNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.WEPG)
}
extension WepgNetwork{
    static let RESPONSE_FORMET = "json"
    static let VERSION = "1.0"
}

class Wepg: Rest{
    
    func getAllChannels(
        regionCode:String?,
        completion: @escaping (AllChannels) -> Void, error: ((_ e:Error) -> Void)? = nil){
        var params = [String:String]()
        params["response_format"] = WepgNetwork.RESPONSE_FORMET
        params["ver"] = WepgNetwork.VERSION
        params["IF"] = "IF-WEPG-301"
        params["m"] = "getAllChannels"
        params["AUDIO_CH_YN"] = "Y"
        params["region_code"] = regionCode ?? ""
      
        fetch(route: WepgGetChannels(query: params), completion: completion, error:error)
    }
    
    func getCurrentChannels(
        epgVersion:String?,
        completion: @escaping (CurrentChannels) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let oDate = AppUtil.networkTimeDate().toDateFormatter(dateFormat: "yyyyMMdd")
        var params = [String:String]()
        params["response_format"] = WepgNetwork.RESPONSE_FORMET
        params["ver"] = WepgNetwork.VERSION
        params["IF"] = "IF-WEPG-305"
        params["m"] = "getDetailAllChannelsAndAllGuides"
        params["o_date"] = oDate
        if let version = epgVersion {
            params["version"] = version
        }
        fetch(route: WepgGetChannels(query: params), completion: completion, error:error)
    }
}

struct WepgGetChannels:NetworkRoute{
    var method: HTTPMethod = .get
    var path: String = "/wepg/epg-stbservice"
    var query: [String : String]? = nil
}

