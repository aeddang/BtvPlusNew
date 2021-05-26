//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupCertification: PageView {
    @Binding var isPurchaseAuth:Bool
    @Binding var isSetWatchLv:Bool

    var watchLvs:[String]? = nil
    var selectedWatchLv:String? = nil
    var selected: ((String) -> Void)
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
                        self.selected(select)
                       
                    }
                )
            }
            .background(Color.app.blueLight)
        }
    }//body
    
}

#if DEBUG
struct SetupCertification_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupCertification(isPurchaseAuth: .constant(false),
                               isSetWatchLv: .constant(false)){ select in
                
            }
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
