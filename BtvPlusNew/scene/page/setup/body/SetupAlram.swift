//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupAlram: PageView {
    @Binding var isPush:Bool
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text(String.pageText.setupAlram).modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: self.$isPush,
                    title: String.pageText.setupAlramMarketing ,
                    subTitle: String.pageText.setupAlramMarketingText,
                    tips: [
                        String.pageText.setupAlramMarketingTip1,
                        String.pageText.setupAlramMarketingTip2,
                        String.pageText.setupAlramMarketingTip3,
                        String.pageText.setupAlramMarketingTip4,
                        String.pageText.setupAlramMarketingTip5
                    ]
                )
            }
            .background(Color.app.blueLight)
        }
    }//body
    
}

#if DEBUG
struct SetupAlram_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupAlram(isPush: .constant(false))
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
