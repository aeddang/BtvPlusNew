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
    let pageSceneObserver:PageSceneObserver?
    let pagePresenter:PagePresenter?
    let dataProvider:DataProvider
    let pairing:Pairing
    private let setting = SettingStorage()
    private let apiCoreDataManager = ApiCoreDataManager()
    private let pairingManager:PairingManager
    private let apiManager:ApiManager
    private let userSetup:Setup
    private var anyCancellable = Set<AnyCancellable>()
    private let drmAgent = DrmAgent.initialize() as? DrmAgent
    
    init(
        dataProvider:DataProvider? = nil,
        pairing:Pairing? = nil,
        pagePresenter:PagePresenter? = nil,
        sceneObserver:PageSceneObserver? = nil,
        setup:Setup? = nil
    ) {
        self.dataProvider = dataProvider ?? DataProvider()
        self.pairing = pairing ?? Pairing()
        self.apiManager = ApiManager()
        self.pageSceneObserver = sceneObserver
        self.pagePresenter = pagePresenter
        self.userSetup = setup ?? Setup()
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
    
    deinit {
        self.drmAgent?.terminate()
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
                //self.pageSceneObserver?.event = .toast("connected")
                self.setting.saveDevice(stbData)
                
            case .disConnected :
                self.pageSceneObserver?.event = .toast(String.alert.pairingDisconnected)
                self.setting.saveUser(nil)
                self.setting.clearDevice()
                self.dataProvider.requestData(q: .init(type: .getGnb))
                
            case .pairingCompleted :
                self.setting.saveUser(self.pairing.user)
                self.pairing.user?.pairingDate = self.setting.pairingDate
                self.pairing.hostDevice?.modelName = self.setting.pairingModelName
                self.pageSceneObserver?.event = .toast(String.alert.pairingCompleted)
                self.dataProvider.requestData(q: .init(type: .getGnb))
         
            
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
            if self.status != .ready { self.status = .error(err) }
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
            self.userSetup.initateSetup()
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
            if data.gnbs == nil || data.gnbs!.isEmpty {
                //self.pageSceneObserver?.event = .toast("respondApi data.gnbs error")
                self.status = .error(nil)
                return
            }
            //self.pageSceneObserver?.event = .toast("respondApi getGnb")
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
        //self.pageSceneObserver?.event = .toast("onReadyApiManager")
        self.dataProvider.requestData(q: .init(type: .getGnb))
    }
    
    private func onReadyRepository(gnbData:GnbBlock){
        self.dataProvider.bands.setDate(gnbData)
        //self.pageSceneObserver?.event = .toast("onReadyRepository")
        if self.status != .ready {self.status = .ready}
    }
    
    func retryRepository()
    {
        //self.pageSceneObserver?.event = .toast("retryRepository")
        self.status = .initate
        self.apiManager.retryApi()
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
    
    func getDrmId() -> String? {
        return drmAgent?.getDeviceInfo()
    }
    
    func getSTBInfo(isWifi:Bool)->[String: Any] {
        var info = [String: Any]()
        let maskingPhoneNumber:String = (pairing.phoneNumer.count == 10)
            ? pairing.phoneNumer.replace(start: 3, len: 2, with:  "****")
            : pairing.phoneNumer.replace(start: 3, len: 3, with:  "****")
        info["phoneNumer"] = maskingPhoneNumber
        info["networkState"] = isWifi ? 1 : 0
        info["pairingState"] = pairing.status == .pairing ? 0 : 1
        info["pairingType"] = 0
        info["stbId"] = pairing.stbId
        info["hashId"] = ApiUtil.getHashId(pairing.stbId)
        info["stbName"] = nil
        info["macAddress"] = pairing.hostDevice?.convertMacAdress ?? "null"
        //var adultMenuLimit = false
        var RCUAgentVersion:String? = nil
        if let hostDevice = pairing.hostDevice {
            //adultMenuLimit = hostDevice.adultAafetyMode
            RCUAgentVersion = hostDevice.agentVersion
           
        }
        info["isAdultAuth"] = setting.isAdultAuth       // 성인인증 ON/OFF
        info["isPurchaseAuth"] = setting.isPurchaseAuth    // 구매인증 ON/OFF
        info["isMemberAuth"] = setting.isFirstAdultAuth   // 최초 본인 인증 여부
        info["restrictedAge"] = setting.isAdultAuth ? (setting.restrictedAge ?? 0) : 0
        info["RCUAgentVersion"] = AppUtil.getSafeString(RCUAgentVersion, defaultValue: "0.0.0")
        info["userAgent"] = ScsNetwork.getUserAgentParameter()
        info["isShowRemoconSelectPopup"] = setting.isShowRemoconSelectPopup
        info["isShowAutoRemocon"] = setting.isShowAutoRemocon
        
        info["marketingInfo"] = setting.pushAble ? 1 : 0
        info["pushInfo"] = setting.pushAble ? 1 : 0
        
        let userInfo = pairing.userInfo?.user
        info["regionCode"] = AppUtil.getSafeString(userInfo?.region_code, defaultValue: "MBC=1^KBS=41^SBS=61^HD=0")
        info["svc"] = AppUtil.getSafeString(userInfo?.svc, defaultValue: "0")
        info["ukey_prod_id"] = AppUtil.getSafeString(userInfo?.ukey_prod_id, defaultValue: "null")
        info["combine_product_use"] = AppUtil.getSafeString(userInfo?.combine_product_use, defaultValue: "N")
        info["combine_product_list"] = AppUtil.getSafeString(userInfo?.combine_product_list, defaultValue: "null")
        info["isSupportSimplePairing"] = AppUtil.getSafeInt(bool: pairing.hostDevice?.isSupportSimplePairing())
        
        info["evaluation"] = AppUtil.getSafeInt(bool: SystemEnvironment.isEvaluation)
        info["clientId"] = SystemEnvironment.deviceId
        info["expiredSTB"] = AppUtil.getSafeInt(bool: false)
      
        return info
    }
    
}
