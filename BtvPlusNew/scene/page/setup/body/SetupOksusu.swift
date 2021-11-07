//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupOksusu: PageView {
    
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    var isInitate:Bool = false
    @State var isOksusu:Bool = false
    @State var isOksusuPurchaseUseAble:Bool = false
    @State var isOksusuPurchase:Bool = false
    @State var willOksusu:Bool? = nil
    @State var willOksusuPurchase:Bool? = nil
     
    @State var mergePurchaseCode:EpsNetwork.MergeOksusuCode? = nil

    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text(String.pageText.setupOksusu).modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: self.$isOksusu,
                    title: String.pageText.setupOksusuSet,
                    subTitle: String.pageText.setupOksusuSetText,
                    tips: [String.pageText.setupOksusuSetTip]
                )
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                SetupItem (
                    isOn: self.$isOksusuPurchase,
                    title: String.pageText.setupOksusuPurchaseSet,
                    subTitle: self.mergePurchaseCode == .PROGRESS
                        ?String.pageText.setupOksusuPurchaseProgresText
                        :String.pageText.setupOksusuPurchaseSetText,
                    tips: [String.pageText.setupOksusuPurchaseSetTip1,
                           String.pageText.setupOksusuPurchaseSetTip2,
                           String.pageText.setupOksusuPurchaseSetTip3
                          ],
                    toggleText: self.getMergeOksusuPurchaseText(),
                    useToggleButton: false,
                    reflash: self.mergePurchaseCode == .PROGRESS || self.mergePurchaseCode == .ERROR ? {
                        self.checkOksusuPurchaseMerge()
                    } : nil
                )
                .opacity(self.isOksusuPurchaseUseAble ? 1.0 : 0.5)
            }
            .background(Color.app.blueLight)
        }
        .onReceive( [self.isOksusu].publisher ) { value in
            if !self.isInitate { return }
            let originValue = self.repository.storage.oksusu.isEmpty == false
            if originValue == value { return }
            if self.willOksusu != nil { return }
            
            if !value {
                if originValue {
                    self.deleteOksusu()
                }
            } else {
                if !originValue {
                    self.setupOksusu()
                }
            }
        }
        .onReceive( [self.isOksusuPurchase].publisher ) { value in
            if !self.isInitate { return }
            let originValue = self.repository.storage.oksusuPurchase.isEmpty == false
            if originValue == value { return }
            if self.willOksusuPurchase != nil { return }
            if !self.isOksusu {
                if value {
                    self.appSceneObserver.event = .toast(String.oksusu.setupPurchaseDiable)
                    self.isOksusuPurchase = !value
                } else {
                    self.willOksusuPurchase = nil
                    self.isOksusuPurchase = true
                }
                return
            }
            
            if self.pairing.status != .pairing {
                self.appSceneObserver.alert = .needPairing()
                self.isOksusuPurchase = !value
                return
            }
            if !value {
                if originValue {
                    //self.appSceneObserver.event = .toast(String.oksusu.setupPurchaseDeleteDiable)
                    self.isOksusuPurchase = true
                }
            } else {
                if !originValue {
                   self.setupOksusuPurchase()
                }
            }
        }
        .onReceive(self.pagePresenter.$event){ evt in
            guard let evt = evt else {return}
            switch evt.type {
            case .certification :
                if let stbId = evt.data as? String {
                    self.setupOksusuCertificationCompleted(stbId:stbId)
                } else {
                    self.setupOksusuCancel()
                }
            default : break
            }
        }
        
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .checkOksusu: self.setOksusuStatus(res: res)
            case .checkOksusuPurchase: self.setOksusuPurchase(res: res)
            case .addOksusuUserToBtvPurchase : self.addedOksusuPurchase(res: res)
            default: break
            }
        }
        .onReceive(self.dataProvider.$error){ err in
            guard let err = err else { return }
            switch err.type {
            case .checkOksusu: self.setOksusu()
            case .checkOksusuPurchase:
                self.mergePurchaseCode = .PROGRESS
                self.appSceneObserver.event = .toast( String.alert.apiErrorServer )
            default: break
            }
        }
        .onReceive(self.pairing.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .disConnected :
                self.repository.storage.oksusuPurchase = ""
                self.isOksusuPurchase = false
                self.setOksusuPurchaseAble()
            case .pairingCompleted : self.setOksusuPurchaseAble()
            default: break
            }
        }
        .onAppear(){
            self.dataProvider.requestData(q: .init(id: self.tag, type: .checkOksusu, isOptional: true))
        }
    }//body
    
    private func setOksusuStatus(res:ApiResultResponds){
        guard let status = res.data as? OksusuStatus else {
            self.setOksusu()
            return
        }
        let isConnect = status.body?.authYn?.toBool() ?? false
        let isPurchaseConnect = status.body?.closeYn?.toBool() ?? false
        if !isConnect {
            self.repository.storage.oksusu = ""
        } else {
            //self.setup.oksusu = "sdsdsddsd"
        }
        if isPurchaseConnect {
            self.repository.storage.oksusuPurchase = "Y"
        } else {
            self.repository.storage.oksusuPurchase = ""
        }
        self.setOksusu()
    }
    
    private func setOksusu(){
        self.isOksusu = self.repository.storage.oksusu.isEmpty == false
        if self.pairing.status != .pairing {
            self.repository.storage.oksusuPurchase = ""
        }
        self.isOksusuPurchase = self.repository.storage.oksusuPurchase.isEmpty == false
        self.setOksusuPurchaseAble()
        self.checkOksusuPurchaseMerge(isOption:true)
    }
    
    private func setOksusuPurchaseAble(){
        self.isOksusuPurchaseUseAble = self.isOksusu && self.pairing.status == .pairing
    }
    
    private func checkOksusuPurchaseMerge(isOption:Bool = false){
        if self.isOksusuPurchase {
            if  self.repository.storage.oksusu.isEmpty == true {
                self.mergePurchaseCode = EpsNetwork.MergeOksusuCode.COMPLETED
            } else {
                self.dataProvider.requestData(
                    q: .init(type: .checkOksusuPurchase(self.pairing.hostDevice,  self.repository.storage.oksusu), isOptional: isOption))
            }
        }
    }
    private func setOksusuPurchase(res:ApiResultResponds){
        guard let data = res.data as? RegistEps else {
            self.appSceneObserver.event = .toast( String.alert.apiErrorServer )
            return
        }
        self.mergePurchaseCode = EpsNetwork.MergeOksusuCode.getType(data.result)
        switch self.mergePurchaseCode {
        case .FAIL:
            let msg = data.reason ?? String.alert.apiErrorServer
            self.appSceneObserver.alert = .alert(String.oksusu.setup, msg)
            self.repository.storage.oksusuPurchase = ""
            self.isOksusuPurchase = self.repository.storage.oksusuPurchase.isEmpty == false
        case .ERROR:
            self.appSceneObserver.event = .toast( String.alert.apiErrorServer )
        default: break
        }
    }
    
    @State var currentSelectedUser:UserData? = nil
    private func setupOksusu(){
        self.willOksusu = true
        self.appSceneObserver.alert = .confirm(
            String.oksusu.certification,
            String.oksusu.setupCertification,
            String.oksusu.setupCertificationSub,
            confirmText:String.button.certification){ isOk in
                if isOk {
                    self.pagePresenter.openPopup(
                        PageProvider.getPageObject(.oksusuCertification)
                    )
                } else {
                    self.setupOksusuCancel()
                }
        }
    }
    
    private func setupOksusuCancel(){
        self.willOksusu = nil
        self.isOksusu = (self.repository.storage.oksusu.isEmpty == false)
    }
    
    private func setupOksusuCertificationCompleted(stbId:String){
        self.willOksusu = nil
        self.repository.storage.oksusu = stbId
        self.appSceneObserver.event = .toast(String.oksusu.setupCompleted)
        self.setOksusuPurchaseAble()
        self.sendLog(category: "옥수수소장vod가져오기", config: true)
    }
    
    private func deleteOksusu(){
        self.willOksusu = false
        self.setupOksusuCancel()
        /*
        self.appSceneObserver.alert = .alert(
            String.oksusu.disconnect,
            self.isOksusuPurchase ? String.oksusu.disconnectButPurchase : String.oksusu.disconnectText
        ){
            
        }*/
    }
    
    private func setupOksusuPurchase(){
        self.willOksusuPurchase = true
        self.dataProvider.requestData(q: .init(id: self.tag, type:.mergeOksusuPurchase(self.pairing.hostDevice, self.repository.storage.oksusu)))
    }
    private func setupOksusuPurchaseCancel(){
        if self.mergePurchaseCode == .PROGRESS {
            self.checkOksusuPurchaseMerge()
        }
        //해재불가
        /*
        self.willOksusuPurchase = nil
        self.isOksusuPurchase = (self.setup.oksusuPurchase.isEmpty == false)
        */
    }
    private func addedOksusuPurchase(res:ApiResultResponds){
        guard let data = res.data as? RegistEps else {
            self.appSceneObserver.event = .toast( String.alert.apiErrorServer )
            self.setupOksusuCancel()
            return
        }
        if data.result == ApiCode.success {
            self.willOksusuPurchase = nil
            self.repository.storage.oksusuPurchase = "Y"
            self.appSceneObserver.event = .toast(String.oksusu.setupPurchaseCompleted)
            self.checkOksusuPurchaseMerge(isOption:true)
            self.sendLog(category: "옥수수구매내역보기", config: true)
        } else {
            self.appSceneObserver.event = .toast( String.alert.apiErrorServer )
            self.setupOksusuCancel()
        }
        //self.sendLog(category: String.pageText.setupPossessionSet, config: false)
    }
    
    private func getMergeOksusuPurchaseText() -> String {
        return self.isOksusuPurchase
        ? self.mergePurchaseCode == .PROGRESS || self.mergePurchaseCode == .ERROR
            ? String.pageText.setupOksusuPurchaseProgresButton
            : self.mergePurchaseCode == .COMPLETED ? String.pageText.setupOksusuPurchaseCompletedButton : ""
        : String.pageText.setupOksusuPurchaseSetButton
    }
    
    private func sendLog(category:String, config:Bool) {
        let actionBody = MenuNaviActionBodyItem( config: config ? "on" : "off", category: category)
        self.naviLogManager.actionLog(.clickConfigSelection, actionBody: actionBody)
    }
}

#if DEBUG
struct SetupOksusu_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupOksusu()
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
