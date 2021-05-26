//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupPossession: PageView {
    @Binding var isPossession:Bool
    
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text(String.pageText.setupPossession).modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: self.$isPossession,
                    title: String.pageText.setupPossessionSet,
                    subTitle: String.pageText.setupPossessionSetText
                )
               
            }
            .background(Color.app.blueLight)
        }
    }//body
    
}

#if DEBUG
struct SetupPossession_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupPossession(isPossession: .constant(false))                               
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
