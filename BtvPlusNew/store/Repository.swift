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
import VideoSubscriberAccount
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
    let audioMirroring:AudioMirroring?
    let webBridge:WebBridge
    let alram:Alram = Alram()
    let vsManager:VSManager?
    let networkObserver:NetworkObserver
    let voiceRecognition:VoiceRecognition
    let shareManager:ShareManager
    let apiCoreDataManager = ApiCoreDataManager()
  
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
    
    private let zeroconf = ZeroConf()
    
    weak var naviLogManager:NaviLogManager? = nil
    init(
        vsManager:VSManager? = nil,
        dataProvider:DataProvider? = nil,
        pairing:Pairing? = nil,
        audioMirroring:AudioMirroring? = nil,
        networkObserver:NetworkObserver? = nil,
        pagePresenter:PagePresenter? = nil,
        appSceneObserver:AppSceneObserver? = nil,
        setup:Setup? = nil
      
    ) {
        self.vsManager = vsManager
        self.dataProvider = dataProvider ?? DataProvider()
        self.pairing = pairing ?? Pairing()
        self.audioMirroring = audioMirroring
        self.networkObserver = networkObserver ?? NetworkObserver()
        self.apiManager = ApiManager()
        self.appSceneObserver = appSceneObserver
        self.pagePresenter = pagePresenter
        self.userSetup = setup ?? Setup()
        self.voiceRecognition = VoiceRecognition(appSceneObserver: appSceneObserver)
        self.shareManager = ShareManager(pagePresenter: pagePresenter)
       
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
        self.pairing.reset()
        self.dataCancellable.forEach{$0.cancel()}
        self.dataCancellable.removeAll()
        self.apiManager.clear()
        self.apiManager = ApiManager()
        self.setupNamedStorage()
        self.setupApiManager()
        self.status = .reset
        
        //self.appSceneObserver?.event = .toast("reset " + (isReleaseMode?.description ?? ""))
    }
    private func setupSetting()->Bool{
        if self.storage.initate {
            self.storage.initate = false
            SystemEnvironment.firstLaunch = true
            self.userSetup.initateSetup()
            return true
        }
        //self.userSetup.possession = "{FA795887-5C31-11E9-B4BF-A911074387AC}"
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
        if SystemEnvironment.tvUserId == nil && self.vsManager?.currentAccountId == nil{
            let tvUserId = storage.tvUserId
            DataLog.d("tvUserId " + (tvUserId ?? ""), tag:"VSManager")
            SystemEnvironment.tvUserId = storage.tvUserId
        }
        SystemEnvironment.oksusuDeviceId = self.namedStorage?.oksusu ?? ""
        let currentPush = self.namedStorage?.registPushUserAgreement
        self.storage.isPush = currentPush ?? true
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
                self.pushManager.retryRegisterPushToken()
                self.namedStorage?.tvUserId = nil
                self.audioMirroring?.close()
                SystemEnvironment.agToken = ""
                //NotificationCoreData().removeAllNotice()
                DataLog.d("disConnected", tag:"VSManager")
               
                
            case .pairingCompleted :
                self.userSetup.saveUser(self.pairing.user)
                self.pairing.user?.pairingDate = self.userSetup.pairingDate
                self.pairing.hostDevice?.modelName = self.userSetup.pairingModelName
                self.dataProvider.requestData(q: .init(type: .getGnb))
                self.apiManager.load(.getAGToken, isOptional: true)
                self.pushManager.retryRegisterPushToken()
                self.pushManager.updateUserAgreement(self.pairing.user?.isAgree3 ?? false)
                self.userSetup.isPurchaseAuth = true
                let prevName = self.namedStorage?.tvUserId
                let pairingDeviceType:PairingDeviceType = SystemEnvironment.currentPairingDeviceType
                if pairingDeviceType == .apple {
                    self.pairing.authority.requestAuth(.updateMyinfo(isReset: false))
                }

                DataLog.d("pairingCompleted " + pairingDeviceType.rawValue, tag:"VSManager")
                DataLog.d("prevName " + (prevName ??  "nil"), tag:"VSManager")
                if pairingDeviceType == .apple && prevName?.isEmpty != false{
                    DispatchQueue.main.async {
                        self.pagePresenter?.openPopup(
                            PageProvider.getPageObject(.pairingAppleTv)
                        )
                    }
                } else if !NpsNetwork.isAutoPairing {
                    self.appSceneObserver?.event = .toast(  self.pairing.user?.isAutoPairing == true
                        ? String.alert.pairingCompletedAuto
                        : String.alert.pairingCompleted
                    )
                }
                if let currentAccountId = self.vsManager?.currentAccountId {
                    DataLog.d("setup currentAccountId " + currentAccountId, tag:"VSManager")
                    self.namedStorage?.tvUserId = currentAccountId
                }
                
            case .syncError :
                if NpsNetwork.hostDeviceId?.isEmpty == false {
                    self.appSceneObserver?.alert = .pairingRecovery
                }
            case .syncFail :
                self.appSceneObserver?.alert = .alert(String.alert.connect, String.alert.pairingError)
            default: break
            }
        }).store(in: &anyCancellable)
    }
    
    private func setupDataProvider(){
       self.dataProvider.$request.sink(receiveValue: { req in
            guard let apiQ = req else { return }
            if apiQ.isLock {
                self.pagePresenter?.isLoading = true
            } else if !apiQ.isOptional && !apiQ.isLog {
                self.appSceneObserver?.isApiLoading = true
            }
            if let coreDatakey = apiQ.type.coreDataKey(){
                self.requestApi(apiQ, coreDatakey:coreDatakey)
            } else{
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
            if !res.isOptional && !res.isLog {
                self.appSceneObserver?.isApiLoading = false
                self.pagePresenter?.isLoading = false
            }
        }).store(in: &dataCancellable)
        
        self.apiManager.$error.sink(receiveValue: { err in
            guard let err = err else { return }
           
            if self.status != .ready && !err.isOptional && !err.isLog{
                self.status = .error(err)
                
            }
            self.dataProvider.error = err
            if !err.isOptional && !err.isLog {
                self.appSceneObserver?.alert = .apiError(err)
                self.appSceneObserver?.isApiLoading = false
                self.pagePresenter?.isLoading = false
            }
            
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
                    self.dataProvider.result = ApiResultResponds(
                        id: apiQ.id,
                        type: apiQ.type,
                        data: coreData,
                        isOptional: apiQ.isOptional,
                        isLog: apiQ.isLog
                        )
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
        case .getAGToken :
            guard let data = res.data as? AGToken  else { return }
            SystemEnvironment.agToken = data.token ?? ""
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
        case .registEndpoint(_, let isAgree) :
            self.updatePush(isAgree, isSync: true)
        case .updatePushUserAgreement(let isAgree) :
            self.updatePush(isAgree, isSync: true)
            
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
                //self.apiCoreDataManager.clearData(server: server)
            } else {
                DataLog.d("init Server " + server.rawValue , tag:self.tag)
                self.storage.setServerConfig(configKey: config.key, path: config.value)
            }
        }
        if self.isFirstLaunch {
            self.apiManager.load(.postUnPairing, isLog:true)
        }
        //self.appSceneObserver?.event = .toast("onReadyApiManager")
        self.dataProvider.requestData(q: .init(type: .getGnb))
        /*
        if self.status == .reset {
            self.event = .reset
            self.status = .ready
        }*/
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
        self.status = .reset
        self.reset()
    }
    
    func updateUser(_ data:ModifyUserData) {
        self.userSetup.updateUser(data)
        self.pairing.updateUser(data)
    }
    
    func updatePush(_ isAgree:Bool, isSync:Bool = false) {
        self.pairing.updateUserAgreement(isAgree)
        self.storage.isPush = isAgree
        GroupStorage().isPush = isAgree
        if !isSync {
            self.pushManager.updateUserAgreement(isAgree)
            DataLog.d("updatePushUserAgreement sync " + isAgree.description, tag:"PushManager")
        } else {
            DataLog.d("updatePushUserAgreement sync completed " + isAgree.description, tag:"PushManager")
        }
    }
    
    func recivePush(_ messageId:String?, data:AlramData?) {
        guard let messageId = messageId else { return }
        self.pushManager.recivePush(messageId)
        self.naviLogManager?.actionLog(.pageShow, pageId:.appPush , actionBody: data?.actionLog)
    }
    
    func confirmPush(_ messageId:String?, data:AlramData?) {
        guard let messageId = messageId else { return }
        self.pushManager.confirmPush(messageId)
        self.naviLogManager?.actionLog(.clickAppPushMessage, pageId:.appPush , actionBody: data?.actionLog)
    }
    
    func updateWatchLv(_ lv:Setup.WatchLv?){
        SystemEnvironment.watchLv = lv?.rawValue ?? 0
        self.userSetup.watchLv = SystemEnvironment.watchLv
        self.appSceneObserver?.alert = .alert(
            lv == nil ? String.alert.watchLvCanceled : String.alert.watchLvCompleted,
            lv == nil ? String.alert.watchLvCanceledInfo :  String.alert.watchLvCompletedInfo)
        self.event = .updatedWatchLv
    }
    
    func resetAuth(){
        SystemEnvironment.isWatchAuth = false
        self.updateAdultAuth(able: false)
        self.updateFirstMemberAuth(able: false)
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
    
    func updateFirstMemberAuth(able:Bool = true){
        self.userSetup.isFirstMemberAuth = able
        SystemEnvironment.isFirstMemberAuth = able
    }
    
    func resetSystemEnvironment(){
        SystemEnvironment.watchLv = 0
        SystemEnvironment.isImageLock = false
        self.userSetup.watchLv = 0
        self.event = .updatedWatchLv
    }
    
    func getDrmId() -> String? {
        return drmAgent?.getDeviceInfo()
    }
    
    func zeroConfUDPSend() {
//        if self.pairing.status == .pairing {
        zeroconf.sendZeroConf(networkObserver: self.networkObserver)
//        }
    }
}
