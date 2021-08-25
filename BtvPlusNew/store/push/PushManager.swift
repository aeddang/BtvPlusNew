//
//  PushManager.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/08/25.
//

import Foundation
import Combine

class PushManager : PageProtocol {
    private(set) var endpointId:String? = nil
    private(set) var apnsToken:String? = nil
    
    private var apiManager:ApiManager? = nil
    private let storage:LocalStorage
    private var dataCancellable = Set<AnyCancellable>()


    init(storage:LocalStorage) {
        self.storage = storage
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
            return
        }
        DataLog.d("create endpoint", tag: self.tag)
        self.storage.registPushToken = ""
        self.storage.retryPushToken = ""
        self.storage.pushEndpoint = ""
        self.apnsToken = ""
        self.endpointId = ""
        self.apiManager?.load(.createEndpoint(token))
        
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
