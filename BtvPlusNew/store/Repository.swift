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
    case initate, ready, reset, error(ApiResultError?)
    
    var description: String {
        switch self {
        case .initate: return "initate"
        case .ready: return "ready"
        case .reset: return "reset"
        case .error: return "error"
        }
    }
    
    static func ==(lhs: RepositoryStatus, rhs: RepositoryStatus) -> Bool {
        switch (lhs, rhs) {
        case ( .initate, .initate):return true
        case ( .ready, .ready):return true
        case ( .reset, .reset):return true
        default: return false
        }
    }
}

enum RepositoryEvent{
    case updatedWatchLv, updatedAdultAuth, reset
}

class Repository:ObservableObject, PageProtocol{
    @Published var status:RepositoryStatus = .initate
    @Published var event:RepositoryEvent? = nil {didSet{ if event != nil { event = nil} }}
    
    let appSceneObserver:AppSceneObserver?
    let pagePresenter:PagePresenter?
    let dataProvider:DataProvider
    let pairing:Pairing
    let webBridge:WebBridge
    let alram:Alram = Alram()
    let networkObserver:NetworkObserver
    let voiceRecognition:VoiceRecognition
    let shareManager:ShareManager
    let apiCoreDataManager = ApiCoreDataManager()
    let audioMirrorManager:AudioMirroring
    let pushManager:PushManager
    let userSetup:Setup
    let storage = LocalStorage()
    var namedStorage:LocalNamedStorage? = nil
    private let accountManager:AccountManager
    private let broadcastManager:BroadcastManager
    private(set) var apiManager:ApiManager
   
    
    private var anyCancellable = Set<AnyCancellable>()
    private var dataCancellable = Set<AnyCancellable>()
    private let drmAgent = DrmAgent.initialize() as? DrmAgent
    private(set) var isFirstLaunch = false
    
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
        self.shareManager = ShareManager(pagePresenter: pagePresenter)
        self.audioMirrorManager = AudioMirroring(pairing: self.pairing)
        self.pushManager = PushManager(storage: self.storage)
        self.accountManager =  AccountManager(
            pairing: self.pairing,
            dataProvider: self.dataProvider)
        
        self.broadcastManager = BroadcastManager(
            pairing: self.pairing,
            dataProvider: self.dataProvider)
        
        self.webBridge = WebBridge(
            pagePresenter: self.pagePresenter,
            dataProvider: self.dataProvider,
            appSceneObserver:self.appSceneObserver,
            pairing: self.pairing,
            storage: self.storage,
            setup: self.userSetup,
            shareManager:self.shareManager,
            networkObserver: self.networkObserver)
        
        self.pagePresenter?.$currentPage.sink(receiveValue: { evt in
            self.apiManager.clear()
            self.appSceneObserver?.isApiLoading = false
            self.pagePresenter?.isLoading = false
            if self.apiManager.status == .ready{
                self.pushManager.retryRegisterPushToken()
            }
        }).store(in: &anyCancellable)
        
        self.isFirstLaunch = self.setupSetting()
        self.setupNamedStorage()
        self.setupDataProvider()
        self.setupApiManager()
        self.setupPairing()
        self.broadcastManager.setup()
        
    }
    
    deinit {
        self.drmAgent?.terminate()
        self.anyCancellable.forEach{$0.cancel()}
        self.anyCancellable.removeAll()
        self.dataCancellable.forEach{$0.cancel()}
        self.dataCancellable.removeAll()
    }
    
    func reset(isReleaseMode:Bool? = nil, isEvaluation:Bool = SystemEnvironment.isEvaluation){
        SystemEnvironment.isReleaseMode = isReleaseMode
        SystemEnvironment.isEvaluation = isEvaluation
        self.storage.isReleaseMode = isReleaseMode
        self.status = .reset
        
        self.dataCancellable.forEach{$0.cancel()}
        self.dataCancellable.removeAll()
        self.apiManager.clear()
        self.apiManager = ApiManager()
        self.setupNamedStorage()
        self.setupApiManager()
        //self.appSceneObserver?.event = .toast("reset " + (isReleaseMode?.description ?? ""))
    }
    private func setupSetting()->Bool{
        if self.storage.initate {
            self.storage.initate = false
            SystemEnvironment.firstLaunch = true
            self.userSetup.initateSetup()
            return true
        }
        if  SystemEnvironment.isReleaseMode == nil {
            SystemEnvironment.isReleaseMode = storage.isReleaseMode
        }
        SystemEnvironment.isAdultAuth = self.userSetup.isAdultAuth
        SystemEnvironment.watchLv = self.userSetup.watchLv
        SystemEnvironment.isFirstMemberAuth = self.userSetup.isFirstMemberAuth
        
        return false
    }
    
    private func setupNamedStorage(){
        let storage = LocalNamedStorage(name:  SystemEnvironment.isStage ? "Stage" : "Release")
        self.namedStorage = storage
        self.webBridge.namedStorage = storage
        self.pushManager.setupStorage(storage: storage)
    }
    
    private func setupPairing(){
        self.accountManager.setupPairing(savedUser:self.userSetup.getSavedUser())
        self.pairing.storage = self.userSetup
        self.pairing.$request.sink(receiveValue: { req in
            guard let requestPairing = req else { return }
            switch requestPairing{
            case .user , .device, .auth:
                self.userSetup.clearDevice()
            default : break
            }
        }).store(in: &anyCancellable)
        
        self.pairing.$event.sink(receiveValue: { evt in
            guard let evt = evt else { return }
            switch evt{
            case .connected(let stbData) :
                self.userSetup.saveDevice(stbData)
                
            case .disConnected :
                self.appSceneObserver?.event = .toast(String.alert.pairingDisconnected)
                self.userSetup.saveUser(nil)
                self.userSetup.clearDevice()
                self.resetSystemEnvironment()
                self.dataProvider.requestData(q: .init(type: .getGnb))
                self.pushManager.updateUserAgreement(false)
                //NotificationCoreData().removeAllNotice()
                
            case .pairingCompleted :
                self.userSetup.saveUser(self.pairing.user)
                self.pairing.user?.pairingDate = self.userSetup.pairingDate
                self.pairing.hostDevice?.modelName = self.userSetup.pairingModelName
                DataLog.d("UPDATEED GNBDATA getGnb", tag:self.tag)
                self.dataProvider.requestData(q: .init(type: .getGnb))
                self.appSceneObserver?.event = .toast(String.alert.pairingCompleted)
                self.pushManager.updateUserAgreement(self.pairing.user?.isAgree3 ?? false)
                
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
            }else if !apiQ.isLog{
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
        self.apiManager.initateApi()
        self.pushManager.setupApiManager(self.apiManager)
        self.accountManager.setupApiManager(self.apiManager)
        self.broadcastManager.setupApiManager(self.apiManager)
        self.apiManager.$result.sink(receiveValue: { res in
            guard let res = res else { return }
            self.respondApi(res)
            self.dataProvider.result = res
            self.appSceneObserver?.isApiLoading = false
            self.pagePresenter?.isLoading = false
        
        }).store(in: &dataCancellable)
        
        self.apiManager.$error.sink(receiveValue: { err in
            guard let err = err else { return }
           
            if self.status != .ready && !err.isOptional && !err.isLog{ self.status = .error(err) }
            self.dataProvider.error = err
            if !err.isOptional && !err.isLog {
                self.appSceneObserver?.alert = .apiError(err)
            }
            self.appSceneObserver?.isApiLoading = false
            self.pagePresenter?.isLoading = false
            
        }).store(in: &dataCancellable)
        
        self.apiManager.$event.sink(receiveValue: { evt in
            guard let evt = evt else { return }
            switch  evt {
            case .pairingUpdated(let data) :
                self.appSceneObserver?.alert = .pairingUpdated(data)
                
            default : break
            }
            
        }).store(in: &dataCancellable)
        
        self.pagePresenter?.isLoading = true
        self.apiManager.$status.sink(receiveValue: { status in
            self.pagePresenter?.isLoading = false
            //self.appSceneObserver?.event = .toast("status " + status.rawValue)
            if status == .ready { self.onReadyApiManager() }
        }).store(in: &dataCancellable)
    }
    
    
    
    private func requestApi(_ apiQ:ApiQ, coreDatakey:String){
        DispatchQueue.global(qos: .background).async(){
            var coreData:Codable? = nil
            switch apiQ.type {
                case .getGnb:
                    if let savedData:GnbBlock = self.apiCoreDataManager.getData(key: coreDatakey){
                        coreData = savedData
                        DispatchQueue.main.async {
                            DataLog.d("respond coreData getGnb", tag:self.tag)
                            DataLog.d("UPDATEED GNBDATA coreData", tag:self.tag)
                            self.onReadyRepository(gnbData: savedData)
                        }
                    }
                default: break
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
    private func respondApi(_ res:ApiResultResponds, coreDatakey:String){
        DispatchQueue.global(qos: .background).async(){
            switch res.type {
                case .getGnb :
                    guard let data = res.data as? GnbBlock  else { return }
                    DataLog.d("save coreData getGnb", tag:self.tag)
                    
                    self.apiCoreDataManager.setData(key: coreDatakey, data: data)
                    DispatchQueue.main.async {
                        DataLog.d("UPDATEED GNBDATA apiData", tag:self.tag)
                        self.onReadyRepository(gnbData: data)
                    }
                default: break
            }
        }
    }
    private func respondApi(_ res:ApiResultResponds){
        if let coreDatakey = res.type.coreDataKey(){
            self.respondApi(res, coreDatakey: coreDatakey)
        }
        
        switch res.type {
        case .getGnb :
            guard let data = res.data as? GnbBlock  else { return }
            if data.gnbs == nil || data.gnbs!.isEmpty {
               // self.appSceneObserver?.event = .debug("respondApi data.gnbs error")
                self.status = .error(nil)
                return
            }
           // self.appSceneObserver?.event = .toast("respondApi getGnb")
            self.onReadyRepository(gnbData: data)
        case .updateAgreement(let isAgree, _) :
            guard let data = res.data as? NpsResult else { return }
            guard let resultCode = data.header?.result else { return }
            if resultCode == NpsNetwork.resultCode.success.code {
                self.updatePush(isAgree)
            }
        default: break
        }
    }
    
    private func onReadyApiManager(){
        SystemEnvironment.serverConfig.filter{ config in
            config.value.hasPrefix("http")
        }.forEach{ config in
            guard let server = ApiServer.getType(config.key) else { return }
            if let savedPath = self.storage.getServerConfig(configKey: config.key){
                if savedPath == config.value { return }
                DataLog.d("reset Server " + server.rawValue , tag:self.tag)
                self.storage.setServerConfig(configKey: config.key, path: config.value)
                self.apiCoreDataManager.clearData(server: server)
            } else {
                DataLog.d("init Server " + server.rawValue , tag:self.tag)
                self.storage.setServerConfig(configKey: config.key, path: config.value)
            }
        }
        if self.isFirstLaunch {
            self.apiManager.load(.postUnPairing, isOptional: true)
        }
        //self.appSceneObserver?.event = .toast("onReadyApiManager")
        self.dataProvider.requestData(q: .init(type: .getGnb))
    }
    
    private func onReadyRepository(gnbData:GnbBlock){
        self.dataProvider.bands.setData(gnbData)
        //self.appSceneObserver?.event = .toast("onReadyRepository " + (SystemEnvironment.isStage ? "STAGE" : "RELEASE"))
        DataLog.d("onReadyRepository " + self.status.description , tag:self.tag)
        DataLog.d("UPDATEED GNBDATA onReadyRepository", tag:self.tag)
        if self.status == .reset {
            self.event = .reset
            self.status = .ready
            
        }else if self.status != .ready {
            self.status = .ready
        }
    }
    
    func retryRepository()
    {
        //self.appSceneObserver?.event = .debug("retryRepository")
        self.status = .reset
        self.apiManager.retryApi()
    }
    
    func updateUser(_ data:ModifyUserData) {
        self.userSetup.updateUser(data)
        self.pairing.updateUser(data)
    }
    
    private func updatePush(_ isAgree:Bool) {
        self.pairing.updateUserAgreement(isAgree)
        self.pushManager.updateUserAgreement(isAgree)
    }
    
    func updateAdultAuth(able:Bool){
        self.userSetup.isAdultAuth = able
        SystemEnvironment.isAdultAuth = able
        if able {
            self.updateFirstMemberAuth()
        }
        if SystemEnvironment.watchLv == 0 {
            SystemEnvironment.isImageLock = false
            self.event = .updatedWatchLv
        } else {
            self.event = .updatedAdultAuth
        }
        
    }
    func updateWatchLv(_ lv:Setup.WatchLv?){
        SystemEnvironment.watchLv = lv?.rawValue ?? 0
        self.userSetup.watchLv = SystemEnvironment.watchLv
        self.appSceneObserver?.alert = .alert(
            lv == nil ? String.alert.watchLvCanceled : String.alert.watchLvCompleted,
            lv == nil ? String.alert.watchLvCanceledInfo :  String.alert.watchLvCompletedInfo)
        self.event = .updatedWatchLv
    }
    
    func updateFirstMemberAuth(){
        self.userSetup.isFirstMemberAuth = true
        SystemEnvironment.isFirstMemberAuth = true
    }
    
    func resetSystemEnvironment(){
        SystemEnvironment.watchLv = 0
        SystemEnvironment.isAdultAuth = false
        SystemEnvironment.isImageLock = false
        if #available(iOS 14.0, *) { SystemEnvironment.isLegacy = false }
        else { SystemEnvironment.isLegacy = true }
        
        
        self.userSetup.watchLv = 0
        self.userSetup.isAdultAuth = false
        
        self.event = .updatedWatchLv
    }
    
    func getDrmId() -> String? {
        return drmAgent?.getDeviceInfo()
    }
    
   
}
