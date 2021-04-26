//
//  Setup.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/08.
//

import Foundation
class Setup:ObservableObject, PageProtocol {
    struct Keys {
        static let VS = "1.000"
        static let dataAlram = "dataAlram" + VS
        static let autoRemocon = "autoRemocon" + VS
        static let remoconVibration = "remoconVibration" + VS
        
        static let autoPlay = "autoPlay" + VS
        static let nextPlay = "nextPlay" + VS
        
        static let isPurchaseAuth = "isPurchaseAuth" + VS
        static let isAdultAuth = "isAdultAuth" + VS
        static let watchLv = "watchLv" + VS
        static let isFirstMemberAuth = "isFirstMemberAuth" + VS
        
        static let isShowRemoconSelectPopup = "isShowRemoconSelectPopup" + VS
        static let isShowAutoRemocon = "isShowAutoRemocon" + VS
        
        static let floatingUnvisibleDate = "floatingUnvisibleDate" + VS
    }
    
    enum WatchLv:Int, CaseIterable {
        case lv1 = 7
        case lv2 = 12
        case lv3 = 15
        case lv4 = 19
        func getName()->String{
            switch self {
            case .lv4:
                let s = self.rawValue.description + String.app.ageCount
                return s + "/" + s + "+"
            default: return self.rawValue.description + String.app.ageCount
            }
        }
        
        static func getLv(_ value:Int)->WatchLv?{
            switch value {
            case 7: return .lv1
            case 12: return .lv2
            case 15: return .lv3
            case 19: return .lv4
            default: return nil
            }
        }
    }
    
    let storage = UserDefaults.init()
    
    func initateSetup(){
        self.autoPlay = true
        self.nextPlay = true
        self.dataAlram = true
        self.autoRemocon = true
        self.remoconVibration = true
        self.isPurchaseAuth = true
        self.isFirstMemberAuth = false
    }
    
    var dataAlram:Bool {
        set(newVal){
            storage.set(newVal, forKey: Keys.dataAlram )
        }
        get{
            return storage.bool(forKey: Keys.dataAlram)
        }
    }
    
    var autoRemocon:Bool {
        set(newVal){
            storage.set(newVal, forKey: Keys.autoRemocon )
        }
        get{
            return storage.bool(forKey: Keys.autoRemocon)
        }
    }
    
    var remoconVibration:Bool {
        set(newVal){
            storage.set(newVal, forKey: Keys.remoconVibration )
        }
        get{
            return storage.bool(forKey: Keys.remoconVibration)
        }
    }
    
    
    var autoPlay:Bool {
        set(newVal){
            storage.set(newVal, forKey: Keys.autoPlay )
        }
        get{
            return storage.bool(forKey: Keys.autoPlay)
        }
    }
    
    var nextPlay:Bool {
        set(newVal){
            storage.set(newVal, forKey: Keys.nextPlay )
        }
        get{
            return storage.bool(forKey: Keys.nextPlay) 
        }
    }
    
    var floatingUnvisibleDate:String{
        set(newVal){
            storage.set(newVal, forKey: Keys.floatingUnvisibleDate)
        }
        get{
            return storage.string(forKey: Keys.floatingUnvisibleDate) ?? ""
        }
    }
    
   
    
    var isPurchaseAuth:Bool{
        set(newVal){
            storage.set(newVal, forKey: Keys.isPurchaseAuth)
        }
        get{
            return storage.bool(forKey: Keys.isPurchaseAuth)
        }
    }
    
    var isAdultAuth:Bool{
        set(newVal){
            storage.set(newVal, forKey: Keys.isAdultAuth)
        }
        get{
            return storage.bool(forKey: Keys.isAdultAuth)
        }
    }
    
    var watchLv:Int{
        set(newVal){
            storage.set(newVal, forKey: Keys.watchLv)
        }
        get{
            return storage.integer(forKey: Keys.watchLv)
        }
    }
    
    var isFirstMemberAuth:Bool{
        set(newVal){
            storage.set(newVal, forKey: Keys.isFirstMemberAuth)
        }
        get{
            return storage.bool(forKey: Keys.isFirstMemberAuth)
        }
    }
    
    var isShowRemoconSelectPopup:Bool{
        set(newVal){
            storage.set(newVal, forKey: Keys.isShowRemoconSelectPopup)
        }
        get{
            return storage.bool(forKey: Keys.isShowRemoconSelectPopup)
        }
    }
    
    var isShowAutoRemocon:Bool{
        set(newVal){
            storage.set(newVal, forKey: Keys.isShowAutoRemocon)
        }
        get{
            return storage.bool(forKey: Keys.isShowAutoRemocon)
        }
    }
    
}
