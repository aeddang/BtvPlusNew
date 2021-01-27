//
//  Pairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation


enum PairingRequest:Equatable{
    case wifi , btv, user(String?), cancel,
         recovery, device(StbData), auth(String) , unPairing, check
    static func ==(lhs: PairingRequest, rhs: PairingRequest) -> Bool {
        switch (lhs, rhs) {
        case ( .wifi, .wifi):return true
        case ( .btv, .btv):return true
        case ( .user, .user):return true
        case ( .recovery, .recovery):return true
        default: return false
        }
    }
}

enum PairingStatus{
    case disConnect , connect , pairing, unstablePairing
}

enum PairingEvent{
    case connected(StbData?), disConnected, connectError(NpsCommonHeader?), disConnectError(NpsCommonHeader?),
         findMdnsDevice([MdnsDevice]), findStbInfoDevice([StbInfoDataItem]),  notFoundDevice,
         syncError(NpsCommonHeader?),
         pairingCompleted, pairingCheckCompleted(Bool)
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

class HostDevice {
    private(set) var macAdress:String? = nil
    private(set) var convertMacAdress:String = ApiConst.defaultMacAdress
    private(set) var agentVersion:String? = nil
    var modelName:String? = nil
   
    func setData(deviceData:HostDeviceData) -> HostDevice{
        self.macAdress = deviceData.stb_mac_address
        if let ma = self.macAdress {
            self.convertMacAdress = ApiUtil.getDecyptedData(
                forNps: ma,
                npsKey: NpsNetwork.AES_KEY, npsIv: NpsNetwork.AES_IV)
        }
        self.agentVersion = deviceData.stb_src_agent_version
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
    private(set) var isPairingAgreement:Bool = false
   
    @Published private(set) var hostDevice:HostDevice? = nil
    private(set) var stbId:String? = nil
    
    func connected(stbData:StbData?){
        self.stbId = NpsNetwork.hostDeviceId 
        self.status = self.stbId != "" ? .connect : .disConnect
        self.event = self.status == .connect ? .connected(stbData) : .connectError(nil)
    }
    
    func disconnected() {
        self.stbId = ""
        self.isPairingAgreement = false
        self.isPairingUser = false
        self.hostDevice = nil
        self.status = .disConnect
        self.event = .disConnected
    }
    
    func disConnectError(header:NpsCommonHeader? = nil) {
        self.status = .disConnect
        self.event = .disConnectError(header)
    }
    
    func connectError(header:NpsCommonHeader? = nil) {
        self.status = .disConnect
        self.event = .connectError(header)
    }
    
    func checkCompleted(isSuccess:Bool) {
        self.event = .pairingCheckCompleted(isSuccess)
    }
    
    func requestPairing(_ request:PairingRequest){
        if request == .recovery {
            self.status = .connect
        }
        self.request = request
        
    }
    
    func foundDevice(mdnsData:[MdnsDevice]){
        self.event = .findMdnsDevice(mdnsData)
    }
    func foundDevice(stbInfoDatas:[StbInfoDataItem]){
        self.event = .findStbInfoDevice(stbInfoDatas)
    }
    func notFoundDevice(){
        self.event = .notFoundDevice
    }
    
    func syncError(header:NpsCommonHeader? = nil) {
        if self.status == .unstablePairing {return}
        self.status = .unstablePairing
        self.event = .syncError(header)
    }
    
    func syncPairingUserData(){
        self.isPairingUser = true
        self.checkComple()
    }

    func syncPairingAgreement(_ guestAgreement:GuestAgreement){
        self.user?.setData(guestAgreement: guestAgreement)
        self.syncPairingAgreement()
    }
    func syncPairingAgreement(){
        self.isPairingAgreement = true
        self.checkComple()
    }
    
    func syncHostDevice(_ hostDevice:HostDevice){
        self.hostDevice = hostDevice
        self.checkComple()
    }
    
    private func checkComple(){
        if self.isPairingUser && self.isPairingAgreement && self.hostDevice != nil{
            self.status = .pairing
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


