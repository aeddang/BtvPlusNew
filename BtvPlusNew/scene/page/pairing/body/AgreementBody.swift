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
                text:String.pairingHitch.userAgreement1,
                more:{
                    self.pagePresenter.openPopup(
                        PageProvider
                            .getPageObject(.webview)
                            .addParam(key: .data, value: BtvWebView.serviceTerms)
                            .addParam(key: .title , value: String.pageTitle.serviceTerms)
                    )
                },
                action:{ ck in
                    self.isAgree1 = ck
                }
            )
            CheckBox(
                style:.small,
                isChecked: self.isAgree2,
                text:String.pairingHitch.userAgreement2,
                more:{
                    self.pagePresenter.openPopup(
                        PageProvider
                            .getPageObject(.privacyAndAgree)
                    )
                },
                action:{ ck in
                    self.isAgree2 = ck
                }
            )
            .onReceive(self.pagePresenter.$event){ evt in
                if evt?.id != "PagePrivacyAndAgree" {return}
                guard let evt = evt else {return}
                switch evt.type {
                case .completed :
                    self.isAgree2 = true
                case .cancel :
                    self.isAgree2 = false
                default : break
                }
            }
            
            CheckBox(
                style:.small,
                isChecked: self.isAgree3,
                text:String.pairingHitch.userAgreement3,
                action:{ ck in
                    self.isAgree3 = ck
                }
            )
        }
        
    }//body
}

