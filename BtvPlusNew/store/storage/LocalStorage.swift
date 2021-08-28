//
//  SettingStorage.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/12.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

class LocalStorage {
    struct Keys {
        static let VS = "1.021"
        static let initate = "isFirst"
        static let retryPushToken = "retryPushToken" + VS
        static let registPushToken = "registPushToken" + VS
        static let registEndpoint = "registEndpoint" + VS
        static let registPushUserAgreement = "registPushUserAgreement" + VS
        static let pushEndpoint = "pushEndpoint" + VS
        static let serverConfig = "serverConfig" + VS
        static let isReleaseMode = "isReleaseMode" + VS
        static let pcId = "pcId" + VS
    }
    let defaults = UserDefaults.standard
    
    func setServerConfig(configKey:String, path:String){
        defaults.set(path, forKey: Keys.serverConfig + configKey)
    }
    func getServerConfig(configKey:String)->String?{
        return defaults.string(forKey: Keys.serverConfig + configKey)
    }
    
    var retryPushToken:String{
        set(newVal){ defaults.set(newVal, forKey: Keys.retryPushToken) }
        get{ return defaults.string(forKey: Keys.retryPushToken) ?? "" }
    }
    
    var registPushToken:String{
        set(newVal){  defaults.set(newVal, forKey: Keys.registPushToken)}
        get{return defaults.string(forKey: Keys.registPushToken) ?? ""}
    }
    
    var pushEndpoint:String{
        set(newVal){defaults.set(newVal, forKey: Keys.pushEndpoint)}
        get{return defaults.string(forKey: Keys.pushEndpoint) ?? ""}
    }
    
    var registEndpoint:String{
        set(newVal){  defaults.set(newVal, forKey: Keys.registEndpoint)}
        get{return defaults.string(forKey: Keys.registEndpoint) ?? ""}
    }
    
    var registPushUserAgreement:Bool{
        set(newVal){defaults.set(newVal, forKey: Keys.registPushUserAgreement)}
        get{return defaults.bool(forKey: Keys.registPushUserAgreement)}
    }
    
    var initate:Bool{
        set(newVal){
            defaults.set(newVal, forKey: Keys.initate)
        }
        get{
            let isShownWebViewIntro = defaults.bool(forKey: "isShownWebViewIntro")
            if isShownWebViewIntro {return false}
            let isShownPermissionGuide = defaults.bool(forKey: "isShownPermissionGuide")
            if isShownPermissionGuide {return false}
            return defaults.object(forKey: Keys.initate) == nil
        }
    }
    var isReleaseMode:Bool?{
        set(newVal){
            defaults.set(newVal, forKey: Keys.isReleaseMode)
        }
        get{
            guard let isRelease = defaults.object(forKey: Keys.isReleaseMode) as? Bool else {return nil}
            return isRelease
        }
    }
    
    
    var pcId:String? {
        set(newVal){
            defaults.set(newVal, forKey: Keys.pcId )
        }
        get{
            return defaults.string(forKey: Keys.pcId)
        }
    }
    
    func getPcid()->String {
        if let id = self.pcId {return id}
        let dateId = Date().toDateFormatter(dateFormat: "yyyyMMddHHmmssSSS", local: "en_US_POSIX")
        var t = time_t(0)
        srand48( time(&t))
        let randNum = drand48() * 1000000
        let id = dateId + randNum.description.toDigits(6)
        self.pcId = id
        return id
    
    }
    
    private var sessionId:String? = nil
    func getSessionId()->String {
        if let id = sessionId {return id}
        var t = time_t(0)
        srand48( time(&t));
        let randNum = drand48() * 100000
        sessionId = self.getPcid() + randNum.description.toDigits(5)
        return sessionId!
    }
}
