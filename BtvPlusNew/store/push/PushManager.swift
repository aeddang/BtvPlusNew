//
//  PushManager.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/25.
//

import Foundation
import Combine

class PushManager : PageProtocol {
    private(set) var endpointId:String = ""
    private(set) var apnsToken:String = ""
    private(set) var userAgreement:Bool = false
    private var apiManager:ApiManager? = nil
    private let storage:LocalStorage
    private var dataCancellable = Set<AnyCancellable>()

    init(storage:LocalStorage) {
        self.storage = storage
        self.endpointId = storage.pushEndpoint
        self.apnsToken = storage.registPushToken
    
    }
    
    func retryRegisterPushToken(){
        if !self.storage.retryPushToken.isEmpty {
            DataLog.d("retryRegisterPushToken", tag: self.tag)
            self.registerPushToken(self.storage.retryPushToken)
        }
    }
    
    func registerPushToken(_ token:String) {
        let registToken = self.storage.registPushToken
        let endpoint = self.storage.pushEndpoint
        if token == registToken && !endpoint.isEmpty {
            DataLog.d("already endpoint", tag: self.tag)
            self.updateUserAgreement(self.userAgreement)
            return
        }
        DataLog.d("create endpoint", tag: self.tag)
        self.storage.registPushToken = ""
        self.storage.retryPushToken = ""
        self.storage.pushEndpoint = ""
        self.storage.registEndpoint = ""
        self.storage.registPushUserAgreement = false
        self.apnsToken = ""
        self.endpointId = ""
        self.apiManager?.load(.createEndpoint(token))
        
    }
    
    func updateUserAgreement(_ isAgree:Bool) {
        self.userAgreement = isAgree
        DataLog.d("updateUserAgreement : " + isAgree.description, tag: self.tag)
        if self.endpointId.isEmpty { return }
        let registEndpoint = self.storage.registEndpoint
        if !registEndpoint.isEmpty {
            if self.storage.registPushUserAgreement == isAgree {
                DataLog.d("already UserAgreement", tag: self.tag)
            } else {
                DataLog.d("update UserAgreement", tag: self.tag)
                self.apiManager?.load(.updatePushUserAgreement(isAgree))
            }
        } else {
            DataLog.d("regist UserAgreement", tag: self.tag)
            self.apiManager?.load(.registEndpoint(self.endpointId, isAgree: isAgree))
        }
    }
    
    func recivePush(_ messageId:String?) {
        guard let messageId = messageId else { return }
        if self.endpointId.isEmpty { return }
        self.apiManager?.load(.recivePush(endpointId, messageId: messageId))
    }
    
    func confirmPush(_ messageId:String?) {
        guard let messageId = messageId else { return }
        if self.endpointId.isEmpty { return }
        self.apiManager?.load(.confirmPush(endpointId, messageId: messageId))
    }
    
    private func onRegistFail(token:String){
        self.storage.retryPushToken = token
        self.storage.registPushToken = ""
        self.storage.pushEndpoint = ""
        DataLog.e("registerToken error", tag:self.tag)
    }

    func setupApiManager(_ apiManager:ApiManager){
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
                apiManager.load(.registerToken(endpoint, token: token))
                
            case .registerToken(let endpoint, let token) :
                self.storage.retryPushToken = ""
                self.storage.registPushToken = token
                self.storage.pushEndpoint = endpoint
                self.apnsToken = token
                self.endpointId = endpoint
                DataLog.d("registerToken success", tag:self.tag)
                self.updateUserAgreement(self.userAgreement)
                
            case .registEndpoint(let endpoint, let isAgree) :
                self.storage.registEndpoint = endpoint
                self.storage.registPushUserAgreement = isAgree
                DataLog.d("registEndpoint success", tag:self.tag)
            case .updatePushUserAgreement(let isAgree) :
                self.storage.registPushUserAgreement = isAgree
                DataLog.d("updatePushUserAgreement success", tag:self.tag)
            default: break
            
            }
        }).store(in: &dataCancellable)
        
        apiManager.$error.sink(receiveValue: { err in
            guard let err = err else { return }
            switch err.type {
            case .createEndpoint(let token), .registerToken(_, let token) :
                self.onRegistFail(token: token)
            default: break
            }
        }).store(in: &dataCancellable)
    }
}
