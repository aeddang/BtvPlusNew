//
//  SettingStorage.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/12.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

class LocalNamedStorage:PageProtocol {
    struct Keys {
        static let VS = "1.0"
        static let registPushCuid = "registPushCuid" + VS
        static let retryPushToken = "retryPushToken" + VS
        static let registPushToken = "registPushToken" + VS
        static let registEndpoint = "registEndpoint" + VS
        static let registPushUserAgreement = "registPushUserAgreement" + VS
        static let pushEndpoint = "pushEndpoint" + VS
        
        static let pcId = "pcId" + VS
    }
    let defaults:UserDefaults
    init(name:String) {
        if let userDefaults = UserDefaults.init(suiteName: name) {
            defaults = userDefaults
            DataLog.d("userDefaults suiteName success", tag: self.tag)
        } else {
            defaults = UserDefaults.standard
            DataLog.e("userDefaults suiteName fail", tag: self.tag)
        }
    }
    
    var retryPushToken:String{
        set(newVal){ defaults.set(newVal, forKey: Keys.retryPushToken) }
        get{ return defaults.string(forKey: Keys.retryPushToken) ?? "" }
    }
    
    var registPushCuid:String{
        set(newVal){ defaults.set(newVal, forKey: Keys.registPushCuid) }
        get{ return defaults.string(forKey: Keys.registPushCuid) ?? "" }
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
    
    var registPushUserAgreement:Bool?{
        set(newVal){defaults.set(newVal, forKey: Keys.registPushUserAgreement)}
        get{return defaults.object(forKey: Keys.registPushUserAgreement) as? Bool }
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
