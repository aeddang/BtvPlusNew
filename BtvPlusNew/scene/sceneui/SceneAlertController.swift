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
    case confirm(String?, String? = nil , String? = nil, (Bool) -> Void), alert(String?, String? = nil, String? = nil, (() -> Void)? = nil),
         recivedApns(AlramData?), apiError(ApiResultError),
         connectWifi((Bool) -> Void) , notFoundDevice((Bool) -> Void), requestLocation((Bool) -> Void),
         
         limitedDevice(PairingInfo?), pairingError(NpsCommonHeader?), pairingUpdated(PairingUpdateData),
         pairingRecovery, needPairing(String? = nil), pairingCheckFail,
        
         needPurchase( PurchaseWebviewModel , String? = nil), needCertification( String?, String?, String? = nil, () -> Void ),
         serviceUnavailable(String?), serviceSelect(String?, String? , (String?) -> Void),
         like(String, Bool?), updateAlram(String, Bool),
         
         
         cancel
    
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
    case complete(SceneAlert), error(SceneAlert) , cancel(SceneAlert?), retry(SceneAlert?)
}
struct DeclarationData:Identifiable {
    let id = UUID.init().uuidString
    let key:String
}

struct SceneAlertController: PageComponent{
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var networkObserver:NetworkObserver
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var appObserver:AppObserver
    
    @State var isShow = false
    @State var title:String? = nil
    @State var image:UIImage? = nil
    @State var text:String? = nil
    @State var subText:String? = nil
    @State var referenceText:String? = nil
    @State var tipText:String? = nil
    @State var imgButtons:[AlertBtnData]? = nil
    @State var buttons:[AlertBtnData] = []
    @State var currentAlert:SceneAlert? = nil
    @State var delayReset:AnyCancellable? = nil
    var body: some View {
        Form{
            Spacer()
        }
        .alert(
            isShowing: self.$isShow,
            title: self.title,
            image: self.image,
            text: self.text,
            subText: self.subText,
            tipText: self.tipText,
            referenceText: self.referenceText,
            imgButtons: self.imgButtons,
            buttons: self.buttons
        ){ idx in
            switch self.currentAlert {
            case .alert(_, _, _, let completionHandler) :
                if let handler = completionHandler { self.selectedAlert(idx, completionHandler:handler) }
            case .confirm(_, _, _, let completionHandler) : self.selectedConfirm(idx, completionHandler:completionHandler)
            case .apiError(let data): self.selectedApi(idx, data:data)
            case .connectWifi(let completionHandler): self.selectedConnectWifi(idx, completionHandler:completionHandler)
            case .notFoundDevice(let completionHandler) : self.selectedNotFoundDevice(idx, completionHandler:completionHandler)
            case .recivedApns(let data): self.selectedRecivedApns(idx, alram:data)
            case .requestLocation(let completionHandler): self.selectedRequestLocation(idx, completionHandler:completionHandler)
            case .limitedDevice(_) : self.selectedLimitedDevice(idx)
            case .pairingUpdated(_) : self.selectedPairingUpdated(idx)
            case .pairingError(_): self.selectedPairingError(idx)
            case .pairingRecovery: self.selectedPairingRecovery(idx)
            case .needPairing: self.selectedNeedPairing(idx)
            case .needPurchase(let data, _): self.selectedNeedPurchase(idx, model: data)
            case .needCertification(_, _, _, let cancleHandler): self.selectedNeedCertification(idx, canclenHandler: cancleHandler) 
            case .serviceUnavailable(let path): self.selectedServiceUnavailable(idx, path: path)
            case .serviceSelect(_ , let value, let completionHandler) : self.selectedServiceSelect(idx, value:value, completionHandler:completionHandler)
            case .pairingCheckFail : self.selectedPairingCheckFail(idx)
            case .like(let id, let isLike) : self.selectedLike(idx, id: id, isLike:isLike)
            case .updateAlram(let id, let isAlram) : self.selectedUpdateAlram(idx, id: id, isAlram:isAlram)
            default: do { return }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.reset()
            }
        
        }
        .onReceive(self.appSceneObserver.$alert){ alert in
            self.reset()
            self.currentAlert = alert
            switch alert{
            case .cancel :
                self.isShow = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.reset()
                }
                return
            case .alert(let title,let text, let subText, _) : self.setupAlert(title:title, text:text, subText:subText)
            case .confirm(let title,let text, let subText, _) : self.setupConfirm(title:title, text:text, subText:subText)
            case .apiError(let data): self.setupApi(data:data)
            case .connectWifi: self.setupConnectWifi()
            case .notFoundDevice: self.setupNotFoundDevice()
            case .requestLocation: self.setupRequestLocation()
            case .pairingUpdated(let data) :
                guard let flag = data.updateFlag else { return }
                if flag == .none { return }
                self.setupPairingUpdated(data:data)
                
            case .limitedDevice(let data) : self.setupLimitedDevice(data: data)
            case .pairingError(let data): self.setupPairingError(data: data)
            case .pairingRecovery: self.setupPairingRecovery()
            case .needPairing(let msg): self.setupNeedPairing(msg:msg)
            case .needPurchase(_ , let msg): self.setupNeedPurchase(msg: msg)
            case .needCertification(let title,let text, let subText, _): self.setupNeedCertification(title: title, text: text, subText: subText)
            case .serviceUnavailable(let path): self.setupServiceUnavailable(path: path)
            case .serviceSelect(let text, _ , _) : self.setupServiceSelect(text: text)
            case .pairingCheckFail : self.setupPairingCheckFail()
            case .like(_, let isLike) : self.setupLike( isLike: isLike)
            case .updateAlram(_, let isAlram) : self.setupUpdateAlram( isAlram: isAlram)
            case .recivedApns(let data):
                let enable = self.setupRecivedApns(alram:data)
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
        self.text = nil
        self.subText = nil
        self.tipText = nil
        self.referenceText = nil
        self.buttons = []
        self.imgButtons = nil
        self.currentAlert = nil
    }

    func setupRecivedApns(alram:AlramData?) -> Bool{
        
        if let data = alram {
            self.title = data.title
            self.text = data.text
            if let move = data.moveButton {
                self.buttons = [
                    AlertBtnData(title: String.app.cancel, index: 0),
                    AlertBtnData(title: move, index: 1)
                ]
            } else {
                self.buttons = [
                    AlertBtnData(title: String.app.corfirm, index: 0)
                ]
            }
            return true
        } else {
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
    }
    
    func selectedRecivedApns(_ idx:Int, alram:AlramData?) {
        if idx == 1 {
            if let data = alram {
                if let move = data.move {
                    switch move {
                    case .home, .category:
                        var findBand:Band? = nil
                        if let gnbTypCd = data.moveData?[PageParam.id] as? String {
                            findBand = dataProvider.bands.getData(gnbTypCd: gnbTypCd)
                        }else if let menuId = data.moveData?[PageParam.data] as? String {
                            findBand = dataProvider.bands.getData(menuId: menuId)
                        }
                        guard let band = findBand else { return }
                        self.pagePresenter.changePage(
                            PageProvider
                                .getPageObject(move)
                                .addParam(params: data.moveData)
                                .addParam(key: .id, value: band.menuId)
                                .addParam(key: UUID().uuidString , value: "")
                        )
                        
                    default :
                        let pageObj = PageProvider.getPageObject(move)
                        pageObj.params = data.moveData
                        self.pagePresenter.openPopup(pageObj)
                    }
                }
                else if let link = data.outLink {
                    AppUtil.openURL(link)
                }
                
                if let link = data.inLink {
                    self.pagePresenter.openPopup(
                        PageProvider
                            .getPageObject(.webview)
                            .addParam(key: .data, value: link)
                            .addParam(key: .title , value: data.title)
                    )
                }
                NotificationCoreData().readNotice(title: data.title ?? "", body: data.text ?? "")
                
            } else{
                
                guard let page = self.appObserver.page?.page else { return }
                if page.isPopup {
                    self.pagePresenter.openPopup(page)
                }else{
                    self.pagePresenter.changePage(page)
                }
            }
            
        }
        self.repository.alram.changedNotification()
        DispatchQueue.main.async {
            self.repository.alram.updatedNotification()
        }
        self.appObserver.resetApns()
    }
    
    
    func setupApi(data:ApiResultError) {
        self.title = String.alert.api
        if let apiError = data.error as? ApiError {
            self.text = ApiError.getViewMessage(message: apiError.message)
        }else{
            if self.networkObserver.status == .none {
                self.text = String.alert.apiErrorClient
                self.buttons = [
                    AlertBtnData(title: String.app.cancel, index: 0),
                    AlertBtnData(title: String.app.retry, index: 1),
                ]
                
            }else{
                self.text = String.alert.apiErrorServer
                self.buttons = [
                    AlertBtnData(title: String.app.corfirm, index: 2),
                ]
            }
        }
    }
    
    func selectedApi(_ idx:Int, data:ApiResultError) {
        if idx == 1 {
            if data.isProcess {
                self.appSceneObserver.alertResult = .retry(nil)
            }else{
                self.dataProvider.requestData(q:.init(type:data.type))
            }
            
        }else if idx == 0  {
            self.appSceneObserver.alertResult = .cancel(nil)
        }
    }
    
    func setupConnectWifi() {
        self.title = String.alert.connect
        self.text = String.alert.connectWifi
        self.subText = String.alert.connectWifiSub
        self.buttons = [
            AlertBtnData(title: String.app.retry, index: 0),
            AlertBtnData(title: String.app.corfirm, index: 1)
        ]
    }
    func selectedConnectWifi(_ idx:Int, completionHandler: @escaping (Bool) -> Void){
        completionHandler(idx == 0)
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
    func selectedNotFoundDevice(_ idx:Int, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(idx == 0)
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
    func selectedRequestLocation(_ idx:Int, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(idx == 0)
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
    
    func setupPairingUpdated(data:PairingUpdateData) {
        switch data.updateFlag {
        case .forceUnpairing:
            self.title = String.alert.unpairing
            self.text = String.alert.forceUnpairing
            self.subText = String.alert.forceUnpairingInfo.replace((data.maxCount ?? Pairing.LIMITED_DEVICE_NUM).description)
        case .upgrade:
            self.title = String.alert.upgradePairing
            self.text = String.alert.upgradePairingSub.replace(
                first:data.productName ?? "" ,
                second: (data.maxCount ?? Pairing.LIMITED_DEVICE_NUM).description)
        default: return
        }
        self.buttons = [
            AlertBtnData(title: String.app.corfirm, index: 0)
        ]
    }
    func selectedPairingUpdated(_ idx:Int) {}
    
    func setupPairingCheckFail() {
        self.title = String.alert.connect
        self.text = String.alert.needConnectStatus
        self.buttons = [
            AlertBtnData(title: String.app.close, index: 0),
            AlertBtnData(title: String.app.corfirm, index: 1)
        ]
    }
    func selectedPairingCheckFail(_ idx:Int) {
        if idx == 0 {
            self.pagePresenter.goBack()
        }else{
            self.pairing.requestPairing(.check)
        }
    }
    
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
                let ani:PageAnimationType = SystemEnvironment.currentPageType == .btv ? .horizontal : .opacity
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.pairingSetupUser,animationType: ani)
                        .addParam(key: PageParam.type, value: PairingRequest.recovery)
                )
            }
        }else{
            self.pairing.requestPairing(.unPairing)
        }
    }
    
    func setupNeedPairing(msg:String? = nil) {
        self.title = String.alert.connect
        self.text = msg ?? String.alert.needConnect
        
        self.buttons = [
            AlertBtnData(title: String.app.cancel, index: 0),
            AlertBtnData(title: String.button.connectBtv, index: 1)
        ]
    }
    func selectedNeedPairing(_ idx:Int) {
        if idx == 1 {
            
            let ani:PageAnimationType = SystemEnvironment.currentPageType == .btv ? .horizontal : .opacity
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.pairing, animationType: ani)
            )
        }
    }
    
    func setupNeedPurchase(msg:String?) {
        self.title = String.alert.purchase
        self.text = msg ?? String.alert.purchaseContinue
        
        self.buttons = [
            AlertBtnData(title: String.app.cancel, index: 0),
            AlertBtnData(title: String.button.purchas, index: 1)
        ]
    }
    func selectedNeedPurchase(_ idx:Int,  model:PurchaseWebviewModel) {
        if idx == 1 {
            let ani:PageAnimationType = SystemEnvironment.currentPageType == .btv ? .horizontal : .opacity
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.purchase, animationType: ani)
                    .addParam(key: .data, value: model)
            )
        }
    }
    
    func setupServiceUnavailable(path:String?) {
        self.title = String.alert.serviceUnavailable
        self.text = String.alert.serviceUnavailableText
        
        self.buttons = [
            AlertBtnData(title: String.app.corfirm, index: 1)
        ]
    }
    func selectedServiceUnavailable(_ idx:Int, path:String?) {}
    
    
    func setupServiceSelect(text:String?) {
        self.text = text ?? ""
        self.buttons = [
            AlertBtnData(title: String.app.cancel, index: 0),
            AlertBtnData(title: String.app.corfirm, index: 1)
        ]
    }
    func selectedServiceSelect(_ idx:Int, value:String?, completionHandler: @escaping (String?) -> Void) {
        if idx == 1 {
            completionHandler(value)
        }else{
            completionHandler(nil)
        }
    }
    
    func setupLike( isLike:Bool? ) {
        self.title = String.alert.like
        self.imgButtons = [
            AlertBtnData(title: String.button.likeOn,
                         img: isLike == true ? Asset.icon.goodOn : Asset.icon.goodOff,
                         index: 1),
            AlertBtnData(title: String.button.likeOff,
                         img: isLike == false ? Asset.icon.badOn : Asset.icon.badOff,
                         index: 2)
        ]
        self.buttons = [
            AlertBtnData(title: String.app.cancel, index: 0)
        ]
    }
    func selectedLike(_ idx:Int, id:String, isLike:Bool?) {
        if idx == 1 {
            if isLike == true { self.dataProvider.requestData(q: .init(id:id, type: .registLike(nil, id, self.pairing.hostDevice))) }
            else { self.dataProvider.requestData(q: .init(id:id, type: .registLike(true, id, self.pairing.hostDevice))) }
        }else if idx == 2 {
            if isLike == false { self.dataProvider.requestData(q: .init(id:id, type: .registLike(nil, id, self.pairing.hostDevice))) }
            else { self.dataProvider.requestData(q: .init(id:id, type: .registLike(false, id, self.pairing.hostDevice))) }
        }
    }
    
    func setupUpdateAlram( isAlram:Bool) {
        self.title = String.alert.updateAlram
        self.text = String.alert.updateAlramSetup
        self.buttons = [
            AlertBtnData(title: String.app.cancel, index: 0),
            AlertBtnData(title: String.button.recieveAlram, index: 1)
        ]
    }
    func selectedUpdateAlram(_ idx:Int, id:String, isAlram:Bool) {
        if idx == 1 {
            
        }
    }
    
    func setupNeedCertification(title:String?, text:String?, subText:String? = nil) {
        self.title = title
        self.text = text ?? ""
        self.subText = subText
        self.buttons = [
            AlertBtnData(title: String.app.cancel, index: 0),
            AlertBtnData(title: String.button.certification, index: 1)
        ]
    }
    func selectedNeedCertification(_ idx:Int, canclenHandler: @escaping () -> Void) {
        if idx == 1 {
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.userCertification)
            )
        } else {
            canclenHandler()
        }
    }
    
    
    func setupConfirm(title:String?, text:String?, subText:String? = nil) {
        self.title = title
        self.text = text ?? ""
        self.subText = subText
        self.buttons = [
            AlertBtnData(title: String.app.cancel, index: 0),
            AlertBtnData(title: String.app.corfirm, index: 1)
        ]
    }
    func selectedConfirm(_ idx:Int,  completionHandler: @escaping (Bool) -> Void) {
        completionHandler(idx == 1)
    }
    
    func setupAlert(title:String?, text:String?, subText:String? = nil) {
        self.title = title
        self.text = text ?? ""
        self.subText = subText
        self.buttons = [
            AlertBtnData(title: String.app.corfirm, index: 0)
        ]
    }
    func selectedAlert(_ idx:Int, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    
    
}


