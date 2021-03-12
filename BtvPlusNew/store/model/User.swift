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
}

class User {
    private(set) var nickName:String = ""
    var characterIdx:Int = 0
    var pairingDate:String? = nil
    private(set) var gender:Gender = .mail
    private(set) var birth:String = ""
    private(set) var isAgree1:Bool = true
    private(set) var isAgree2:Bool = true
    private(set) var isAgree3:Bool = true
    private(set) var postAgreement:Bool = false
    
    init(){}
    init(nickName:String?,characterIdx:Int?,gender:String?,birth:String?){
        self.nickName = nickName ?? ""
        self.characterIdx = characterIdx ?? 0
        self.gender = gender == "M" ? .mail : .femail
        self.birth = birth ?? ""
    }
    
    init(nickName:String,characterIdx:Int,gender:Gender,birth:String,
         isAgree1:Bool = false,isAgree2:Bool = false,isAgree3:Bool = false){
        
        self.nickName = nickName
        self.characterIdx = characterIdx
        self.gender = gender
        self.birth = birth
        self.isAgree1 = isAgree1
        self.isAgree2 = isAgree2
        self.isAgree3 = isAgree3
        self.postAgreement = true
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
