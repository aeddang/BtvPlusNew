//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupQA: PageView {
   
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var repository:Repository
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text("QA").modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: .constant(true),
                    title: "실서버",
                    more:{
                        self.repository.reset(isReleaseMode: true, isEvaluation: false)
                    }
                )
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                SetupItem (
                    isOn: .constant(true),
                    title: "스테이지",
                    more:{
                        self.repository.reset(isReleaseMode: false, isEvaluation: false)
                    }
                )
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                SetupItem (
                    isOn: .constant(true),
                    title: "Log 수집",
                    more:{
                        self.appSceneObserver.useLogCollector.toggle()
                    }
                )
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                SetupItem (
                    isOn: .constant(true),
                    title: "Reset Auth",
                    subTitle: "성인인증 본인인증 리셋",
                    more:{
                        self.repository.resetAuth()
                        self.appSceneObserver.event = .toast("리셋 되었습니다")
                    }
                )
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                SetupItem (
                    isOn: .constant(true),
                    title: "Device ID",
                    subTitle: SystemEnvironment.deviceId,
                    more:{
                        UIPasteboard.general.string = SystemEnvironment.deviceId
                        self.appSceneObserver.event = .toast("복사되었습니다")
                    }
                )
            }
        }
    }//body
    
}

#if DEBUG
struct SetupQA_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupQA()
            .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
