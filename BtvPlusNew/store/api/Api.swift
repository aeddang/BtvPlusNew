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
    var isOptional:Bool = false
    var isLock:Bool = false
    var isLog:Bool = false
    var isProcess:Bool = false
    func copy(newId:String? = nil) -> ApiQ {
        let nid = newId ?? id
        return ApiQ(id: nid, type: type, isOptional: isOptional, isLock: isLock, isLog:isLog)
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
    var isLog:Bool = false
    var isProcess:Bool = false
}

enum ApiType{
    // VMS
    case versionCheck
    //EUXP
    case getGnb,
         getGnbKids,
         getCWGrid( String?, String?, isKids:Bool = false),
         getCWGridKids(Kid? , String?, EuxpNetwork.SortType?),
         getGridEvent(String?, EuxpNetwork.SortType? = nil, Int? = nil, Int? = nil),
         getGridPreview(String?, Int? = nil, Int? = nil),
         getGatewaySynopsis(SynopsisData),
         getSynopsis(SynopsisData),
         getInsideInfo(SynopsisData),
         getRelationContents(SynopsisRelationData),
         getEventBanner(String?, EuxpNetwork.BannerType = .page)
    
    
    //METV
    case getPurchase(Int? = nil , Int? = nil),
         deletePurchase([String]),
         getCollectiblePurchase(Int? = nil , Int? = nil),
         getPurchaseMonthly(Int? = nil , Int? = nil),
         getPeriodPurchaseMonthly(Int? = nil , Int? = nil),
         getMonthly(Bool = false, Int? = nil , Int? = nil),
         getMonthlyData(String?, isDetail:Bool = false),
         getWatch(isPpm:Bool = false, Int? = nil , Int? = nil),
         deleteWatch([String]? = nil, isAll:Bool = false),
         getBookMark(Int? = nil , Int? = nil),
         postBookMark(SynopsisData),
         deleteBookMark(SynopsisData),
         getDirectView(SynopsisModel),
         getPackageDirectView(SynopsisPackageModel? = nil, isPpm:Bool = false, pidList:[String]? = nil),
         getPossessionPurchase(String, Int? = nil , Int? = nil)
    //METV event
    case postAttendance(pcid:String,callback:String? = nil),
         getAttendance(pcid:String,callback:String? = nil)
    
    //NPS
    case registHello,
         getDevicePairingStatus,
         getDevicePairingInfo(String?, String?, prevResult:NpsCommonHeader? = nil),
         postDevicePairing(User?, StbData?),
         postAuthPairing(User?, String?),
         postUnPairing,rePairing,  // rePairing 재시도용
         getHostDeviceInfo,
         postGuestInfo(User?),
         postGuestNickname(String?),
         postGuestAgreement(User?), getGuestAgreement, updateAgreement(Bool),
         updateUser(ModifyUserData?),
         getPairingToken(String?),
         sendMessage(NpsMessage?),
         validatePairingToken(pairingToken:String),
         postPairingByToken(User?, pairingToken:String)
         
    //KMS
    case getStbList(String?),
         getTerminateStbInfo(String?)
    //SMD
    case getLike(String?, HostDevice?),
         registLike(Bool?, String?, HostDevice?)
    
    //SCS
    case getPreview(String?, HostDevice?),
         getPreplay(String?, Bool?),
         getPlay(String?, HostDevice?),
         confirmPassword(String?, HostDevice?, ScsNetwork.ConfirmType),
         connectTerminateStb(ScsNetwork.ConnectType, String?),
         getStbInfo(HostDevice?)
    //PSS
    case getPairingUserInfo(String?, String? = nil),
         getPairingUserInfoByPackageID(String?)
    
    //NF
    case getNotificationVod([String]?, [String]?, NfNetwork.NotiType?, returnDatas:Any? = nil),
         postNotificationVod(NotificationData?),
         deleteNotificationVod(String?)
    //EPS
    case getTotalPointInfo(HostDevice?),
         getTotalPoint(HostDevice?, Bool = true),
         getCoupons( HostDevice?, Int? = nil , Int? = nil),
         postCoupon( HostDevice?, String?),
         getBPoints( HostDevice?, Int? = nil , Int? = nil),
         postBPoint( HostDevice?, String?),
         getBCashes( HostDevice?, Int? = nil , Int? = nil),
         postBCash( HostDevice?, String?),
         getTMembership( HostDevice? ),
         postTMembership( HostDevice?, RegistCardData),
         deleteTMembership( HostDevice? ),
         getTvPoint( HostDevice? ),
         getOkCashPoint( HostDevice?, OcbItem?, String?),
         postOkCashPoint( HostDevice?, RegistCardData),
         updateOkCashPoint( HostDevice?, RegistCardData),
         deleteOkCashPoint( HostDevice?, masterSequence:Int )
    
    
    //WEPG
    case getAllChannels(String?),
         getCurrentChannels(String?)
    //WEB
    case getSearchKeywords,
         getCompleteKeywords(String?,PageType = .btv),
         getSeachVod(String?,PageType = .btv),
         getSeachPopularityVod
    
    //KES
    case getKidsProfiles,
         updateKidsProfiles([Kid]),
         getKidStudy(Kid),
         getEnglishReport(Kid),
         getReadingReport(Kid),
         getMonthlyReport(Kid, Date? = nil),
         
         getEnglishLvReportExam(Kid, target:String? ),
         getEnglishLvReportQuestion(Kid, String? , Int?, [QuestionData]),
         getEnglishLvReportResult( Kid ),
    
         getReadingReportExam(Kid, area:String?),
         getReadingReportQuestion(Kid, String?, Int?, [QuestionData]),
         getReadingReportResult( Kid, area:String?),
         
         getCreativeReportExam(Kid),
         getCreativeReportQuestion(Kid, String? , Int?, [QuestionData]),
         getCreativeReportResult( Kid),
    
         getEvaluationReportExam(Kid, srisId:String?),
         getEvaluationReportQuestion(Kid, String? , Int?, [QuestionData])
    //RPS
    case getRecommendHistory(callback:String? = nil),
         getRecommendBenefit,
         registRecommend(User, SynopsisData),
         getRecommendCoupon(mgmId:String, srisTypeCd:String?)
    
    //LGS
    case postWatchLog(LgsNetwork.PlayEventType, SynopsisPlayData, synopData:SynopsisData, Pairing,
                      pcId:String, isKidZone:Bool = false, gubun:String? = nil),
         postWatchLogPossession(LgsNetwork.PlayEventType, SynopsisPlayData, synopData:SynopsisData, Pairing,
                                mbtvKey:String, pcId:String, isKidZone:Bool = false, gubun:String? = nil)
    
    //VLS
    case checkProhibitionSimultaneous(SynopsisData, Pairing, pcId:String),
         sendNaviLog(String, isAnonymous:Bool)
    
    //PUCR
    case createEndpoint(String),
         registerToken(String, token:String),
         recivePush(String, messageId:String),
         confirmPush(String, messageId:String)

    //PUSH
    case registEndpoint(String, isAgree:Bool),
         updatePushUserAgreement(Bool)
    
    //CBS
    case certificationCoupon(String, StbInfo),
         requestBPointIssuance(pointPolicyNum:String, pointAmount:Int, callback:String? = nil)
    
    
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


