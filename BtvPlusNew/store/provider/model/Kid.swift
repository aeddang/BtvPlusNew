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
   
    
    init(){}
    init(nickName:String?,characterIdx:Int?,birth:String?){
        self.nickName = nickName ?? ""
        self.characterIdx = characterIdx ?? 0
        self.birth = birth ?? ""
    }
    
    @discardableResult
    func update(_ data:ModifyUserData) -> Kid{
        if let value = data.nickName { self.nickName = value }
        if let value = data.characterIdx { self.characterIdx = value }
        return self
    }

}
