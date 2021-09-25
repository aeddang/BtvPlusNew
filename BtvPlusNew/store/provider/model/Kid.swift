//
//  User.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/12.
//

import Foundation

class Kid:ObservableObject, PageProtocol, Identifiable{
    static let LIMITED_AGE = 13
    static let defaultCharacterIdx = 2
    
    private(set) var id:String = "0"
    
    @Published private(set) var nickName:String = ""
    @Published var characterIdx:Int = 0
    @Published private(set) var age:Int? = nil
    @Published private(set) var ageMonth:Int? = nil
    
    private(set) var birth:String = ""
    private(set) var gender:String = ""
   
    var modifyUserData:ModifyUserData? = nil
    var locVal:Int = -1
    var updateType:KesNetwork.UpdateType? = nil
    
    init(){}
    init(nickName:String?,characterIdx:Int?,birth:String?){
        self.nickName = nickName ?? ""
        self.birth = birth ?? ""
        self.setupGender(idx: characterIdx ?? Self.defaultCharacterIdx)
        self.setupAge()
    }
    init(nickName:String?,characterIdx:Int?,birthDate:Date?){
        self.nickName = nickName ?? ""
        self.setupGender(idx: characterIdx ?? Self.defaultCharacterIdx)
        self.birth = birthDate?.toDateFormatter(dateFormat: Setup.dateFormat) ?? ""
        self.setupAge()
    }
    init(data:KidsProfileItem){
        self.setData(data)
    }
    
    @discardableResult
    func setData(_ data:KidsProfileItem)-> Kid{
        self.modifyUserData = nil
        self.id = data.profile_id ?? UUID().uuidString
        self.nickName = data.profile_nm ?? ""
        self.birth = data.birth_ym ?? ""
        self.setupCharacterIdx(id:data.chrter_img_id)
        self.locVal = data.prof_loc_val?.number?.toInt() ?? -1
        self.setupAge()
        return self
    }
    
    @discardableResult
    func update(_ data:ModifyUserData) -> Kid{
        self.modifyUserData = data
        return self
    }
    
    private func setupAge(){
        if self.birth.count < 4 {return}
        let now = Date()
        let nowYear  = now.toDateFormatter(dateFormat: "yyyy")
        let nowMonth  = now.toDateFormatter(dateFormat: "MM")
        let birthYear  = self.birth.subString(start: 0, len: 4)
        let birthMonth  = self.birth.count >= 6 ? self.birth.subString(start: 4, len: 2) : "01"
        let age = nowYear.toInt() - birthYear.toInt() + 1
        self.age = age
        
        let nowM = nowYear.toInt() * 12 + nowMonth.toInt()
        let birthM = birthYear.toInt() * 12 + birthMonth.toInt()
        let ageMonth = nowM - birthM
        self.ageMonth = ageMonth
        
    }
    
    private func setupCharacterIdx(id:String?){
        let idx = getCharacterIdxById(id)
        self.setupGender(idx: idx)
    }
    private func setupGender(idx:Int){
        if idx < 3 {
            self.gender = String.app.mailDetail
        } else {
            self.gender = String.app.femailDetail
        }
        self.characterIdx = idx
    }
    
    
    
    private func getCharacterIdxById(_ id:String?) -> Int {
        switch id {
        case "1": return 3
        case "2": return 4
        case "3": return 5
        case "4": return 0
        case "5": return 1
        case "6": return 2
        default:return 3
        }
    }
    func getNickname() -> String {
        let nick = self.modifyUserData?.nickName ?? self.nickName
        return nick
    }
    func getBirth() -> String {
        let birth = self.modifyUserData?.birth ?? self.birth
        return birth.subString(start:0,len:6)
    }
    func getCharacterId() -> String {
        let idx = self.modifyUserData?.characterIdx ?? self.characterIdx
        switch idx {
        case 3: return "1"
        case 4: return "2"
        case 5: return "3"
        case 0: return "4"
        case 1: return "5"
        case 2: return "6"
        default:return "4"
        }
    }
    
    func getGenderKey() -> String? {
        let idx = self.modifyUserData?.characterIdx ?? self.characterIdx
        if idx < 3 {
            return Gender.mail.apiValue()
        } else {
            return Gender.femail.apiValue()
        }
    }

}
