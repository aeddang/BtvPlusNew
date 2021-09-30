//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct AgreementBody: PageComponent {
    
    @EnvironmentObject var pagePresenter:PagePresenter

    @ObservedObject var pageObservable:PageObservable = PageObservable()
    @Binding var isAgree1:Bool
    @Binding var isAgree2:Bool
    @Binding var isAgree3:Bool
    var body: some View {
        VStack(spacing:Dimen.margin.thin){
            CheckBox(
                style:.small,
                isChecked: self.isAgree1,
                isCheckAble: false,
                text:String.pairingHitch.userAgreement1.replace("\n", with: ""),
                alignment: .top,
                more:{
                    self.pagePresenter.openPopup(
                        PageProvider
                            .getPageObject(.webview)
                            .addParam(key: .data, value: BtvWebView.serviceTerms)
                            .addParam(key: .title , value: String.pageTitle.serviceTerms)
                    )
                }
            )
            CheckBox(
                style:.small,
                isChecked: self.isAgree2,
                isCheckAble: false,
                text:String.pairingHitch.userAgreement2.replace("\n", with: ""),
                alignment: .top,
                more:{
                    self.pagePresenter.openPopup(
                        PageProvider
                            .getPageObject(.webview)
                            .addParam(key: .data, value: BtvWebView.privacyAgreement)
                            .addParam(key: .title , value: String.pageTitle.privacyAndAgree)
                    )
                    /*
                    self.pagePresenter.openPopup(
                        PageProvider
                            .getPageObject(.privacyAndAgree)
                    )*/
                }
            )
            
            CheckBox(
                style:.small,
                isChecked: self.isAgree3,
                text:String.pairingHitch.userAgreement3.replace("\n", with: ""),
                alignment: .top,
                action:{ ck in
                    self.isAgree3 = ck
                }
            )
        }
        
    }//body
}

