//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupTest: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var repository:Repository
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text("Laboratory").modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: .constant(true),
                    title: "실서버",
                    more:{
                        //self.isInitate = false
                        self.repository.reset(isReleaseMode: true, isEvaluation: false)
                    }
                )
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                SetupItem (
                    isOn: .constant(true),
                    title: "스테이지",
                    more:{
                        //self.isInitate = false
                        self.repository.reset(isReleaseMode: false, isEvaluation: false)
                    }
                )
            }
            .background(Color.app.blueLight)
        }
    }//body
    
}

#if DEBUG
struct SetupTest_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupTest()
            .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
