//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupPlay: PageView {
    @Binding var isAutoPlay:Bool
    @Binding var isNextPlay:Bool

    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text(String.pageText.setupPlay).modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: self.$isAutoPlay,
                    title: String.pageText.setupPlayAuto ,
                    subTitle: String.pageText.setupPlayAutoText
                )
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                SetupItem (
                    isOn: self.$isNextPlay,
                    title: String.pageText.setupPlayNext ,
                    subTitle: String.pageText.setupPlayNextText
                )

            }
            .background(Color.app.blueLight)
        }
    }//body
    
}

#if DEBUG
struct SetupPlay_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupPlay(isAutoPlay: .constant(false),
                      isNextPlay: .constant(false))
                .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
