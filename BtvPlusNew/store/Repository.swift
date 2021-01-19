//
//  Repository.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/06.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

enum RepositoryStatus{
    case initate, ready
}

class Repository:ObservableObject, PageProtocol{
    @Published var status:ApiStatus = .initate
    let pageSceneObserver:PageSceneObserver?
    let pagePresenter:PagePresenter?
    let dataProvider:DataProvider
    let pairing:Pairing
    private let setting = SettingStorage()
    private let apiCoreDataManager = ApiCoreDataManager()
    private let pairingManager:PairingManager
    private let apiManager:ApiManager
    private var anyCancellable = Set<AnyCancellable>()
    
    init(
        dataProvider:DataProvider? = nil,
        pairing:Pairing? = nil,
        pagePresenter:PagePresenter? = nil,
        sceneObserver:PageSceneObserver? = nil
    ) {
        self.dataProvider = dataProvider ?? DataProvider()
        self.pairing = pairing ?? Pairing()
        self.apiManager = ApiManager()
        self.pageSceneObserver = sceneObserver
        self.pagePresenter = pagePresenter
        self.pairingManager =  PairingManager(
            pairing: self.pairing,
            dataProvider: self.dataProvider,
            apiManager: self.apiManager)
        
        self.pagePresenter?.$currentPage.sink(receiveValue: { evt in
            self.apiManager.clear()
            self.pageSceneObserver?.isApiLoading = false
            self.pagePresenter?.isLoading = false
            self.retryRegisterPushToken()
        }).store(in: &anyCancellable)
        
        self.setupDataProvider()
        self.setupSetting()
        self.setupPairing()
    }
    
    private func setupPairing(){
        self.pairingManager.setupPairing(savedUser:self.setting.getSavedUser())
        
        self.pairing.$request.sink(receiveValue: { req in
            guard let requestPairing = req else { return }
            switch requestPairing{
            case .user , .device, .auth:
                self.setting.clearDevice()
            default : do{}
            }
        }).store(in: &anyCancellable)
        
        self.pairing.$event.sink(receiveValue: { evt in
            guard let evt = evt else { return }
            switch evt{
            case .connected(let stbData) :
                self.pageSceneObserver?.event = .toast("connected")
                self.setting.saveDevice(stbData)
                
            case .disConnected :
                self.pageSceneObserver?.event = .toast("disConnected")
                self.setting.saveUser(nil)
                self.setting.clearDevice()
                
            case .pairingCompleted :
                self.setting.saveUser(self.pairing.user)
                self.pairing.user?.pairingDate = self.setting.pairingDate
                self.pairing.hostDevice?.modelName = self.setting.pairingModelName
                self.pageSceneObserver?.event = .toast(String.alert.pairingCompleted)
            
            case .syncError :
                self.pageSceneObserver?.alert = .pairingRecovery
            default: do{}
            }
        }).store(in: &anyCancellable)
    }
    
    private func setupDataProvider(){
       self.dataProvider.$request.sink(receiveValue: { req in
            guard let apiQ = req else { return }
            if apiQ.isLock {
                self.pagePresenter?.isLoading = true
            }else{
                self.pageSceneObserver?.isApiLoading = true
            }
            if let coreDatakey = apiQ.type.coreDataKey(){
                self.requestApi(apiQ, coreDatakey:coreDatakey)
            }else{
                self.apiManager.load(q: apiQ)
            }
        }).store(in: &anyCancellable)
        
        self.apiManager.$result.sink(receiveValue: { res in
            guard let res = res else { return }
            self.respondApi(res)
            DispatchQueue.main.async {
                self.dataProvider.result = res
                self.pageSceneObserver?.isApiLoading = false
                self.pagePresenter?.isLoading = false
            }
        }).store(in: &anyCancellable)
        
        self.apiManager.$error.sink(receiveValue: { err in
            guard let err = err else { return }
            DispatchQueue.main.async {
                self.dataProvider.error = err
                if !err.isOptional {
                    self.pageSceneObserver?.alert = .apiError(err)
                }
                self.pageSceneObserver?.isApiLoading = false
                self.pagePresenter?.isLoading = false
            }
        }).store(in: &anyCancellable)
        
        self.apiManager.$status.sink(receiveValue: { status in
            if status == .ready { self.onReadyApiManager() }
        }).store(in: &anyCancellable)
        
    }
    
    private func setupSetting(){
        if !self.setting.initate {
            self.setting.initate = true
            SystemEnvironment.firstLaunch = true
        }
        if self.setting.retryPushToken != "" {
            self.registerPushToken(self.setting.retryPushToken)
        }
    }
    
    private func requestApi(_ apiQ:ApiQ, coreDatakey:String){
        DispatchQueue.global().async(){
            var coreData:Codable? = nil
            switch apiQ.type {
                case .getGnb :
                    if let savedData:GnbBlock = self.apiCoreDataManager.getData(key: coreDatakey){
                        coreData = savedData
                        DispatchQueue.main.async {
                            self.onReadyRepository(gnbData: savedData)
                        }
                    }
                default: do{}
            }
            DispatchQueue.main.async {
                if let coreData = coreData {
                    self.dataProvider.result = ApiResultResponds(id: apiQ.id, type: apiQ.type, data: coreData)
                    self.pageSceneObserver?.isApiLoading = false
                    self.pagePresenter?.isLoading = false
                }else{
                    self.apiManager.load(q: apiQ)
                }
            }
        }
    }
    
    private func respondApi(_ res:ApiResultResponds){
        switch res.type {
        case .getGnb :
            guard let data = res.data as? GnbBlock  else { return }
            self.onReadyRepository(gnbData: data)
        
        default: do{}
        }
    }
    
    private func onReadyApiManager(){
        SystemEnvironment.serverConfig.filter{ config in
            config.value.hasPrefix("http")
        }.forEach{ config in
            guard let server = ApiServer.getType(config.key) else { return }
            if let savedPath = self.setting.getServerConfig(configKey: config.key){
                if savedPath == config.value { return }
                self.setting.setServerConfig(configKey: config.key, path: config.value)
                self.apiCoreDataManager.clearData(server: server)
            }
        }
        self.dataProvider.requestData(q: .init(type: .getGnb))
    }
    
    private func onReadyRepository(gnbData:GnbBlock){
        self.dataProvider.bands.setDate(gnbData)
        if self.status == .initate {self.status = .ready}
    }
    
    func requestBandsData(){
        self.dataProvider.bands.resetData()
        self.dataProvider.requestData(q: .init(type: .getGnb))
    }
   
    // PushToken
    func retryRegisterPushToken(){
        if self.setting.retryPushToken != "" {
            self.registerPushToken(self.setting.retryPushToken)
        }
    }
    
    func registerPushToken(_ token:String) {
        self.setting.retryPushToken = token
    }
    
}
