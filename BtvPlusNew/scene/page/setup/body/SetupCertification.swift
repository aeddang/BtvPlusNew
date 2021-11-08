//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupCertification: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var pairing:Pairing
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var dataProvider:DataProvider
    @EnvironmentObject var naviLogManager:NaviLogManager
    var isInitate:Bool = false
    var isPairing:Bool = false
    var pairingStbType:PairingDeviceType = .btv
    @Binding var isPurchaseAuth:Bool
    @Binding var isSetWatchLv:Bool
    @Binding var isKidsExitAuth:Bool
    @Binding var watchLvs:[String]?
    @Binding var selectedWatchLv:String?
    
    @State var willPurchaseAuth:Bool? = nil
    @State var willSelectedWatchLv:String? = nil
    @State var willKidsExitAuth:Bool? = nil
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text(String.pageText.setupCertification).modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: self.$isPurchaseAuth,
                    title: String.pageText.setupCertificationPurchase,
                    subTitle: String.pageText.setupCertificationPurchaseText
                )
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                SetupItem (
                    isOn: self.$isSetWatchLv,
                    title: String.pageText.setupCertificationAge,
                    subTitle: String.pageText.setupCertificationAgeText,
                    radios: self.isSetWatchLv ? self.watchLvs : nil,
                    selectedRadio: self.isSetWatchLv ? self.selectedWatchLv : nil,
                    selected: { select in
                        self.setupWatchLv(select: select)
                    }
                )
                if self.pairingStbType == .btv {
                    Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                    SetupItem (
                        isOn: self.$isKidsExitAuth,
                        title: String.pageText.setupCertificationKidsExit,
                        subTitle: String.pageText.setupCertificationKidsExitText
                    )
                }
            }
            .background(Color.app.blueLight)
        }
        .onReceive( [self.isSetWatchLv].publisher ) { value in
            if !self.isInitate { return }
            if self.willSelectedWatchLv != nil { return }
            if self.isPairing && (SystemEnvironment.watchLv > 0) == self.isSetWatchLv { return }
            if !self.isPairing && !self.isSetWatchLv { return }
            if self.isPairing == false {
                self.appSceneObserver.alert = .needPairing()
                self.isSetWatchLv = false
                return
            }
            if !SystemEnvironment.isAdultAuth && value == true {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.adultCertification)
                )
                self.isSetWatchLv = false
                return
            }
            self.setupWatchLv(select: value ? Setup.WatchLv.lv4.getName() : nil)
            self.isSetWatchLv = !value
        }
        .onReceive( [self.isPurchaseAuth].publisher ) { value in
            if !self.isInitate { return }
            if self.willPurchaseAuth != nil { return }
            if self.isPairing && self.setup.isPurchaseAuth == self.isPurchaseAuth { return }
            if !self.isPairing && !self.isPurchaseAuth { return }
            
            if self.isPairing == false && value == true {
                self.appSceneObserver.alert = .needPairing()
                self.isPurchaseAuth = false
                return
            }
            self.setupPurchaseAuth(value)
            self.isPurchaseAuth = !value
            
        }
        .onReceive( [self.isKidsExitAuth].publisher ) { value in
            if !self.isInitate { return }
            if self.willPurchaseAuth != nil { return }
            if self.isPairing && self.setup.isKidsExitAuth == self.isKidsExitAuth{ return }
            if !self.isPairing && !self.isKidsExitAuth { return }
            
            if self.isPairing == false && value == true {
                self.appSceneObserver.alert = .needPairing()
                self.isKidsExitAuth = false
                return
            }
            if !SystemEnvironment.isAdultAuth && value == true {
                self.pagePresenter.openPopup(
                    PageProvider.getPageObject(.adultCertification)
                )
                self.isKidsExitAuth = false
                return
            }
            self.setupKidsExitAuth(value)
            self.isKidsExitAuth = !value
            
        }
        .onReceive(self.pagePresenter.$event){ evt in
            guard let evt = evt else {return}
            
            switch evt.type {
            case .completed :
                guard let type = evt.data as? ScsNetwork.ConfirmType  else { return }
                switch type {
                case .adult:
                    if let willSelectedWatchLv = self.willSelectedWatchLv {
                        self.onSetupWatchLv(select: willSelectedWatchLv)
                    }
                    if let willKidsExitAuth = self.willKidsExitAuth {
                        self.onKidsExitAuth(willKidsExitAuth)
                    }
                case .purchase:
                    guard let willPurchaseAuth = self.willPurchaseAuth  else { return }
                    self.onPurchaseAuth(willPurchaseAuth)
                }
            case .cancel :
                guard let type = evt.data as? ScsNetwork.ConfirmType  else { return }
                switch type {
                case .adult: self.willSelectedWatchLv = nil
                case .purchase: self.willPurchaseAuth = nil
                }
                
            default : break
            }
        }
    }//body
    
    private func setupWatchLv(select:String?){
        if self.isPairing == false {
            self.appSceneObserver.alert = .needPairing()
            return
        }
        self.willSelectedWatchLv = select ?? ""
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.confirmNumber)
                .addParam(key: .type, value: ScsNetwork.ConfirmType.adult)
        )
    }
   
    private func onSetupWatchLv(select:String){
        if self.isPairing == false { return }
        if select.isEmpty {
            self.isSetWatchLv = false
            self.repository.updateWatchLv(nil)
            self.selectedWatchLv = nil
            self.willSelectedWatchLv = nil
            self.sendLog(category: String.pageText.setupCertificationAge, config: false)
            return
        }
        guard let find = self.watchLvs?.firstIndex(where: {$0 == select}) else {return}
        self.isSetWatchLv = true
        self.repository.updateWatchLv(Setup.WatchLv.allCases[find])
        self.selectedWatchLv = select
        self.willSelectedWatchLv = nil
        self.sendLog(category: String.pageText.setupCertificationAge, config: true)
    }
    
    private func setupKidsExitAuth(_ select:Bool){
        if self.isPairing == false { return }
        self.willKidsExitAuth = select
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.confirmNumber)
                .addParam(key: .type, value: ScsNetwork.ConfirmType.adult)
                .addParam(key: .title, value: String.pageText.setupCertificationKidsExit)
        )
    }
    private func setupPurchaseAuth(_ select:Bool){
        if self.isPairing == false { return }
        self.willPurchaseAuth = select
        self.pagePresenter.openPopup(
            PageProvider.getPageObject(.confirmNumber)
                .addParam(key: .type, value: ScsNetwork.ConfirmType.purchase)
        )
    }
    
    
    private func onKidsExitAuth(_ select:Bool){
        self.setup.isKidsExitAuth = select
        self.isKidsExitAuth = select
        self.willKidsExitAuth = nil
        self.appSceneObserver.alert = .alert(
            select ? String.alert.kidsExitCompleted : String.alert.kidsExitCanceled,
            select ? String.alert.kidsExitCompletedInfo : String.alert.kidsExitCanceledInfo)
        
        self.sendLog(category: String.pageText.setupCertificationKidsExit, config: select)
    }
    private func onPurchaseAuth(_ select:Bool){
        self.setup.isPurchaseAuth = select
        self.isPurchaseAuth = select
        self.willPurchaseAuth = nil
        self.appSceneObserver.alert = .alert(
            select ? String.alert.purchaseAuthCompleted : String.alert.purchaseAuthCanceled,
            select ? String.alert.purchaseAuthCompletedInfo : String.alert.purchaseAuthCanceledInfo)
        self.sendLog(category: String.pageText.setupCertificationPurchase, config: select)
    }
    
    private func sendLog(category:String, config:Bool) {
        let actionBody = MenuNaviActionBodyItem( config: config ? "on" : "off", category: category)
        self.naviLogManager.actionLog(.clickConfigSelection, actionBody: actionBody)
    }
}

#if DEBUG
struct SetupCertification_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupCertification(isPurchaseAuth: .constant(false),
                               isSetWatchLv: .constant(false),
                               isKidsExitAuth: .constant(false),
                               watchLvs:.constant(Setup.WatchLv.allCases.map{$0.getName()}),
                               selectedWatchLv: .constant(nil))
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
