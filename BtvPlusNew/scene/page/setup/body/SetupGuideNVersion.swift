//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI
struct SetupGuideNVersion: PageView {
    @EnvironmentObject var pagePresenter:PagePresenter
    var body: some View {
        VStack(alignment:.leading , spacing:Dimen.margin.thinExtra) {
            Text(String.pageText.setupGuideNVersion).modifier(ContentTitle())
            VStack(alignment:.leading , spacing:0) {
                SetupItem (
                    isOn: .constant(true),
                    title: String.pageText.setupGuide,
                    more:{
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
                        
                    }
                )
                Spacer().modifier(LineHorizontal(margin:Dimen.margin.thin))
                SetupItem (
                    isOn: .constant(true),
                    title: String.pageText.setupOpensource,
                    more:{
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
    
}

#if DEBUG
struct SetupGuideNVersion_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            SetupGuideNVersion()
            .frame(width: 375, height: 640, alignment: .center)
        }
    }
}
#endif
