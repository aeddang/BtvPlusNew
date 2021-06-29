//
//  User.swift
//  BtvPlusNew
//
//  Created by JeongCheol Kim on 2021/03/12.
//

import Foundation

class Kid:ObservableObject, PageProtocol, Identifiable{
    private(set) var id:String = ""
    @Published private(set) var nickName:String = ""
    @Published var characterIdx:Int = 0
    @Published private(set) var age:Int? = nil
    
    private(set) var birth:String = ""
    private(set) var gender:String = ""
    var updateType:KesNetwork.UpdateType? = nil
    
    init(){}
    init(nickName:String?,characterIdx:Int?,birth:String?){
        self.nickName = nickName ?? ""
        self.birth = birth ?? ""
        self.setupGender(idx: characterIdx ?? 0)
        self.setupAge()
    }
    init(nickName:String?,characterIdx:Int?,birthDate:Date?){
        self.nickName = nickName ?? ""
        self.setupGender(idx: characterIdx ?? 0)
        self.birth = birthDate?.toDateFormatter(dateFormat: Setup.dateFormat) ?? ""
        self.setupAge()
    }
    init(data:KidsProfileItem){
        self.id = data.profile_id ?? UUID().uuidString
        self.nickName = data.profile_nm ?? ""
        self.birth = data.birth_ym ?? ""
        self.setupCharacterIdx(id:data.chrter_img_id)
        self.setupAge()
    }
    
    private func setupAge(){
        if self.birth.count < 4 {return}
        let nowYear  = Date().toDateFormatter(dateFormat: "yyyy")
        let birthYear  = self.birth.subString(start: 0, len: 4)
        self.age = nowYear.toInt() - birthYear.toInt() + 1
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
    
    @discardableResult
    func update(_ data:ModifyUserData) -> Kid{
        if let value = data.nickName { self.nickName = value }
        if let value = data.characterIdx { self.characterIdx = value }
        if let value = data.birth { self.birth = value }
        return self
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
    
    func getCharacterId() -> String {
        switch self.characterIdx {
        case 3: return "1"
        case 4: return "2"
        case 5: return "3"
        case 0: return "4"
        case 1: return "5"
        case 2: return "6"
        default:return "4"
        }
    }
    

}
