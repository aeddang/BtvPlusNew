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
        static let VS = "1.021"
        static let initate = "initate" + VS
        static let accountId = "accountId" + VS
        static let pushAble = "pushAble" + VS
        static let retryPushToken = "retryPushToken" + VS
        
        static let serverConfig = "serverConfig" + VS
        
        static let nickName = "nickName" + VS
        static let birth = "birth" + VS
        static let character = "character" + VS
        static let gender = "gender" + VS
        static let pairingDate = "pairingDate" + VS
        static let pairingModelName = "pairingModelName" + VS
    }
    let defaults = UserDefaults.standard
    
    func setServerConfig(configKey:String, path:String){
        defaults.set(path, forKey: Keys.serverConfig + configKey)
    }
    func getServerConfig(configKey:String)->String?{
        return defaults.string(forKey: Keys.serverConfig + configKey)
    }
    
    func getSavedUser()-> User?{
        let nicName = self.nickName
        let birth = self.birth
        let character = self.character
        let gender = self.gender
        
        if nicName != nil && birth != nil && character != nil && gender != nil {
            let savedUser = User(nickName: nicName, characterIdx: character, gender: gender, birth: birth)
            savedUser.pairingDate = self.pairingDate
            return savedUser
        }
        return nil
    }
    
    func saveUser(_ user:User? = nil){
        self.nickName = user?.nickName
        self.birth = user?.birth
        self.character = user?.characterIdx
        self.gender = user?.gender.apiValue()
        if user == nil {
            self.pairingDate = nil
        }else if self.pairingDate == nil {
            self.pairingDate = Date().localDate().description
        }
    }
    
    func saveDevice(_ stbData:StbData? = nil){
        guard let stbData = stbData else { return }
        self.pairingModelName = stbData.stbName
    }
    func clearDevice(){
        self.pairingModelName = nil
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
    
    var nickName:String? {
        set(newVal){
            defaults.set(newVal, forKey: Keys.nickName)
        }
        get{
            return defaults.string(forKey: Keys.nickName)
        }
    }
    
    var birth:String? {
        set(newVal){
            defaults.set(newVal, forKey: Keys.birth)
        }
        get{
            return defaults.string(forKey: Keys.birth)
        }
    }
    
    var gender:String? {
        set(newVal){
            defaults.set(newVal, forKey: Keys.gender)
        }
        get{
            return defaults.string(forKey: Keys.gender)
        }
    }
    
    var character:Int? {
        set(newVal){
            defaults.set(newVal, forKey: Keys.character )
        }
        get{
            return defaults.integer(forKey: Keys.character )
        }
    }
    
    var pairingDate:String? {
        set(newVal){
            defaults.set(newVal, forKey: Keys.pairingDate )
        }
        get{
            return defaults.string(forKey: Keys.pairingDate)
        }
    }
    
    var pairingModelName:String? {
        set(newVal){
            defaults.set(newVal, forKey: Keys.pairingModelName )
        }
        get{
            return defaults.string(forKey: Keys.pairingModelName)
        }
    }
    
}
