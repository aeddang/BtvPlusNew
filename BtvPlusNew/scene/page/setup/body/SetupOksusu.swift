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
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text(String.pageText.setupOksusu).modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: self.$isOksusu,
                    title: String.pageText.setupOksusuSet,
                    subTitle: String.pageText.setupOksusuSetText
                )
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                SetupItem (
                    isOn: self.$isOksusuPurchase,
                    title: String.pageText.setupOksusuPurchaseSet,
                    subTitle: String.pageText.setupOksusuPurchaseSetText
                )
                .opacity(self.isOksusuPurchaseUseAble ? 1.0 : 0.5)
            }
            .background(Color.app.blueLight)
        }
        .onReceive( [self.isOksusu].publisher ) { value in
            if !self.isInitate { return }
            let originValue = self.setup.oksusu.isEmpty == false
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
            let originValue = self.setup.oksusuPurchase.isEmpty == false
            if originValue == value { return }
            if self.willOksusuPurchase != nil { return }
            if !self.isOksusu {
                if value {
                    self.appSceneObserver.event = .toast(String.oksusu.setupPurchaseDiable)
                    self.isOksusuPurchase = !value
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
                    self.appSceneObserver.event = .toast(String.oksusu.setupPurchaseDeleteDiable)
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
                if let cid = evt.data as? String {
                    self.setupOksusuCertificationCompleted(cid:cid)
                } else {
                    self.setupOksusuCancel()
                }
            case .selected :
                if let user = evt.data as? UserData {
                    self.selectedOksusu(user)
                } else {
                    self.setupOksusuCancel()
                }
            default : break
            }
        }
        
        .onReceive(self.dataProvider.$result){ res in
            guard let res = res else { return }
            switch res.type {
            case .getOksusuUser : self.checkGetOksusuAble(res:res)
            case .getOksusuUserInfo : self.connectedUserInfo(res: res)
            case .connectOksusuUser : self.connectedOksusu(res: res)
            case .disconnectOksusuUser : self.deletedOksusu(res: res)
            case .addOksusuUserToBtvPurchase : self.addedOksusuPurchase(res: res)
            default: break
            }
        }
        .onReceive(self.dataProvider.$error){ err in
            guard let err = err else { return }
            switch err.type {
            case .getOksusuUser : break
            default: break
            }
        }
        .onReceive(self.pairing.$event){ evt in
            guard let evt = evt else { return }
            switch evt {
            case .disConnected :
                self.setup.oksusuPurchase = ""
                self.isOksusuPurchase = false
                self.setOksusuPurchaseAble()
            case .pairingCompleted : self.setOksusuPurchaseAble()
            default: break
            }
        }
        .onAppear(){
            self.isOksusu = self.setup.oksusu.isEmpty == false
            if self.pairing.status != .pairing {
                self.setup.oksusuPurchase = ""
            }
            self.isOksusuPurchase = self.setup.oksusuPurchase.isEmpty == false
            self.setOksusuPurchaseAble()
        }
    }//body
    
    private func setOksusuPurchaseAble(){
        self.isOksusuPurchaseUseAble = self.isOksusu && self.pairing.status == .pairing
    }
    
    
    @State var currentSelectedUser:UserData? = nil
    private func setupOksusu(){
        self.willOksusu = true
        self.appSceneObserver.alert = .needCertification(
            String.oksusu.certification,
            String.oksusu.setupCertification,
            String.oksusu.setupCertificationSub,
            pageTitle:String.oksusu.certification){
            self.setupOksusuCancel()
        }
    }
    
    private func setupOksusuCancel(){
        self.willOksusu = nil
        self.isOksusu = (self.setup.oksusu.isEmpty == false)
    }
    
    private func setupOksusuCertificationCompleted(cid:String){
        let test = "5qDs1ydeLCB2M08k/JpZOMHa3rOdTUe3ZXJ7PawML/revc/e31zPHWYLJlgwxEOr2UDd0vnR5Am8oqv9bSVnzw=="
        self.dataProvider.requestData(q: .init(id: self.tag, type: .getOksusuUser(test)))
    }
    private func checkGetOksusuAble(res:ApiResultResponds){
       
        guard let data = res.data as? StbListItem  else {
            self.appSceneObserver.event = .toast( String.alert.apiErrorServer )
            self.setupOksusuCancel()
            return
        }
        guard let stbs = data.data?.stb_infos else {
            self.appSceneObserver.alert = .alert(
                String.oksusu.setupDiable,
                String.oksusu.setupDiableText,
                String.oksusu.setupDiableTip,
                confirmText: String.app.close
            )
            self.setupOksusuCancel()
            return
        }
        if stbs.isEmpty {
            self.appSceneObserver.alert = .alert(
                String.oksusu.setupDiable,
                String.oksusu.setupDiableText,
                String.oksusu.setupDiableTip,
                confirmText: String.app.close
            )
            self.setupOksusuCancel()
            return
        }
        self.pagePresenter.openPopup(
            PageProvider
                .getPageObject(.oksusuUser)
                .addParam(key: .data, value: stbs)
        )
    }
    
    private func selectedOksusu(_ user:UserData){
        self.currentSelectedUser = user
        let test = "5qDs1ydeLCB2M08k/JpZOMHa3rOdTUe3ZXJ7PawML/revc/e31zPHWYLJlgwxEOr2UDd0vnR5Am8oqv9bSVnzw=="
        self.dataProvider.requestData(
            q:.init(id: self.tag,
                    type: .getOksusuUserInfo(test)))
    }
    private func connectedUserInfo(res:ApiResultResponds){
        guard let data = res.data as? StbListItem  else {
            self.appSceneObserver.event = .toast( String.alert.apiErrorServer )
            self.setupOksusuCancel()
            return
        }
        let isAlreadyUser = true
        if isAlreadyUser {
            self.appSceneObserver.alert = .confirm(
                String.oksusu.setupAlreadyUsed,
                String.oksusu.setupAlreadyUsedSub,
                confirmText: String.oksusu.setupButtonConnect
            )
            { isOk in
                if isOk {
                    let test = "5qDs1ydeLCB2M08k/JpZOMHa3rOdTUe3ZXJ7PawML/revc/e31zPHWYLJlgwxEOr2UDd0vnR5Am8oqv9bSVnzw=="
                    self.dataProvider.requestData(
                        q:.init(id: self.tag,
                                type: .disconnectOksusuUser(test)))
                } else {
                    self.setupOksusuCancel()
                }
            }
        } else {
            let test = "5qDs1ydeLCB2M08k/JpZOMHa3rOdTUe3ZXJ7PawML/revc/e31zPHWYLJlgwxEOr2UDd0vnR5Am8oqv9bSVnzw=="
            self.dataProvider.requestData(
                q:.init(id: self.tag,
                        type: .connectOksusuUser(test)))
        }
    }
    private func connectedOksusu(res:ApiResultResponds){
        guard let data = res.data as? StbListItem  else {
            self.appSceneObserver.event = .toast( String.alert.apiErrorServer )
            self.setupOksusuCancel()
            return
        }
        self.setupOksusuCompleted(res:res)
    }
    
    private func setupOksusuCompleted(res:ApiResultResponds){
        self.willOksusu = nil
        self.setup.oksusu = UUID().uuidString
        self.appSceneObserver.event = .toast(String.oksusu.setupCompleted)
        self.pagePresenter.closePopup(pageId: .oksusuUser)
        self.setOksusuPurchaseAble()
        //self.sendLog(category: String.pageText.setupPossessionSet, config: true)
    }
    
    private func deleteOksusu(){
        self.willOksusu = false
        self.appSceneObserver.alert = .confirm(
            String.oksusu.disconnect,
            self.isOksusuPurchase ? String.oksusu.disconnectButPurchase : String.oksusu.disconnectText,
            confirmText: String.oksusu.setupButtonDisConnect
        )
        { isOk in
            if isOk {
                let test = "5qDs1ydeLCB2M08k/JpZOMHa3rOdTUe3ZXJ7PawML/revc/e31zPHWYLJlgwxEOr2UDd0vnR5Am8oqv9bSVnzw=="
                self.dataProvider.requestData(
                    q:.init(id: self.tag,
                            type: .disconnectOksusuUser(test)))
            } else {
                self.setupOksusuCancel()
            }
        }
    }
    private func deletedOksusu(res:ApiResultResponds){
        guard let data = res.data as? StbListItem  else {
            self.appSceneObserver.event = .toast( String.alert.apiErrorServer )
            self.setupOksusuCancel()
            return
        }
        if willOksusu == true {
            let test = "5qDs1ydeLCB2M08k/JpZOMHa3rOdTUe3ZXJ7PawML/revc/e31zPHWYLJlgwxEOr2UDd0vnR5Am8oqv9bSVnzw=="
            self.dataProvider.requestData(
                q:.init(id: self.tag,
                        type: .connectOksusuUser(test)))
        } else {
            self.deletedOksusuCompleted()
        }
        //self.sendLog(category: String.pageText.setupPossessionSet, config: false)
    }
    
    private func deletedOksusuCompleted(){
        self.willOksusu = nil
        self.currentSelectedUser = nil
        self.setup.oksusu = ""
        self.setup.oksusuPurchase = ""
        self.setOksusuPurchaseAble()
        self.appSceneObserver.event = .toast(
            String.oksusu.disconnectCompleted
        )
        self.pagePresenter.closePopup(pageId: .oksusuUser)
    }
    
    
    private func setupOksusuPurchase(){
        self.willOksusuPurchase = true
        let test = "5qDs1ydeLCB2M08k/JpZOMHa3rOdTUe3ZXJ7PawML/revc/e31zPHWYLJlgwxEOr2UDd0vnR5Am8oqv9bSVnzw=="
        self.dataProvider.requestData(q: .init(id: self.tag, type: .addOksusuUserToBtvPurchase(test)))
    }
    private func setupOksusuPurchaseCancel(){
        self.willOksusuPurchase = nil
        self.isOksusuPurchase = (self.setup.oksusuPurchase.isEmpty == false)
    }
    private func addedOksusuPurchase(res:ApiResultResponds){
        guard let data = res.data as? StbListItem  else {
            self.appSceneObserver.event = .toast( String.alert.apiErrorServer )
            self.setupOksusuCancel()
            return
        }
        self.willOksusuPurchase = nil
        self.setup.oksusuPurchase = UUID().uuidString
        self.appSceneObserver.event = .toast(String.oksusu.setupPurchaseCompleted)
        //self.sendLog(category: String.pageText.setupPossessionSet, config: false)
    }
    
    private func sendLog(category:String, config:Bool) {
        let actionBody = MenuNaviActionBodyItem( config: config ? "on" : "off", category: category)
        self.naviLogManager.actionLog(.clickCardRegister, actionBody: actionBody)
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
