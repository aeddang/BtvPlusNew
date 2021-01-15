//
//  AppLayout.swift
//  Valla
//
//  Created by JeongCheol Kim on 2020/08/08.
//  Copyright © 2020 JeongCheol Kim. All rights reserved.
//
import Foundation
import Foundation
import SwiftUI
import Combine

enum SceneAlert:Equatable {
    case confirm(String?, String?,(Bool) -> Void), alert(String?, String?, (() -> Void)?),
         recivedApns, apiError(ApiResultError),
         connectWifi , notFoundDevice, requestLocation,
         limitedDevice(PairingInfo?), pairingError(NpsCommonHeader?), pairingRecovery,
         serviceUnavailable(String?), serviceSelect(String?, String? , (String?) -> Void)
    
    static func ==(lhs: SceneAlert, rhs: SceneAlert) -> Bool {
        switch (lhs, rhs) {
        case ( .connectWifi, .connectWifi):return true
        case ( .notFoundDevice, .notFoundDevice):return true
        case ( .requestLocation, .requestLocation):return true
        default: return false
        }
    }

}
enum SceneAlertResult {
    case complete(SceneAlert), error(SceneAlert) , cancel(SceneAlert), retry(SceneAlert)
}
struct DeclarationData:Identifiable {
    let id = UUID.init().uuidString
    let key:String
}

struct SceneAlertController: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var networkObserver:NetworkObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var pageSceneObserver:PageSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    
    @State var isShow = false
    @State var title:String? = nil
    @State var image:UIImage? = nil
    @State var text:String = ""
    @State var subText:String? = nil
    @State var referenceText:String? = nil
    @State var tipText:String? = nil
    @State var buttons:[AlertBtnData] = []
    @State var currentAlert:SceneAlert? = nil
    @State var delayReset:AnyCancellable? = nil
    var body: some View {
        Form{
            Spacer()
        }
        .alert(
            isShowing: self.$isShow,
            title: self.$title,
            image: self.$image,
            text: self.$text,
            subText: self.$subText,
            tipText: self.$tipText,
            referenceText: self.$referenceText,
            buttons: self.$buttons
        ){ idx in
            switch self.currentAlert {
            case .alert(_, _, let completionHandler) :
                if let handler = completionHandler { self.selectedAlert(idx, completionHandler:handler) }
            case .confirm(_, _, let completionHandler) : self.selectedConfirm(idx, completionHandler:completionHandler)
            case .apiError(let data): self.selectedApi(idx, data:data)
            case .connectWifi: self.selectedConnectWifi(idx)
            case .notFoundDevice : self.selectedNotFoundDevice(idx)
            case .recivedApns: self.selectedRecivedApns(idx)
            case .requestLocation: self.selectedRequestLocation(idx)
            case .limitedDevice(_) : self.selectedLimitedDevice(idx)
            case .pairingError(_): self.selectedPairingError(idx)
            case .pairingRecovery: self.selectedPairingRecovery(idx)
            case .serviceUnavailable(let path): self.selectedServiceUnavailable(idx, path: path)
            case .serviceSelect(_ , let value, let completionHandler) : self.selectedServiceSelect(idx, value:value, completionHandler:completionHandler)
           
            default: do { return }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reset()
            }
        
        }
        .onReceive(self.pageSceneObserver.$alert){ alert in
            self.reset()
            self.currentAlert = alert
            switch alert{
            case .alert(let title,let text, _) : self.setupAlert(title:title, text:text)
            case .confirm(let title,let text, _) : self.setupConfirm(title:title, text:text)
            case .apiError(let data): self.setupApi(data:data)
            case .connectWifi: self.setupConnectWifi()
            case .notFoundDevice: self.setupNotFoundDevice()
            case .requestLocation: self.setupRequestLocation()
            case .limitedDevice(let data) : self.setupLimitedDevice(data: data)
            case .pairingError(let data): self.setupPairingError(data: data)
            case .pairingRecovery: self.setupPairingRecovery()
            case .serviceUnavailable(let path): self.setupServiceUnavailable(path: path)
            case .serviceSelect(let text, _ , _) : self.setupServiceSelect(text: text)

            case .recivedApns:
                let enable = self.setupRecivedApns()
                if !enable { return }
            default: do { return }
            }
            withAnimation{
                self.isShow = true
            }
        }
    }//body
    
    func reset(){
        if self.isShow { return }
        self.title = nil
        self.image = nil
        self.text = ""
        self.subText = nil
        self.tipText = nil
        self.referenceText = nil
        self.buttons = []
        self.currentAlert = nil
    }

    func setupRecivedApns() -> Bool{
        guard let apns = self.appObserver.apns else { return false }
        guard let alert = apns["alert"] as? [String:String] else { return false }
        self.title = String.alert.apns
        self.text = alert["title"] as String? ?? ""
        self.subText = alert["body"] as String? ?? ""
        if (self.appObserver.page?.page) != nil {
            self.buttons = [
                AlertBtnData(title: String.app.cancel, index: 0), 
                AlertBtnData(title: String.app.corfirm, index: 1)
            ]
        }else{
            self.buttons = [
                AlertBtnData(title: String.app.corfirm, index: 0)
            ]
        }
        return true
    }
    
    func selectedRecivedApns(_ idx:Int) {
        if idx == 1 {
            guard let page = self.appObserver.page?.page else { return }
            if page.isPopup {
                self.pagePresenter.openPopup(page)
            }else{
                self.pagePresenter.changePage(page)
            }
        }
        self.appObserver.reset()
    }
    
    
    func setupApi(data:ApiResultError) {
        self.title = String.alert.api
        if let apiError = data.error as? ApiError {
            self.text = ApiError.getViewMessage(message: apiError.message)
        }else{
            if self.networkObserver.status == .none {
                self.text = String.alert.apiErrorClient
                
            }else{
                self.text = String.alert.apiErrorServer
            }
        }
        self.buttons = [
            AlertBtnData(title: String.app.corfirm, index: 0),
        ]
    }
    func selectedApi(_ idx:Int, data:ApiResultError) {}
    
    func setupConnectWifi() {
        self.title = String.alert.connect
        self.text = String.alert.connectWifi
        self.subText = String.alert.connectWifiSub
        self.buttons = [
            AlertBtnData(title: String.app.retry, index: 0),
            AlertBtnData(title: String.app.corfirm, index: 1)
        ]
    }
    func selectedConnectWifi(_ idx:Int){
        if idx == 0 {
            self.pageSceneObserver.alertResult = .retry(.connectWifi)
        }else {
            self.pageSceneObserver.alertResult = .cancel(.connectWifi)
        }
    }
    
    func setupNotFoundDevice() {
        self.title = String.alert.connect
        self.text = String.alert.connectNotFound
        self.subText = String.alert.connectNotFoundSub
        self.buttons = [
            AlertBtnData(title: String.app.retry, index: 0),
            AlertBtnData(title: String.app.corfirm, index: 1)
        ]
    }
    func selectedNotFoundDevice(_ idx:Int) {
        if idx == 0 {
            self.pageSceneObserver.alertResult = .retry(.notFoundDevice)
        }else {
            self.pageSceneObserver.alertResult = .cancel(.notFoundDevice)
        }
    }
    
    func setupRequestLocation() {
        self.title = String.alert.connect
        self.text = String.alert.location
        self.subText = String.alert.locationSub
        self.buttons = [
            AlertBtnData(title: String.alert.locationBtn, index: 0),
            AlertBtnData(title: String.app.cancel, index: 1)
        ]
    }
    func selectedRequestLocation(_ idx:Int) {
        if idx == 0 {
            self.pageSceneObserver.alertResult = .retry(.requestLocation)
        }else {
            self.pageSceneObserver.alertResult = .cancel(.requestLocation)
        }
    }
    
    func setupLimitedDevice(data:PairingInfo?) {
        self.title = String.alert.connect
        if let count = data?.count {
            self.text = String.alert.limitedDevice.replace(count.description)
        }
        self.subText = String.alert.limitedDeviceSub.replace(data?.max_count?.description ?? Pairing.LIMITED_DEVICE_NUM.description)
        if let max = data?.max_count {
            if Int(max) ?? 0 < Pairing.LIMITED_DEVICE_NUM {
                self.tipText = String.alert.limitedDeviceTip.replace(Pairing.LIMITED_DEVICE_NUM.description)
                self.referenceText = String.alert.limitedDeviceReference
            }
        }
        self.buttons = [
            AlertBtnData(title: String.app.corfirm, index: 0)
        ]
    }
    func selectedLimitedDevice(_ idx:Int) {}
    
    
    func setupPairingError(data:NpsCommonHeader?) {
        self.title = String.alert.connect
        switch data?.result {
        case NpsNetwork.resultCode.authcodeInvalid.code :
            self.text = String.alert.authcodeInvalid
        case NpsNetwork.resultCode.authcodeWrong.code :
            self.text = String.alert.authcodeWrong
        case NpsNetwork.resultCode.authcodeTimeout.code :
            self.text = String.alert.authcodeTimeout
        case NpsNetwork.resultCode.pairingLimited.code :
            self.text = String.alert.limitedConnect
        default :
            self.text = String.alert.stbConnectFail
        }
        self.buttons = [
            AlertBtnData(title: String.app.corfirm, index: 0)
        ]
    }
    func selectedPairingError(_ idx:Int) {}
    
    func setupPairingRecovery() {
        self.title = String.alert.connect
        self.text = String.alert.pairingRecovery
        
        self.buttons = [
            AlertBtnData(title: String.button.connect, index: 0),
            AlertBtnData(title: String.button.disConnect, index: 1)
        ]
    }
    func selectedPairingRecovery(_ idx:Int) {
        if idx == 0 {
            if self.pairing.user != nil { self.pairing.requestPairing(.recovery) }
            else {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.pairingSetupUser)
                        .addParam(key: PageParam.type, value: PairingRequest.recovery)
                )
            }
        }else{
            self.pairing.requestPairing(.unPairing)
        }
    }
    
    func setupServiceUnavailable(path:String?) {
        self.title = String.alert.connect
        self.text = String.alert.pairingRecovery
        
        self.buttons = [
            AlertBtnData(title: String.app.retry, index: 0),
            AlertBtnData(title: String.app.cancel, index: 1)
        ]
    }
    func selectedServiceUnavailable(_ idx:Int, path:String?) {
        if idx == 0 {
            
        }else{
            
        }
    }
    
    
    func setupServiceSelect(text:String?) {
        self.text = text ?? ""
        self.buttons = [
            AlertBtnData(title: String.app.corfirm, index: 0),
            AlertBtnData(title: String.app.cancel, index: 1)
        ]
    }
    func selectedServiceSelect(_ idx:Int, value:String?, completionHandler: @escaping (String?) -> Void) {
        if idx == 0 {
            completionHandler(value)
        }else{
            completionHandler(nil)
        }
    }
    
    func setupConfirm(title:String?, text:String?) {
        self.title = title
        self.text = text ?? ""
        self.buttons = [
            AlertBtnData(title: String.app.corfirm, index: 0),
            AlertBtnData(title: String.app.cancel, index: 1)
        ]
    }
    func selectedConfirm(_ idx:Int,  completionHandler: @escaping (Bool) -> Void) {
        completionHandler(idx == 0)
    }
    
    func setupAlert(title:String?, text:String?) {
        self.title = title
        self.text = text ?? ""
        self.buttons = [
            AlertBtnData(title: String.app.corfirm, index: 0)
        ]
    }
    func selectedAlert(_ idx:Int, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
}


