//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupApp: PageView {
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    var isInitate:Bool = false
    var isPairing:Bool = false
    var pairingType:PairingDeviceType = .btv
    @Binding var isDataAlram:Bool
    @Binding var isAutoRemocon:Bool
    @Binding var isRemoconVibration:Bool
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text(String.pageText.setupApp).modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: self.$isDataAlram,
                    title: String.pageText.setupAppDataAlram ,
                    subTitle: String.pageText.setupAppDataAlramText
                )
                
                if self.pairingType == .btv {
                    Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                    SetupItem (
                        isOn: self.$isAutoRemocon,
                        title: String.pageText.setupAppAutoRemocon ,
                        subTitle: String.pageText.setupAppAutoRemoconText
                    )
                    //if !SystemEnvironment.isTablet {
                    Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                    SetupItem (
                        isOn: self.$isRemoconVibration,
                        title: String.pageText.setupAppRemoconVibration ,
                        subTitle: String.pageText.setupAppRemoconVibrationText
                    )
                    //}
                }
            }
            .background(Color.app.blueLight)
        }
        .onReceive( [self.isDataAlram].publisher ) { value in
            if !self.isInitate { return }
            if self.setup.dataAlram == self.isDataAlram { return }
            
            self.setup.dataAlram = self.isDataAlram
            self.appSceneObserver.event = .toast(
                self.isDataAlram ? String.alert.dataAlramOn : String.alert.dataAlramOff
            )
            self.sendLog(category: String.pageText.setupAppDataAlram , config: self.isDataAlram)
            
        }
        .onReceive( [self.isAutoRemocon].publisher ) { value in
            if !self.isInitate { return }
            if self.setup.autoRemocon == self.isAutoRemocon { return }
            if self.isPairing == false && value == true {
                self.appSceneObserver.alert = .needPairing()
                self.isAutoRemocon = false
                return
            }
            self.setup.autoRemocon = self.isAutoRemocon
            self.appSceneObserver.event = .toast(
                self.isAutoRemocon ? String.alert.autoRemoconOn : String.alert.autoRemoconOff
            )
            self.sendLog(category: String.pageText.setupAppAutoRemocon  , config: self.isAutoRemocon)
            
        }
        .onReceive( [self.isRemoconVibration].publisher ) { value in
            if !self.isInitate { return }
            if self.setup.remoconVibration == self.isRemoconVibration { return }
            if SystemEnvironment.isTablet && value == true {
                self.setup.remoconVibration = false
                self.isRemoconVibration = false
                self.appSceneObserver.event = .toast(String.alert.guideNotSupportedVibrate)
                return
            }
            if self.isPairing == false && value == true {
                self.appSceneObserver.alert = .needPairing()
                self.isRemoconVibration = false
                return
            }
            self.setup.remoconVibration = self.isRemoconVibration
            self.appSceneObserver.event = .toast(
                self.isRemoconVibration ? String.alert.remoconVibrationOn : String.alert.remoconVibrationOff
            )
            self.sendLog(category: String.pageText.setupAppRemoconVibration  , config: self.isRemoconVibration)
            
        }
    }//body
    
    private func sendLog(category:String, config:Bool) {
        let actionBody = MenuNaviActionBodyItem( config: config ? "on" : "off", category: category)
        self.naviLogManager.actionLog(.clickCardRegister, actionBody: actionBody)
    }
    
    
}

#if DEBUG
struct SetupApp_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupApp(isDataAlram: .constant(false),
                     isAutoRemocon: .constant(false),
                     isRemoconVibration: .constant(false))
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .environmentObject(Repository())
                .environmentObject(DataProvider())
                .environmentObject(Pairing())
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
