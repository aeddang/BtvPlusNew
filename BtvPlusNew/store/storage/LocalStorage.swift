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
        static let serverConfig = "serverConfig" + VS
        static let isReleaseMode = "isReleaseMode" + VS
        static let isPush = "isPush" + VS
        
        static let oksusu = "oksusu"
        static let oksusuPurchase = "oksusuPurchase"
        
    }
    let defaults = UserDefaults.standard
    
    func setServerConfig(configKey:String, path:String){
        defaults.set(path, forKey: Keys.serverConfig + configKey)
    }
    func getServerConfig(configKey:String)->String?{
        return defaults.string(forKey: Keys.serverConfig + configKey)
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
    
    var isPush:Bool{
        set(newVal){
            defaults.set(newVal, forKey: Keys.isPush)
        }
        get{
            return defaults.bool(forKey: Keys.isPush)
        }
    }
    
    var oksusu:String{
        set(newVal){
            defaults.set(newVal, forKey: Keys.oksusu)
        }
        get{
            return defaults.string(forKey: Keys.oksusu) ?? ""
        }
    }
    
    var oksusuPurchase:String{
        set(newVal){
            defaults.set(newVal, forKey: Keys.oksusuPurchase)
        }
        get{
            return defaults.string(forKey: Keys.oksusuPurchase) ?? ""
        }
    }
    
}
