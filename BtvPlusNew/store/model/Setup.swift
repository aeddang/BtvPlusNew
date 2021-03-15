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
        
        static let pushAble = "pushAble" + VS
        static let isPurchaseAuth = "isPurchaseAuth" + VS
        static let isAdultAuth = "isAdultAuth" + VS
        static let isFirstAdultAuth = "isFirstAdultAuth" + VS
        
        static let isShowRemoconSelectPopup = "isShowRemoconSelectPopup" + VS
        static let isShowAutoRemocon = "isShowAutoRemocon" + VS
        
        static let floatingUnvisibleDate = "floatingUnvisibleDate" + VS
    }
    
    let storage = UserDefaults.init()
    
    func initateSetup(){
        self.autoPlay = true
        self.nextPlay = true
        self.dataAlram = true
        self.autoRemocon = true
        self.remoconVibration = true
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
    
    var pushAble:Bool{
        set(newVal){
            storage.set(newVal, forKey: Keys.pushAble)
        }
        get{
            return storage.bool(forKey: Keys.pushAble)
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
    
    var isFirstAdultAuth:Bool{
        set(newVal){
            storage.set(newVal, forKey: Keys.isFirstAdultAuth)
        }
        get{
            return storage.bool(forKey: Keys.isFirstAdultAuth)
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
