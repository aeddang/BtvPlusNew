//
//  Rps.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/07/28.
//

import Foundation

struct VlsNetwork : Network{
    var enviroment: NetworkEnvironment = ApiPath.getRestApiPath(.VLS)
    func onRequestIntercepter(request: URLRequest) -> URLRequest {
        return ApiGateway.setGatewayheader(request: request)
    }
}
extension VlsNetwork{
    static let VERSION = "1.0"
    static let SERVICE_CODE = "v512.cdrLogNs"
    
    enum ProhibitionReason {
        case R1,R2,R4, unowned
        static func getType(_ value:String?)->ProhibitionReason{
            switch value {
                case "R1": return .R1
                case "R2": return .R2
                case "R4": return .R4
            default : return .unowned
            }
        }
        
        var reason: String {
            switch self {
            case .R1 : return String.alert.playProhibitionSimultaneous1
            case .R2: return String.alert.playProhibitionSimultaneous2
            case .R4: return String.alert.playProhibitionSimultaneous4
            default : return String.alert.playProhibitionSimultaneous3
            }
        }
        
        var config: String {
            switch self {
            case .R1 : return "지상파월정액시청"
            case .R2: return "동일cp사시청"
            case .R4: return "동일 장르영상"
            default : return "동일콘텐츠시청"
            }
        }
    }
    
}

class Vls: Rest{
    /**
     * 동시시청제한 가능 여부 체크  (IF-VLS-001)
     * @param epsdId NCMS-EpisodeID
     * @param isLimit 동시시청가능여부 Y/N
     * @param cpId CP 계약코드 ( limit_flag 값이 Y 일 경우 값이 없어도 가능)
     * @param ppmIds 시청시사용된 월정액 상품정보
     */
    func checkProhibitionSimultaneous(
        synopData:SynopsisData, pairing:Pairing, pcId:String,
        completion: @escaping (ProhibitionSimultaneous) -> Void, error: ((_ e:Error) -> Void)? = nil){
        
        let stbId = NpsNetwork.hostDeviceId ?? ApiConst.defaultStbId
        var params = [String:Any]()
        params["ver"] = VlsNetwork.VERSION
        params["if"] = "IF-VLS-001"
        params["service_code"] = VlsNetwork.SERVICE_CODE
        
        params["stb_id"] = stbId
        params["cp_id"] = synopData.cpId
        params["ppm_ids"] = synopData.ppmIds ?? ""
        params["episode_id"] = synopData.epsdId
        params["limit_flag"] = synopData.isLimitedWatch ? "Y" : "N"
        params["pc_id"] = pcId
        params["fromaction"] = nil
        fetch(route: VlsCheckProhibitionSimultaneous(body: params), completion: completion, error:error)
    }
}

struct VlsCheckProhibitionSimultaneous:NetworkRoute{
    var method: HTTPMethod = .post
    var path: String = "/vls/v5/execute"
    var body: [String : Any]? = nil
}




