//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupApp: PageView {
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
    }//body
    
}

#if DEBUG
struct SetupApp_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupApp(isDataAlram: .constant(false),
                     isAutoRemocon: .constant(false),
                     isRemoconVibration: .constant(false))
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
