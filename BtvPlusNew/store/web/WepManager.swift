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
    private let setting:SettingStorage
    private let networkObserver:NetworkObserver
    init(pairing:Pairing,setting:SettingStorage, networkObserver:NetworkObserver) {
        self.pairing = pairing
        self.setting = setting
        self.networkObserver = networkObserver
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
            //adultMenuLimit = hostDevice.adultAafetyMode
            RCUAgentVersion = hostDevice.agentVersion
           
        }
        info["isAdultAuth"] = setting.isAdultAuth       // 성인인증 ON/OFF
        info["isPurchaseAuth"] = true//setting.isPurchaseAuth    // 구매인증 ON/OFF
        info["isMemberAuth"] = true//setting.isFirstAdultAuth   // 최초 본인 인증 여부
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
        info["isSupportSimplePairing"] = pairing.hostDevice?.isSupportSimplePairing() ?? false
        info["evaluation"] = SystemEnvironment.isEvaluation
        info["clientId"] = SystemEnvironment.deviceId
        info["expiredSTB"] = false
      
        return info
    }

    
}
