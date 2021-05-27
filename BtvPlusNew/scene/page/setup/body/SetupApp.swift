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
    
    var isInitate:Bool = false
    var isPairing:Bool = false
    
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
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                SetupItem (
                    isOn: self.$isAutoRemocon,
                    title: String.pageText.setupAppAutoRemocon ,
                    subTitle: String.pageText.setupAppAutoRemoconText
                )
                if !SystemEnvironment.isTablet {
                    Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                    SetupItem (
                        isOn: self.$isRemoconVibration,
                        title: String.pageText.setupAppRemoconVibration ,
                        subTitle: String.pageText.setupAppRemoconVibrationText
                    )
                }
            }
            .background(Color.app.blueLight)
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
            
        }
        .onReceive( [self.isRemoconVibration].publisher ) { value in
            if !self.isInitate { return }
            if self.setup.remoconVibration == self.isRemoconVibration { return }
            if self.isPairing == false && value == true {
                self.appSceneObserver.alert = .needPairing()
                self.isRemoconVibration = false
                return
            }
            self.setup.remoconVibration = self.isRemoconVibration
            self.appSceneObserver.event = .toast(
                self.isRemoconVibration ? String.alert.remoconVibrationOn : String.alert.remoconVibrationOff
            )
            
        }
    }//body
    
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
