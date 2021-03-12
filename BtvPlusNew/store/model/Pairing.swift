//
//  Pairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation


enum PairingRequest:Equatable{
    case wifi , btv, user(String?), cancel,
         recovery, device(StbData), auth(String) , unPairing, check, userInfo
    static func ==(lhs: PairingRequest, rhs: PairingRequest) -> Bool {
        switch (lhs, rhs) {
        case ( .wifi, .wifi):return true
        case ( .btv, .btv):return true
        case ( .user, .user):return true
        case ( .recovery, .recovery):return true
        case ( .userInfo, .userInfo):return true
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
    private(set) var phoneNumer:String = "01000000000"
    
    @Published var userInfo:PairingUserInfo? = nil
    let authority:Authority = Authority()
   
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
        self.authority.reset()
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
    
    func updateUserinfo(_ data:PairingUserInfo){
        self.userInfo = data
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


