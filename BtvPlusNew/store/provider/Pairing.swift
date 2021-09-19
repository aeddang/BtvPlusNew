//
//  Pairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//

import Foundation
enum PairingRequest:Equatable{
    case wifi(retryCount:Int = 2) , btv, user(String?), cancel,
         hostInfo(auth:String?, device:String?, prevResult:NpsCommonHeader?),
         hostNickNameInfo(isAll:Bool = false),
         recovery, device(StbData), auth(String) , token(String),
         unPairing, check,
         userInfo, updateKids, registKid(Kid), selectKid(Kid), modifyKid(Kid), deleteKid(Kid),
         updateKidStudy
    static func ==(lhs: PairingRequest, rhs: PairingRequest) -> Bool {
        switch (lhs, rhs) {
        case ( .wifi, .wifi ):return true
        case ( .btv, .btv ):return true
        case ( .user, .user ):return true
        case ( .recovery, .recovery ):return true
        case ( .userInfo, .userInfo ):return true
        case ( .hostInfo, .hostInfo ):return true
        default: return false
        }
    }
}

enum PairingDeviceType{
    case btv, apple
}

enum PairingType{
    case  wifi, btv, user, token
    var logConfig: String {
        switch self {
        case .wifi: return "wifi"
        case .btv: return "btv_auth_number"
        case .user: return "subscriber_auth"
        case .token: return "token"
        }
    }
}

enum PairingStatus{
    case initate, disConnect , connect , pairing, unstablePairing, recovery
}

enum PairingEvent{
    case ready, pairingRequest,
         connected(StbData?), disConnected,
         connectError(NpsCommonHeader?), disConnectError(NpsCommonHeader?), connectErrorReason(PairingInfo?),
         findMdnsDevice([MdnsDevice]), findStbInfoDevice([StbListInfoDataItem]),  notFoundDevice,
         syncPairingUser,
         syncError(NpsCommonHeader?),
         syncFail,
         pairingCompleted, pairingCheckCompleted(Bool),
         
         updatedKids(KesNetwork.UpdateType?), notFoundKid, editedKids,
         updatedKidsError, editedKidsError(KesNetwork.UpdateType?)
}

class Pairing:ObservableObject, PageProtocol {
    static let LIMITED_DEVICE_NUM = 4
    
    @Published private(set) var request:PairingRequest? = nil
    @Published private(set) var event:PairingEvent? = nil {didSet{ if event != nil { event = nil} }}
    @Published private(set) var status:PairingStatus = .initate
    @Published var user:User? = nil
    private(set) var pairingDeviceType:PairingDeviceType = .btv
    private(set) var pairingType:PairingType? = nil
    private(set) var isPairingUser:Bool = false
    private(set) var isPairingAgreement:Bool = false
   
    @Published private(set) var hostDevice:HostDevice? = nil
    @Published private(set) var hostNickName:HostNickName? = nil
    
    private(set) var stbId:String? = nil
    private(set) var phoneNumer:String = "01000000000"
    
    @Published var userInfo:PairingUserInfo? = nil
    @Published private(set) var kid:Kid? = nil
    @Published private(set) var kidStudyData:KidStudy? = nil
    
    private(set) var kids:[Kid] = []
    private(set) var isKidsSearch:Bool = false
    private(set) var isFirstKidRegist:Bool = false
    
    let authority:Authority = Authority()
    var storage:Setup? = nil
    var naviLogManager:NaviLogManager? = nil
    
    
    
    func requestPairing(_ request:PairingRequest){
        switch request {
        case .recovery :
            self.status = .recovery
        case .selectKid(let kid) :
            self.selectKid(kid)
            
        
        case .registKid(let kid) :
            kid.updateType = .post
            kid.locVal = self.kids.count
            if self.kids.isEmpty {
                self.isFirstKidRegist = true
            }
        case .modifyKid(let kid) :
            kid.updateType = .put
        case .updateKids :
            if isKidsSearch {return}
            self.isKidsSearch = true
           
        case .deleteKid(let kid) :
            kid.updateType = .del
            kid.modifyUserData = nil
        //case .updateKidStudy :
            //if self.kid == nil { return }
            
        //case .unPairing :
    
            
        case .wifi :
            self.event = .pairingRequest
            self.pairingType = .wifi
        case .btv :
            self.event = .pairingRequest
            self.pairingType = .btv
        case .user :
            self.event = .pairingRequest
            self.pairingType = .user
        /*
        case .token :
            self.pairingType = .token
        */
        default : break
        }
        self.request = request
        
    }
    func reset(){
        self.status = .initate
    }
    func ready(){
        let status = self.status
        if status == .disConnect {
            self.event = .ready
        }
    }
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
        self.hostNickName = nil
        self.user = nil
        self.status = .disConnect
        self.event = .disConnected
        self.authority.reset()
        self.kids = []
        self.kid = nil
        self.kidStudyData = nil
        
    }
    
    
    func disConnectError(header:NpsCommonHeader? = nil) {
        self.status = .disConnect
        self.event = .disConnectError(header)
    }
    
    func connectError(header:NpsCommonHeader? = nil) {
        switch header?.result {
        case NpsNetwork.resultCode.pairingLimited.code :
            self.naviLog(pageID: .pairingLimited)
            
        default : break
           
        }
        self.status = .disConnect
        self.event = .connectError(header)
    }
    func connectErrorReason(_ reason:PairingInfo? = nil) {
        self.event = .connectErrorReason(reason)
    }
    
    func checkCompleted(isSuccess:Bool) {
        self.event = .pairingCheckCompleted(isSuccess)
    }
    
    func foundDevice(mdnsData:[MdnsDevice]){
        self.event = .findMdnsDevice(mdnsData)
    }
    func foundDevice(stbInfoDatas:[StbListInfoDataItem]){
        self.event = .findStbInfoDevice(stbInfoDatas)
    }
    func notFoundDevice(){
        self.naviLog(pageID: .pairingDeviceNotfound)
        self.event = .notFoundDevice
    }
    
    func syncError(header:NpsCommonHeader? = nil) {
        if self.status == .unstablePairing {return}
        if self.status == .recovery {
            self.status = .unstablePairing
            self.event = .syncFail
        } else {
            self.status = .unstablePairing
            self.event = .syncError(header)
        }
    }
    
    func syncPairingUserData(){
        self.isPairingUser = true
        self.event = .syncPairingUser
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
    
    func updateUser(_ data:ModifyUserData){
        let user = self.user?.clone().update(data)
        self.user = user
    }
    
    func updateUserAgreement(_ isAgree:Bool){
        self.user?.update(isAgree: isAgree)
    }
    
    
    func updateHostNicknameInfo(_ info:HostNickName){
        self.hostNickName = info
    }
    func getCurrentHostInfoData(_ host:HostNickName) -> HostNickNameItem? {
        guard let find = self.stbId else { return nil }
        guard let hosts = host.stbList else { return nil }
        guard let curHost = hosts.first(where:{$0.joined_stb_id == find}) else { return nil }
        return curHost
    }
    
    func updatedKidsProfiles(_ data:KidsProfiles? = nil, updateType:KesNetwork.UpdateType? = nil){
        self.isKidsSearch = false
        if let data = data {
            self.kids = data.profiles?.map{ Kid(data: $0) } ?? []
            if let kidId = self.storage?.selectedKidsProfileId {
                self.kid = self.kids.first(where: {$0.id == kidId})
                if self.kid == nil {
                    self.storage?.selectedKidsProfileId = nil
                    self.event = .notFoundKid
                    return
                }
            }
            if self.isFirstKidRegist {
                self.isFirstKidRegist = false
                if !self.kids.isEmpty {
                    self.selectKid(self.kids.first!)
                }
            }
            self.event = .updatedKids(updateType)
        } else {
            self.isFirstKidRegist = false
            self.event = .updatedKidsError
        }
        SystemEnvironment.isInitKidsPage = true
    }
    
    private func selectKid(_ kid:Kid){
        self.kid = kid
        self.kidStudyData = nil
        self.storage?.selectedKidsProfileId = kid.id
    }
    
    func editedKidsProfiles(_ data:KidsProfiles? , editedKid:Kid?){
        guard let editedKid = editedKid else {return}
        if let data = data {
            let updateKids = data.profiles ?? []
            let originCount = self.kids.count
            let updateCount = updateKids.count
            var isSuccess = false
            var isUpdated = false
            switch editedKid.updateType {
            case .post:
                let f = updateKids.first(where: {$0.profile_nm == editedKid.nickName})
                isSuccess = f != nil
                isUpdated = isSuccess ? true : (originCount != updateCount)
            case .del:
                let f = updateKids.first(where: {$0.profile_id == editedKid.id})
                isSuccess = f == nil
                isUpdated = isSuccess ? true : (originCount != updateCount)
            case .put:
                let f = updateKids.first(where: {$0.profile_id == editedKid.id})
                if let updateData = f {
                    isSuccess = true
                    editedKid.setData(updateData)
                }
                isUpdated = originCount != updateCount
            default: return
            }
            if isSuccess {
                if isUpdated { self.updatedKidsProfiles(data, updateType: editedKid.updateType) }
                else { self.event = .editedKids }
            } else {
                self.event = .editedKidsError(editedKid.updateType)
            }
            
        } else {
            self.event = .editedKidsError(editedKid.updateType)
        }
    }
    func editedKidsProfilesError(){
        self.event = .editedKidsError(nil)
    }
    
    func updatedKidStudy(_ data:KidStudy){
        self.kidStudyData = data
    }
    private func checkComple(){
        if self.isPairingUser && self.isPairingAgreement && self.hostDevice != nil{
            self.naviLog(pageID: .pairingCompleted)
            self.status = .pairing
            self.event = .pairingCompleted
            self.pairingDeviceType = self.user?.pairingDeviceType ?? .btv
        }
    }
    
    private func naviLog(pageID:NaviLog.PageId){
        if let pairingType = self.pairingType {
            self.naviLogManager?.pairingLog(pageId: pageID, config: pairingType.logConfig)
        }
    }
    
    func getRegionCode()->String {
        var code = "MBC=1^KBS=41^SBS=61^HD=0"
        guard let user = userInfo?.user else {return code}
        guard let host = hostDevice else {return code}
        guard let region = user.region_code else {return code}
        
        code = region
        if !code.contains("^HD=0") { code = code + "^HD=0" }
        let versions = host.agentVersion?.split(separator: ".")
        let major = String( versions?.first ?? "0")
        if major.toInt() >= 3 { code = code + "^UHD=100" }
        return code
    
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


