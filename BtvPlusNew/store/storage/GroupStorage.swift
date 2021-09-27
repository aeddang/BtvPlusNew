//
//  SettingStorage.swift
//  today
//
//  Created by JeongCheol Kim on 2020/05/12.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//

import Foundation

class GroupStorage {
    struct Keys {
        static let VS = "1.000"
        static let isPush = "isPush" + VS
    }
    let defaults = UserDefaults(suiteName: "group.com.skb.btvplus")
    
    var isPush:Bool{
        set(newVal){
            self.defaults?.set(newVal, forKey: Keys.isPush)
        }
        get{
            return self.defaults?.bool(forKey: Keys.isPush) ?? false 
        }
    }
    
}
