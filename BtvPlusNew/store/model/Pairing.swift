//
//  Pairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation

enum PairingRequest{
    case wifi , btv, user, cancel
}

enum PairingStatus{
    case disConnect , connect
}

enum PairingEvent{
    case connected, disConnected, error
}
enum Gender {
    case mail, femail
}

class Pairing:ObservableObject, PageProtocol {
    @Published private(set) var request:PairingRequest? = nil
    @Published var event:PairingEvent? = nil
    @Published var status:PairingStatus = .disConnect
    @Published var user:User? = nil
    
    private(set) var stbId:String = "{F76A4668-46EA-11EA-91F5-9D29A492214E}"
    func requestPairing(_ request:PairingRequest){
        self.request = request
    }
    
    func foundDevice(_ mdnsData:[MdnsDevice]){
        
    }
    func notFoundDevice(){
        
    }
}

class User {
    private(set) var nickName:String = ""
    var characterIdx:Int = 0
    private(set) var gender:Gender = .mail
    private(set) var birth:String = ""
    private(set) var isAgree1:Bool = true
    private(set) var isAgree2:Bool = true
    var isAgree3:Bool = true
    
    
    init(nickName:String,characterIdx:Int,gender:Gender,birth:String,isAgree1:Bool,isAgree2:Bool,isAgree3:Bool){
        self.nickName = nickName
        self.characterIdx = characterIdx
        self.gender = gender
        self.birth = birth
        self.isAgree1 = isAgree1
        self.isAgree2 = isAgree2
        self.isAgree3 = isAgree3
    }
}
