//
//  PopupPairing.swift
//  BtvPlusNew
//
//  Created by KimJeongCheol on 2020/12/28.
//
import Foundation
import SwiftUI

struct PagePairingAppleTv: PageView {
    @EnvironmentObject var repository:Repository
    @EnvironmentObject var pagePresenter:PagePresenter
    @EnvironmentObject var appSceneObserver:AppSceneObserver
    @EnvironmentObject var naviLogManager:NaviLogManager
    @ObservedObject var pageObservable:PageObservable = PageObservable()
   
    @State var isAgree1:Bool = true
    @State var isAgree2:Bool = true
    @State var isAgree3:Bool = true
    var body: some View {
        ZStack(alignment: .center) {
            Button(action: {
                self.pagePresenter.closePopup(self.pageObject?.id)
            }) {
               Spacer().modifier(MatchParent())
                   .background(Color.transparent.black70)
            }
            VStack(spacing:0){
                Image(Asset.image.pairindPopup)
                    .renderingMode(.original)
                    .resizable()
                    .frame(
                        height: SystemEnvironment.isTablet ? 125 : 104)
                Text(String.pageText.pairingAppletvText1)
                    .modifier(BoldTextStyle(size: Font.size.regular, color: Color.app.white))
                    .padding(.top, Dimen.margin.microExtra)
                
                Text(String.pageText.pairingAppletvText2)
                    .modifier(MediumTextStyle(size: Font.size.lightExtra, color: Color.app.white))
                    .multilineTextAlignment(.center)
                    .padding(.top, Dimen.margin.regular)
                Text(String.alert.notAvailableAppleTvTip)
                    .modifier(MediumTextStyle(size: Font.size.tiny, color: Color.brand.primary))
                    .multilineTextAlignment(.center)
                    .padding(.top, Dimen.margin.thin)
                
                Spacer().modifier(LineHorizontal(height: Dimen.line.light, margin: Dimen.margin.regular))
                    .padding(.top, Dimen.margin.thin)
                
                AgreementBody(
                    pageObservable : self.pageObservable,
                    isAgree1: self.$isAgree1,
                    isAgree2:  self.$isAgree2,
                    isAgree3:  self.$isAgree3
                )
                .padding(.top, Dimen.margin.thin)
                .padding(.horizontal, Dimen.margin.regular)
                
                HStack(spacing:0){
                    FillButton(
                        text: String.app.cancel,
                        isSelected: true ,
                        textModifier: TextModifier(
                            family: Font.family.bold,
                            size: Font.size.lightExtra,
                            color: Color.app.white,
                            activeColor: Color.app.white
                        ),
                        size: Dimen.button.regular,
                        bgColor:Color.brand.secondary
                    ){_ in
                        self.sendLog(category: String.app.cancel)
                        self.pagePresenter.closePopup(self.pageObject?.id)
                    }
                    FillButton(
                        text: String.app.confirm,
                        isSelected: (self.isAgree1 && self.isAgree2),
                        textModifier: TextModifier(
                            family: Font.family.bold,
                            size: Font.size.lightExtra,
                            color: Color.app.white,
                            activeColor: Color.app.white
                        ),
                        size: Dimen.button.regular,
                        margin: 0,
                        bgColor:Color.brand.primary
                    ){_ in
                        self.sendLog(category: String.app.confirm)
                        if !self.isAgree1 {
                            self.appSceneObserver.event = .toast(String.alert.needAgreeTermsOfService)
                            return
                        }
                        if !self.isAgree2 {
                            self.appSceneObserver.event = .toast(String.alert.needAgreePrivacy)
                            return
                        }
                        self.pagePresenter.closePopup(self.pageObject?.id)
                        
                    }
                }
                .padding(.top, Dimen.margin.regular)
                
            }
            .frame(width: Dimen.popup.regular)
            .background(Color.brand.bg)
        }
        .modifier(MatchParent())
        .onAppear(){
           
        }
        
    }//body
    
    private func sendLog(category:String? = nil) {
        let actionBody = MenuNaviActionBodyItem( category: category)
        self.naviLogManager.actionLog(.clickConfirmButton, actionBody: actionBody)
    }
}

#if DEBUG
struct PagePairingAppleTv_Previews: PreviewProvider {
    static var previews: some View {
        Form{
            PagePairingAppleTv().contentBody
                .environmentObject(Repository())
                .environmentObject(PagePresenter())
                .environmentObject(PageSceneObserver())
                .environmentObject(AppSceneObserver())
                .frame(width: 420, height: 640, alignment: .center)
        }
    }
}
#endif
