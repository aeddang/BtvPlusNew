//
//  Setup.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/02/08.
//

import Foundation
class Setup:ObservableObject, PageProtocol {
    
    struct Keys {
        static let VS = "1.001"
        static let dataAlram = "isAlarmMobieNetworkV4"
        static let autoRemocon = "isShowRemoconSelectPopup"
        static let remoconVibration = "isHapticFeedbackV4"
        static let autoPlay = "isAutoPlayV4"
        static let nextPlay = "isSeriesAutoPlayV4"
        static let selectedQuality = "selectedQuality" + VS
        static let isPurchaseAuth = "isPurchaseAuth"
        static let isAdultAuth = "isAdultAuth"
        static let watchLv = "restrictedAge"
        static let isKidsExitAuth = "isKidsExitAuth"
        static let isFirstMemberAuth = "isFirstAdultAuth"
        static let possession = "terminatedStbId"
        
        static let oksusu = "oksusu"
        static let oksusuPurchase = "oksusuPurchase"
        
        static let floatingUnvisibleDate = "floatingUnvisibleDate" + VS
        static let kidsRegistUnvisibleDate = "kidsRegistUnvisibleDate" + VS
        static let alramUnvisibleDate = "alramUnvisibleDate" + VS
        
        static let nickName = "profileNickname"
        static let birth = "profileBirthYear"
        static let character = "profileCharacter"
        static let gender = "profileGender"
        static let selectedKidsProfileId = "kidsSelectedProfileId"
        static let pairingDate = "pairingDate"
        static let pairingModelName = "stbModelName"
        static let restrictedAge = "restrictedAge"
        static let isFirstCashCharge = "isFirstCashCharge" + VS
        
        static let drmTestUser = "drmTestUser" + VS
        static let listApi = "listApi" + VS
        static let videoPath = "videoPath" + VS
        
        
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
    
    static let dateFormat = "yyyyMMdd"
    static func getDateKey() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Self.dateFormat
        let todayString: String = dateFormatter.string(from: Date())
        return todayString
    }
    
    let storage = UserDefaults.standard
    
    func initateSetup(){
        self.autoPlay = true
        self.nextPlay = true
        self.dataAlram = true
        self.autoRemocon = true
        self.remoconVibration = SystemEnvironment.isTablet ? false : true
        self.isPurchaseAuth = false
        self.watchLv = 0
        self.isFirstMemberAuth = false
        self.isFirstCashCharge = true
    }
    
    func getSavedUser()-> User?{
        let nicName = self.nickName
        let birth = self.birth
        let character = self.character
        let gender = self.gender
        
        if nicName != nil && birth != nil && character != nil && gender != nil {
            let savedUser = User(nickName: nicName, character: character, gender: gender, birth: birth)
            savedUser.pairingDate = self.pairingDate
            return savedUser
        }
        return nil
    }
    
    func saveUser(_ user:User? = nil){
        self.nickName = user?.nickName
        self.birth = user?.birth
        self.character = User.getCharacter(idx: user?.characterIdx ?? 0) 
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
        if let value = data.characterIdx { self.character = Asset.characterList[value] }
    }
    
    func saveDevice(_ stbData:StbData? = nil){
        guard let stbData = stbData else { return }
        self.pairingModelName = stbData.stbName
    }
    func clearDevice(){
        self.pairingModelName = nil
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
    var selectedQuality:String? {
        set(newVal){
            storage.set(newVal, forKey: Keys.selectedQuality )
        }
        get{
            return storage.string(forKey: Keys.selectedQuality)
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
    
    var kidsRegistUnvisibleDate:String{
        set(newVal){
            storage.set(newVal, forKey: Keys.kidsRegistUnvisibleDate)
        }
        get{
            return storage.string(forKey: Keys.kidsRegistUnvisibleDate) ?? ""
        }
    }
    
    func isRegistUnvisibleDate()-> Bool {
        let prevDateKey = self.kidsRegistUnvisibleDate
        if !prevDateKey.isEmpty,
           let prevDate = prevDateKey.toDate(dateFormat: Setup.dateFormat)
        {
            let diffTime = abs(prevDate.timeIntervalSinceNow)
            let diffDay = diffTime / (24 * 60 * 60 * 1000)
            if diffDay < 7 {
                return true
            }
        }
        return false
    }
    
    var alramUnvisibleDate:String{
        set(newVal){
            storage.set(newVal, forKey: Keys.alramUnvisibleDate)
        }
        get{
            return storage.string(forKey: Keys.alramUnvisibleDate) ?? ""
        }
    }
    
    func isAlramUnvisibleDate()-> Bool {
        let prevDateKey = self.alramUnvisibleDate
        if !prevDateKey.isEmpty {
            let now = Setup.getDateKey()
            if now == prevDateKey {
                return true
            }
        }
        return false
    }
    
   
    
    
    var possession:String{
        set(newVal){
            storage.set(newVal, forKey: Keys.possession)
        }
        get{
            return storage.string(forKey: Keys.possession) ?? ""
        }
    }
    
    var oksusu:String{
        set(newVal){
            storage.set(newVal, forKey: Keys.oksusu)
        }
        get{
            return storage.string(forKey: Keys.oksusu) ?? ""
        }
    }
    
    var oksusuPurchase:String{
        set(newVal){
            storage.set(newVal, forKey: Keys.oksusuPurchase)
        }
        get{
            return storage.string(forKey: Keys.oksusuPurchase) ?? ""
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
    
    var isKidsExitAuth:Bool{
        set(newVal){
            storage.set(newVal, forKey: Keys.isKidsExitAuth)
        }
        get{
            return storage.bool(forKey: Keys.isKidsExitAuth)
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
        
    var nickName:String? {
        set(newVal){
            storage.set(newVal, forKey: Keys.nickName)
        }
        get{
            return storage.string(forKey: Keys.nickName)
        }
    }
    
    var birth:String? {
        set(newVal){
            storage.set(newVal, forKey: Keys.birth)
        }
        get{
            return storage.string(forKey: Keys.birth)
        }
    }
    
    var gender:String? {
        set(newVal){
            storage.set(newVal, forKey: Keys.gender)
        }
        get{
            return storage.string(forKey: Keys.gender)
        }
    }

    var character:String? {
        set(newVal){
            storage.set(newVal, forKey: Keys.character )
        }
        get{
            return storage.string(forKey: Keys.character )
        }
    }
    
    var selectedKidsProfileId:String? {
        set(newVal){
            storage.set(newVal, forKey: Keys.selectedKidsProfileId )
        }
        get{
            return storage.string(forKey: Keys.selectedKidsProfileId)
        }
    }
    
    
    var pairingDate:String? {
        set(newVal){
            storage.set(newVal, forKey: Keys.pairingDate )
        }
        get{
            return storage.string(forKey: Keys.pairingDate)
        }
    }
    
    var pairingModelName:String? {
        set(newVal){
            storage.set(newVal, forKey: Keys.pairingModelName )
        }
        get{
            return storage.string(forKey: Keys.pairingModelName)
        }
    }
    
    var restrictedAge:Int? {
        set(newVal){
            storage.set(newVal, forKey: Keys.restrictedAge )
        }
        get{
            return storage.integer(forKey: Keys.restrictedAge )
        }
    }
    
    var isFirstCashCharge:Bool{
        set(newVal){
           storage.set(newVal, forKey: Keys.isFirstCashCharge)
        }
        get{
            return storage.bool(forKey: Keys.isFirstCashCharge)
        }
    }
    
    var listApi:String{
        set(newVal){
            storage.set(newVal, forKey: Keys.listApi)
        }
        get{
            return storage.string(forKey: Keys.listApi) ?? ""
        }
    }
    var drmTestUser:Bool{
        set(newVal){
            storage.set(newVal, forKey: Keys.drmTestUser)
        }
        get{
            return storage.bool(forKey: Keys.drmTestUser) 
        }
    }
    
    var videoPath:String{
        set(newVal){
            storage.set(newVal, forKey: Keys.videoPath)
        }
        get{
            return storage.string(forKey: Keys.videoPath) ?? ""
        }
    }
    
}
