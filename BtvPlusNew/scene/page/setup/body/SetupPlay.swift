//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupPlay: PageView {
    @EnvironmentObject var setup:Setup
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    
    var isInitate:Bool = false
    var isPairing:Bool = false
  
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
        .onReceive( [self.isAutoPlay].publisher ) { value in
            if !self.isInitate { return }
            if self.setup.autoPlay == self.isAutoPlay { return }
            self.setup.autoPlay = self.isAutoPlay
            self.appSceneObserver.event = .toast(
                self.isAutoPlay ? String.alert.autoPlayOn : String.alert.autoPlayOff
            )
        }.onReceive( [self.isNextPlay].publisher ) { value in
            if !self.isInitate { return }
            if self.setup.nextPlay == self.isNextPlay { return }
            self.setup.nextPlay = self.isNextPlay
            self.appSceneObserver.event = .toast(
                self.isNextPlay ? String.alert.nextPlayOn : String.alert.nextPlayOff
            )
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
