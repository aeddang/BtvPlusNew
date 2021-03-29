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

enum RepositoryStatus:Equatable{
    case initate, ready, error(ApiResultError?)
    static func ==(lhs: RepositoryStatus, rhs: RepositoryStatus) -> Bool {
        switch (lhs, rhs) {
        case ( .initate, .initate):return true
        case ( .ready, .ready):return true
        default: return false
        }
    }
}

class Repository:ObservableObject, PageProtocol{
    @Published var status:RepositoryStatus = .initate
    let appSceneObserver:AppSceneObserver?
    let pagePresenter:PagePresenter?
    let dataProvider:DataProvider
    let pairing:Pairing
    let webManager:WebManager
    let networkObserver:NetworkObserver
    let voiceRecognition:VoiceRecognition
    let apiCoreDataManager = ApiCoreDataManager()
    
    private let storage = LocalStorage()
    private let accountManager:AccountManager
    private var apiManager:ApiManager
    
    private let userSetup:Setup
    private var anyCancellable = Set<AnyCancellable>()
    private var dataCancellable = Set<AnyCancellable>()
    private let drmAgent = DrmAgent.initialize() as? DrmAgent
    
    
    init(
        dataProvider:DataProvider? = nil,
        pairing:Pairing? = nil,
        networkObserver:NetworkObserver? = nil,
        pagePresenter:PagePresenter? = nil,
        sceneObserver:AppSceneObserver? = nil,
        setup:Setup? = nil
    ) {
        self.dataProvider = dataProvider ?? DataProvider()
        self.pairing = pairing ?? Pairing()
        self.networkObserver = networkObserver ?? NetworkObserver()
        self.apiManager = ApiManager()
        self.appSceneObserver = sceneObserver
        self.pagePresenter = pagePresenter
        self.userSetup = setup ?? Setup()
        self.voiceRecognition = VoiceRecognition(appSceneObserver: sceneObserver)
        
        self.accountManager =  AccountManager(
            pairing: self.pairing,
            dataProvider: self.dataProvider)
        
        self.webManager = WebManager(
            pairing: self.pairing,
            storage: self.storage,
            setup: self.userSetup,
            networkObserver: self.networkObserver)
        
        self.pagePresenter?.$currentPage.sink(receiveValue: { evt in
            self.apiManager.clear()
            self.appSceneObserver?.isApiLoading = false
            self.pagePresenter?.isLoading = false
            self.retryRegisterPushToken()
        }).store(in: &anyCancellable)
        
        self.setupDataProvider()
        self.setupApiManager()
        self.setupSetting()
        self.setupPairing()
        
    }
    
    deinit {
        self.drmAgent?.terminate()
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
        self.dataCancellable.forEach{$0.cancel()}
        self.dataCancellable.removeAll()
    }
    
    func reset(isReleaseMode:Bool = true, isEvaluation:Bool = false){
        SystemEnvironment.isReleaseMode = isReleaseMode
        SystemEnvironment.isEvaluation = isEvaluation
        self.dataCancellable.forEach{$0.cancel()}
        self.dataCancellable.removeAll()
        self.apiManager.clear()
        self.apiManager = ApiManager()
        self.setupApiManager()
    }
    
    
    private func setupPairing(){
        self.accountManager.setupPairing(savedUser:self.storage.getSavedUser())
        self.pairing.$request.sink(receiveValue: { req in
            guard let requestPairing = req else { return }
            switch requestPairing{
            case .user , .device, .auth:
                self.storage.clearDevice()
            default : do{}
            }
        }).store(in: &anyCancellable)
        
        self.pairing.$event.sink(receiveValue: { evt in
            guard let evt = evt else { return }
            switch evt{
            case .connected(let stbData) :
                //self.appSceneObserver?.event = .toast("connected")
                self.storage.saveDevice(stbData)
                
            case .disConnected :
                self.appSceneObserver?.event = .toast(String.alert.pairingDisconnected)
                self.storage.saveUser(nil)
                self.storage.clearDevice()
                self.dataProvider.requestData(q: .init(type: .getGnb))
                
            case .pairingCompleted :
                self.storage.saveUser(self.pairing.user)
                self.pairing.user?.pairingDate = self.storage.pairingDate
                self.pairing.hostDevice?.modelName = self.storage.pairingModelName
                //self.appSceneObserver?.event = .toast(String.alert.pairingCompleted)
                self.dataProvider.requestData(q: .init(type: .getGnb))
         
            
            case .syncError :
                self.appSceneObserver?.alert = .pairingRecovery
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
                self.appSceneObserver?.isApiLoading = true
            }
            if let coreDatakey = apiQ.type.coreDataKey(){
                self.requestApi(apiQ, coreDatakey:coreDatakey)
            }else{
                self.apiManager.load(q: apiQ)
            }
        }).store(in: &anyCancellable)
    }
    
    private func setupApiManager(){
        self.accountManager.setupApiManager(self.apiManager)
        
        self.apiManager.$result.sink(receiveValue: { res in
            guard let res = res else { return }
            self.respondApi(res)
            //DispatchQueue.main.async {
                self.dataProvider.result = res
                self.appSceneObserver?.isApiLoading = false
                self.pagePresenter?.isLoading = false
            //}
        }).store(in: &dataCancellable)
        
        self.apiManager.$error.sink(receiveValue: { err in
            guard let err = err else { return }
            if self.status != .ready { self.status = .error(err) }
            //DispatchQueue.main.async {
                self.dataProvider.error = err
                if !err.isOptional {
                    self.appSceneObserver?.alert = .apiError(err)
                }
                self.appSceneObserver?.isApiLoading = false
                self.pagePresenter?.isLoading = false
            //}
        }).store(in: &dataCancellable)
        
        self.pagePresenter?.isLoading = true
        self.apiManager.$status.sink(receiveValue: { status in
            self.pagePresenter?.isLoading = false
            if status == .ready { self.onReadyApiManager() }
        }).store(in: &dataCancellable)
        
    }
    
    private func setupSetting(){
        if !self.storage.initate {
            self.storage.initate = true
            SystemEnvironment.firstLaunch = true
            self.userSetup.initateSetup()
        }
        if self.storage.retryPushToken != "" {
            self.registerPushToken(self.storage.retryPushToken)
        }
    }
    
    private func requestApi(_ apiQ:ApiQ, coreDatakey:String){
        DispatchQueue.global(qos: .background).async(){
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
                    self.appSceneObserver?.isApiLoading = false
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
            if data.gnbs == nil || data.gnbs!.isEmpty {
                self.appSceneObserver?.event = .debug("respondApi data.gnbs error")
                self.status = .error(nil)
                return
            }
            self.appSceneObserver?.event = .debug("respondApi getGnb")
            self.onReadyRepository(gnbData: data)
        
        default: do{}
        }
    }
    
    private func onReadyApiManager(){
        SystemEnvironment.serverConfig.filter{ config in
            config.value.hasPrefix("http")
        }.forEach{ config in
            guard let server = ApiServer.getType(config.key) else { return }
            if let savedPath = self.storage.getServerConfig(configKey: config.key){
                if savedPath == config.value { return }
                self.storage.setServerConfig(configKey: config.key, path: config.value)
                self.apiCoreDataManager.clearData(server: server)
            }
        }
        self.appSceneObserver?.event = .debug("onReadyApiManager")
        self.dataProvider.requestData(q: .init(type: .getGnb))
    }
    
    private func onReadyRepository(gnbData:GnbBlock){
        self.dataProvider.bands.setDate(gnbData)
        self.appSceneObserver?.event = .debug("onReadyRepository " + (SystemEnvironment.isStage ? "STAGE" : "RELEASE"))
        if self.status != .ready {self.status = .ready}
    }
    
    func retryRepository()
    {
        self.appSceneObserver?.event = .debug("retryRepository")
        self.status = .initate
        self.apiManager.retryApi()
    }
    
   
    // PushToken
    func retryRegisterPushToken(){
        if self.storage.retryPushToken != "" {
            self.registerPushToken(self.storage.retryPushToken)
        }
    }
    
    func registerPushToken(_ token:String) {
        self.storage.retryPushToken = token
    }
    
    func updateUser(_ data:ModifyUserData) {
        self.storage.updateUser(data)
        self.pairing.updateUser(data)
    }
    
    func getDrmId() -> String? {
        return drmAgent?.getDeviceInfo()
    }
    
}
