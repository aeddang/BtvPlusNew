//
//  User.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/12.
//

import Foundation



class Kid{
    private(set) var nickName:String = ""
    var characterIdx:Int = 0
    private(set) var birth:String = ""
    private(set) var age:Int? = nil
    
    init(){}
    init(nickName:String?,characterIdx:Int?,birth:String?){
        self.nickName = nickName ?? ""
        self.characterIdx = characterIdx ?? 0
        self.birth = birth ?? ""
        self.setupAge()
    }
    init(nickName:String?,characterIdx:Int?,birthDate:Date?){
        self.nickName = nickName ?? ""
        self.characterIdx = characterIdx ?? 0
        self.birth = birthDate?.toDateFormatter(dateFormat: Setup.dateFormat) ?? ""
        self.setupAge()
    }
    
    private func setupAge(){
        if self.birth.count < 4 {return}
        let nowYear  = Date().toDateFormatter(dateFormat: "yyyy")
        let birthYear  = self.birth.subString(start: 0, len: 4)
        self.age = nowYear.toInt() - birthYear.toInt() + 1
    }
    
    @discardableResult
    func update(_ data:ModifyUserData) -> Kid{
        if let value = data.nickName { self.nickName = value }
        if let value = data.characterIdx { self.characterIdx = value }
        return self
    }

}
