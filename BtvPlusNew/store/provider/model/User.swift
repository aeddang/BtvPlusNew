//
//  User.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/12.
//

import Foundation

enum Gender {
    case mail, femail
    func apiValue() -> String? {
        switch self {
            case .mail : return "M"
            case .femail : return "F"
        }
    }
    func logValue() -> String? {
        switch self {
            case .mail : return "male"
            case .femail : return "female"
        }
    }
}

struct ModifyUserData {
    var nickName:String? = nil
    var birth:String? = nil
    var characterIdx:Int? = nil
}

class User {
    static let defaultNickName:String = "0000"
    private(set) var nickName:String = ""
    var characterIdx:Int = 0
    
    static func getCharacter(idx:Int) -> String {
        let max = Asset.characterList.count
        if idx >= max { return Asset.characterList[0] }
        if idx < 0 { return Asset.characterList[0] }
        return Asset.characterList[idx]
    }
    
    var pairingDate:String? = nil
    var pairingDeviceType:PairingDeviceType = .btv
    private(set) var gender:Gender = .mail
    private(set) var birth:String = ""
    private(set) var isAgree1:Bool = true
    private(set) var isAgree2:Bool = true
    private(set) var isAgree3:Bool = true
    private(set) var postAgreement:Bool = false
    
    private(set) var isAutoPairing:Bool = false
    
    init(){}
    init(nickName:String?,character:String?,gender:String?,birth:String?){
        self.isAutoPairing = false
        self.nickName = nickName ?? ""
        if let character = character {
            let key = character.replace(".png", with: "").replace(".jpg", with: "").replace(".jpeg", with: "")
            self.characterIdx = Asset.characterList.firstIndex(of: key) ?? 0
        }else {
            self.characterIdx = 0
        }
        self.gender = gender == "M" ? .mail : .femail
        self.birth = birth ?? ""
    }
    
    init(nickName:String,pairingDate:String?,characterIdx:Int,gender:Gender,birth:String,
         isAgree1:Bool = false,isAgree2:Bool = false,isAgree3:Bool = false){
        self.isAutoPairing = false
        self.nickName = nickName
        self.pairingDate = pairingDate
        self.characterIdx = characterIdx
        self.gender = gender
        self.birth = birth
        self.isAgree1 = isAgree1
        self.isAgree2 = isAgree2
        self.isAgree3 = isAgree3
        self.postAgreement = true
    }
    
    
    
    init(isAgree:Bool){
        self.isAgree3 = isAgree
    }
    func setTvProvider(isAgree:Bool, savedUser:User?) -> User{
        self.isAutoPairing = true
        self.nickName = savedUser?.nickName ?? "Apple Tv provider"
        self.characterIdx = savedUser?.characterIdx ?? 0
        self.gender = savedUser?.gender ?? .femail
        self.birth = savedUser?.birth ?? "2021"
        self.isAgree1 = true
        self.isAgree2 = true
        self.isAgree3 = isAgree
        self.postAgreement = true
        self.pairingDeviceType = .apple
        return self
    }
    func setDefault(isAgree:Bool) -> User{
        self.isAutoPairing = true
        self.nickName = User.defaultNickName
        self.characterIdx = 0
        self.gender = .mail
        self.birth = "1990"
        self.isAgree1 = true
        self.isAgree2 = true
        self.isAgree3 = isAgree
        self.postAgreement = true
        return self
    }
    
    func clone() -> User{
        return User(nickName: self.nickName, pairingDate:self.pairingDate,
                    characterIdx: self.characterIdx,
                    gender: self.gender, birth: self.birth,
                    isAgree1: self.isAgree1, isAgree2: self.isAgree2, isAgree3: self.isAgree3)
    }
    
    func update(_ data:ModifyUserData) -> User{
        if let value = data.nickName { self.nickName = value }
        if let value = data.characterIdx { self.characterIdx = value }
        return self
    }
    
    func update(isAgree:Bool){
        self.isAgree3 = isAgree
    }
    
    @discardableResult
    func setData(guestAgreement:GuestAgreement) -> User{
        self.isAgree1 = guestAgreement.market == "1" ? true : false
        self.isAgree2 = guestAgreement.personal == "1" ? true : false
        self.isAgree3 = guestAgreement.push == "1" ? true : false
        self.postAgreement = false
        return self
    }
}
