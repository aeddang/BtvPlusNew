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
    case initate, ready, reflash
}

class ApiManager :PageProtocol, ObservableObject{
    
    var status:ApiStatus = .initate
    @Published var result:ApiResultResponds? = nil {didSet{ if result != nil { result = nil} }}
    @Published var error:ApiResultError? = nil {didSet{ if error != nil { error = nil} }}
    
    private var apiQ :[ ApiQ ] = []
    private let vms:Vms = Vms(network: VmsNetwork())
    private lazy var euxp:Euxp = Euxp(network: EuxpNetwork())
    init() {
        self.initateApi()
    }
    
    func clear(){
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
    
    func load(q:ApiQ){
        self.load(q.type, action: q.action, resultId: q.id, isOptional: q.isOptional)
    }
    
    @discardableResult
    func load(_ type:ApiType, action:ApiAction? = nil,
              resultId:String? = nil, isOptional:Bool = false, isLock:Bool = false)->String
    {
        let apiID = (resultId == nil) ? UUID().uuidString : (resultId! + UUID().uuidString)
        if status != .ready{
            self.apiQ.append(ApiQ(id: apiID, type: type, action: action, isOptional: isOptional, isLock: isLock))
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
        }
        return apiID
    }
    
    private func complated<T:Decodable>(id:String, type:ApiType, res:T){
        self.result = .init(id: id, type:type, data: res)
    }
    private func complated(id:String, type:ApiType, res:Blank){
        self.result = .init(id: id, type:type, data: res)
    }
    private func onError(id:String, type:ApiType, e:Error,isOptional:Bool = false){
        self.error = .init(id: id, type:type, error: e, isOptional:isOptional)
    }

    
}
