//
//  ApiManager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import Combine
enum ApiStatus:String{
    case initate, ready
}

enum ApiEvents{
    case pairingHostChanged, pairingUpdated(PairingUpdateData), needUpdate(UpdateFlag, serverMsg:String?)
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
    var defaultMessage: String {
        switch self {
        case .force: return String.alert.updateForce
        case .recommend: return String.alert.updateRecommend
        default: return ""
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
    private lazy var vms:Vms = Vms(network: VmsNetwork())
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
    private lazy var vls:Vls = Vls(network: VlsNetwork())
    private lazy var cbs:Cbs = Cbs(network: CbsNetwork())
    private lazy var uoRps:UoRps = UoRps(network: UoRpsNetwork())
    
    // 로그 서버 || 권한등  페이지이동시 켄슬 안함
    private lazy var lgs:Lgs = Lgs(network: LgsNetwork())
    private(set) lazy var navilog:Navilog = Navilog(network: NavilogNetwork())
    private(set) lazy var navilogNpi:Navilog = Navilog(network: NavilogNpiNetwork())
    private lazy var pucr:Pucr = Pucr(network: PucrNetwork())
    private lazy var push:Push = Push(network: PushNetwork())
    private lazy var metvAuth:Metv = Metv(network: MetvNetwork())
    private lazy var metvEvent:Metv = Metv(network: MetvNetwork())
    private(set) var updateFlag: UpdateFlag = .none
    
    var isSystemStop:Bool = false
    
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
        self.vls.clear()
        self.cbs.clear()
        self.uoRps.clear()
        self.apiQ.removeAll()
    }
    
    func initateApi()
    {
        NpsNetwork.goodbye()
        if self.isSystemStop {return}
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
                            SystemEnvironment.serverConfig[key]
                                = value.replace("\n", with: "").replace(" ", with: "")
                            DataLog.d("key " + key + " value " + value, tag:self.tag)
                        }
                    }
                }
                switch self.updateFlag {
                case .force :
                    self.event = .needUpdate(self.updateFlag, serverMsg:res.releaseNote)
                    return
                case .recommend :
                    self.event = .needUpdate(self.updateFlag, serverMsg:res.releaseNote)
                    return
                default : break
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
    func initApi()
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
                self.load(.registHello, resultId: q.id,
                          isOptional: q.isOptional, isLock: q.isLock, isLog:q.isLog, isProcess: q.isProcess)
                return
            }
        default : break
        }
        self.load(q.type, resultId: q.id,
                  isOptional: q.isOptional, isLock: q.isLock, isLog:q.isLog, isProcess: q.isProcess)
    }
    
    

    @discardableResult
    func load(_ type:ApiType, resultId:String = "",
              isOptional:Bool = false, isLock:Bool = false, isLog:Bool = false, isProcess:Bool = false)->String
    {
        let apiID = resultId //+ UUID().uuidString
        if status != .ready{
            self.apiQ.append(ApiQ(id: resultId, type: type, isOptional: isOptional, isLock: isLock, isLog: isLog))
            return apiID
        }
        let error = {err in self.onError(id: apiID, type: type, e: err, isOptional: isOptional, isLog: isLog, isProcess: isProcess)}
         
        switch type {
        case .versionCheck : self.vms.versionCheck(
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getGnb : self.euxp.getGnbBlock(
            isKids: false,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getGnbKids : self.euxp.getGnbBlock(
            isKids: true,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getCWGrid(let menuId, let cwCallId, let isKids) : self.euxp.getCWGrid(
            menuId: menuId, cwCallId: cwCallId, isKids: isKids,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getCWGridKids(let kid , let cwCallId, let sortType) : self.euxp.getCWGridKids(
            kid:kid, cwCallId: cwCallId, sortType: sortType,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getGridEvent(let menuId, let sort, let page, let count) : self.euxp.getGridEvent(
            menuId: menuId, sortType: sort, page: page, pageCnt: count, version: nil,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getGridPreview(let menuId, let page, let count) : self.euxp.getGridPreview(
            menuId: menuId, page: page, pageCnt: count, version: nil,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getGatewaySynopsis(let data, let anotherStb) : self.euxp.getGatewaySynopsis(
            data:data, anotherStbId: anotherStb,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getSynopsis(let data, let anotherStb) : self.euxp.getSynopsis(
            data:data, anotherStbId: anotherStb,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getRelationContents(let data, let anotherStb) : self.euxp.getRelationContents(
            data:data, anotherStbId: anotherStb,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getInsideInfo(let epsdId) : self.euxp.getInsideInfo(
            epsdId: epsdId, 
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getEventBanner(let menuId, let bnrType) : self.euxp.getEventBanner(
            menuId: menuId, bnrTypCd: bnrType,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        //METV
        case .getPlayTime(let epsdId) : self.metv.getPlayTime(
            epsdId: epsdId,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getPurchase(let page, let count) : self.metv.getPurchase(
            page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .deletePurchase(let list) : self.metv.deletePurchase(
            deleteList: list, 
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getCollectiblePurchase(let page, let count) : self.metv.getCollectiblePurchase(
            page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        
        case .getMonthlyData(let prcPrdId, let isDetail) :  self.metv.getMonthlyData(
            prdPrcId: prcPrdId, isDetail: isDetail,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getWatch(let isPpm, let isKid, let page, let count) : self.metv.getWatch(
            isPpm:isPpm, isKids: isKid, page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .deleteWatch(let list, let isAll) : self.metv.deleteWatch(
            deleteList: list, isAll: isAll,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getWatchMobile(let isPpm, let page, let count) : self.metv.getWatchMobile(
            isPpm:isPpm, page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .deleteWatchMobile(let list, let isAll) : self.metv.deleteWatchMobile(
            deleteList: list, isAll: isAll,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getBookMark(let page, let count) : self.metv.getBookMark(
            page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .postBookMark(let data) : self.metv.postBookMark(
            data: data,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .deleteBookMark(let data) : self.metv.deleteBookMark(
            data: data,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        
        case .getPossessionPurchase(let stbId ,let page, let count) : self.metv.getPossessionPurchase(
            stbId:stbId, page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getHostNickname(let isAll, let anotherStbId): self.metv.getHostNickname(
            isAll: isAll, anotherStbId:anotherStbId,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .updateStbNickName(let nickName) : self.metv.updateStbNickName(name: nickName ?? "",
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
            
        //ME_AUTH
        case .getPurchaseMonthly(let page, let count) : self.metvAuth.getPurchaseMonthly(
            page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getPeriodPurchaseMonthly(let page, let count) : self.metvAuth.getPeriodPurchaseMonthly(
            page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getMonthly(let lowLevelPpm, let page, let count) : self.metvAuth.getMonthly(
            lowLevelPpm:lowLevelPpm, page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        //ME_EVENT
        case .postAttendance(let pcid, _): self.metvEvent.postAttendance(
            pcId: pcid,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getAttendance(let pcid, _): self.metvEvent.getAttendance(
            pcId: pcid,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        
        //NPS
        case .registHello : self.nps.postHello(
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getDevicePairingStatus : self.nps.getDevicePairingStatus(
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getUserDevicePairingStatus : self.nps.getDevicePairingStatus(
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getDevicePairingInfo (let authcode, let hostDeviceid, _) : self.nps.getDevicePairingInfo(
            authcode:authcode, hostDeviceid:hostDeviceid,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .postDevicePairing (let user, let device) : self.nps.postDevicePairing(
            user: user, device: device,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .postUserDevicePairing(let user, let device) : self.nps.postUserDevicePairing(
            user: user, device: device,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .postAuthPairing (let user, let authcode) : self.nps.postAuthPairing(
            user: user, authcode: authcode,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getHostDeviceInfo : self.nps.getHostDeviceInfo(
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .postGuestInfo(let user) : self.nps.postGuestInfo(user: user,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .postGuestNickname(let name) : self.nps.postGuestNickname(name: name, 
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getGuestAgreement : self.nps.getGuestAgreement(
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .postGuestAgreement(let user) : self.nps.postGuestAgreement(user: user,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .updateAgreement(let isAgree, _) : self.nps.postGuestAgreement(
            user: User(isAgree: isAgree),
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .postUnPairing, .rePairing : self.nps.postUnPairing(
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .updateUser(let data) : self.nps.updateUser(data: data,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getPairingToken(let hostDeviceid, let pairingInType) : self.nps.getPairingToken(
            hostDeviceid: hostDeviceid, pairingInType:pairingInType,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .validatePairingToken(let pairingToken) : self.nps.validatePairingToken(
            pairingToken: pairingToken,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .postPairingByToken(let user, let pairingToken) : self.nps.postPairingByToken(
            user: user, pairingToken: pairingToken,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        
        case .sendMessage(let data) : self.nps.sendMessage(data: data,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .pushMessage(let data) : self.nps.pushMessage(data: data,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        //KMS
        case .getStbList(let cid): self.kms.getStbList(ci: cid,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getTerminateStbInfo(let cid): self.kms.getTerminateStbList(ci: cid,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        //OKSUSU TEST
        case .getOksusuUser(let cid): self.kms.getTerminateStbList(ci: cid,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getOksusuUserInfo(let cid): self.kms.getTerminateStbList(ci: cid,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .connectOksusuUser(let cid) : self.kms.getTerminateStbList(ci: cid,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .disconnectOksusuUser(let cid) : self.kms.getTerminateStbList(ci: cid,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .addOksusuUserToBtvPurchase(let cid) : self.kms.getTerminateStbList(ci: cid,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
    
        //SMD
        case .getLike(let seriesId, let device, let isTotal) : self.smd.getLike(
            seriesId: seriesId, hostDevice: device, isTotal: isTotal,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .registLike(let isLike, let seriesId, let device, _, _) : self.smd.postLike(
            isLike: isLike, seriesId: seriesId, hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        //SCS
        case .getDirectView(let data, let anotherStb): self.scs.getDirectView(
            data: data, anotherStbId: anotherStb,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getPackageDirectView(let data, let isPpm, let pidList, let anotherStb): self.scs.getPackageDirectView(
            data: data, isPpm:isPpm, pidList: pidList, anotherStbId: anotherStb,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getPreview(let epsdRsluId, let device) : self.scs.getPreview(
            epsdRsluId: epsdRsluId, hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getPreplay(let epsdRsluId, let isPreview, let device) : self.scs.getPreplay(
            epsdRsluId: epsdRsluId, isPreview: isPreview, hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getPlay(let epsdRsluId, let anotherStb, let device) : self.scs.getPlay(
            epsdRsluId: epsdRsluId, anotherStbId: anotherStb, hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .confirmPassword(let pw, let device, let pwType) : self.scs.confirmPassword(
            pw: pw, hostDevice: device, type: pwType,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .connectTerminateStb(let cType, let stbId) : self.scs.connectTerminateStb(
            type: cType, stbId: stbId,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getStbInfo(let device) : self.scs.getStbInfo(
            hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        //PSS
        case .getPairingUserInfo(let macAddress, let uiName) : self.pss.getPairingUserInfo(
            macAddress: macAddress, uiName: uiName,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getPairingUserInfoByPackageID(let charId) : self.pss.getPairingUserInfoByPackageID(
            charId: charId,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        //NF
        case .getNotificationVod(let srisId, let epsdId, let notiType , _ ) : self.nf.getNotificationVod(
            srisId:srisId, epsdId:epsdId, type:notiType,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .postNotificationVod(let data) : self.nf.postNotificationVod(
            data:data,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .deleteNotificationVod(let srisId) : self.nf.deleteNotificationVod(
            srisId:srisId,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        //EPS
        case .getTotalPointInfo(let device) : self.eps.getTotalPointInfo(
            hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getTotalPoint(let device, let isSimple) : self.eps.getTotalPoint(
            hostDevice: device, isSimple: isSimple,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getCoupons(let device, let page, let count) : self.eps.getCoupons(
            hostDevice: device, page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .postCoupon(let device, let couponNum) : self.eps.postCoupon(
            hostDevice: device, couponNum:couponNum,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getBPoints(let device, let page, let count) : self.eps.getBPoints(
            hostDevice: device, page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .postBPoint(let device, let pointId) : self.eps.postBPoint(
            hostDevice: device, pointId:pointId,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getBCashes(let device, let page, let count) : self.eps.getBCashes(
            hostDevice: device, page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .postBCash(let device, let cashId) : self.eps.postBCash(
            hostDevice: device, cashId:cashId,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getTvPoint(let device) : self.eps.getTvPoint(
            hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error: error)
        case .getTMembership(let device) : self.eps.getTMembership(
            hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .postTMembership(let device, let card) : self.eps.postTMembership(
            hostDevice: device, card: card,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .deleteTMembership(let device) : self.eps.deleteTMembership(
            hostDevice: device,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getOkCashPoint(let device,let card, let pw) : self.eps.getOkCashPoint(
            hostDevice: device, card: card, password:pw,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .postOkCashPoint(let device, let card) : self.eps.postOkCashPoint(
            hostDevice: device, card: card,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .updateOkCashPoint(let device, let card) : self.eps.updateOkCashPoint(
            hostDevice: device, card: card,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .deleteOkCashPoint(let device, let masterSequence) : self.eps.deleteOkCashPoint(
            hostDevice: device, masterSequence: masterSequence,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        //WEPG
        case .getAllChannels(let code) : self.wepg.getAllChannels(regionCode: code,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getCurrentChannels(let ver) : self.wepg.getCurrentChannels(epgVersion: ver,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        //WEB
        case .getSearchKeywords :  self.web.getSearchKeywords(
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getCompleteKeywords(let word, let pageType) : self.web.getCompleteKeywords(
            word: word, type:pageType,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getSeachVod(let word, let pageType) : self.web.getSearchVod(
            word: word, type:pageType,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getSeachPopularityVod : self.web.getSeachPopularityVod(
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        //KES
        case .getKidsProfiles: self.kes.getKidsProfiles(
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .updateKidsProfiles(let profiles): self.kes.updateKidsProfiles(
            profiles: profiles,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getKidStudy(let kid): self.kes.getKidStudy(
            profile: kid,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
            
        case .getMonthlyReport(let kid, let date): self.kes.getMonthlyReport(
            profile: kid, date: date, 
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
            
        case .getEnglishReport(let kid): self.kes.getEnglishReport(
            profile: kid,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getEnglishLvReportExam(let kid, let target): self.kes.getEnglishLvReportExam(
            profile: kid, target: target,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getEnglishLvReportQuestion(let kid, let epNo, let epTpNo, let questions ): self.kes.getEnglishLvReportQuestion(
            profile: kid, epNo: epNo, epTpNo: epTpNo, questions: questions,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getEnglishLvReportResult(let kid): self.kes.getEnglishLvReportResult(
            profile: kid,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
            
        case .getReadingReport(let kid): self.kes.getReadingReport(
            profile: kid,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getReadingReportExam(let kid, let area): self.kes.getReadingReportExam(
            profile: kid, area: area,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getReadingReportQuestion(let kid, let epNo, let epTpNo, let questions ): self.kes.getReadingReportQuestion(
            profile: kid, epNo: epNo, epTpNo: epTpNo, questions: questions,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getReadingReportResult(let kid, let area): self.kes.getReadingReportResult(
            profile: kid, area: area,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        
        case .getCreativeReportExam(let kid): self.kes.getCreativeReportExam(
            profile: kid,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getCreativeReportQuestion(let kid, let epNo, let epTpNo, let questions ): self.kes.getCreativeReportQuestion(
            profile: kid, epNo: epNo, epTpNo: epTpNo, questions: questions,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getCreativeReportResult(let kid): self.kes.getCreativeReportResult(
            profile: kid,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)

        case .getEvaluationReportExam(let kid, let srisId): self.kes.getEvaluationReportExam(
            profile: kid, srisId: srisId, 
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getEvaluationReportQuestion(let kid, let epNo, let epTpNo, let questions ): self.kes.getEvaluationReportQuestion(
            profile: kid, epNo: epNo, epTpNo: epTpNo, questions: questions,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        
        //RPS
        case .getRecommendHistory : self.rps.getRecommendHistory(
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getRecommendBenefit : self.mgmRps.getRecommendBenefit(
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .registRecommend(let user, let data) : self.mgmRps.registRecommend(
            user: user, data: data,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .getRecommendCoupon(let mgmId, let srisTypeCd): self.mgmRps.getRecommendCoupon(
            mgmId: mgmId, srisTypeCd: srisTypeCd,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
            
        //LGS
        case .postWatchLog(let evt, let playData, let synopData, let pairing,
                           let pcId, let isKidZone, let gubun) : self.lgs.postWatchLog(
            evt: evt, playData: playData, synopData: synopData,
            pairing: pairing, pcId: pcId,
            isKidZone: isKidZone, gubun: gubun,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
            
        case .postWatchLogPossession(let evt, let playData, let synopData, let pairing, let mbtvKey,
                           let pcId, let isKidZone, let gubun) : self.lgs.postWatchLogPossession(
            evt: evt, playData: playData, synopData: synopData,
            pairing: pairing,mbtvKey: mbtvKey, pcId: pcId,
            isKidZone: isKidZone, gubun: gubun,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
            
        case .checkProhibitionSimultaneous(let synopData, let pairing, let pcId): self.vls.checkProhibitionSimultaneous(
            synopData: synopData,pairing: pairing, pcId: pcId,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
            
        //CBS
        case .certificationCoupon(let no, let device): self.cbs.certificationCoupon(
            couponNum: no, stbInfo: device,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .requestBPointIssuance(let pointPolicyNum, let pointAmount, _): self.cbs.requestBPointIssuance(
            pointPolicyNum: pointPolicyNum, pointAmount: pointAmount,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
            
        //UORPS
        case .checkNuguPairing(let macAddress): self.uoRps.checkNuguPairing(macAddress: macAddress, 
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        //NaviLog
        case .sendNaviLog(let log, let isAnonymous):
            if isAnonymous {
                self.navilogNpi.sendLogNpi(log: log, completion: {_ in}, error: nil)
            } else {
                self.navilog.sendLog(log: log, completion: {_ in}, error: nil)
            }
        case .createEndpoint(_) : self.pucr.createEndpoint(
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .registerToken(let endpointId, let token) : self.pucr.registerToken(
            endpointId: endpointId, token: token,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .recivePush(let endpointId, let messageId) : self.pucr.recivePush(
            endpointId: endpointId, messageId: messageId,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .confirmPush(let endpointId, let messageId) : self.pucr.confirmPush(
            endpointId: endpointId, messageId: messageId,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .registEndpoint(let endpointId, let isAgree) : self.push.registEndpoint(
            endpointId: endpointId, isAgree: isAgree,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        case .updatePushUserAgreement(let isAgree) : self.push.updatePushUserAgreement(
            isAgree: isAgree,
            completion: {res in self.complated(id: apiID, type: type, res: res, isOptional: isOptional, isLog: isLog)},
            error:error)
        }
        return apiID
    }
    
    private func complated<T:Decodable>(id:String, type:ApiType, res:T, isOptional:Bool = false, isLog:Bool = false){
        let result:ApiResultResponds = .init(id: id, type:type, data: res, isOptional: isOptional, isLog: isLog)
        let prevHost = (NpsNetwork.hostDeviceId ?? "") + NpsNetwork.pairingId
        switch type {
        case .registHello :
            if let path = NpsNetwork.hello(res: result) {
                self.nps = Nps(network: NpsNetwork(enviroment: path))
                if  NpsNetwork.hostDeviceId == nil {
                    self.load(q: .init(type: .postUnPairing, isOptional:true))
                }
            }
            self.updatePairing(res: result )
            
        case .postAuthPairing, .postDevicePairing, .postUserDevicePairing, .postPairingByToken :
            NpsNetwork.pairing(res: result)
        case .getUserDevicePairingStatus :
            NpsNetwork.pairingUser(res: result)
        case .postUnPairing :
            if !isLog { NpsNetwork.unpairing(res: result) }
        case .getDevicePairingStatus :
            NpsNetwork.checkPairing(res: result) 
        default: break
        }
        let currentHost = (NpsNetwork.hostDeviceId ?? "") + NpsNetwork.pairingId
        if prevHost != currentHost {
            self.event = .pairingHostChanged
        }
        if let trans = transition[result.id] {
            transition.removeValue(forKey: result.id)
            self.load(q:trans)
        }else{
            self.result = .init(id: id, type:type, data: res, isOptional: isOptional, isLog: isLog)
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
    
    private func complated(id:String, type:ApiType, res:Blank, isOptional:Bool, isLog:Bool){
        let result:ApiResultResponds = .init(id: id, type:type, data: res, isOptional: isOptional, isLog: isLog)
        if let trans = transition[result.id] {
            transition.removeValue(forKey: result.id)
            self.load(q:trans)
        }else{
            self.result = .init(id: id, type:type, data: res, isOptional: isOptional, isLog: isLog)
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
