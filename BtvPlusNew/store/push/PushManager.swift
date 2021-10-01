//
//  PushManager.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/25.
//

import Foundation
import Combine

class PushManager : PageProtocol {
    static func getCurrentCuid()-> String{
       return SystemEnvironment.originDeviceId
    }
    static func setupCurrentCuid(){
        Self.currentCuid = getCurrentCuid()
    }
    static private(set) var currentCuid:String = "btvplus"
    
    private(set) var currentToken:String = ""
    private(set) var endpointId:String = ""
    private(set) var apnsToken:String = ""
    private(set) var userAgreement:Bool = false
    private var apiManager:ApiManager? = nil
    private let localStorage:LocalStorage
    private var dataCancellable = Set<AnyCancellable>()
    var namedStorage:LocalNamedStorage? = nil
    private var isBusy:Bool = false
    init(storage:LocalStorage) {
        self.localStorage = storage
    }
    
    private func reset(){
        if let storage = namedStorage {
            endpointId = storage.pushEndpoint
            apnsToken = storage.registPushToken
        }
        userAgreement = false
        isBusy = false
    }
    
    func setupStorage(storage:LocalNamedStorage){
        self.namedStorage = storage
        self.reset()
    }
    
    func retryRegisterPushToken(){
        if self.currentToken.isEmpty {
            //DataLog.d("not ready currentToken", tag: self.tag)
            return
        }
        
        guard let storage = namedStorage else { return }
        if self.isBusy {
            //DataLog.d("already process retryRegisterPushToken", tag: self.tag)
            return
            
        }
        if !storage.retryPushToken.isEmpty {
            DataLog.d("retry RegisterPushToken", tag: self.tag)
            self.resetRegisterPushToken(storage.retryPushToken)
        } else {
            if storage.registPushCuid != Self.getCurrentCuid() {
                DataLog.d("reset RegisterPushToken", tag: self.tag)
                self.resetRegisterPushToken(self.currentToken)
            } else {
                //DataLog.d("already RegisterPushToken", tag: self.tag)
            }
        }
    }
    
    func resetRegisterPushToken(_ token:String) {
        self.namedStorage?.registPushToken = ""
        self.registerPushToken(token)
    }
    
    func initRegisterPushToken(_ token:String) {
        self.currentToken = token
        self.registerPushToken(token)
    }
    
    
    private func registerPushToken(_ token:String) {
        guard let storage = namedStorage else {
            self.isBusy = false
            return
        }
        Self.setupCurrentCuid()
        let registToken = storage.registPushToken
        let endpoint = storage.pushEndpoint
        if token == registToken && !endpoint.isEmpty {
            DataLog.d("already endpoint " + token, tag: self.tag)
            //self.updateUserAgreement(self.userAgreement)
            return
        }
        self.isBusy = true
        DataLog.d("create endpoint", tag: self.tag)
        storage.registPushCuid = ""
        storage.registPushToken = ""
        storage.pushEndpoint = ""
        storage.registEndpoint = ""
        storage.registPushUserAgreement = nil
        self.apnsToken = ""
        self.endpointId = ""
        self.apiManager?.load(.createEndpoint(token), isOptional: true)
    }
    
    func updateUserAgreement(_ isAgree:Bool) {
        guard let storage = namedStorage else {
            self.isBusy = false
            return
        }
        self.userAgreement = isAgree
        if self.endpointId.isEmpty {
            self.isBusy = false
            return
        }
        DataLog.d("updateUserAgreement : " + isAgree.description, tag: self.tag)
        let registEndpoint = storage.registEndpoint
        if !registEndpoint.isEmpty {
            if storage.registPushUserAgreement == isAgree {
                DataLog.d("already UserAgreement", tag: self.tag)
                self.isBusy = false
            } else {
                DataLog.d("update UserAgreement", tag: self.tag)
                DataLog.d("updated " + Self.currentCuid, tag:self.tag)
                self.apiManager?.load(.updatePushUserAgreement(isAgree), isOptional: true)
            }
        } else {
            DataLog.d("regist Endpoint", tag: self.tag)
            self.apiManager?.load(.registEndpoint(self.endpointId, isAgree: isAgree), isOptional: true)
        }
    }
    
    private func onRegistFail(token:String){
        self.isBusy = false
        guard let storage = namedStorage else { return }
        storage.retryPushToken = token
        storage.registPushToken = ""
        storage.pushEndpoint = ""
        DataLog.e("registerToken error", tag:self.tag)
    }

    func recivePush(_ messageId:String?) {
        guard let messageId = messageId else { return }
        if self.endpointId.isEmpty { return }
        self.apiManager?.load(.recivePush(endpointId, messageId: messageId), isLog: true)
    }
    
    func confirmPush(_ messageId:String?) {
        guard let messageId = messageId else { return }
        if self.endpointId.isEmpty { return }
        self.apiManager?.load(.confirmPush(endpointId, messageId: messageId),  isLog: true)
    }
    
    
    func setupApiManager(_ apiManager:ApiManager){
        self.reset()
        self.apiManager = apiManager
        self.dataCancellable.forEach{$0.cancel()}
        self.dataCancellable.removeAll()
        apiManager.$result.sink(receiveValue: { res in
            guard let res = res else { return }
            switch res.type {
            case .createEndpoint(let token) : 
                guard let data = res.data as? EndPoint else { return self.onRegistFail(token: token) }
                guard let endpoint = data.endpoint_id  else { return self.onRegistFail(token: token) }
                DataLog.d("createEndpoint success", tag:self.tag)
                apiManager.load(.registerToken(endpoint, token: token), isOptional: true)
                
            case .registerToken(let endpoint, let token) :
                self.namedStorage?.retryPushToken = ""
                self.namedStorage?.registPushCuid = Self.currentCuid
                self.namedStorage?.registPushToken = token
                self.namedStorage?.pushEndpoint = endpoint
                self.apnsToken = token
                self.endpointId = endpoint
                DataLog.d("registerToken success " + endpoint, tag:self.tag)
                DataLog.d("updated " + Self.currentCuid, tag:self.tag)
                self.updateUserAgreement(self.userAgreement)
                
            case .registEndpoint(let endpoint, let isAgree) :
                self.namedStorage?.registEndpoint = endpoint
                self.namedStorage?.registPushUserAgreement = isAgree
                DataLog.d("registEndpoint success " + isAgree.description, tag:self.tag)
                DataLog.d("updated " + Self.currentCuid, tag:self.tag)
                self.isBusy = false
            case .updatePushUserAgreement(let isAgree) :
                self.namedStorage?.registPushUserAgreement = isAgree
                self.isBusy = false
                DataLog.d("updatePushUserAgreement success " + isAgree.description, tag:self.tag)
               
            default: break
            
            }
        }).store(in: &dataCancellable)
        
        apiManager.$error.sink(receiveValue: { err in
            guard let err = err else { return }
            switch err.type {
            case .createEndpoint(let token), .registerToken(_, let token) :
                self.onRegistFail(token: token)
            case .updatePushUserAgreement :
                DataLog.e("updatePushUserAgreement fail", tag:self.tag)
                self.isBusy = false
            default: break
            }
        }).store(in: &dataCancellable)
    }
}
