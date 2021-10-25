//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
import Combine
struct SetupGuideNVersion: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    @Binding var isQAMode:Bool
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text(String.pageText.setupGuideNVersion).modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: .constant(true),
                    title: String.pageText.setupGuide,
                    more:{
                        self.sendLog(category: String.pageText.setupGuide)
                        self.pagePresenter.openPopup(
                            PageProvider
                                .getPageObject(.webview)
                                .addParam(key: .data, value: BtvWebView.faq)
                                .addParam(key: .title , value: String.pageText.setupGuide)
                        )
                    }
                )
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                SetupItem (
                    isOn: .constant(true),
                    title: SystemEnvironment.bundleVersion + "(" + SystemEnvironment.buildNumber + ")",
                    statusText: SystemEnvironment.needUpdate ? nil : String.pageText.setupVersionLatest,
                    more:{
                        self.delayQaModeCount()
                    }
                )
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                SetupItem (
                    isOn: .constant(true),
                    title: String.pageText.setupOpensource,
                    more:{
                        self.sendLog(category: String.pageText.setupOpensource)
                        self.pagePresenter.openPopup(
                            PageProvider
                                .getPageObject(.webview)
                                .addParam(key: .data, value: BtvWebView.opensrcLicense)
                                .addParam(key: .title , value: String.pageText.setupOpensource)
                        )
                    }
                )
            }
            .background(Color.app.blueLight)
        }
    }//body
    private func sendLog(category:String) {
        let actionBody = MenuNaviActionBodyItem( config: "", category: category)
        self.naviLogManager.actionLog(.clickCardRegister, actionBody: actionBody)
    }
    
    @State var qaModeCount:Int = 0
    @State var qaModeReset:AnyCancellable?
    func delayQaModeCount(){
        self.qaModeCount += 1
        if self.qaModeCount > 5 {
            self.isQAMode.toggle()
            self.appSceneObserver.event = .toast(self.isQAMode ? "테스트모드 시작" : "테스트모드 종료")
            return
        }
        self.qaModeReset?.cancel()
        self.qaModeReset = Timer.publish(
            every: 2.0, on: .current, in: .common)
            .autoconnect()
            .sink() {_ in
                
                self.clearQaMode()
            }
    }
    func clearQaMode() {
        self.qaModeCount = 0
        self.qaModeReset?.cancel()
        self.qaModeReset = nil
    }
}

#if DEBUG
struct SetupGuideNVersion_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupGuideNVersion(
                isQAMode: .constant(true)
            )
            .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
