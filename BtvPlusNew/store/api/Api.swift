//
//  Api.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
struct ApiError :Error,Identifiable{
    let id = UUID().uuidString
    var message:String? = nil
    static func getViewMessage(message:String?)->String{
        return message ?? String.alert.apiErrorServer
    }
}

struct ApiQ :Identifiable{
    var id:String = UUID().uuidString
    let type:ApiType
    var action:ApiAction? = nil
    var isOptional:Bool = false
    var isLock:Bool = false
    var isProcess:Bool = false
    
    func copy(newId:String? = nil) -> ApiQ {
        let nid = newId ?? id
        return ApiQ(id: nid, type: type, action: action, isOptional: isOptional, isLock: isLock)
    }
}

struct ApiResultResponds:Identifiable{
    let id:String
    let type:ApiType
    let data:Any
}
struct ApiResultError :Identifiable{
    let id:String
    let type:ApiType
    let error:Error
    var isOptional:Bool = false
    var isProcess:Bool = false
}


enum ApiType{
    // VMS
    case versionCheck
    
    //EUXP
    case getGnb,
         getCWGrid(String?, String?),
         getGridEvent(String?, EuxpNetwork.SortType? = Optional.none, Int? = nil, Int? = nil),
         getGridPreview(String?, Int? = nil, Int? = nil),
         getGatewaySynopsis(SynopsisData),
         getSynopsis(SynopsisData),
         getInsideInfo(SynopsisData),
         getRelationContents(SynopsisRelationData),
         getEventBanner(String?, EuxpNetwork.BannerType = .page)
    
    //METV
    case getMonthly(Bool = false, Int? = nil , Int? = nil),
         getWatch(Bool = false, Int? = nil , Int? = nil),
         deleteWatch([String]? = nil, Bool = false),
         getBookMark(Int? = nil , Int? = nil),
         postBookMark(SynopsisData),
         deleteBookMark(SynopsisData),
         getDirectView(SynopsisModel),
         getPackageDirectView(SynopsisPackageModel, Bool = false)
    
    //NPS
    case registHello,
         getDevicePairingStatus,
         getDevicePairingInfo(String?, String?),
         postDevicePairing(User?, StbData?),
         postAuthPairing(User?, String?),
         postUnPairing,rePairing,  // rePairing 재시도용
         getHostDeviceInfo,
         postGuestInfo(User?),
         postGuestNickname(User?),
         postGuestAgreement(User?), getGuestAgreement
    //KMS
    case getStbInfo(String?)
    //SMD
    case getLike(String?, HostDevice?),
         registLike(Bool?, String?, HostDevice?)
    
    //SCS
    case getPreview(String?, HostDevice?),
         getPreplay(String?, Bool?),
         getPlay(String?, HostDevice?)
    
    //PSS
    case getPairingUserInfo(String?, String? = nil),
         getPairingUserInfoByPackageID(String?)
    
    //NF
    case getNotificationVod([String]?, [String]?, NfNetwork.NotiType?, returnDatas:Any? = nil),
         postNotificationVod(NotificationData?),
         deleteNotificationVod(String?)
    
    //WEB
    case getSearchKeywords,
         getCompleteKeywords(String?),
         getSeachVod(String?),
         getSeachPopularityVod
    
    func coreDataKey() -> String? {
        switch self {
        //case .getGnb : return "getGnb"
        default : return nil
        }
    }
    func transitionKey() -> String {
        switch self {
        case .registHello : return "postHello"
        default : return ""
        }
    }
}
