//
//  ConnectButton.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//

import Foundation
import SwiftUI


struct SelectPairingType: View {
    @EnvironmentObject var sceneObserver:PageSceneObserver
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var networkObserver:NetworkObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    var body: some View {
        VStack(spacing: 0){
            Image( Asset.image.pairingHitchText02 )
                .renderingMode(.original).resizable()
                .scaledToFit()
                .modifier(MatchHorizontal(height: SystemEnvironment.isTablet ? 33 : 27))
                .padding(.top, SystemEnvironment.isTablet ?  Dimen.margin.mediumExtra : Dimen.margin.medium)
            Text( String.pairingHitch.select)
                .kerning(Font.kern.thin)
                .modifier( MediumTextStyle(
                        size: SystemEnvironment.isTablet ? Font.size.thinExtra : Font.size.lightExtra,
                        color: Color.app.blackExtra)
                )
                .multilineTextAlignment(.center)
                .padding(.top, Dimen.margin.light)
           
            HStack( spacing: Dimen.margin.tiny){
                HitchPairingItem(type: .wifi, isSelected: false)
                    .onTapGesture {
                        self.requestPairing(type: .wifi)
                    }
                HitchPairingItem(type: .btv, isSelected: false)
                    .onTapGesture {
                        self.requestPairing(type: .btv)
                    }
                HitchPairingItem(type: .user, isSelected: false)
                    .onTapGesture {
                        self.requestPairing(type: .user)
                    }
                
            }
            .padding(.top, Dimen.margin.regularExtra)
            
            Text( String.pairingHitch.selectAppleTip)
                .modifier( MediumTextStyle(
                        size: SystemEnvironment.isTablet ? Font.size.tinyExtra : Font.size.thinExtra,
                        color: Color.app.greyDeep)
                )
                .multilineTextAlignment(.center)
                .padding(.top, Dimen.margin.thin)
        }
        .padding(.bottom, SystemEnvironment.isTablet
                    ?  Dimen.margin.thin
                    : self.sceneObserver.safeAreaIgnoreKeyboardBottom + Dimen.margin.thin)
        
    }//body
    
    
    private func requestPairing(type:HitchPairingItem.PairingType){
        switch type {
        case .wifi:
            self.sendLog(menuName: "wifi연결")
            if self.networkObserver.status != .wifi {
                self.appSceneObserver.alert = .connectWifi
                return
            }
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.pairingSetupUser)
                    .addParam(key: PageParam.type, value: PairingRequest.wifi)
                    .addParam(key: PageParam.subType, value: "mob-home-popup")
            )
        case .btv:
            self.sendLog(menuName: "인증번호연결")
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.pairingSetupUser)
                    .addParam(key: PageParam.type, value: PairingRequest.btv)
                    .addParam(key: PageParam.subType, value: "mob-home-popup")
            )
        case .user:
            self.sendLog(menuName: "가입자인증")
           self.pagePresenter.openPopup(
                PageProvider.getPageObject(.pairingSetupUser)
                    .addParam(key: PageParam.type, value: PairingRequest.user(nil))
                    .addParam(key: PageParam.subType, value: "mob-home-popup")
            )
            
        }
        
    }
    
    private func sendLog(menuName:String? = nil) {
        var actionBody = MenuNaviActionBodyItem()
        actionBody.config = "case4"
        actionBody.menu_name = menuName
        self.naviLogManager.actionLog(.clickConfirmButton, pageId: .autoPairing, actionBody: actionBody)
        
    }
}


#if DEBUG
struct SelectPairingType_Previews: PreviewProvider {
    
    static var previews: some View {
        Form{
            SelectPairingType(
               
            )
            .environmentObject(PagePresenter())
            .environmentObject(PageSceneObserver())
            .environmentObject(AppSceneObserver())
            .environmentObject(NetworkObserver())
            .frame( width: 300)
        }
    }
}
#endif

