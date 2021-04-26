//
//  ApiManager.swift
//  shoppingTrip
//
//  Created by JeongCheol Kim on 2020/07/31.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation
import Combine

class WebManager :PageProtocol{
    private let pairing:Pairing
    private let storage:LocalStorage
    private let setup:Setup
    private let networkObserver:NetworkObserver
    private var sessionId:String? = nil
    init(pairing:Pairing,storage:LocalStorage, setup:Setup, networkObserver:NetworkObserver) {
        self.pairing = pairing
        self.storage = storage
        self.setup = setup
        self.networkObserver = networkObserver
    }
    func getNetworkState()->[String: Any] {
        var networkState:String = ""
        switch (self.networkObserver.status) {
        case .wifi: networkState = "WIFI"
        case .cellular: networkState = "MOBILE"
        default: networkState = "UNCONNECTED"
        }
        var info = [String: Any]()
        info["networkState"] = networkState
        return info
    }

    func getSTBInfo()->[String: Any] {
        var info = [String: Any]()
        let maskingPhoneNumber:String = (pairing.phoneNumer.count == 10)
            ? pairing.phoneNumer.replace(start: 3, len: 2, with:  "****")
            : pairing.phoneNumer.replace(start: 3, len: 3, with:  "****")
        info["phoneNumer"] = maskingPhoneNumber
        info["networkState"] = self.networkObserver.status == .wifi ? 1 : 0
        info["pairingState"] = pairing.status == .pairing ? 0 : 1
        info["pairingType"] = 0
        info["stbId"] = pairing.stbId
        info["hashId"] = ApiUtil.getHashId(pairing.stbId)
        info["stbName"] = nil
        info["macAddress"] = pairing.hostDevice?.convertMacAdress ?? "null"
        //var adultMenuLimit = false
        var RCUAgentVersion:String? = nil
        if let hostDevice = pairing.hostDevice {
           // adultMenuLimit = hostDevice.adultAafetyMode
            RCUAgentVersion = hostDevice.agentVersion
           
        }
        info["isAdultAuth"] = setup.isAdultAuth       // 성인인증 ON/OFF
        info["isPurchaseAuth"] = setup.isPurchaseAuth   // 구매인증 ON/OFF
        info["isMemberAuth"] = true//setting.isFirstAdultAuth   // 최초 본인 인증 여부
        info["restrictedAge"] = setup.isAdultAuth ? (storage.restrictedAge ?? 0) : 0
        info["RCUAgentVersion"] = AppUtil.getSafeString(RCUAgentVersion, defaultValue: "0.0.0")
        info["userAgent"] = ScsNetwork.getUserAgentParameter()
        info["isShowRemoconSelectPopup"] = setup.isShowRemoconSelectPopup
        info["isShowAutoRemocon"] = setup.isShowAutoRemocon
        
        info["marketingInfo"] = pairing.user?.isAgree3 == true ? 1 : 0
        info["pushInfo"] = pairing.user?.isAgree1 == true ? 1 : 0
        
        let userInfo = pairing.userInfo?.user
        info["regionCode"] = self.getRegionCode()
        info["svc"] = AppUtil.getSafeString(userInfo?.svc, defaultValue: "0")
        info["ukey_prod_id"] = AppUtil.getSafeString(userInfo?.ukey_prod_id, defaultValue: "null")
        info["combine_product_use"] = AppUtil.getSafeString(userInfo?.combine_product_use, defaultValue: "N")
        info["combine_product_list"] = AppUtil.getSafeString(userInfo?.combine_product_list, defaultValue: "null")
        info["isSupportSimplePairing"] = pairing.hostDevice?.isSupportSimplePairing() ?? false
        info["evaluation"] = SystemEnvironment.isEvaluation 
        info["clientId"] = SystemEnvironment.deviceId
        info["expiredSTB"] = false
      
        return info
    }

    func getPassAge()-> String {
        return SystemEnvironment.watchLv.description
    }

    
    func getLogInfo()->[String: Any] {
        var info = [String: Any]()
        info["log_type"] = SystemEnvironment.isStage ? "dev" : "live"
        info["stb_onead_id"] = nil
        info["pcid"] = self.getPcid()
        info["session_id"] = self.getSessionId()
        info["stbId"] = pairing.stbId
        info["stb_mac"] = pairing.hostDevice?.convertMacAdress ?? ""
        info["app_release_version"] = SystemEnvironment.bundleVersion
        info["app_build_version"] = SystemEnvironment.buildNumber
        info["os_name"] = "iOS"
        info["os_version"] = SystemEnvironment.systemVersion
        info["device_model"] = AppUtil.model
        
        info["manufacturer"] = "Apple"
        info["gaid"] = nil
        info["idfa"] = AppUtil.idfa
        info["client_ip"] = AppUtil.getIPAddress() ?? "0.0.0.0"
        
        info["pi_url"] = ApiPath.getRestApiPath(.NAVILOG)
        info["npi_url"] = ApiPath.getRestApiPath(.NAVILOG_NPI)
        return info
    }
    
    private func getRegionCode()->String {
        var code = "MBC=1^KBS=41^SBS=61^HD=0"
        guard let user = pairing.userInfo?.user else {return code}
        guard let host = pairing.hostDevice else {return code}
        guard let region = user.region_code else {return code}
        
        code = region
        if !code.contains("^HD=0") { code = code + "^HD=0" }
        let versions = host.agentVersion?.split(separator: ".")
        let major = String( versions?.first ?? "0")
        if major.toInt() >= 3 { code = code + "^UHD=100" }
        return code
    
    }
    
    private func getPcid()->String {
        if let id = storage.pcId {return id}
        let dateId = Date().toTimestamp(dateFormat: "yyyyMMddHHmmssSSS", local: "en_US_POSIX")
        var t = time_t(0)
        srand48( time(&t))
        let randNum = drand48() * 1000000
        let id = dateId + randNum.description.toDigits(6)
        storage.pcId = id
        return id
    
    }
    private func getSessionId()->String {
        if let id = sessionId {return id}
        var t = time_t(0)
        srand48( time(&t));
        let randNum = drand48() * 100000
        sessionId = getPcid() + randNum.description.toDigits(5)
        return sessionId!
    }
}
