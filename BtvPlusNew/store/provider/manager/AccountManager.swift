//
//  PairingManager.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//
import Foundation
import SwiftUI
import Combine

class AccountManager : PageProtocol{
    private let mdnsPairingManager = MdnsPairingManager()
    private let pairing:Pairing
    private let dataProvider:DataProvider
    private var anyCancellable = Set<AnyCancellable>()
    private var dataCancellable = Set<AnyCancellable>()
    init(pairing:Pairing, dataProvider:DataProvider) {
        self.pairing = pairing
        self.dataProvider = dataProvider
    }
    
    var requestDevice:StbData? = nil
    var requestAuthcode:String? = nil
    var requestToken:String? = nil
    var requestKid:Kid? = nil
    
    private func resetRequest(){
        requestDevice = nil
        requestAuthcode = nil
        requestToken = nil
    }
    
    func setupPairing(savedUser:User? = nil){
        
        self.pairing.$request.sink(receiveValue: { req in
            guard let requestPairing = req else { return }
            
            self.requestDevice = nil
            self.requestAuthcode = nil
        
            switch requestPairing{
            case .cancel :
                self.mdnsPairingManager.requestPairing( requestPairing )
            case .wifi(let retryCount) :
                self.mdnsPairingManager.requestPairing( requestPairing, retryCount:retryCount,
                   found: { data in
                        self.pairing.foundDevice(mdnsData:data)
                        
                        
                   },notFound: {
                        self.pairing.notFoundDevice()
                        
                   })
            
            case .user(let cid) :
                self.dataProvider.requestData(q: .init(type: .getStbList(cid), isOptional: false))
            
            case .device(let device) :
                self.requestDevice = device
                self.dataProvider.requestData(q: .init(type: .postDevicePairing(self.pairing.user, device), isOptional: true))
            
            case .auth(let code) :
                self.requestAuthcode = code
                self.dataProvider.requestData(q: .init(type: .postAuthPairing(self.pairing.user, code), isOptional: true))
            case .token(let token) :
                self.requestToken = token
                self.dataProvider.requestData(q: .init(type: .postPairingByToken(self.pairing.user, pairingToken: token), isOptional: true))
                
            case .hostInfo(let auth, let device, let prevResult) :
                self.dataProvider.requestData(q: .init(type: .getDevicePairingInfo(auth, device, prevResult:prevResult),  isOptional: true))
                
            case .recovery :
                if let user = self.pairing.user {
                    if !self.pairing.isPairingUser { self.dataProvider.requestData(q: .init(type: .postGuestInfo(user), isOptional: true))}
                    if !self.pairing.isPairingAgreement {
                        if user.postAgreement { self.dataProvider.requestData(q: .init(type: .postGuestAgreement(user), isOptional: true)) }
                        else { self.dataProvider.requestData(q: .init(type: .getGuestAgreement, isOptional: true)) }
                    }
                    if self.pairing.hostDevice == nil { self.dataProvider.requestData(q: .init(type: .getHostDeviceInfo, isOptional: true)) }
                } else {
                    
                }
            case .unPairing :
                self.dataProvider.requestData(q: .init(type: .postUnPairing, isOptional: true))
            case .check :
                self.dataProvider.requestData(q: .init(type: .getDevicePairingStatus, isOptional: true))
            case .userInfo :
                self.dataProvider.requestData(q: .init(type: .getPairingUserInfo(self.pairing.hostDevice?.apiMacAdress), isOptional: true))
                
            case .updateKids :
                self.dataProvider.requestData(q: .init(type: .getKidsProfiles, isOptional: true))
            case .registKid(let kid) :
                self.requestKid = kid
                self.dataProvider.requestData(q: .init(type: .updateKidsProfiles([kid]), isOptional: false))
            case .modifyKid(let kid) :
                self.requestKid = kid
                self.dataProvider.requestData(q: .init(type: .updateKidsProfiles([kid]), isOptional: false))
            case .deleteKid(let kid) :
                self.requestKid = kid
                self.dataProvider.requestData(q: .init(type: .updateKidsProfiles([kid]), isOptional: false))
            case .updateKidStudy :
                if let kid = self.pairing.kid {
                    self.dataProvider.requestData(q: .init(type: .getKidStudy(kid), isOptional: false))
                }
                
            default: do{}
            }
        }).store(in: &anyCancellable)
        
        self.pairing.authority.$request.sink(receiveValue: { req in
            guard let requestPairing = req else { return }
            switch requestPairing{
            case .updateTicket :
                if self.pairing.status != .pairing {return}
                self.dataProvider.requestData(q: .init(type: .getMonthly(false),  isOptional: true))
                self.dataProvider.requestData(q: .init(type: .getMonthly(true),  isOptional: true))
            case .updateTotalPoint :
                if self.pairing.status != .pairing {return}
                self.dataProvider.requestData(q: .init(type: .getTotalPointInfo(self.pairing.hostDevice), isOptional: true))
            case .updateMonthlyPurchase(let isPeriod) :
                if self.pairing.status != .pairing {return}
                if isPeriod {
                    self.dataProvider.requestData(q: .init(type: .getPeriodPurchaseMonthly(), isOptional: true))
                } else {
                    self.dataProvider.requestData(q: .init(type: .getPurchaseMonthly(), isOptional: true))
                    
                }
            default : break
            }
        }).store(in: &anyCancellable)
        
        self.pairing.$event.sink(receiveValue: { evt in
            guard let evt = evt else { return }
            switch evt{
            case .connected :
                self.dataProvider.requestData(q: .init(type: .getHostDeviceInfo, isOptional: true))
                if let user = self.pairing.user {
                    self.dataProvider.requestData(q: .init(type: .postGuestInfo(user), isOptional: true))
                    if user.postAgreement {
                        self.dataProvider.requestData(q: .init(type: .postGuestAgreement(user), isOptional: true))
                    }
                    else {
                        self.dataProvider.requestData(q: .init(type: .getGuestAgreement, isOptional: true))
                    }
                }else{
                    if savedUser == nil {
                        self.pairing.syncError()
                    }
                    else{
                        self.pairing.user = savedUser
                        self.pairing.syncPairingUserData()
                        self.dataProvider.requestData(q: .init(type: .getGuestAgreement, isOptional: true))
                    }
                }
            case .disConnected : do{}
            case .pairingCompleted :
                self.pairing.requestPairing(.userInfo)
        
            default: break
            }
        }).store(in: &anyCancellable)
        
       
    }
    func setupApiManager(_ apiManager:ApiManager){
        self.dataCancellable.forEach{$0.cancel()}
        self.dataCancellable.removeAll()
        
        apiManager.$event.sink(receiveValue: {evt in
            switch evt {
            case .pairingHostChanged :
                if NpsNetwork.isPairing { self.pairing.connected(stbData:self.requestDevice) }
                else { self.pairing.disconnected() }
                
            default: do{}
            }
        }).store(in: &dataCancellable)
        
        apiManager.$result.sink(receiveValue: { res in
            guard let res = res else { return }
            
            switch res.type {
            case .postUnPairing :
                if !self.checkConnectHeader(res) { return }
                
            case .postAuthPairing, .postDevicePairing, .postPairingByToken :
                if !self.checkConnectHeader(res) { return }
    
            case .rePairing :
                if !self.checkConnectHeader(res) { return }
                guard let user = self.pairing.user else {
                    self.pairing.connectError()
                    return
                }
                if let code = self.requestAuthcode {
                    self.dataProvider.requestData(q: .init(type: .postAuthPairing(user, code), isOptional: true))
                }
                if let device = self.requestDevice {
                    self.dataProvider.requestData(q: .init(type: .postDevicePairing(user , device), isOptional: true))
                }
                if let token = self.requestToken {
                    self.dataProvider.requestData(q: .init(type: .postPairingByToken(user, pairingToken: token), isOptional: true))
                }
                
            case .getHostDeviceInfo :
                guard let data = res.data as? HostDeviceInfo else { return }
                if !self.checkSyncHeader(data.header) { return }
                guard let hostData = data.body?.host_deviceinfo  else {
                    self.pairing.syncError()
                    return
                }
                self.pairing.syncHostDevice(HostDevice().setData(deviceData: hostData))
           
            case .getDevicePairingInfo(_, _, let prevResult) :
                guard let data = res.data as? DevicePairingInfo else {
                    return self.pairing.connectError(header: prevResult)
                }
                guard let info = data.body?.pairing_info else {
                    return self.pairing.connectError(header: prevResult)
                }
                self.pairing.connectErrorReason(info)
                
            case .postGuestInfo :
                guard let data = res.data as? NpsResult  else { return }
                if !self.checkSyncHeader(data.header) { return }
                self.pairing.syncPairingUserData()
                
            case .postGuestAgreement :
                guard let data = res.data as? NpsResult  else { return }
                if !self.checkSyncHeader(data.header) { return }
                self.pairing.syncPairingAgreement()
                
            case .getGuestAgreement :
                guard let data = res.data as? GuestAgreementInfo  else { return }
                if !self.checkSyncHeader(data.header) { return }
                guard let agreement = data.body?.agreement  else {
                    self.pairing.syncError()
                    return
                }
                self.pairing.syncPairingAgreement(agreement)
                
            case .getStbList :
                guard let data = res.data as? StbListItem else {
                    self.pairing.notFoundDevice()
                    return
                }
                guard let datas = data.data?.stb_infos else {
                    self.pairing.notFoundDevice()
                    return
                }
                if datas.isEmpty {
                    self.pairing.notFoundDevice()
                    return
                }
                self.pairing.foundDevice(stbInfoDatas: datas)
            
            case .getDevicePairingStatus :
                self.pairing.checkCompleted(isSuccess: NpsNetwork.pairingStatus != "")
        
            case .getPairingUserInfo :
                guard let data = res.data as? PairingUserInfo  else { return }
                self.pairing.updateUserinfo(data)
                
            case .getMonthly(let lowLevelPpm , _ , _) :
                guard let resData = res.data as? MonthlyInfo else { return }
                guard let purchases = resData.purchaseList else { return }
                self.pairing.authority.updatedPurchaseTicket(purchases, lowLevelPpm: lowLevelPpm)
            case .getTotalPointInfo :
                guard let resData = res.data as? TotalPointInfo else { return }
                self.pairing.authority.updatedTotalPointInfo(resData)
            case .getPurchaseMonthly :
                guard let resData = res.data as? MonthlyPurchaseInfo else { return }
                self.pairing.authority.updatedMonthlyPurchaseInfo(resData)
            case .getPeriodPurchaseMonthly :
                guard let resData = res.data as? PeriodMonthlyPurchaseInfo else { return }
                self.pairing.authority.updatedMonthlyPurchaseInfo(resData)
            case .getKidsProfiles :
                guard let resData = res.data as? KidsProfiles else {
                    self.pairing.updatedKidsProfiles(nil)
                    return
                }
                self.pairing.updatedKidsProfiles(resData)
            case .updateKidsProfiles :
                guard let resData = res.data as? KidsProfiles else {
                    self.pairing.editedKidsProfiles(nil, editedKid: self.requestKid)
                    self.requestKid = nil
                    return
                }
                self.pairing.editedKidsProfiles(resData, editedKid: self.requestKid)
                self.requestKid = nil
            case .getKidStudy(let kid) :
                if kid.id != self.pairing.kid?.id {return}
                guard let resData = res.data as? KidStudy else { return }
                self.pairing.updatedKidStudy(resData)
            default: break
            
            }
        }).store(in: &dataCancellable)
        
        apiManager.$error.sink(receiveValue: { err in
            guard let err = err else { return }
            switch err.type {
            case .postUnPairing, .postAuthPairing, .postDevicePairing, .rePairing, .postPairingByToken : self.pairing.connectError()
            case .getDevicePairingInfo(_, _, let prevResult) : self.pairing.connectError(header: prevResult)
            case .getHostDeviceInfo, .postGuestInfo, .postGuestAgreement, .getGuestAgreement: self.pairing.syncError()
            case .getDevicePairingStatus : self.pairing.checkCompleted(isSuccess: false)
            case .getTotalPointInfo, .getPurchaseMonthly, .getPeriodPurchaseMonthly : self.pairing.authority.errorMyInfo(err)
            case .getKidsProfiles : self.pairing.updatedKidsProfiles(nil)
            case .updateKidsProfiles :
                self.pairing.editedKidsProfilesError()
                self.requestKid = nil
            default: break
            }
        }).store(in: &dataCancellable)
    }
    private func checkDisConnectHeader(_ res:ApiResultResponds ) -> Bool{
        guard let data = res.data as? NpsResult  else {
            self.pairing.disConnectError()
            return false
        }
        guard let resultCode = data.header?.result else {
            self.pairing.disConnectError()
            return false
        }
        if resultCode == NpsNetwork.resultCode.pairingRetry.code {
            self.dataProvider.requestData(q: .init(type: .rePairing , isOptional: true))
            return false
        }
        
        if resultCode != NpsNetwork.resultCode.success.code {
            self.pairing.disConnectError(header: data.header)
            return false
        }
        return true
    }
    
    private func checkConnectHeader(_ res:ApiResultResponds ) -> Bool{
        guard let data = res.data as? DevicePairing  else {
            self.pairing.connectError()
            return false
        }
        guard let resultCode = data.header?.result else {
            self.pairing.connectError()
            return false
        }
        if resultCode == NpsNetwork.resultCode.pairingRetry.code {
            self.dataProvider.requestData(q: .init(type: .rePairing , isOptional: true))
            return false
        }
        if resultCode == NpsNetwork.resultCode.existPairing.code {
            self.pairing.syncError(header: nil)
            return false
        }
        if resultCode != NpsNetwork.resultCode.success.code {
            self.pairing.connectError(header: data.header)
            self.resetRequest()
            return false
        }
        return true
    }
    
    private func checkSyncHeader(_ header:NpsCommonHeader? ) -> Bool{
        if header?.result != NpsNetwork.resultCode.success.code {
            self.pairing.syncError(header: header)
            return false
        }
        return true
    }
    
    
}
