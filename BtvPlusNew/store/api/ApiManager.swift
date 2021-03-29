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
    case pairingHostChanged
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
    private lazy var web:Web = Web(network: WebNetwork())
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
        self.apiQ.removeAll()
    }
    
    private func initateApi()
    {
        NpsNetwork.goodbye()
        self.vms.versionCheck(
            completion:{res in
                self.complated(id: "", type: .versionCheck, res: res)
                if let configs = res.server_conf {
                    configs.forEach{ con in
                        let key = con.keys.first ?? ""
                        if let value = con[key] {
                            SystemEnvironment.serverConfig[key] = value
                            DataLog.d("key " + key + " value " + value)
                        }
                    }
                }
                self.initApi()
            },
            error:{ err in
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
                self.load(.registHello, action: q.action, resultId: q.id, isOptional: q.isOptional, isProcess: q.isProcess)
                return
            }
        default : do{}
        }
        self.load(q.type, action: q.action, resultId: q.id, isOptional: q.isOptional, isProcess: q.isProcess)
    }
    

    @discardableResult
    func load(_ type:ApiType, action:ApiAction? = nil,
              resultId:String = "", isOptional:Bool = false, isLock:Bool = false, isProcess:Bool = false)->String
    {
        let apiID = resultId //+ UUID().uuidString
        if status != .ready{
            self.apiQ.append(ApiQ(id: resultId, type: type, action: action, isOptional: isOptional, isLock: isLock))
            return apiID
        }
        let error = {err in self.onError(id: apiID, type: type, e: err, isOptional: isOptional, isProcess: isProcess)}
        switch type {
        case .versionCheck : self.vms.versionCheck(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getGnb : self.euxp.getGnbBlock(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getCWGrid(let menuId, let cwCallId) : self.euxp.getCWGrid(
            menuId: menuId, cwCallId: cwCallId,
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
        //NPS
        case .registHello : self.nps.postHello(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getDevicePairingStatus : self.nps.getDevicePairingStatus(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getDevicePairingInfo (let authcode, let hostDeviceid) : self.nps.getDevicePairingInfo(
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
        case .postGuestNickname(let user) : self.nps.postGuestNickname(user: user,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getGuestAgreement : self.nps.getGuestAgreement(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .postGuestAgreement(let user) : self.nps.postGuestAgreement(user: user,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .postUnPairing, .rePairing : self.nps.postUnPairing(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .updateUser(let data) : self.nps.updateUser(data: data,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        //KMS
        case .getStbInfo(let cid): self.kms.getStbList(ci: cid,
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
        //WEB
        case .getSearchKeywords :   self.web.getSearchKeywords(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getCompleteKeywords(let word) : self.web.getCompleteKeywords(
            word: word,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getSeachVod(let word) : self.web.getSearchVod(word: word,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .getSeachPopularityVod : self.web.getSeachPopularityVod(
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
            }
        case .postAuthPairing, .postDevicePairing :
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
    
    private func complated(id:String, type:ApiType, res:Blank){
        let result:ApiResultResponds = .init(id: id, type:type, data: res)
        if let trans = transition[result.id] {
            transition.removeValue(forKey: result.id)
            self.load(q:trans)
        }else{
            self.result = .init(id: id, type:type, data: res)
        }
    }
    
    private func onError(id:String, type:ApiType, e:Error,isOptional:Bool = false, isProcess:Bool = false){
        if let trans = transition[id] {
            transition.removeValue(forKey: id)
            self.error = .init(id: id, type:trans.type, error: e, isOptional:isOptional, isProcess:isProcess)
        }else{
            self.error = .init(id: id, type:type, error: e, isOptional:isOptional, isProcess:isProcess)
        }
        
    }

    
}
