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
        static let initate = "initate"
        static let accountId = "accountId"
        static let pushAble = "pushAble"
        static let retryPushToken = "retryPushToken"
    }
    let defaults = UserDefaults.standard
    
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
