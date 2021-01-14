//
//  PairingManager.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/23.
//
import Foundation
import SwiftUI
import Combine

class PairingManager : PageProtocol{
    private let mdnsPairingManager = MdnsPairingManager()
    private let pairing:Pairing
    private let dataProvider:DataProvider
    private let apiManager:ApiManager
    private var anyCancellable = Set<AnyCancellable>()
    
    init(pairing:Pairing, dataProvider:DataProvider, apiManager:ApiManager) {
        self.pairing = pairing
        self.dataProvider = dataProvider
        self.apiManager = apiManager
    }
    
    var requestDevice:MdnsDevice? = nil
    var requestAuthcode:String? = nil
    func setupPairing(savedUser:User? = nil){
        
        self.pairing.$request.sink(receiveValue: { req in
            guard let requestPairing = req else { return }
            self.requestDevice = nil
            self.requestAuthcode = nil
        
            switch requestPairing{
            case .wifi :
                self.mdnsPairingManager.requestPairing( requestPairing,
                   found: { data in
                        self.pairing.foundDevice(data)
                   },notFound: {
                        self.pairing.notFoundDevice()
                   })
            
            case .device(let device) :
                self.requestDevice = device
                self.dataProvider.requestData(q: .init(type: .postDevicePairing(self.pairing.user, device), isOptional: true))
                
            case .auth(let code) :
                self.requestAuthcode = code
                self.dataProvider.requestData(q: .init(type: .postAuthPairing(self.pairing.user, code), isOptional: true))
                
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
             
            default: do{}
            }
        }).store(in: &anyCancellable)
        
        self.apiManager.$event.sink(receiveValue: {evt in
            switch evt {
            case .pairingHostChanged :
                if NpsNetwork.isPairing { self.pairing.connected() }
                else { self.pairing.disconnected() }
                
            default: do{}
            }
        }).store(in: &anyCancellable)
        
        self.pairing.$event.sink(receiveValue: { evt in
            guard let evt = evt else { return }
            switch evt{
            case .connected :
                self.dataProvider.requestData(q: .init(type: .getHostDeviceInfo, isOptional: true))
                if let user = self.pairing.user {
                    self.dataProvider.requestData(q: .init(type: .postGuestInfo(user), isOptional: true))
                    if user.postAgreement { self.dataProvider.requestData(q: .init(type: .postGuestAgreement(user), isOptional: true)) }
                    else { self.dataProvider.requestData(q: .init(type: .getGuestAgreement, isOptional: true)) }
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
            case .pairingCompleted : do{}
            default: do{}
            }
        }).store(in: &anyCancellable)
        
        
        
        self.apiManager.$result.sink(receiveValue: { res in
            guard let res = res else { return }
            
            switch res.type {
            case .postUnPairing :
                if !self.checkConnectHeader(res) { return }
                
            case .postAuthPairing, .postDevicePairing :
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
                
            case .getHostDeviceInfo :
                guard let data = res.data as? HostDeviceInfo else { return }
                if !self.checkSyncHeader(data.header) { return }
                guard let hostData = data.body?.host_deviceinfo  else {
                    self.pairing.syncError()
                    return
                }
                self.pairing.syncHostDevice(HostDevice().setData(deviceData: hostData))
           
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
                
            default: do{}
            }
        }).store(in: &anyCancellable)
        
        self.apiManager.$error.sink(receiveValue: { err in
            guard let err = err else { return }
            switch err.type {
            case .postUnPairing, .postAuthPairing, .postDevicePairing, .rePairing : self.pairing.connectError()
            case .getHostDeviceInfo, .postGuestInfo, .postGuestAgreement, .getGuestAgreement: self.pairing.syncError()
            default: do{}
            }
        }).store(in: &anyCancellable)
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
        if resultCode != NpsNetwork.resultCode.success.code {
            self.pairing.connectError(header: data.header)
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
