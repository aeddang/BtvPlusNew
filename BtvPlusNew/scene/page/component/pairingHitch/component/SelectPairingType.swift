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
    var body: some View {
        VStack(spacing: 0){
            Image( Asset.image.pairingHitchText02 )
                .renderingMode(.original).resizable()
                .scaledToFit()
                .modifier(MatchHorizontal(height: SystemEnvironment.isTablet ? 33 : 27))
                .padding(.top, Dimen.margin.medium)
            Text( String.pairingHitch.select)
                .modifier( MediumTextStyle(
                        size: Font.size.lightExtra,
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
                        size: Font.size.thinExtra,
                        color: Color.app.greyDeep)
                )
                .multilineTextAlignment(.center)
                .padding(.top, Dimen.margin.light)
        }
        .padding(.bottom, self.sceneObserver.safeAreaBottom + Dimen.margin.thin)
        
    }//body
    
    
    private func requestPairing(type:HitchPairingItem.PairingType){
        switch type {
        case .wifi:
            if self.networkObserver.status != .wifi {
                self.appSceneObserver.alert = .connectWifi{ retry in
                    if retry { self.requestPairing(type: .wifi) }
                }
                return
            }
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.pairingSetupUser)
                    .addParam(key: PageParam.type, value: PairingRequest.wifi)
            )
        case .btv:
            self.pagePresenter.openPopup(
                PageProvider.getPageObject(.pairingSetupUser)
                    .addParam(key: PageParam.type, value: PairingRequest.btv)
            )
        case .user:
           self.pagePresenter.openPopup(
                PageProvider.getPageObject(.pairingSetupUser)
                    .addParam(key: PageParam.type, value: PairingRequest.user(nil))
            )
            
        }
        
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

