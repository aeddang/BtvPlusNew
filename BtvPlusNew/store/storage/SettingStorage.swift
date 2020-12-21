//
//  SettingStorage.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/12.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

class SettingStorage {
    struct Keys {
        static let VS = "1.0"
        static let initate = "initate" + VS
        static let accountId = "accountId" + VS
        static let pushAble = "pushAble" + VS
        static let retryPushToken = "retryPushToken" + VS
        
        static let serverConfig = "serverConfig" + VS
    }
    let defaults = UserDefaults.standard
    
    func setServerConfig(configKey:String, path:String){
        defaults.set(path, forKey: Keys.serverConfig + configKey)
    }
    func getServerConfig(configKey:String)->String?{
        return defaults.string(forKey: Keys.serverConfig + configKey)
    }
    
    var retryPushToken:String{
        set(newVal){
            defaults.set(newVal, forKey: Keys.retryPushToken)
        }
        get{
            return defaults.string(forKey: Keys.retryPushToken) ?? ""
        }
    }
    
    var pushAble:Bool{
        set(newVal){
            defaults.set(newVal, forKey: Keys.pushAble)
        }
        get{
            return defaults.bool(forKey: Keys.pushAble)
        }
    }
    
    var initate:Bool{
        set(newVal){
            defaults.set(newVal, forKey: Keys.initate)
        }
        get{
            return defaults.bool(forKey: Keys.initate) 
        }
    }
    
}
