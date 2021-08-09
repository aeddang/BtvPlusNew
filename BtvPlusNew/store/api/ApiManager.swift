//
//  ApiManager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import Combine
enum ApiStatus{
    case initate, ready
}

enum ApiEvents{
    case pairingHostChanged, pairingUpdated(PairingUpdateData)
}

enum UpdateFlag:String{
    case none ,force ,recommend ,emergency ,advance
    static func getFlag(_ value:String?)->UpdateFlag{
        switch value {
            case "0", "none": return .none
            case "1", "force": return .force
            case "2", "recommend": return .recommend
            case "3", "emergency": return .emergency
            case "4", "advance": return .advance
            default : return .none
        }
    }
}

enum PairingUpdateFlag:String{
    case none ,forceUnpairing ,upgrade
    static func getFlag(_ value:String?)->PairingUpdateFlag{
        switch value {
            case "0": return .none
            case "1": return .forceUnpairing
            case "2": return .upgrade
            default : return .none
        }
    }
}

struct PairingUpdateData {
    var updateFlag:PairingUpdateFlag? = nil
    var productName:String? = nil
    var maxCount:Int? = nil
    var count:Int? = nil
    
}


class ApiManager :PageProtocol, ObservableObject{
    @Published var status:ApiStatus = .initate
    @Published var result:ApiResultResponds? = nil {didSet{ if result != nil { result = nil} }}
    @Published var error:ApiResultError? = nil {didSet{ if error != nil { error = nil} }}
    @Published var event:ApiEvents? = nil {didSet{ if event != nil { event = nil} }}
    
    
    private var anyCancellable = Set<AnyCancellable>()
    private var apiQ :[ ApiQ ] = []
    private let vms:Vms = Vms(network: VmsNetwork())
    private lazy var euxp:Euxp = Euxp(network: EuxpNetwork())
    private lazy var metv:Metv = Metv(network: MetvNetwork())
    private lazy var nps:Nps = Nps(network: NpsNetwork())
    private lazy var kms:Kms = Kms(network: KmsNetwork())
    private lazy var smd:Smd = Smd(network: SmdNetwork())
    private lazy var scs:Scs = Scs(network: ScsNetwork())
    private lazy var pss:Pss = Pss(network: PssNetwork())
    private lazy var nf:Nf = Nf(network: NfNetwork())
    private lazy var eps:Eps = Eps(network: EpsNetwork())
    private lazy var wepg:Wepg = Wepg(network: WepgNetwork())
    private lazy var web:Web = Web(network: WebNetwork())
    private lazy var kes:Kes = Kes(network: KesNetwork())
    private lazy var rps:Rps = Rps(network: RpsNetwork())
    private lazy var mgmRps:MgmRps = MgmRps(network: MgmRpsNetwork())
    
    // 로그 서버 페이지이동시 켄슬 안함
    private lazy var lgs:Lgs = Lgs(network: LgsNetwork())
    private(set) var updateFlag: UpdateFlag = .none
    init() {
        self.initateApi()
    }
    
    func clear(){
        if self.status == .initate {return}
        self.euxp.clear()
        self.metv.clear()
        self.kms.clear()
        self.smd.clear()
        self.scs.clear()
        self.pss.clear()
        self.nf.clear()
        self.eps.clear()
        self.web.clear()
        self.wepg.clear()
        self.kes.clear()
        self.rps.clear()
        self.mgmRps.clear()
        self.apiQ.removeAll()
    }
    
    private func initateApi()
    {
        NpsNetwork.goodbye()
        self.vms.versionCheck(
            completion:{res in
                
                DataLog.d("eUpdateFlag " + (res.eUpdateFlag ?? "nil"), tag:self.tag)
                DataLog.d("releaseNote " + (res.releaseNote ?? "nil"), tag:self.tag)
                DataLog.d("tstore " + (res.tstore ?? "nil"), tag:self.tag)
                DataLog.d("update_url " + (res.update_url ?? "nil"), tag:self.tag)
                DataLog.d("server_conf " + (res.server_conf?.debugDescription ?? "nil"), tag:self.tag)
                self.updateFlag = UpdateFlag.getFlag(res.eUpdateFlag)
                DataLog.d("self.updateFlag " +  self.updateFlag.rawValue, tag:self.tag)
                SystemEnvironment.isEvaluation = (self.updateFlag == .advance)
                SystemEnvironment.needUpdate = !(self.updateFlag == .none || self.updateFlag == .advance)
                DataLog.d("SystemEnvironment.isEvaluation " +  SystemEnvironment.isEvaluation.description, tag:self.tag)
                
                self.complated(id: "", type: .versionCheck, res: res)
                if let configs = res.server_conf {
                    configs.forEach{ con in
                        let key = con.keys.first ?? ""
                        if let value = con[key] {
                            SystemEnvironment.serverConfig[key] = value
                            DataLog.d("key " + key + " value " + value, tag:self.tag)
                        }
                    }
                }
                self.initApi()
            },
            error:{ err in
                DataLog.e("versionCheck " + err.localizedDescription, tag:self.tag)
                self.onError(id: "", type: .versionCheck, e: err, isOptional: true)
                self.initApi()
            }
        )
    }
    func retryApi()
    {
        self.status = .initate
        initateApi()
    }
    private func initApi()
    {
        self.status = .ready
        self.executeQ()
    }
    private func executeQ(){
        self.apiQ.forEach{ q in self.load(q: q)}
        self.apiQ.removeAll()
    }
    

    private var transition = [String : ApiQ]()
    func load(q:ApiQ){
        switch q.type {
        case .getGnb,
             .postAuthPairing, .getDevicePairingInfo, .postDevicePairing, .postUnPairing :
            if NpsNetwork.sessionId == "" {
                transition[q.id] = q
                self.load(.registHello, action: q.action, resultId: q.id,
                          isOptional: q.isOptional, isLock: q.isLock, isLog:q.isLog, isProcess: q.isProcess)
                return
            }
        default : do{}
        }
        self.load(q.type, action: q.action, resultId: q.id,
                  isOptional: q.isOptional, isLock: q.isLock, isLog:q.isLog, isProcess: q.isProcess)
    }
    

    @discardableResult
    func load(_ type:ApiType, action:ApiAction? = nil,
              resultId:String = "",
              isOptional:Bool = false, isLock:Bool = false, isLog:Bool = false, isProcess:Bool = false)->String
    {
        let apiID = resultId //+ UUID().uuidString
        if status != .ready{
            self.apiQ.append(ApiQ(id: resultId, type: type, action: action, isOptional: isOptional, isLock: isLock, isLog: isLog))
            return apiID
        }
        let error = {err in self.onError(id: apiID, type: type, e: err, isOptional: isOptional, isLog: isLog, isProcess: isProcess)}
        switch type {
        case .versionCheck : self.vms.versionCheck(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getGnb : self.euxp.getGnbBlock(
            isKids: false,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getGnbKids : self.euxp.getGnbBlock(
            isKids: true,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getCWGrid(let menuId, let cwCallId, let isKids) : self.euxp.getCWGrid(
            menuId: menuId, cwCallId: cwCallId, isKids: isKids,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getCWGridKids(let kid , let cwCallId, let sortType) : self.euxp.getCWGridKids(
            kid:kid, cwCallId: cwCallId, sortType: sortType,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getGridEvent(let menuId, let sort, let page, let count) : self.euxp.getGridEvent(
            menuId: menuId, sortType: sort, page: page, pageCnt: count, version: nil,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getGridPreview(let menuId, let page, let count) : self.euxp.getGridPreview(
            menuId: menuId, page: page, pageCnt: count, version: nil,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getGatewaySynopsis(let data) : self.euxp.getGatewaySynopsis(
            data:data,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getSynopsis(let data) : self.euxp.getSynopsis(
            data:data,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getRelationContents(let data) : self.euxp.getRelationContents(
            data:data,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getInsideInfo(let data) : self.euxp.getInsideInfo(
            data:data,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getEventBanner(let menuId, let bnrType) : self.euxp.getEventBanner(
            menuId: menuId, bnrTypCd: bnrType,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        //METV
        case .getPurchase(let page, let count) : self.metv.getPurchase(
            page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .deletePurchase(let list) : self.metv.deletePurchase(
            deleteList: list, 
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getCollectiblePurchase(let page, let count) : self.metv.getCollectiblePurchase(
            page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getPurchaseMonthly(let page, let count) : self.metv.getPurchaseMonthly(
            page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getPeriodPurchaseMonthly(let page, let count) : self.metv.getPeriodPurchaseMonthly(
            page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getMonthly(let lowLevelPpm, let page, let count) : self.metv.getMonthly(
            lowLevelPpm:lowLevelPpm, page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getMonthlyData(let prcPrdId, let isDetail) :  self.metv.getMonthlyData(
            prdPrcId: prcPrdId, isDetail: isDetail,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getWatch(let isPpm, let page, let count) : self.metv.getWatch(
            isPpm:isPpm, page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .deleteWatch(let list, let isAll) : self.metv.deleteWatch(
            deleteList: list, isAll: isAll,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getBookMark(let page, let count) : self.metv.getBookMark(
            page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .postBookMark(let data) : self.metv.postBookMark(
            data: data,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .deleteBookMark(let data) : self.metv.deleteBookMark(
            data: data,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getDirectView(let data): self.metv.getDirectView(
            data: data,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getPackageDirectView(let data, let isPpm): self.metv.getPackageDirectView(
            data: data, isPpm:isPpm,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getPossessionPurchase(let stbId ,let page, let count) : self.metv.getPossessionPurchase(
            stbId:stbId, page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        //NPS
        case .registHello : self.nps.postHello(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getDevicePairingStatus : self.nps.getDevicePairingStatus(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getDevicePairingInfo (let authcode, let hostDeviceid, _) : self.nps.getDevicePairingInfo(
            authcode:authcode, hostDeviceid:hostDeviceid,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .postDevicePairing (let user, let device) : self.nps.postDevicePairing(
            user: user, device: device,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .postAuthPairing (let user, let authcode) : self.nps.postAuthPairing(
            user: user, authcode: authcode,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getHostDeviceInfo : self.nps.getHostDeviceInfo(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .postGuestInfo(let user) : self.nps.postGuestInfo(user: user,
            completion: {res in self.complated(id: apiID, type: type, res: res)}, 
            error:error)
        case .postGuestNickname(let name) : self.nps.postGuestNickname(name: name, 
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getGuestAgreement : self.nps.getGuestAgreement(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .postGuestAgreement(let user) : self.nps.postGuestAgreement(user: user,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .updateAgreement(let isAgree) : self.nps.postGuestAgreement(
            user: User(isAgree: isAgree),
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .postUnPairing, .rePairing : self.nps.postUnPairing(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .updateUser(let data) : self.nps.updateUser(data: data,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getPairingToken(let hostDeviceid) : self.nps.getPairingToken(
            hostDeviceid: hostDeviceid,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .validatePairingToken(let pairingToken) : self.nps.validatePairingToken(
            pairingToken: pairingToken,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .postPairingByToken(let user, let pairingToken) : self.nps.postPairingByToken(
            user: user, pairingToken: pairingToken,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        
        case .sendMessage(let data) : self.nps.sendMessage(data: data,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        //KMS
        case .getStbInfo(let cid): self.kms.getStbList(ci: cid,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getTerminateStbInfo(let cid): self.kms.getTerminateStbList(ci: cid,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        //SMD
        case .getLike(let seriesId, let device) : self.smd.getLike(
            seriesId: seriesId, hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .registLike(let isLike, let seriesId, let device) : self.smd.postLike(
            isLike: isLike, seriesId: seriesId, hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        //SCS
        case .getPreview(let epsdRsluId, let device) : self.scs.getPreview(
            epsdRsluId: epsdRsluId, hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getPreplay(let epsdRsluId, let isPreview) : self.scs.getPreplay(
            epsdRsluId: epsdRsluId, isPreview: isPreview,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getPlay(let epsdRsluId, let device) : self.scs.getPlay(
            epsdRsluId: epsdRsluId, hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .confirmPassword(let pw, let device, let pwType) : self.scs.confirmPassword(
            pw: pw, hostDevice: device, type: pwType,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .connectTerminateStb(let cType, let stbId) : self.scs.connectTerminateStb(
            type: cType, stbId: stbId,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        //PSS
        case .getPairingUserInfo(let macAddress, let uiName) : self.pss.getPairingUserInfo(
            macAddress: macAddress, uiName: uiName,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getPairingUserInfoByPackageID(let charId) : self.pss.getPairingUserInfoByPackageID(
            charId: charId,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        //NF
        case .getNotificationVod(let srisId, let epsdId, let notiType , _ ) : self.nf.getNotificationVod(
            srisId:srisId, epsdId:epsdId, type:notiType,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .postNotificationVod(let data) : self.nf.postNotificationVod(
            data:data,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .deleteNotificationVod(let srisId) : self.nf.deleteNotificationVod(
            srisId:srisId,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        //EPS
        case .getTotalPointInfo(let device) : self.eps.getTotalPointInfo(
            hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getTotalPoint(let device, let isSimple) : self.eps.getTotalPoint(
            hostDevice: device, isSimple: isSimple,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getCoupons(let device, let page, let count) : self.eps.getCoupons(
            hostDevice: device, page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .postCoupon(let device, let couponNum) : self.eps.postCoupon(
            hostDevice: device, couponNum:couponNum,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getBPoints(let device, let page, let count) : self.eps.getBPoints(
            hostDevice: device, page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .postBPoint(let device, let pointId) : self.eps.postBPoint(
            hostDevice: device, pointId:pointId,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getBCashes(let device, let page, let count) : self.eps.getBCashes(
            hostDevice: device, page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .postBCash(let device, let cashId) : self.eps.postBCash(
            hostDevice: device, cashId:cashId,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getTvPoint(let device) : self.eps.getTvPoint(
            hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error: error)
        case .getTMembership(let device) : self.eps.getTMembership(
            hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .postTMembership(let device, let card) : self.eps.postTMembership(
            hostDevice: device, card: card,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .deleteTMembership(let device) : self.eps.deleteTMembership(
            hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getOkCashPoint(let device,let card, let pw) : self.eps.getOkCashPoint(
            hostDevice: device, card: card, password:pw,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .postOkCashPoint(let device, let card) : self.eps.postOkCashPoint(
            hostDevice: device, card: card,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .updateOkCashPoint(let device, let card) : self.eps.updateOkCashPoint(
            hostDevice: device, card: card,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .deleteOkCashPoint(let device, let masterSequence) : self.eps.deleteOkCashPoint(
            hostDevice: device, masterSequence: masterSequence,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        //WEPG
        case .getAllChannels(let code) : self.wepg.getAllChannels(regionCode: code,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getCurrentChannels(let ver) : self.wepg.getCurrentChannels(epgVersion: ver,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        //WEB
        case .getSearchKeywords :  self.web.getSearchKeywords(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getCompleteKeywords(let word, let pageType) : self.web.getCompleteKeywords(
            word: word, type:pageType,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getSeachVod(let word, let pageType) : self.web.getSearchVod(
            word: word, type:pageType,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getSeachPopularityVod : self.web.getSeachPopularityVod(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        //KES
        case .getKidsProfiles: self.kes.getKidsProfiles(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .updateKidsProfiles(let profiles): self.kes.updateKidsProfiles(
            profiles: profiles,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getKidStudy(let kid): self.kes.getKidStudy(
            profile: kid,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
            
        case .getMonthlyReport(let kid, let date): self.kes.getMonthlyReport(
            profile: kid, date: date, 
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
            
        case .getEnglishReport(let kid): self.kes.getEnglishReport(
            profile: kid,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getEnglishLvReportExam(let kid, let target): self.kes.getEnglishLvReportExam(
            profile: kid, target: target,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getEnglishLvReportQuestion(let kid, let epNo, let epTpNo, let questions ): self.kes.getEnglishLvReportQuestion(
            profile: kid, epNo: epNo, epTpNo: epTpNo, questions: questions,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getEnglishLvReportResult(let kid): self.kes.getEnglishLvReportResult(
            profile: kid,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
            
        case .getReadingReport(let kid): self.kes.getReadingReport(
            profile: kid,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getReadingReportExam(let kid, let area): self.kes.getReadingReportExam(
            profile: kid, area: area,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getReadingReportQuestion(let kid, let epNo, let epTpNo, let questions ): self.kes.getReadingReportQuestion(
            profile: kid, epNo: epNo, epTpNo: epTpNo, questions: questions,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getReadingReportResult(let kid, let area): self.kes.getReadingReportResult(
            profile: kid, area: area,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        
        case .getCreativeReportExam(let kid): self.kes.getCreativeReportExam(
            profile: kid,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getCreativeReportQuestion(let kid, let epNo, let epTpNo, let questions ): self.kes.getCreativeReportQuestion(
            profile: kid, epNo: epNo, epTpNo: epTpNo, questions: questions,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getCreativeReportResult(let kid): self.kes.getCreativeReportResult(
            profile: kid,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)

        case .getEvaluationReportExam(let kid, let srisId): self.kes.getEvaluationReportExam(
            profile: kid, srisId: srisId, 
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getEvaluationReportQuestion(let kid, let epNo, let epTpNo, let questions ): self.kes.getEvaluationReportQuestion(
            profile: kid, epNo: epNo, epTpNo: epTpNo, questions: questions,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        
        //RPS
        case .getRecommendHistory : self.rps.getRecommendHistory(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getRecommendBenefit : self.mgmRps.getRecommendBenefit(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .registRecommend(let user, let data) : self.mgmRps.registRecommend(
            user: user, data: data,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getRecommendCoupon(let mgmId, let srisTypeCd): self.mgmRps.getRecommendCoupon(
            mgmId: mgmId, srisTypeCd: srisTypeCd,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
            
        //LGS
        case .postWatchLog(let evt, let playData, let synopData, let pairing,
                           let pcId, let isKidZone, let gubun) : self.lgs.postWatchLog(
            evt: evt, playData: playData, synopData: synopData,
            pairing: pairing, pcId: pcId,
            isKidZone: isKidZone, gubun: gubun,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
            
        case .postWatchLogPossession(let evt, let playData, let synopData, let pairing, let mbtvKey,
                           let pcId, let isKidZone, let gubun) : self.lgs.postWatchLogPossession(
            evt: evt, playData: playData, synopData: synopData,
            pairing: pairing,mbtvKey: mbtvKey, pcId: pcId,
            isKidZone: isKidZone, gubun: gubun,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
            
        }
        return apiID
    }
    
    private func complated<T:Decodable>(id:String, type:ApiType, res:T){
        let result:ApiResultResponds = .init(id: id, type:type, data: res)
        let prevHost = NpsNetwork.hostDeviceId
        
        switch type {
        case .registHello :
            if let path = NpsNetwork.hello(res: result) {
                self.nps = Nps(network: NpsNetwork(enviroment: path))
                if  NpsNetwork.hostDeviceId == nil {
                    self.load(q: .init(type: .postUnPairing, isOptional:true))
                }
            }
            self.updatePairing(res: result )
            
        case .postAuthPairing, .postDevicePairing, .postPairingByToken :
            NpsNetwork.pairing(res: result)
        case .postUnPairing :
            NpsNetwork.unpairing(res: result)
        case .getDevicePairingStatus :
            NpsNetwork.checkPairing(res: result) 
        default: do{}
        }
        
        if prevHost != NpsNetwork.hostDeviceId{
            self.event = .pairingHostChanged
        }
        if let trans = transition[result.id] {
            transition.removeValue(forKey: result.id)
            self.load(q:trans)
        }else{
            self.result = .init(id: id, type:type, data: res)
        }
    }
    
    private func updatePairing(res:ApiResultResponds){
        guard let resData = res.data as? Hello else { return }
        guard let tierInfo = resData.body?.tier_info else { return }
        let pairingUpdateFlag = PairingUpdateFlag.getFlag( tierInfo.lastest_update_level )
        let productNm = tierInfo.product_name
        let maxCount = resData.body?.pairing_info?.max_count?.toInt()
        let count = resData.body?.pairing_info?.count?.toInt()
        let data = PairingUpdateData(updateFlag: pairingUpdateFlag, productName: productNm, maxCount: maxCount, count: count)
        self.event = .pairingUpdated(data)
    }
    
    private func complated(id:String, type:ApiType, res:Blank){
        let result:ApiResultResponds = .init(id: id, type:type, data: res)
        if let trans = transition[result.id] {
            transition.removeValue(forKey: result.id)
            self.load(q:trans)
        }else{
            self.result = .init(id: id, type:type, data: res)
        }
    }
    
    private func onError(id:String, type:ApiType, e:Error,isOptional:Bool = false, isLog:Bool = false, isProcess:Bool = false){
        if let trans = transition[id] {
            transition.removeValue(forKey: id)
            self.error = .init(id: id, type:trans.type, error: e, isOptional:isOptional, isLog:isLog, isProcess:isProcess)
        }else{
            self.error = .init(id: id, type:type, error: e, isOptional:isOptional, isLog:isLog, isProcess:isProcess)
        }
        
    }

    
}
