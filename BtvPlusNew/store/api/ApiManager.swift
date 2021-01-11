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

class ApiManager :PageProtocol, ObservableObject{
    static private(set) var stbId:String = "{00000000-0000-0000-0000-000000000000}"
    @Published var status:ApiStatus = .initate
    @Published var result:ApiResultResponds? = nil {didSet{ if result != nil { result = nil} }}
    @Published var error:ApiResultError? = nil {didSet{ if error != nil { error = nil} }}
    
    private var anyCancellable = Set<AnyCancellable>()
    private var apiQ :[ ApiQ ] = []
    private let vms:Vms = Vms(network: VmsNetwork())
    private lazy var euxp = Euxp(network: EuxpNetwork())
    private lazy var metv = Metv(network: MetvNetwork())
    private lazy var nps = Nps(network: NpsNetwork())
    private var stbId:String
    init(pairing:Pairing) {
        self.stbId = pairing.stbId
        self.initateApi()
        pairing.$event.sink(receiveValue: { evt in
            Self.stbId = pairing.stbId
        
        }).store(in: &anyCancellable)
    }
    
    func clear(){
        self.euxp.clear()
        self.metv.clear()
        self.nps.clear()
        self.apiQ.removeAll()
    }
    
    private func initateApi()
    {
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
        case .postAuthPairing, .postDevicePairingInfo, .postDevicePairing :
            if NpsNetwork.sessionId == "" {
                transition[q.id] = q
                self.load(.postHello, action: q.action, resultId: q.id, isOptional: q.isOptional)
                return
            }
        default : do{}
        }
        self.load(q.type, action: q.action, resultId: q.id, isOptional: q.isOptional)
    }
    
    
    
    @discardableResult
    func load(_ type:ApiType, action:ApiAction? = nil,
              resultId:String = "", isOptional:Bool = false, isLock:Bool = false)->String
    {
        let apiID = resultId //+ UUID().uuidString
        if status != .ready{
            self.apiQ.append(ApiQ(id: resultId, type: type, action: action, isOptional: isOptional, isLock: isLock))
            return apiID
        }
        let error = {err in self.onError(id: apiID, type: type, e: err, isOptional: isOptional)}
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
        //METV
        case .getBookMark(let page, let count) : self.metv.getBookMark(
            page: page, pageCnt: count,
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        //NPS
        case .postHello : self.nps.postHello(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        case .postDevicePairingInfo (let authcode, let hostDeviceid) : self.nps.postDevicePairingInfo(
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
        case .postHostDeviceInfo : self.nps.postHostDeviceInfo(
            completion: {res in self.complated(id: apiID, type: type, res: res)},
            error:error)
        } 
        return apiID
    }
    
    private func complated<T:Decodable>(id:String, type:ApiType, res:T){
        let result:ApiResultResponds = .init(id: id, type:type, data: res)
        switch type {
        case .postHello :
            if let path = NpsNetwork.hello(res: result) {
                nps = Nps(network: NpsNetwork(enviroment: path))
            }
        default: do{}
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
    
    private func onError(id:String, type:ApiType, e:Error,isOptional:Bool = false){
        if let trans = transition[id] {
            transition.removeValue(forKey: id)
            self.error = .init(id: id, type:trans.type, error: e, isOptional:isOptional)
        }else{
            self.error = .init(id: id, type:type, error: e, isOptional:isOptional)
        }
        
    }

    
}
