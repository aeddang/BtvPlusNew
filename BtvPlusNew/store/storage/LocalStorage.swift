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
        static let initate = "initate" + VS
        static let accountId = "accountId" + VS
        static let retryPushToken = "retryPushToken" + VS
        static let registPushToken = "registPushToken" + VS
        static let registEndpoint = "registEndpoint" + VS
        static let registPushUserAgreement = "registPushUserAgreement" + VS
        static let pushEndpoint = "pushEndpoint" + VS
        static let serverConfig = "serverConfig" + VS
        static let nickName = "nickName" + VS
        static let birth = "birth" + VS
        static let character = "character" + VS
        static let gender = "gender" + VS
        static let pairingDate = "pairingDate" + VS
        static let pairingModelName = "pairingModelName" + VS
        static let restrictedAge = "restrictedAge" + VS
        static let pcId = "pcId" + VS
        static let selectedKidsProfileId = "selectedKidsProfileId3" + VS // kidsSelectedProfileId
        
        static let isFirstCashCharge = "isFirstCashCharge" + VS
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
            self.selectedKidsProfileId = nil
            
        }else if self.pairingDate == nil {
            self.pairingDate = Date().localDate().description
        }
    }
    
    func updateUser(_ data:ModifyUserData){
        if let value = data.nickName { self.nickName = value }
        if let value = data.characterIdx { self.character = value }
    }
    
    func saveDevice(_ stbData:StbData? = nil){
        guard let stbData = stbData else { return }
        self.pairingModelName = stbData.stbName
    }
    func clearDevice(){
        self.pairingModelName = nil
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
    
    var restrictedAge:Int? {
        set(newVal){
            defaults.set(newVal, forKey: Keys.restrictedAge )
        }
        get{
            return defaults.integer(forKey: Keys.restrictedAge )
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
    
    var selectedKidsProfileId:String? {
        set(newVal){
            defaults.set(newVal, forKey: Keys.selectedKidsProfileId )
        }
        get{
            return defaults.string(forKey: Keys.selectedKidsProfileId)
        }
    }
    
    var isFirstCashCharge:Bool{
        set(newVal){
            defaults.set(newVal, forKey: Keys.isFirstCashCharge)
        }
        get{
            return defaults.bool(forKey: Keys.isFirstCashCharge)
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
