//
//  Rps.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/28.
//

import Foundation

struct LgsNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.LGS)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setDefaultheader(request: request)
    }
}
extension LgsNetwork{
    static let RESPONSE_FORMET = "json"
    static let VERSION = "1.0"
    static let GUBUN_ETC = "99"
    static let UI_NAME = "BTVMOBV520"
    enum PlayEventType: String {
        case play = "3" // 3 : 재생 (Btv Plus 에서 전달 가능)
        case playBase = "4" // 4 : 시청에 대한 기준시점 – HeadEnd 에 상품구매시 전달한 Charge_Period 를 참조하여 처음부터 보기 시청하여 Charge_Period % 가 지난 시점에 리포팅한다
        case stop = "5" // 5 : 특정위치에서 플레이를 한 후 중지시, 채널변경시 , Home, Power off 시 리포팅 (Btv Plus 에서 전달 가능)
        case buffering = "6" // 6 : 다운로드 버퍼링시
        case play80 = "7" // 7 : 콘텐츠 시청중 80% 시청시
        case stopAd = "9" // 9 : 광고중 종료시
        case playPreview = "10"  // 10 : 미리보기 재생 시작시
        case stopPreview = "11"  // 11 : 미리보기 재생 종료시
    }
    
}

class Lgs: Rest{
    /**0804 ->동시시청 제어 VLS
    * 시청정보전송(Btv Plus 전용) (IF-LGS-CDRLOG-UI5-002)
    */
    func postWatchLog(
        evt:LgsNetwork.PlayEventType, playData:SynopsisPlayData,
        synopData:SynopsisData, pairing:Pairing,  pcId:String, isKidZone:Bool = false,  gubun:String? = nil,
        completion: @escaping (WatchLogResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = LgsNetwork.RESPONSE_FORMET
        params["ver"] = LgsNetwork.VERSION
        params["if"] = "IF-LGS-CDRLOG-UI5-002"
        params["ui_name"] = LgsNetwork.UI_NAME
        params["stb_patch_version"] =  pairing.hostDevice?.patchVersion
        params["method"] = "post";
        params["sw_ver"] = "1.0"
        params["stb_id"] = stbId
        params["pcid"] = pcId;
        
        params["cdr_index"] = "1"
        params["svc_type"] = "1"
        params["pid"] = synopData.pId ?? "0"
        params["cid"] = synopData.contentId
        params["epsd_id"] = synopData.epsdId
        params["sris_id"] = synopData.srisId
        params["cpid"] = synopData.cpId
        params["ppm_ids"] = synopData.ppmIds ?? ""
       
        params["limit_flag"] = synopData.isLimitedWatch ? "Y" : "N"
        params["event_type"] = evt.rawValue
        params["mobile_id"] = SystemEnvironment.deviceId
        params["mobile_ver"] = SystemEnvironment.bundleVersion
        params["profile_id"] = NpsNetwork.pairingId
        params["kidschar_id"] = isKidZone ?  pairing.kid?.id : nil
        params["g_gubun"] = gubun?.isEmpty == false ? gubun : LgsNetwork.GUBUN_ETC
        
        params["event_time"] = playData.eventTime
        params["play_start"] = playData.start ?? playData.eventTime
        params["play_end"] = playData.end ?? playData.eventTime
        params["play_position"] = playData.position
        params["end_rate"] = playData.rate
        params["trans_type"] = "3"
        params["yn_kzone"] = isKidZone ? "Y" : "N"
        fetch(route: LgsPostWatchLog(body: params), completion: completion, error:error)
    }
    
    /**
    * 시청정보전송(모바일 Btv 해지고객 소장 VOD 재생 전용) (IF-LGS-CDRLOG-UI5-003)
    */
    func postWatchLogPossession(
        evt:LgsNetwork.PlayEventType, playData:SynopsisPlayData,
        synopData:SynopsisData, pairing:Pairing,  mbtvKey:String,  pcId:String, isKidZone:Bool = false,  gubun:String? = nil,
        completion: @escaping (WatchLogResult) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["response_format"] = LgsNetwork.RESPONSE_FORMET
        params["ver"] = LgsNetwork.VERSION
        params["if"] = "IF-LGS-CDRLOG-UI5-003"
        params["ui_name"] = LgsNetwork.UI_NAME
        params["stb_patch_version"] =  pairing.hostDevice?.patchVersion
        params["method"] = "post";
        params["sw_ver"] = "1.0"
        params["stb_id"] = stbId
        params["pcid"] = pcId;
        
        params["cdr_index"] = "1"
        params["svc_type"] = "1"
        params["pid"] = synopData.pId ?? "0"
        params["cid"] = synopData.contentId
        params["epsd_id"] = synopData.epsdId
        params["sris_id"] = synopData.srisId
        params["cpid"] = synopData.cpId
        params["ppm_ids"] = synopData.ppmIds ?? ""
       
        params["limit_flag"] = synopData.isLimitedWatch ? "Y" : "N"
        params["event_type"] = evt.rawValue
        params["mobile_id"] = mbtvKey
        params["mbtv_key"] = mbtvKey
        params["g_gubun"] = gubun?.isEmpty == false ? gubun : LgsNetwork.GUBUN_ETC
        
        params["event_time"] = playData.eventTime
        params["play_start"] = playData.start ?? playData.eventTime
        params["play_end"] = playData.end ?? playData.eventTime
        params["play_position"] = playData.position
        params["end_rate"] = playData.rate
        params["trans_type"] = "3"
        params["yn_kzone"] = isKidZone ? "Y" : "N"
        
        fetch(route: LgsPostWatchLogPossession(body: params), completion: completion, error:error)
    }
    
}

struct LgsPostWatchLog:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/LGS/v5/cdrLogNs.jsp"
    var body: [String : Any]? = nil
}

struct LgsPostWatchLogPossession:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/LGS/v5/cdrLogNsCancelStb.jsp"
    var body: [String : Any]? = nil
}



