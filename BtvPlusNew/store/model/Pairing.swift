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
    case connected, disConnected, error, findMdnsDevice([MdnsDevice]) , notFoundDevice, pairingCompleted
}

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
    private(set) var gender:Gender = .mail
    private(set) var birth:String = ""
    private(set) var isAgree1:Bool = true
    private(set) var isAgree2:Bool = true
    var isAgree3:Bool = true
    
    init(){}
    init(nickName:String,characterIdx:Int,gender:Gender,birth:String,isAgree1:Bool,isAgree2:Bool,isAgree3:Bool){
        self.nickName = nickName
        self.characterIdx = characterIdx
        self.gender = gender
        self.birth = birth
        self.isAgree1 = isAgree1
        self.isAgree2 = isAgree2
        self.isAgree3 = isAgree3
    }
    
    func setData() -> User{
        return self
    }
}

class HostDevice {
    
    func setData(deviceData:HostDeviceData) -> HostDevice{
        return self
    }
}

class Pairing:ObservableObject, PageProtocol {
    static let LIMITED_DEVICE_NUM = 4
    
    @Published private(set) var request:PairingRequest? = nil
    @Published private(set) var event:PairingEvent? = nil {didSet{ if event != nil { event = nil} }}
    @Published private(set) var status:PairingStatus = .disConnect
    
    @Published var user:User? = nil
    private(set) var isPairingUser:Bool = false
   
    @Published private(set) var hostDevice:HostDevice? = nil
    private(set) var stbId:String? = nil
    
    func connected(){
        self.stbId = NpsNetwork.hostDeviceId 
        self.status = self.stbId != "" ? .connect : .disConnect
        self.event = self.status == .connect ? .connected : .error
    }
    
    func disconnected() {
        self.stbId = ""
        self.hostDevice = nil
        self.status = .disConnect
        self.event = .disConnected
    }
    
    func requestPairing(_ request:PairingRequest){
        self.request = request
    }
    
    func foundDevice(_ mdnsData:[MdnsDevice]){
        self.event = .findMdnsDevice(mdnsData)
    }
    func notFoundDevice(){
        self.event = .notFoundDevice
    }
    
    func syncPairingUserData(){
        self.isPairingUser = true
        if self.hostDevice != nil {
            self.event = .pairingCompleted
        }
    }
    
    func syncHostDevice(_ hostDevice:HostDevice){
        self.hostDevice = hostDevice
        if self.isPairingUser {
            self.event = .pairingCompleted
        }
    }
    
    static func getSTBImage(stbModel: String?) -> String {
        switch stbModel {
        case "BKO-AI700":
            return "imgStb01"
        case "BID-AI100":
            return "imgStb02"
        case "BIP-AI100":
            return "imgStb02"
        case "BKO-S200":
            return "imgStb03"
        case "BHX-S100":
            return "imgStb03"
        case "BDS-S200":
            return "imgStb04"
        case "BKO-UH400":
            return "imgStb05"
        case "BHX-UH400":
            return "imgStb05"
        case "BDS-S100":
            return "imgStb06"
        case "BKO-100":
            return "imgStb07"
        case "BKO-UH600":
            return "imgStb08"
        case "BHX-UH600":
            return "imgStb08"
        case "BHX-UH200":
            return "imgStb09"
        case "BKO-UA500":
            return "imgStb10"
        case "BKO-AT800":
            return "imgStb11"
        case "BAS-AT800":
            return "imgStb11"
        case "BFX-AT100":
            return "imgStb12"
        default:
            return "imgStbDefault"
        }
    }
}


